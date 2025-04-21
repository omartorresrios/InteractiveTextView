//
//  CustomLayoutManager.swift
//
//
//  Created by Omar Torres on 4/19/25.
//

import AppKit

internal final class CustomLayoutManager: NSLayoutManager {
	private let selectionColor: NSColor
	
	init(selectionColor: NSColor) {
		self.selectionColor = selectionColor
		super.init()
	}
	
	required init?(coder: NSCoder) {
		self.selectionColor = .selectedTextBackgroundColor
		super.init(coder: coder)
	}
	
	override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: NSPoint) {
		guard let textStorage = textStorage,
			  let textContainer = textContainers.first else {
			super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
			return
		}
		
		// Get the selection range
		guard let textView = textContainer.textView,
			  textView.selectedRange().length > 0 else {
			super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
			return
		}
		
		// Convert the character selection range to glyph range
		let selectedRange = textView.selectedRange()
		let glyphRange = glyphRange(forCharacterRange: selectedRange, actualCharacterRange: nil)
		
		// Only proceed if the selected glyphs intersect with the glyphs we're being asked to draw
		guard NSIntersectionRange(glyphRange, glyphsToShow).length > 0 else {
			super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
			return
		}
		
		// Call super to handle any non-selection background drawing
		super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
		
		// Enumerate line fragments in the selection
		enumerateLineFragments(forGlyphRange: NSIntersectionRange(glyphRange,
																  glyphsToShow)) { [weak self] (_,
																								_,
																								textContainer,
																								lineGlyphRange,
																								_) in
			guard let self = self else { return }
			// Get the character range for this line fragment
			let lineCharRange = self.characterRange(forGlyphRange: lineGlyphRange,
													 actualGlyphRange: nil)
			
			// Calculate the intersection of this line's character range with the selection
			let intersectionRange = NSIntersectionRange(lineCharRange, selectedRange)
			if intersectionRange.length > 0 {
				// Convert back to glyph range for rendering
				let intersectionGlyphRange = self.glyphRange(forCharacterRange: intersectionRange,
															 actualCharacterRange: nil)
				
				guard let font = textStorage.attribute(.font,
													   at: intersectionRange.location,
													   effectiveRange: nil) as? NSFont else { return }
				
				// Get the bounding rect for the selection in this line
				let selectionRect = self.boundingRect(forGlyphRange: intersectionGlyphRange,
													  in: textContainer)
				
				// Calculate the text height based on the font
				let textHeight = font.ascender - font.descender
				
				// Create adjusted rectangle that centers around just the text (not the added line spacing)
				let adjustedRect = NSRect(x: selectionRect.origin.x + origin.x,
										  y: selectionRect.origin.y,
										  width: selectionRect.width,
										  height: textHeight)
				
				selectionColor.setFill()
				let path = NSBezierPath(rect: adjustedRect)
				path.fill()
			}
		}
	}
}
