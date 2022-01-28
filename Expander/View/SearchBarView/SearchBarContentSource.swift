//
//  SearchBarContentSource.swift
//  Expander
//
//  Created by 陳奕利 on 2022/1/27.
//

import Foundation
import DSFQuickActionBar
import SwiftUI

class SearchBarContentSource: DSFQuickActionBarSwiftUIContentSource {

	@Binding var selectedLongSnippet: LongSnippetModel?
	
	let appDelegate = NSApplication.shared.delegate as! AppDelegate
	
	init(selectedLongSnippet: Binding<LongSnippetModel?>) {
		self._selectedLongSnippet = selectedLongSnippet
	}
	
	func identifiersForSearch(_ searchTerm: String) -> [DSFQuickActionBar.ItemIdentifier] {
		if searchTerm.isEmpty { return [] }
		let snippetsFiles = appDelegate.getLongSnippet()
		return snippetsFiles.filter {
			$0.name.contains(searchTerm)
		}.map { $0.identifier }
	}
	
	func viewForIdentifier<RowContent>(_ identifier: DSFQuickActionBar.ItemIdentifier, searchTerm: String) -> RowContent? where RowContent : View {
		guard let longSnippet = appDelegate.getLongSnippet().filter({ $0.identifier == identifier }).first else {
			return nil
		}
		return SearchBarCellView(longSnippet: longSnippet) as? RowContent
	}
	
	func didSelectIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier) {
		guard let longSnippet = appDelegate.getLongSnippet().filter({ $0.identifier == identifier }).first else {
			return
		}
		self.selectedLongSnippet = longSnippet
	}
	
	func didCancel() {
		self.selectedLongSnippet = nil
	}
}
