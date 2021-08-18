//
//  SnippetTableView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/18.
//

import AppKit

class SnippetTableContoller: NSViewController, NSFetchedResultsControllerDelegate, NSTextFieldDelegate {
	//
	var scrollView: NSScrollView!
	var tableView: NSTableView!
	// MARK: - core data
	let viewContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	lazy var dataController: NSFetchedResultsController<SnippetData> = {
		let request = NSFetchRequest<SnippetData>(entityName: "SnippetData")
		request.sortDescriptors = [NSSortDescriptor(key: "snippetTrigger", ascending: true)]
		let dataController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		dataController.delegate = self
		return dataController
	}()
	override func loadView() {
		self.view = NSView()
		self.view.frame = CGRect(origin: .zero, size: CGSize(width: 335, height: 345))
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		do {
			try self.dataController.performFetch()
		} catch {
			fatalError("\(error)")
		}
		//
		scrollView = NSScrollView(frame: self.view.bounds)
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
		
		// MARK: - reload data
		func reloadTable(notfification: Notification) -> Void {
			tableView.reloadData()
		}
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "reloadtable"), object: nil, queue: nil, using: reloadTable)
		
		// MARK: - delete handling
		func deleteRow(notification: Notification) -> Void {
			removeRow()
		}
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "deleteRow"), object: nil, queue: nil, using: deleteRow)
		//
		func deselectAll(notification: Notification) -> Void {
			tableView.deselectAll(nil)
		}
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "addRow"), object: nil, queue: nil, using: deselectAll)
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
	// for deleting row by deletekey down
	var deletekeyEvent: Any?
}

extension SnippetTableContoller: NSTableViewDelegate, NSTableViewDataSource, NSControlTextEditingDelegate {
	// MARK: - delete handling
	override func keyDown(with event: NSEvent) {
		if event.isDeleteKey {
			self.removeRow()
		}
	}
	
	func createDeleteKeyEventMonitor() {
		print("start detect")
		self.deletekeyEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
			self.keyDown(with: $0)
			return $0
		}
	}
	
	func controlTextDidEndEditing(_ obj: Notification) {
		if let textfield = obj.object as? NSTextField {
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
			createDeleteKeyEventMonitor()
		}
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		createDeleteKeyEventMonitor()
	}
	
	func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
		if let deletekeyEvent = deletekeyEvent {
			print("stop detect")
			NSEvent.removeMonitor(deletekeyEvent)
		}
		return true
	}
	/*
	---------------------------------
	*/
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
