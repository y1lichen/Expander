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
			let button = NSButton(image: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "gearshape")!, target: nil, action: #selector(openGeneral))
			button.bezelStyle = .recessed
			return customToolbarItem(itemIdentifier: itemIdentifier, label: "General", toolTip: "Your custom settings",
				image: NSImage(named: NSImage.preferencesGeneralName)!, itemContent: button)
		case NSToolbarItem.Identifier.snippets:
			let button = NSButton(image: NSImage(systemSymbolName: "doc.text", accessibilityDescription: "doc.text")!, target: nil, action: #selector(addSnippets))
			button.bezelStyle = .recessed
			return customToolbarItem(itemIdentifier: itemIdentifier, label: "Snippets", toolTip: "Manage your snippets",
				image: NSImage(named: NSImage.addTemplateName)!, itemContent: button)
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
						   toolTip: String, image: NSImage, itemContent: NSButton) -> NSToolbarItem? {
		let toolBarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
		toolBarItem.label = label
		toolBarItem.view = itemContent
		toolBarItem.toolTip = toolTip
		let menuItem = NSMenuItem()
		menuItem.submenu = nil
		menuItem.title = label
		toolBarItem.menuFormRepresentation = menuItem
		return toolBarItem
	}
}
