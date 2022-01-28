//
//  SearchBarCellView.swift
//  Expander
//
//  Created by 陳奕利 on 2022/1/27.
//

import SwiftUI

struct SearchBarCellView: View {
	let longSnippet: LongSnippetModel
    var body: some View {
		Text(longSnippet.name).font(.title)
    }
}
