//
//  GetIPaddress.swift
//  Expander
//
//  Created by 陳奕利 on 2021/9/22.
//

import Foundation

class IPAdress: ObservableObject {
	@Published var internalIP: String = "--"
	@Published var externalIP: String = "--"
	func updateIP() {
		// external IP
		let address = try? String(contentsOf: URL(string: "https://api.ipify.org")!, encoding: .utf8)
		// internal IP
		let process = Process()
		process.launchPath = "/usr/sbin/ipconfig"
		process.arguments = ["getifaddr", "en0"]

		let pipe = Pipe()
		process.standardOutput = pipe
		process.standardError = pipe
		process.launch()

		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		//
		let lip = String(data: data, encoding: .utf8) ?? ""
		self.externalIP = address ?? "--"
		self.internalIP = lip
	}
}
