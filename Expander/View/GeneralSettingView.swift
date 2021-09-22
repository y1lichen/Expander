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

	var isPassive: Bool {
		didSet {
			UserDefaults.standard.setValue(self.isPassive, forKey: "passiveMode")
			NotificationCenter.default.post(name: NSNotification.Name("passiveModeChanged"),object: nil, userInfo: nil)
		}
	}

	var expandKey: String {
		didSet {
			UserDefaults.standard.setValue(self.expandKey, forKey: "passiveExpandKey")
			NotificationCenter.default.post(name: NSNotification.Name("passiveKeyChanged"),object: nil, userInfo: nil)
		}
	}

	init() {
		self.showNotification = UserDefaults.standard.bool(forKey: "showNotification")
		self.dateformat = UserDefaults.standard.integer(forKey: "dateformat")
		self.isPassive = UserDefaults.standard.bool(forKey: "passiveMode")
		self.expandKey = UserDefaults.standard.string(forKey: "passiveExpandKey") ?? "\\"
	}
}

struct GeneralSettingView: View {
	@EnvironmentObject var appData: AppData
	@State var settings = appSettings()
	var maxdelete = [2,3,4,5]
	func reloadIP() {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadipdata"), object: self)
	}
    var body: some View {
		VStack (alignment: .leading){
			Spacer().frame(height: 10)
			//
			Button(action: reloadIP) {
				Text("reload IP adress")
			}
			Spacer().frame(height: 20)
			// MARK: notification
			Toggle("Show notification when Expander is disabled", isOn: $settings.showNotification)
			Spacer().frame(height: 20)
			Picker("Date format", selection: $settings.dateformat) {
				Text("yyyy-mm-dd").tag(0)
				Text("mm-dd-yyyy").tag(1)
			}.frame(width: 200)
			Spacer().frame(height: 20)
			Toggle("Passive mode", isOn: $settings.isPassive)
			if settings.isPassive {
				Spacer().frame(height: 20)
				Picker(selection: $settings.expandKey, label: Text("expanding key")) {
					Text("\\").tag("\\").frame(width: 75)
					Text(";").tag(";").frame(width: 75)
					Text(",").tag(",").frame(width: 75)
					Text(".").tag(".").frame(width: 75)
				}.pickerStyle(RadioGroupPickerStyle())
				Spacer().frame(height: 10)
				Text("With passive mode, all of the snippets will be exapnded only when typing \(settings.expandKey) twice after triggers.  eg: date\(settings.expandKey)\(settings.expandKey) \n\n⚠️ All the backslash(\\) in the triggers of the default snippets will be removed.").frame(width: 280)
			} else {
				Spacer()
			}
		}.padding(20)
    }
}

