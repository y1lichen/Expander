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
			SnippetList()
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

struct SnippetList: View {
	@FetchRequest(entity: SnippetData.entity(), sortDescriptors: [NSSortDescriptor(key: "snippetTrigger", ascending: true)])
	var results: FetchedResults<SnippetData>
	@State var snippetslist: Array<SnippetData>?
	var body: some View {
//		List {
//			ForEach(results) {
//				result in
//				SnippetListComponent(trigger: result.snippetTrigger ?? "", content: result.snippetContent ?? "").tag(result)
//			}
//		}
		SnippetTableView()
	}
}

struct SnippetListComponent: View {
	var trigger: String
	var content: String
	var body: some View {
		HStack {
			Text(trigger)
				.frame(width: 80)
			Divider()
			Text(content)
				.frame(width: 220)
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
			try? self.viewContext.save()
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
		.frame(width: 35, height: 50)
	}
}

struct innerToolBarView: View {
	@Binding var isShow: Bool
	func add() {
		self.isShow = true
	}
	func remove() {
		
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
		//
		do {
			try self.dataController.performFetch()
		} catch {
			fatalError("\(error)")
		}
		//
		// MARK: - core data #end
		scrollView = NSScrollView(frame: self.view.bounds)
		self.view.addSubview(scrollView)
		tableView = NSTableView(frame: CGRect(x: 0, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height))
		tableView.delegate = self
		tableView.dataSource = self
		// first column
		let firstCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "firstCol"))
		firstCol.width = 120
		firstCol.title = "Trigger"
		tableView.addTableColumn(firstCol)
		// second column
		let secondCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "secondCol"))
		secondCol.width = scrollView.bounds.size.width - 120
		secondCol.title = "Snippet"
		tableView.addTableColumn(secondCol)
		
		scrollView.documentView = tableView
	}
	//
	override var representedObject: Any? {
		didSet {
		}
	}
}

extension SnippetTableContoller: NSTableViewDelegate, NSTableViewDataSource {
	
	func numberOfSections(in tableview: NSTableView) -> Int {
		return dataController.sections?.count ?? 0
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return 15
	}
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let textfield = NSTextField()
		if tableColumn?.identifier == NSUserInterfaceItemIdentifier("firstCol") {
			// trigger column
			textfield.stringValue = "test"
		} else {
			// snippet column
			textfield.stringValue = "--"
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
