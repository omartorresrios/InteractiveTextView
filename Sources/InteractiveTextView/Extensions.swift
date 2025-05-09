//
//  Extensions.swift
//
//
//  Created by Omar Torres on 4/19/25.
//

import SwiftUI

internal extension Color {
	init?(hex: String) {
		var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

		var rgb: UInt64 = 0
		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 1.0

		let length = hexSanitized.count
		guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

		if length == 6 {
			r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
			g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
			b = CGFloat(rgb & 0x0000FF) / 255.0
		} else if length == 8 {
			r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
			g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
			b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
			a = CGFloat(rgb & 0x000000FF) / 255.0
		} else {
			return nil
		}

		self.init(red: r, green: g, blue: b, opacity: a)
	}
}

internal extension NSMutableAttributedString {
	func addCustomAttributes(regex: NSRegularExpression,
							 with text: String,
							 foregroundColor: NSColor) {
		let matches = regex.matches(in: text, 
									range: NSRange(location: 0,
												   length: text.count))
		for match in matches {
			addAttribute(.foregroundColor, value: foregroundColor, range: match.range)
		}
	}
}
