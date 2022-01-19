//
//  ContentView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/8.
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var appData: AppData
    var body: some View {
		VStack {
			if self.appData.preferencesView == 0 {
				GeneralSettingView()
			} else {
				SnippetView()
			}
		}
		.frame(width: 400, height: 430, alignment: .center)
	}
}

