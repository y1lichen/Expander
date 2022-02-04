//
//  SearchBarCellView.swift
//  Expander
//
//  Created by 陳奕利 on 2022/1/27.
//

import SwiftUI

struct SearchBarCellView: View {
	let longSnippet: LongSnippetModel
	
	func removeFileExtension(name: String) -> String {
		let length: Int = name.count
		let indexOfDot: Int = name.lastIndex(of: ".")?.utf16Offset(in: name) ?? 0
		let result = String(name.dropLast(length - indexOfDot))
		return result
	}
	
    var body: some View {
		Text(removeFileExtension(name: longSnippet.path.lastPathComponent))
			.font(.system(size: 25, weight: .bold))
			.padding(5)
	}
}
