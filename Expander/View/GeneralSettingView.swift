//
//  GeneralSettingView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/9.
//

import SwiftUI

struct GeneralSettingView: View {
	@ObservedObject var model = ExpanderModel()
    var body: some View {
		VStack {
			Text("General")
			// MARK: launch at login
			// MARK: notification
			// MARK: delay
			Text("\(model.text)")
		}
    }
}

