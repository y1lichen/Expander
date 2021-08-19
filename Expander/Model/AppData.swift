//
//  AppData.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/9.
//

import Foundation

class AppData: ObservableObject {

	@Published var isOn: Bool = true
	@Published var preferencesView: Int = 0
	@Published var tableSortDescriptor: String = UserDefaults.standard.string(forKey: "sortMethod")! {
		didSet {
			UserDefaults.standard.set(self.tableSortDescriptor, forKey: "sortMethod")
			let nc = NotificationCenter.default
			nc.post(name: Notification.Name("sortdescriptorchanged"), object: nil, userInfo: nil)
		}
	}
}
