//
//  SnippetTableView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/18.
//

import AppKit

class SnippetTableContoller: NSViewController, NSFetchedResultsControllerDelegate, NSTextFieldDelegate, NSSearchFieldDelegate {
	//
	var scrollView: NSScrollView!
	var tableView: NSTableView!
	//
	var sortMethodMenu: NSPopUpButton!
	var searchField: NSSearchField!
	//
	var predicate: NSPredicate? = nil
	// MARK: - core data
	let viewContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	func setController() -> NSFetchedResultsController<SnippetData> {
		let sortMethod =  UserDefaults.standard.string(forKey: "sortMethod")
		let request = NSFetchRequest<SnippetData>(entityName: "SnippetData")
		request.sortDescriptors = [NSSortDescriptor(key: sortMethod, ascending: true)]
		request.predicate = self.predicate
		let dataController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		dataController.delegate = self
		return dataController
	}
	
	lazy var dataController: NSFetchedResultsController<SnippetData> = {
		return setController()
	}()
	
	override func loadView() {
		self.view = NSView()
		self.view.frame = CGRect(origin: .zero, size: CGSize(width: 355, height: 345))
	}
	
	func resetDataController() {
		self.dataController = setController()
		do {
			try self.dataController.performFetch()
		} catch {
			fatalError("\(error)")
		}
		self.tableView.reloadData()
	}
	
	
	@objc func sortMethodChanged() {
		let methodIndex = self.sortMethodMenu.indexOfSelectedItem
		if methodIndex == 0 {
			// sort by trigger
			UserDefaults.standard.setValue("snippetTrigger", forKey: "sortMethod")
		} else {
			// sort bt date
			UserDefaults.standard.setValue("date", forKey: "sortMethod")
		}
		resetDataController()
	}
	
	// MARK: - sort method changed handling
	func addSortMethodChangingMenu() {
		let label = NSTextField()
		label.isEditable = false
		label.isSelectable = false
		label.isBezeled = false
		label.stringValue = "sort by"
		label.frame = CGRect(x: 10, y: 350, width: 40, height: 20)
		label.sizeToFit()
		let sortMethod =  UserDefaults.standard.string(forKey: "sortMethod")
		sortMethodMenu = NSPopUpButton(frame: CGRect(x: 60, y: 345, width: 100, height: 20))
		sortMethodMenu.target = self
		sortMethodMenu.action = #selector(self.sortMethodChanged)
		if sortMethod == "trigger" {
			sortMethodMenu.selectItem(at: 0)
		} else {
			sortMethodMenu.selectItem(at: 1)
		}
		sortMethodMenu.addItem(withTitle: "trigger")
		sortMethodMenu.addItem(withTitle: "date")
		self.view.addSubview(label)
		self.view.addSubview(sortMethodMenu)
	}
	
	// MARK: - add searchfield
	func addSearchField() {
		searchField = NSSearchField(frame: CGRect(x: 180, y: 345, width: 170, height: 20))
		searchField.delegate = self
		self.view.addSubview(searchField)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		do {
			try self.dataController.performFetch()
		} catch {
			fatalError("\(error)")
		}
		//
		addSortMethodChangingMenu()
		addSearchField()
		//
		scrollView = NSScrollView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width , height: self.view.bounds.size.width - 30))
		self.view.addSubview(scrollView)
		tableView = NSTableView(frame: CGRect(x: 0, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height))
		tableView.delegate = self
		tableView.dataSource = self
		// first column
		let firstCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "firstCol"))
		firstCol.width = 130
		firstCol.title = "Trigger"
		tableView.addTableColumn(firstCol)
		// second column
		let secondCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "secondCol"))
		secondCol.width = scrollView.bounds.size.width - 130
		secondCol.title = "Snippet"
		tableView.addTableColumn(secondCol)
		scrollView.documentView = tableView
		
		func addNotificationCenterObserver(notificationName: String, action: @escaping (Notification) -> Void) {
			NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: notificationName), object: nil, queue: nil, using: action)
		}
		
		// MARK: - reload data
		func reloadTable(notfification: Notification) -> Void {
			tableView.reloadData()
		}
		addNotificationCenterObserver(notificationName: "reloadtable", action: reloadTable)
		
		// MARK: - delete handling
		func deleteRow(notification: Notification) -> Void {
			removeRow()
		}
		addNotificationCenterObserver(notificationName: "deleteRow", action: deleteRow)
		
		// deselect row before adding new snippet
		func deselectAll(notification: Notification) -> Void {
			tableView.deselectAll(nil)
		}
		addNotificationCenterObserver(notificationName: "addRow", action: deselectAll)
	}
	func removeRow() {
		// remove from core data
		guard let index = tableView.selectedRowIndexes.first else {
			return }
		let path = IndexPath(item: index, section: 0)
		let objectToDelete = dataController.object(at: path)
		viewContext.delete(objectToDelete)
		try? viewContext.save()
		// remove from view
		let selectedRow = tableView.selectedRow
		tableView.removeRows(at: IndexSet(integer: selectedRow), withAnimation: .effectFade)
	}
	var deletekeyEvent: Any?
}

