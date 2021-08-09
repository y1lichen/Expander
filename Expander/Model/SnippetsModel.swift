//
//  SnippetsModel.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/8.
//

import Foundation

struct Snippets {
	let trigger: String
	let content: String

	func isMatch(_ inputString: String) -> Bool {
		let matchTrigger = inputString.hasPrefix(self.trigger)
		let isFullWord = (inputString.dropLast(self.trigger.count).last ?? " ").isWhitespace
		return matchTrigger && isFullWord
	}
}

