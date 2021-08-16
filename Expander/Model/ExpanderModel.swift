//
//  ExpanderModel.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/8.
//


import Foundation
import SwiftUI

class ExpanderModel: ObservableObject {
	@Published var text = ""
	init() {
		NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
			guard let character = event.characters else { return }
			// if character is nil, the following won't be execute
			let keycode = event.keyCode
			print(character, keycode)
			if keycode > 95 {
				self.text = ""
			} else if event.isDeleteKey && self.text != "" {
				self.text.removeLast()
			} else {
				self.text += character
			}
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

	func inputSnippet() {
	//MARK: -
	// 1. register to clipboard
	// 2.delete
	// 3.paste
	// 4.register origin input to clipboard
	}
}
