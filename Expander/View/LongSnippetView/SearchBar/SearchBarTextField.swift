//
//  SearchBarTextField.swift
//  Expander
//
//  Created by 陳奕利 on 2022/1/21.
//

import SwiftUI

struct SearchBarTextField: NSViewRepresentable {
	typealias NSViewType = NSView
	
	func makeNSView(context: Context) -> NSView {
		let view = NSVisualEffectView()
		view.material = .contentBackground
		view.blendingMode = .behindWindow
		view.wantsLayer = true
		view.state = .active
		view.layer?.cornerRadius = 7.5
		return view
	}
	
	func updateNSView(_ nsView: NSView, context: Context) {
	}
}
