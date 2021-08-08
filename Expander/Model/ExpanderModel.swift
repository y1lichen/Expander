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
		NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseUp, .otherMouseDown]) { _ in
			self.text = ""
		}
		// testing
		NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { event in
			self.text = ""
			return event
		}
	}
}

