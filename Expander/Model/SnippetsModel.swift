//
//  SnippetsModel.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/8.
//

import Foundation
import CoreData

struct Snippets {
	let trigger: String
	let content: String

	func isMatch(_ inputString: String) -> Bool {
		let matchTrigger = inputString.hasSuffix(self.trigger)
		let isFullWord = (inputString.dropLast(self.trigger.count).last ?? " ").isWhitespace
		return matchTrigger && isFullWord
	}
}

extension Snippets {
	init(data: SnippetData) {
		self.trigger = data.snippetTrigger!
		self.content = data.snippetContent!
	}
}

extension Snippets {
	static var defaults: [Snippets] = [
	Snippets(trigger: ":date", content: "CurrentDate")
	]
}

