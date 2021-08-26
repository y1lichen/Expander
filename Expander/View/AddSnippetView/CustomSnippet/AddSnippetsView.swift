//
//  AddSnippetsView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/9.
//

import SwiftUI

struct AddSnippetsView: View {
	@State var showSheet = false
	var body: some View {
		VStack {
			Spacer().frame(height: 4)
			SnippetTableView()
			Spacer().frame(height: 3)
			footerToolBarView(isShow: $showSheet)
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
			data.date = Date()
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

struct footerToolBarView: View {

	func sendNotification(notificationName: String) {
		let nc = NotificationCenter.default
		nc.post(name: Notification.Name(notificationName), object: nil)
	}

	@Binding var isShow: Bool
	func add() {
		sendNotification(notificationName: "addRow")
		self.isShow = true
	}
	func remove() {
		sendNotification(notificationName: "deleteRow")
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

/*
--
/Users/chenli/Desktop/workplace/Expander/Expander/View/AddSnippetView/SnippetTableView.swift
*/
struct SnippetTableView: NSViewControllerRepresentable {
	func makeNSViewController(context: Context) -> some NSViewController {
		return SnippetTableContoller()
	}
	func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
	}
}
