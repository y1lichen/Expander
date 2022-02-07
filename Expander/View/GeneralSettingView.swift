//
//  GeneralSettingView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/9.
//

import SwiftUI

struct appSettings {
	
	private func createDefultLongSnippetDirectory() {
		do {
			try FileManager.default.createDirectory(atPath: NSHomeDirectory() + "/Documents/Expander/", withIntermediateDirectories: false, attributes: nil)
		} catch {
//			print(error)
		}
	}
	
	let defaultDirectory: String = NSHomeDirectory() + "/Documents/Expander/"
	
	mutating func resetLongSnippetsDirectory() {
		longSnippetsDirectory = defaultDirectory
	}
	let userDefaults = UserDefaults.standard
	var showAlert: Bool
	// 0 => default, 1 => custom
	var urlSelectionType: Int = 0 {
		didSet {
			if urlSelectionType == 0 {
				createDefultLongSnippetDirectory()
			}
		}
	}
	var longSnippetsDirectory: String {
		didSet {
			userDefaults.setValue(longSnippetsDirectory, forKey: "longSnippetsDirectory")
		}
	}
    var showNotification: Bool {
        didSet {
            userDefaults.setValue(showNotification, forKey: "showNotification")
        }
    }

    var dateformat: Int {
        didSet {
			userDefaults.setValue(dateformat, forKey: "dateformat")
        }
    }

    var isPassive: Bool {
        didSet {
			if (isPassive) { showAlert = true }
			userDefaults.setValue(isPassive, forKey: "passiveMode")
            NotificationCenter.default.post(name: NSNotification.Name("passiveModeChanged"), object: nil, userInfo: nil)
        }
    }

    var expandKey: String {
        didSet {
			showAlert = true
			userDefaults.setValue(expandKey, forKey: "passiveExpandKey")
            NotificationCenter.default.post(name: NSNotification.Name("passiveKeyChanged"), object: nil, userInfo: nil)
        }
    }
	
	var enableLongSnippets: Bool {
		didSet {
			userDefaults.setValue(enableLongSnippets, forKey: "enableLongSnippets")
			NotificationCenter.default.post(name: NSNotification.Name("enableLongSnippetsChanged"), object: nil, userInfo: nil)
		}
	}

    init() {
		showAlert = false
		longSnippetsDirectory = userDefaults.string(forKey: "longSnippetsDirectory") ?? (NSHomeDirectory() + "/Documents/Expander/")
		showNotification = userDefaults.bool(forKey: "showNotification")
		dateformat = userDefaults.integer(forKey: "dateformat")
		isPassive = userDefaults.bool(forKey: "passiveMode")
        expandKey = userDefaults.string(forKey: "passiveExpandKey") ?? "\\"
		enableLongSnippets = userDefaults.bool(forKey: "enableLongSnippets")
		if (self.longSnippetsDirectory != defaultDirectory) {
			urlSelectionType = 1
		}
    }
}

struct GeneralSettingView: View {
    @EnvironmentObject var appData: AppData
    @State var settings = appSettings()
    var maxdelete = [2, 3, 4, 5]
	
    func reloadIP() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadipdata"), object: self)
    }
	
	func parseCustomDirectory(_ pathName: String) -> String {
		let result = pathName.dropFirst(7)
		return String(result)
	}
	
	func parseCustomDirectoryForView(_ pathName: String) -> String {
		let result = pathName.replacingOccurrences(of: NSHomeDirectory(), with: "~")
		return result
	}
	
	func selectDirectory() {
		let dialog: NSOpenPanel = {
			let dialog = NSOpenPanel()
			dialog.title = "Choose the directory of your snippets"
			dialog.showsResizeIndicator = true
			dialog.allowsMultipleSelection = false
			dialog.canChooseFiles = false
			dialog.canChooseDirectories = true
			dialog.showsHiddenFiles = false
			return dialog
		}()
		if (dialog.runModal() == NSApplication.ModalResponse.OK) {
			guard let result = dialog.url else {
				return
			}
			self.settings.longSnippetsDirectory = parseCustomDirectory(result.absoluteString)
			self.settings.urlSelectionType = 1
		}
	}

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            //
            Button(action: reloadIP) {
                Text("reload IP adress")
			}
            // MARK: notification
            Toggle("Show notification when Expander is disabled", isOn: $settings.showNotification)
			Toggle("Enable Long Snippets", isOn: $settings.enableLongSnippets)
			Picker("Directory of long snippets", selection: $settings.urlSelectionType) {
				if (settings.urlSelectionType == 0) {
					Text("~/Documents/Expender/").tag(0)
					Divider()
					Text("Other").tag(2)
				} else if (settings.urlSelectionType == 1) {
					Text(parseCustomDirectoryForView(self.settings.longSnippetsDirectory)).tag(1)
					Text("~/Documents/Expender/").tag(0)
					Divider()
					Text("Other").tag(2)
				}
			}
			.disabled(!(self.settings.enableLongSnippets))
			.onChange(of: self.settings.urlSelectionType) { newValue in
				if (newValue == 2) {
					self.selectDirectory()
				} else if (newValue == 0) {
					self.settings.resetLongSnippetsDirectory()
				}
			}
            Picker("Date format", selection: $settings.dateformat) {
                Text("yyyy-mm-dd").tag(0)
                Text("mm-dd-yyyy").tag(1)
            }.frame(width: 200)
			Toggle("Passive mode", isOn: $settings.isPassive)
			Picker(selection: $settings.expandKey, label: Text("Expanding key")) {
				Text("\\").tag("\\").frame(width: 75)
				Text(";").tag(";").frame(width: 75)
				Text(",").tag(",").frame(width: 75)
				Text(".").tag(".").frame(width: 75)
			}
			.disabled(!(self.settings.isPassive))
			.pickerStyle(RadioGroupPickerStyle())
		}
		.padding(20)
		.alert(isPresented: $settings.showAlert) {
			Alert(title: Text("⚠️ Notice!"),
				  message: Text("With passive mode, all of the snippets will be exapnded only when typing \(settings.expandKey) twice after triggers.  eg: date\(settings.expandKey)\(settings.expandKey) \n\nAll the backslash(\\) in the triggers of the default snippets will be removed.")
			)
		}
    }
}
