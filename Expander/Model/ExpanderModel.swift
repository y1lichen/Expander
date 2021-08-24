//
//  ExpanderModel.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/8.
//


import Foundation
import SwiftUI
import IOKit


extension NSEvent {
	var isDeleteKey: Bool {
		self.keyCode == 51
	}
}


class ExpanderModel {
	var text = ""
	//
	let appdelegate = NSApplication.shared.delegate as! AppDelegate
	lazy var context = appdelegate.persistentContainer.viewContext
	let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SnippetData")
	func fetchSnippetList() -> [Snippets] {
		let managedObject = try! context.fetch(request) as! [SnippetData]
		let snippetList = managedObject.map {
			Snippets.init(data: $0)
		}
		return snippetList
	}
	//
	
	var defaultSnippetList: [Snippets] {
		get {
			var dateformat: Int {
				get {
					return UserDefaults.standard.integer(forKey: "dateformat")
				}
			}
			return [
				Snippets(trigger: "\\date", content: {
					let dateFormatter : DateFormatter = DateFormatter()
					if dateformat == 0 {
						dateFormatter.dateFormat = "yyyy/MM/dd"
					} else {
						dateFormatter.dateFormat = "MM/dd/yyyy"
					}
					let date = Date()
					let dateString = dateFormatter.string(from: date)
					return dateString
				}()),
				Snippets(trigger: "timestp", content: {
					let dateFormatter : DateFormatter = DateFormatter()
					if dateformat == 0 {
						dateFormatter.dateFormat = "yyyy-dd-MM HH:mm:ss"
					} else {
						dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
					}
					let date = Date()
					let timeString = dateFormatter.string(from: date)
					return timeString
				}())
			]
		}
	}
	//
	lazy var snippetList: [Snippets] = fetchSnippetList()
	// reload core data
	@objc func managedObjectContextWillSave() {
		self.snippetList = fetchSnippetList()
	}
	//
	init() {
		NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSNotification.Name.NSManagedObjectContextWillSave, object: self.context)
		// MARK: - MAIN
		NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) in
			
			if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 14 {
				self.appdelegate.toggleExpander()
				return
			}
			if self.appdelegate.isOn {
				guard let character = event.characters else { return }
				// if character is nil, the following won't be execute
				let keycode = event.keyCode
				// print(character, keycode)
				if keycode > 95 {
					self.text = ""
				} else if event.isDeleteKey && self.text != "" {
					self.text.removeLast()
				} else {
					self.text += character
				}
				self.checkMatch()
			}
		}
		// global event
		NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .directTouch]) { _ in
			self.text = ""
		}
		// in-app event
		NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .directTouch]) { event in
			self.text = ""
			return event
		}
	}
	
	func checkMatch() {
		// default
		if let match = defaultSnippetList.first(where: {
			$0.isMatch(self.text)
		}) {
			inputSnippet(match)
			return
		}
		// user's snippets
		if let match = snippetList.first(where: {
			$0.isMatch(self.text)
		}) {
			inputSnippet(match)
		}
	}

	func inputSnippet(_ snippet: Snippets) {
		// MARK: - delete
		for _ in snippet.trigger {
			pressDeleteKey()
		}
		// MARK: - paste
		pasteSnippet(snippet: snippet)
	}
	
	// simulating keypress
	func pressDeleteKey() {
		let eventSource = CGEventSource(stateID: .combinedSessionState)
		let keydownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x33, keyDown: true)
		let keyupEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x33, keyDown: false)
		keydownEvent?.post(tap: .cghidEventTap)
		keyupEvent?.post(tap: .cghidEventTap)
	}
	func pasteSnippet(snippet: Snippets) {
		// MARK: - save original clipboard
		let oldClipboard = NSPasteboard.general.string(forType: .string)!
		// MARK: - register to clipboard
		NSPasteboard.general.declareTypes([.string], owner: nil)
		NSPasteboard.general.clearContents()
		NSPasteboard.general.setString(snippet.content, forType: .string)
		// MARK: - paste
		let eventSource = CGEventSource(stateID: .combinedSessionState)
		// cmd+v down
		let keydownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x09, keyDown: true)
		keydownEvent!.flags = CGEventFlags.maskCommand
		// cmd+v up
		let keyupEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x09, keyDown: false)
		let pasteSerialQueue = DispatchQueue(label: "pastesnippet.serial.queue")
		pasteSerialQueue.async {
			keydownEvent?.post(tap: CGEventTapLocation.cghidEventTap)
		}
		pasteSerialQueue.async {
			keyupEvent?.post(tap: CGEventTapLocation.cghidEventTap)
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			NSPasteboard.general.clearContents()
			NSPasteboard.general.setString(oldClipboard, forType: .string)
			self.text = ""
		}
	}
}

/*
*/
