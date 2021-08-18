//
//  AppData.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/9.
//

import Foundation

class AppData: ObservableObject {
	@Published var isOn: Bool = true
	@Published var preferencesView: Int = 0
	@Published var tableSortDescriptor: NSSortDescriptor = NSSortDescriptor(keyPath: \SnippetData.snippetTrigger, ascending: true)
}
