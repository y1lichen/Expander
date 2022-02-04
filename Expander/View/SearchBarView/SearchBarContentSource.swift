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
			return allSnippets.map {
				$0.identifier
			}
		}
		return allSnippets.filter {
			$0.path.lastPathComponent.localizedCaseInsensitiveContains(searchTerm)
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
		let userInfo = ["path": self.selectedLongSnippet!.path]
		NotificationCenter.default.post(name: NSNotification.Name("getLongSnippet"), object: nil, userInfo: userInfo)
	}
	
	func didCancel() {
		self.selectedLongSnippet = nil
		appDelegate.originalActiveApp?.activate(options: .activateAllWindows)
	}
}

/*

 */
