//
//  SnippetView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/25.
//

import SwiftUI

struct SnippetView: View {
	@State var tab: Int = 1
    var body: some View {
		TabView(selection: $tab, content:  {
			AddSnippetsView().tabItem {
				Text("Custom Snippets")}.tag(1)
			DefaultSnippetsView().tabItem {
				Text("Default Snippets")
			}.tag(2)
		}
		)
    }
}
