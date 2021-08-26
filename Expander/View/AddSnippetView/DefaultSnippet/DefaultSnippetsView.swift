//
//  DefaultSnippetsView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/25.
//

import SwiftUI

struct DefaultSnippetsView: View {
    var body: some View {
		VStack {
			DefualtSnippetTable()
			Spacer().frame(height: 20)
		}
		.border(Color(NSColor.gridColor), width: 1.5)
		.padding(15)
    }
}

struct DefualtSnippetTable: NSViewControllerRepresentable {
	func makeNSViewController(context: Context) -> some NSViewController {
		return DefaultSnippetTableContoller()
	}
	func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
	}
}