extension SnippetTableContoller: NSTableViewDelegate, NSTableViewDataSource, NSControlTextEditingDelegate {
	
	func controlTextDidChange(_ obj: Notification) {
		// MARK: - search handling
		var textfield: NSTextField?
		textfield = obj.object as? NSTextField
		if (textfield != nil) && (textfield == self.searchField) {
			let targetQuery = textfield!.stringValue as String
			if targetQuery.isEmpty {
				self.predicate = nil
			} else {
				self.predicate = NSPredicate(format: "snippetTrigger CONTAINS %@ OR snippetContent CONTAINS %@", targetQuery, targetQuery)
			}
			self.resetDataController()
		}
	}
	
	func controlTextDidEndEditing(_ obj: Notification) {
		// MARK: - delete handling
		if let textfield = obj.object as? NSTextField {
			if textfield == self.searchField {
				return
			}
			let newStr = textfield.stringValue
			let cell = textfield.superview!
			let row = tableView.row(for: cell)
			let col = tableView.column(for: cell)
			let path = IndexPath(item: row, section: 0)
			let objectToUpdate = dataController.object(at: path)
			if col == 0 {
				// trigger
				objectToUpdate.setValue(newStr, forKey: "snippetTrigger")
			} else {
				// snippet
				objectToUpdate.setValue(newStr, forKey: "snippetContent")
			}
			try? viewContext.save()
		}
	}
	
	override func keyDown(with event: NSEvent) {
		let isNotEditing: Bool = (self.tableView.editedRow == -1)
			if event.isDeleteKey && isNotEditing {
				self.removeRow()
			}
		}
	/*
	---------------------------------
	*/
	func pasteSnippet() {
		let eventSource = CGEventSource(stateID: .combinedSessionState)
		let keydownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x09, keyDown: true)
		let keyupEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x09, keyDown: false)
		keydownEvent!.flags = CGEventFlags.maskCommand
		keyupEvent!.post(tap: CGEventTapLocation.cghidEventTap)
	}
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
	// Table View
	func numberOfRows(in tableView: NSTableView) -> Int {
		return dataController.fetchedObjects?.count ?? 0
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let snippetItem = dataController.fetchedObjects![row]
		let textfield: NSTextField = {
			let textfield = NSTextField()
			textfield.isBordered = false
			textfield.translatesAutoresizingMaskIntoConstraints = false
			textfield.isBezeled = true
			textfield.delegate = self
			return textfield
		}()
		if tableColumn?.identifier == NSUserInterfaceItemIdentifier("firstCol") {
			// trigger column
			textfield.stringValue = snippetItem.snippetTrigger ?? "--"
		} else {
			// snippet column
			textfield.stringValue = snippetItem.snippetContent ?? "--"
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
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn, row: Int) -> NSTableRowView? {
		let rowView = NSTableRowView()
		rowView.isEmphasized = false
		return rowView
	}
}

