//
//  SearchBar.swift
//  Expander
//
//  Created by 陳奕利 on 2022/1/20.
//

import SwiftUI

struct SearchBar: View {
    var body: some View {
		HStack {
			Image(systemName: "magnifyingglass")
				.resizable()
				.scaledToFit()
				.frame(height: 25)
		}
	}
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar()
    }
}
