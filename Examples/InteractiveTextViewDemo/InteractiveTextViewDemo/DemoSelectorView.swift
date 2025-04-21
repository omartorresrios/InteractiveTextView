//
//  DemoSelectorView.swift
//  InteractiveTextViewDemo
//
//  Created by Omar Torres on 4/20/25.
//

import SwiftUI

private enum TextViewType {
	case single
	case multiple
}

struct DemoSelectorView: View {
	@State private var selectedDemo: TextViewType = .multiple
	
	private var width: CGFloat {
		(NSScreen.main?.visibleFrame.width ?? 0) / 2
	}
	
	var body: some View {
		VStack {
			HStack(spacing: 10) {
				Button(action: {
					selectedDemo = .single
				}) {
					Text("Single TextView")
						.padding()
						.background(selectedDemo == .single ? Color.blue : Color.gray)
						.foregroundColor(.white)
						.cornerRadius(8)
				}
				.buttonStyle(.plain)
				
				Button(action: {
					selectedDemo = .multiple
				}) {
					Text("Multiple TextViews")
						.padding()
						.background(selectedDemo == .multiple ? Color.blue : Color.gray)
						.foregroundColor(.white)
						.cornerRadius(8)
				}
				.buttonStyle(.plain)
			}
			.padding()
			
			switch selectedDemo {
			case .single:
				SingleTextView()
			case .multiple:
				MultipleTextViews()
			}
		}
		.frame(width: width)
	}
}

#Preview {
	DemoSelectorView()
}
