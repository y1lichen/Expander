//
//  LongSnippetHandlerModel.swift
//  Expander
//
//  Created by 陳奕利 on 2022/2/3.
//

import Foundation
import AppKit

class LongSnippetHandlerModel {
	var contenOfFile: String? = nil
	var pathOfLongSnippet: URL? = nil
	
	func getContentOfLongSnippet(path: URL) -> String {
		self.pathOfLongSnippet = path
		readContent()
		self.pathOfLongSnippet = nil
		return self.contenOfFile ?? ""
	}
	
	private func showAlert() {
		let alert = NSAlert()
		alert.messageText = "Error occured when accessing the directory of the snippets!"
		alert.addButton(withTitle: "Cancel")
		alert.runModal()
	}
	
	private func readContent() {
		do {
			let data = try String(contentsOf: self.pathOfLongSnippet!, encoding: .utf8)
			self.contenOfFile = data
		} catch {
			showAlert()
		}
	}
}
