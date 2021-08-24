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
	
	func getCurrentDate() -> String {
		let dateFormatter : DateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MMM-dd"
		let date = Date()
		let dateString = dateFormatter.string(from: date)
		return dateString
	}
}

extension Snippets {
	init(data: SnippetData) {
		self.trigger = data.snippetTrigger!
		self.content = data.snippetContent!
	}
}
