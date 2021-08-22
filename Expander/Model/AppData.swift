//
//  AppData.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/9.
//

import Foundation



class AppData: ObservableObject {
	let nc = NotificationCenter.default
	@Published var preferencesView: Int = 0
	@Published var tableSortDescriptor: String = UserDefaults.standard.string(forKey: "sortMethod")! {
		didSet {
			UserDefaults.standard.set(self.tableSortDescriptor, forKey: "sortMethod")
			nc.post(name: Notification.Name("sortdescriptorchanged"), object: nil, userInfo: nil)
		}
	}
}
