//
//  DeleteKeyEvent.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/8.
//

import SwiftUI

extension NSEvent {
	var isDeleteKey: Bool {
		self.keyCode == 51
	}
}

