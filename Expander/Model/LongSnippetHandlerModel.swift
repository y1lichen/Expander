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
	var fileName: String? = nil
	
	func handleEvent(fileName: String) {
		self.fileName = fileName
		readContent()
	}
	
	func showAlert() {
		let alert = NSAlert()
		alert.messageText = "Error occured when accessing the directory of the snippets!"
		alert.addButton(withTitle: "Cancel")
		alert.runModal()
	}
	
	private func readContent() {
		guard let directory = UserDefaults.standard.string(forKey: "longSnippetsDirectory") else {
			return
		}
	}
}
