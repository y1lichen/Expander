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
	var selectedLongSnippet: LongSnippetModel? = nil
	var allSnippets: [LongSnippetModel]
	
	init(allSnippets: [LongSnippetModel]) {
		self.allSnippets = allSnippets
	}
	
	let appDelegate = NSApplication.shared.delegate as! AppDelegate
	

	func identifiersForSearch(_ searchTerm: String) -> [DSFQuickActionBar.ItemIdentifier] {
		if searchTerm.isEmpty {
			return []
		}
		return allSnippets.filter {
			$0.name.localizedCaseInsensitiveContains(searchTerm)
		}.map {
			$0.identifier
		}
	}
	
	func viewForIdentifier<RowContent>(_ identifier: DSFQuickActionBar.ItemIdentifier, searchTerm: String) -> RowContent? where RowContent : View {
		guard let longSnippet = allSnippets.filter({
			$0.identifier == identifier
		}).first else {
			return nil
		}
		return SearchBarCellView(longSnippet: longSnippet) as? RowContent
	}
	
	func didSelectIdentifier(_ identifier: DSFQuickActionBar.ItemIdentifier) {
		guard let longSnippet = allSnippets.filter({
			$0.identifier == identifier
		}).first else {
			return
		}
		self.selectedLongSnippet = longSnippet
		print(longSnippet.name)
	}
	
	func didCancel() {
		self.selectedLongSnippet = nil
	}
}
