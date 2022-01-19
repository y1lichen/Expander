//
//  ToolBarItemView.swift
//  Expander
//
//  Created by 陳奕利 on 2022/1/19.
//

import SwiftUI

struct ToolBarItemView: View {
	let name: String
	let image: String
	let action: () -> Void
	@State private var isPressing: Bool = Bool()
	var body: some View {
		VStack(spacing: 2.0) {
					Image(systemName: image)
					Text(name)
				}
				.frame(width: 50)
				.background(Color.white.opacity(0.01))
				.padding(.horizontal, 5.0)
				.padding(.vertical, 2.0)
				.overlay(RoundedRectangle(cornerRadius: 5.0).stroke(Color.secondary.opacity(0.5), style: StrokeStyle(lineWidth: 1.0)))
				.opacity(isPressing ? 0.75 : 1.0)
				.scaleEffect(isPressing ? 0.95 : 1.0)
				.gesture(DragGesture(minimumDistance: .zero, coordinateSpace: .local).onChanged { _ in isPressing = true }.onEnded { _ in isPressing = false; action() })
				.animation(Animation.interactiveSpring(), value: isPressing)
	}
}

