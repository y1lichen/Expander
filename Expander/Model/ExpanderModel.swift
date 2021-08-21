//
//  ExpanderModel.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/8.
//


import Foundation
import SwiftUI


extension NSEvent {
	var isDeleteKey: Bool {
		self.keyCode == 51
	}
}

class ExpanderModel: ObservableObject {
	@Published var text = ""
	//
	let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SnippetData")
	func fetchSnippetList() -> [Snippets] {
		let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		let managedObject = try! context.fetch(request) as! [SnippetData]
		let snippetList = managedObject.map {
			Snippets.init(data: $0)
		}
		return snippetList
	}
	//
	let defaultSnippetList: [Snippets] = Snippets.defaults
	lazy var snippetList: [Snippets] = fetchSnippetList()
	//
	init() {
		NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
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
		// global event
		NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseUp, .otherMouseDown]) { _ in
			self.text = ""
		}
		// in-app event
		NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { event in
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
	// MARK: - 1. register to clipboard
	// MARK: - 2.delete
	// MARK: - 3.paste
	// MARK: - 4.register origin input to clipboard
	}
	
	//
	func deleteUserInput() {
		let eventSource = CGEventSource(stateID: .combinedSessionState)
		let keydownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x33, keyDown: true)
		let keyupEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x33, keyDown: false)

		keydownEvent?.post(tap: .cghidEventTap)
		keyupEvent?.post(tap: .cghidEventTap)
	}
	func pasteSnippet() {
		let eventSource = CGEventSource(stateID: .combinedSessionState)
		let keydownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x09, keyDown: true)
		let keyupEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x09, keyDown: false)
		keydownEvent!.flags = CGEventFlags.maskCommand
		keyupEvent!.post(tap: CGEventTapLocation.cghidEventTap)
	}
}
