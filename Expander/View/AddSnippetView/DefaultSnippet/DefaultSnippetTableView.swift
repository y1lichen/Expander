//
//  DefaultSnippetTableView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/25.
//

import AppKit

class DefaultSnippetTableContoller: NSViewController, NSTableViewDelegate, NSTextFieldDelegate, NSTableViewDataSource {

	var scrollView: NSScrollView!
	var tableView: NSTableView!

	// date
	var snippetsList: [Snippets] = []

	override func loadView() {
		self.view = NSView()
		self.view.frame = CGRect(origin: .zero, size: CGSize(width: 355, height: 345))
		self.setSnippetList()
	}
	//
	var isPassive: Bool!
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		//
		self.isPassive = UserDefaults.standard.bool(forKey: "passiveMode")
		//
		scrollView = NSScrollView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width , height: self.view.bounds.size.width - 30))
		self.view.addSubview(scrollView)
		tableView = NSTableView(frame: CGRect(x: 0, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height))
		tableView.delegate = self
		tableView.dataSource = self
		scrollView.documentView = tableView
		scrollView.hasHorizontalScroller = false
		scrollView.hasVerticalScroller = true
		let firstCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "defaultFirstCol"))
		firstCol.width = 130
		firstCol.title = "Trigger"
		tableView.addTableColumn(firstCol)
		// second column
		let secondCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "defaultSecondCol"))
		secondCol.width = scrollView.bounds.size.width - 130
		secondCol.title = "Snippet"
		tableView.addTableColumn(secondCol)
		//
	}

	func setSnippetList() {
		let defaultSnippetsList: [Snippets] = [
			Snippets(trigger: "\\date", content: "CURRENT DATE"),
			Snippets(trigger: "\\timestp",
			content: "CURRENT TIME"),
			Snippets(trigger: "\\ip",
			content: "PUBLIC IP address"),
			Snippets(trigger: "\\lip",
			content: "PRIVATE(LOCAL) IP address")
		]
		var emojiList: [Snippets] = Snippets.emoji
		emojiList.sort {
			$0.trigger < $1.trigger
		}
		self.snippetsList.append(contentsOf: defaultSnippetsList)
		self.snippetsList.append(contentsOf: emojiList)
	}
}

extension DefaultSnippetTableContoller {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return self.snippetsList.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		// row item
		let item = self.snippetsList[row]
		//
		let textfield: NSTextField = {
			let textfield = NSTextField()
			textfield.isEditable = false
			textfield.isBordered = false
			textfield.translatesAutoresizingMaskIntoConstraints = false
			textfield.isBezeled = true
			textfield.delegate = self
			return textfield
		}()
		if tableColumn?.identifier == NSUserInterfaceItemIdentifier("defaultFirstCol") {
			// trigger column
			if self.isPassive {
				textfield.stringValue = String(item.trigger.dropFirst())
			} else {
				textfield.stringValue = item.trigger
			}
		} else {
			// snippet column
			textfield.stringValue = item.content
		}
		let cell: NSTableCellView = {
			let tablecell = NSTableCellView()
			tablecell.addSubview(textfield)
			tablecell.addConstraint(NSLayoutConstraint(item: textfield, attribute: .centerY, relatedBy: .equal, toItem: tablecell, attribute: .centerY, multiplier: 1, constant: 0))
			tablecell.addConstraint(NSLayoutConstraint(item: textfield, attribute: .left, relatedBy: .equal, toItem: tablecell, attribute: .left, multiplier: 1, constant: 0))
			tablecell.addConstraint(NSLayoutConstraint(item: textfield, attribute: .right, relatedBy: .equal, toItem: tablecell, attribute: .right, multiplier: 1, constant: 0))
			return tablecell
		}()
		return cell
	}
}


