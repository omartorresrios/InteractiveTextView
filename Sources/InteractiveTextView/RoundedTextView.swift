//
//  RoundedTextView.swift
//  
//
//  Created by Omar Torres on 4/19/25.
//

import AppKit

internal final class RoundedTextView: NSTextView {
	private let codeBackgroundColor: NSColor
	
	convenience init(codeBackgroundColor: NSColor,
					 selectionColor: NSColor,
					 frame: NSRect = .zero,
					 textContainer: NSTextContainer? = nil) {
		self.init(frame: frame,
				  textContainer: textContainer,
				  codeBackgroundColor: codeBackgroundColor,
				  selectionColor: selectionColor)
	}

	init(frame frameRect: NSRect,
		 textContainer container: NSTextContainer?,
		 codeBackgroundColor: NSColor,
		 selectionColor: NSColor) {
		self.codeBackgroundColor = codeBackgroundColor
		let layoutManager = CustomLayoutManager(selectionColor: selectionColor)
		let textStorage = NSTextStorage()
		textStorage.addLayoutManager(layoutManager)
		let textContainer = container ?? NSTextContainer()
		layoutManager.addTextContainer(textContainer)
		
		super.init(frame: frameRect, textContainer: textContainer)
	}

	required init?(coder: NSCoder) {
		self.codeBackgroundColor = .clear
		super.init(coder: coder)
	}

	override func drawBackground(in rect: NSRect) {
		super.drawBackground(in: rect)

		guard let layoutManager = layoutManager, let textStorage = textStorage else { return }

		textStorage.enumerateAttribute(.init(rawValue: Fonts.isInlineCode),
									   in: NSRange(location: 0, length: textStorage.length),
									   options: []) { (value, range, _) in
			guard value as? Bool == true else { return }

			let glyphRange = layoutManager.glyphRange(forCharacterRange: range,
													  actualCharacterRange: nil)

			// Enumerate line fragments for the glyph range to handle preceding text correctly
			layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { [weak self] (_,
																			   _,
																			   textContainer,
																			   lineGlyphRange, _) in
				guard let self = self else { return }
				
				// Get the intersection of the line's glyph range with the inline code glyph range
				let intersectionGlyphRange = NSIntersectionRange(lineGlyphRange, glyphRange)
				guard intersectionGlyphRange.length > 0 else { return }

				// Get the bounding rect for the intersection glyph range
				let boundingRect = layoutManager.boundingRect(forGlyphRange: intersectionGlyphRange, 
															  in: textContainer)
				
				// Adjust the bounding rect by the text container's origin
				let adjustedRect = boundingRect.offsetBy(dx: self.textContainerOrigin.x,
														 dy: self.textContainerOrigin.y)

				guard let font = textStorage.attribute(.font, 
													   at: range.location,
													   effectiveRange: nil) as? NSFont else { return }
				let textHeight = font.ascender - font.descender
				
				let finalRect = NSRect(x: adjustedRect.origin.x,
									   y: adjustedRect.origin.y,
									   width: adjustedRect.width,
									   height: textHeight)
				
				let paddedRect = finalRect.insetBy(dx: 0, dy: 0)
				let path = NSBezierPath(roundedRect: paddedRect, xRadius: 4, yRadius: 4)
				self.codeBackgroundColor.setFill()
				path.fill()
			}
		}
	}

	override func draw(_ dirtyRect: NSRect) {
		drawBackground(in: dirtyRect)
		super.draw(dirtyRect)
	}
}
