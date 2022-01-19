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
	let emojiList: [Snippets] = Snippets.emoji
	let passiveEmojiList: [Snippets] = Snippets.passiveEmoji
	//
	var isPassive: Bool!
	var expandKey: String!
	// IP data
	@ObservedObject var ipdata = IPAdress()
	//
	var ipSnippetsList: [Snippets] {
		get {
			if self.isPassive {
				let list: [Snippets] = [
					Snippets(trigger: "ip", content: ipdata.externalIP),
					Snippets(trigger: "lip", content: ipdata.internalIP)
				]
				return list
			} else {
				let list: [Snippets] = [
					Snippets(trigger: "\\ip", content: ipdata.externalIP),
					Snippets(trigger: "\\lip", content: ipdata.internalIP)
				]
				return list
			}
		}
	}
	//
	var defaultSnippetList: [Snippets] {
		get {
			let dateformat: Int = UserDefaults.standard.integer(forKey: "dateformat")
			return [
				Snippets(trigger: {
					if self.isPassive {
						return "date"
					} else {
						return "\\date"
					}
				}(), content: {
					let dateFormatter: DateFormatter = DateFormatter()
					if dateformat == 0 {
						dateFormatter.dateFormat = "yyyy/MM/dd"
					} else {
						dateFormatter.dateFormat = "MM/dd/yyyy"
					}
					let date = Date()
					let dateString = dateFormatter.string(from: date)
					return dateString
				}()),
				Snippets(trigger: {
					if self.isPassive {
						return "timestp"
					} else {
						return "\\timestp"
					}
				}(), content: {
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
	// TODO: - finish this function
	func toggleLongSnippetView() {
	}
	// reload core data
	@objc func managedObjectContextWillSave() {
		self.snippetList = fetchSnippetList()
	}
	//
	@objc func passivemodeDidChanged() {
		self.isPassive = UserDefaults.standard.bool(forKey: "passiveMode")
	}

	@objc func passivekeyDidChanged() {
		self.expandKey = UserDefaults.standard.string(forKey: "passiveExpandKey")
	}
	//
	@objc func reloadIPdata() {
		self.ipdata.updateIP()
	}
	func passiveModeHandler() {
		NotificationCenter.default.addObserver(self, selector: #selector(passivemodeDidChanged), name: NSNotification.Name("passiveModeChanged"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(passivekeyDidChanged), name: NSNotification.Name("passiveKeyChanged"), object: nil)
	}
	//
	init() {
		self.passivemodeDidChanged()
		self.passivekeyDidChanged()
		self.passiveModeHandler()
		NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSNotification.Name.NSManagedObjectContextWillSave, object: self.context)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadIPdata), name: NSNotification.Name(rawValue: "loadipdata"), object: nil)
		// MARK: - MAIN
		NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) in
			if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 14 {
				self.appdelegate.toggleExpander()
				return
			} else if ((event.modifierFlags.contains([.command, .shift]) && event.keyCode == 32)) {
				self.toggleLongSnippetView()
			}
			if self.appdelegate.isOn {
				guard let character = event.characters else { return }
				// if character is nil, the following won't be execute
				let keycode = event.keyCode
				// print(character, keycode)
				if keycode > 95 {
					self.text = ""
				} else if event.isDeleteKey, !self.text.isEmpty {
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
	/*
	*/
	func checkMatch() {
		let target = String(repeating: self.expandKey, count: 2)
		if self.isPassive {
			if self.text.suffix(2) != target {
				return
			} else {
				self.text = String(self.text.dropLast(2))
			}
			if let match = passiveEmojiList.first(where: {
				$0.isMatch(self.text)
			}) {
				inputSnippet(match, isPassive: self.isPassive)
				return
			}
		}
		// user's snippets
		if let match = snippetList.first(where: {
			$0.isMatch(self.text)
		}) {
			inputSnippet(match, isPassive: self.isPassive)
			return
		}
		// emoji
		if let match = emojiList.first(where: {
			$0.isMatch(self.text)
		}) {
			inputSnippet(match, isPassive: self.isPassive)
			return
		}
		// dafault
		if let match = defaultSnippetList.first(where: {
			$0.isMatch(self.text)
		}) {
			inputSnippet(match, isPassive: self.isPassive)
			return
		}
		// ip
		if let match = ipSnippetsList.first(where: {
			$0.isMatch(self.text)
		}) {
			inputSnippet(match, isPassive: self.isPassive)
			return
		}
	}

	func inputSnippet(_ snippet: Snippets, isPassive: Bool) {
		// MARK: - delete
		if isPassive {
			pressDeleteKey()
			pressDeleteKey()
		}
		for _ in snippet.trigger {
			pressDeleteKey()
		}
		// MARK: - paste
		pasteSnippet(inputContent: snippet.content)
	}

	// simulating keypress
	func pressDeleteKey() {
		let eventSource = CGEventSource(stateID: .combinedSessionState)
		let keydownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x33, keyDown: true)
		let keyupEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x33, keyDown: false)
		keydownEvent?.post(tap: .cghidEventTap)
		keyupEvent?.post(tap: .cghidEventTap)
	}
	func pasteSnippet(inputContent: String) {
		// MARK: - save original clipboard
		let oldClipboard = NSPasteboard.general.string(forType: .string) ?? ""
		// MARK: - register to clipboard
		NSPasteboard.general.declareTypes([.string], owner: nil)
		NSPasteboard.general.clearContents()
		NSPasteboard.general.setString(inputContent, forType: .string)
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
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
			NSPasteboard.general.clearContents()
			NSPasteboard.general.setString(oldClipboard, forType: .string)
			self.text = ""
		}
	}
}

/*
*/
