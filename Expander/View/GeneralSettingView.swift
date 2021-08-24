//
//  GeneralSettingView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/9.
//

import SwiftUI

struct appSettings {
	var showNotification: Bool {
		didSet {
			UserDefaults.standard.setValue(self.showNotification, forKey: "showNotification")
		}
	}
	var dateformat: Int {
		didSet {
			UserDefaults.standard.setValue(self.dateformat, forKey: "dateformat")
		}
	}

	init() {
		self.showNotification = UserDefaults.standard.bool(forKey: "showNotification")
		self.dateformat = UserDefaults.standard.integer(forKey: "dateformat")
	}
}

struct GeneralSettingView: View {
	@EnvironmentObject var appData: AppData
	@State var settings = appSettings()
	var maxdelete = [2,3,4,5]
    var body: some View {
		VStack (alignment: .leading){
			Spacer()
			// MARK: launch at login
			// MARK: notification
			Toggle("Show notification when Expander is disabled", isOn: $settings.showNotification)
			Spacer()
			Picker("Date format", selection: $settings.dateformat) {
				Text("yyyy-mm-dd").tag(0)
				Text("mm-dd-yyyy").tag(1)
			}.frame(width: 200)
			Spacer()
		}.padding(20)
    }
}

