//
//  LongSnippetView.swift
//  Expander
//
//  Created by 陳奕利 on 2022/1/20.
//

import SwiftUI

struct LongSnippetView: View {
    var body: some View {
		VStack {
			SearchBar()
			Spacer()
		}
		.frame(width: 800, height: 500, alignment: .topLeading)
	}
}

