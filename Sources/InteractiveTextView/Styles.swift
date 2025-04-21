//
//  Styles.swift
//
//
//  Created by Omar Torres on 4/19/25.
//

import SwiftUI

internal struct ThemeColors {
	// Code block colors
	static let codeKeywordTextColor = NSColor(Color(hex: "a626a4")!)
	static let codeMethodTextColor = NSColor(Color(hex: "4078f2")!)
	static let codeTypeTextColor = NSColor(Color(hex: "b76b01")!)
	static let codeCommentTextColor = NSColor(Color(hex: "a0a1a7")!)
	static let codeStringTextColor = NSColor(Color(hex: "50a14f")!)
	static let programmingLanguageTextColor = NSColor(Color(hex: "73726c")!)
	
	struct Light {
		// Background colors
		static let codeLightBackgroundColor = Color(hex: "FFFFFF")!
		static let codeWordBackgroundColor = NSColor(Color(hex: "db855726")!)
		static let selectedTextBackgroundColor = NSColor.selectedTextBackgroundColor
		
		// Foreground colors
		static let textLightForegroundColor = NSColor(Color(hex: "0A0A0A")!)
		static let codeWordLightForegroundColor = NSColor(Color(hex: "9e3f00")!)
		static let defaultCodeLightTextColor = NSColor(Color(hex: "383a42")!)
	}
	
	struct Dark {
		// Background colors
		static let codeDarkBackgroundColor = Color(hex: "1a1b1e")!
		
		// Foreground colors
		static let codeWordDarkForegroundColor = NSColor(Color(hex: "e86b6b")!)
		static let textDarkForegroundColor = NSColor(Color(hex: "f9f8f6e6")!)
		static let defaultCodeDarkTextColor = NSColor(Color(hex: "abb2bf")!)
	}
}

internal struct Fonts {
	static let isInlineCode = "isInlineCode"
	static let textFont = NSFont(name: "OpenSans-Regular", size: 15)
	static let codeFont = NSFont(name: "FiraCode-Regular", size: 14)
	static let header1Font = NSFont(name: "OpenSansRoman-Bold", size: 22)
	static let header2Font = NSFont(name: "OpenSansRoman-SemiBold", size: 20)
	static let header3Font = NSFont(name: "OpenSansRoman-SemiBold", size: 18)
	static let codeLanguageKeywordFont = NSFont(name: "FiraCode-Regular", size: 13)
	static let boldTextFont = NSFont(name: "OpenSansRoman-Bold", size: 15)
}
