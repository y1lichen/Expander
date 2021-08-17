//
//  AddSnippetsView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/9.
//

import AppKit
import SwiftUI

struct AddSnippetsView: View {
	@State var showSheet = false
	var body: some View {
		VStack {
			SnippetTableView()
			Spacer().frame(height: 3)
			innerToolBarView(isShow: $showSheet)
		}
		.border(Color(NSColor.gridColor), width: 1.5)
		.padding(15)
		.sheet(isPresented: $showSheet) {
			SheetView(isShow: $showSheet)
		}
    }
}

struct SheetView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@Binding var isShow: Bool
	@State var trigger: String = ""
	@State var content: String = ""
	func saveData() {
		let data = SnippetData(context: self.viewContext)
		if (trigger != "") && (content != "") {
			data.snippetTrigger = self.trigger
			data.snippetContent = self.content
			data.id = UUID()
			do {
				try self.viewContext.save()
			} catch {
				print(error.localizedDescription)
			}
		}
	}
	var body: some View {
		VStack {
			Text("Create new snippet")
				.font(.headline)
				.fontWeight(.heavy)
			Spacer()
			HStack {
				TextField("trigger", text: $trigger)
					.frame(width: 80)
				TextField("snippet", text: $content)
			}
			Spacer().frame(maxHeight: 20)
			HStack {
				Button("Cancel") {
					self.isShow = false
				}
				Spacer()
				Button("Done") {
					self.isShow = false
					self.saveData()
					let nc = NotificationCenter.default
					nc.post(name: Notification.Name("reloadtable"), object: nil)
				}
			}
		}
		.frame(width: 300, height: 100)
		.padding()
	}
}


/* add, remove button */
struct ListButton: View {
	var imageName: String
	var action: () -> Void
	var body: some View {
		Button(action: action) {
			Image(nsImage: NSImage(named: imageName)!)
				.resizable()
		}
		.buttonStyle(BorderlessButtonStyle())
		.frame(width: 35, height: 55)
	}
}

struct innerToolBarView: View {
	
	@Binding var isShow: Bool
	func add() {
		self.isShow = true
	}
	func remove() {
		let nc = NotificationCenter.default
		nc.post(name: Notification.Name("deleteRow"), object: nil)
	}
	var body: some View {
		HStack(spacing: 0) {
			ListButton(imageName: NSImage.addTemplateName, action: add)
			Divider()
			ListButton(imageName: NSImage.removeTemplateName, action: remove)
			Divider()
			Spacer()
		}.frame(height: 20)
	}
}


struct SnippetTableView: NSViewControllerRepresentable {
	func makeNSViewController(context: Context) -> some NSViewController {
		return SnippetTableContoller()
	}
	func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
	}
}

class SnippetTableContoller: NSViewController, NSFetchedResultsControllerDelegate {
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
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "deleteRow"), object: nil, queue: nil, using: deleteRow)
	}
}

extension SnippetTableContoller: NSTableViewDelegate, NSTableViewDataSource {
	
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
		let textfield = NSTextField()
		if tableColumn?.identifier == NSUserInterfaceItemIdentifier("firstCol") {
			// trigger column
			textfield.stringValue = snippetItem.snippetTrigger ?? "--"
		} else {
			// snippet column
			textfield.stringValue = snippetItem.snippetContent ?? "--"
		}
		let cell = NSTableCellView()
		cell.addSubview(textfield)
		textfield.isBordered = false
		textfield.translatesAutoresizingMaskIntoConstraints = false
		cell.addConstraint(NSLayoutConstraint(item: textfield, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0))
		cell.addConstraint(NSLayoutConstraint(item: textfield, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 0))
		cell.addConstraint(NSLayoutConstraint(item: textfield, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: 0))
		return cell
	}
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn, row: Int) -> NSTableRowView? {
		let rowView = NSTableRowView()
		rowView.isEmphasized = false
		return rowView
	}
}
