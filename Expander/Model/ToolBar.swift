//
//  ToolBar.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/8.
//

import SwiftUI

extension NSToolbarItemGroup.Identifier {
	static let general = NSToolbarItem.Identifier(rawValue: "general")
	static let snippets = NSToolbarItem.Identifier(rawValue: "notification")
}

extension NSToolbar {
	static let prefToolBar: NSToolbar = {
		let toolbar = NSToolbar(identifier: "PreferenceToolBar")
		toolbar.displayMode = .iconAndLabel
		return toolbar
	}()
}

extension AppDelegate: NSToolbarDelegate {

	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		[.general, .snippets]
	}

	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		[.general, .snippets]
	}

	func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
				willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		switch itemIdentifier {
		case NSToolbarItem.Identifier.general:
			return customToolbarItem(itemIdentifier: itemIdentifier, label: "General",
				image: NSImage(named: NSImage.preferencesGeneralName)!, action: #selector(openGeneral))
		case NSToolbarItem.Identifier.snippets:
			return customToolbarItem(itemIdentifier: itemIdentifier, label: "Add snippets",
				image: NSImage(named: NSImage.addTemplateName)!, action: #selector(addSnippets))
		default:
			return nil
		}
	}
	
	@objc private func openGeneral() {
		self.appData.preferencesView = 0
	}

	@objc private func addSnippets() {
		self.appData.preferencesView = 1
	}

	func customToolbarItem(itemIdentifier: NSToolbarItem.Identifier, label: String,
							image: NSImage, action: Selector) -> NSToolbarItem? {
		let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
		toolbarItem.label = label
		toolbarItem.action = action
		toolbarItem.image = image
		toolbarItem.isEnabled = true
		toolbarItem.target = self
		return toolbarItem
	}
}
