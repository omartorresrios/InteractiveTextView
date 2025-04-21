//
//  InteractiveTextView.swift
//
//
//  Created by Omar Torres on 4/19/25.
//

import AppKit
import SwiftUI

/// A SwiftUI view that renders markdown text with selectable text blocks.
/// Supports highlighting selected text and positioning an actionable button at the selection's bounding rectangle.
public struct InteractiveTextView: NSViewRepresentable {
	@Binding public var height: CGFloat
	@Binding public var highlightedText: String
	@Binding public var buttonPosition: CGPoint
	public let text: String
	public var width: CGFloat
	@Environment(\.colorScheme) var colorScheme
	
	private var isDarkMode: Bool {
		colorScheme == .dark
	}
	
	public init(
		height: Binding<CGFloat>,
		highlightedText: Binding<String>,
		buttonPosition: Binding<CGPoint>,
		text: String,
		width: CGFloat
	) {
		self._height = height
		self._highlightedText = highlightedText
		self._buttonPosition = buttonPosition
		self.text = text
		self.width = width
	}
	
	public class Coordinator: NSObject, NSTextViewDelegate {
		var parent: InteractiveTextView
		var textViewBlockTypes: [NSTextView: MarkdownBlockType]
		var previousText: String
		
		enum MarkdownBlockType {
			case text
			case code
		}
		
		init(_ parent: InteractiveTextView) {
			self.parent = parent
			self.previousText = parent.text
			self.textViewBlockTypes = [:]
		}
		
		public func textViewDidChangeSelection(_ notification: Notification) {
			guard let textView = notification.object as? NSTextView else { return }
			
			let selectedRange = textView.selectedRange()
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				if selectedRange.length > 0 {
					let selectedText = (textView.string as NSString).substring(with: selectedRange).trimmingCharacters(in: .whitespacesAndNewlines)
					guard !selectedText.isEmpty else {
						self.parent.highlightedText = ""
						return
					}
					
					if let layoutManager = textView.layoutManager,
					   let textContainer = textView.textContainer {
						let glyphRange = layoutManager.glyphRange(forCharacterRange: selectedRange, 
																  actualCharacterRange: nil)
						let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, 
																	  in: textContainer)
						let containerOrigin = textView.textContainerOrigin
						
						self.parent.highlightedText = selectedText
						self.parent.buttonPosition = CGPoint(x: containerOrigin.x + boundingRect.maxX,
															 y: containerOrigin.y + boundingRect.minY)
					}
				} else {
					self.parent.highlightedText = ""
				}
			}
		}
	}
	
	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public func makeNSView(context: Context) -> NSScrollView {
		let scrollView = NSScrollView()
		scrollView.hasVerticalScroller = true
		scrollView.hasHorizontalScroller = false
		scrollView.drawsBackground = false
		scrollView.borderType = .noBorder
		scrollView.autohidesScrollers = true
		scrollView.verticalScrollElasticity = .allowed
		
		let containerView = NSView()
		containerView.translatesAutoresizingMaskIntoConstraints = false

		let stackView = NSStackView()
		stackView.orientation = .vertical
		stackView.spacing = 8
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		containerView.addSubview(stackView)
		scrollView.documentView = containerView
		
		let padding: CGFloat = 16
		
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
			stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
			stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			stackView.widthAnchor.constraint(equalToConstant: width - 2 * padding)
		])
		
		updateStackView(stackView, with: text, coordinator: context.coordinator)
		
		return scrollView
	}
	
	public func updateNSView(_ scrollView: NSScrollView, context: Context) {
		guard let containerView = scrollView.documentView,
			  let stackView = containerView.subviews.first as? NSStackView else { return }
		
		if context.coordinator.previousText != text {
			updateStackView(stackView, with: text, coordinator: context.coordinator)
			context.coordinator.previousText = text
		}
		
		DispatchQueue.main.async {
			let contentHeight = max(stackView.fittingSize.height, 1)
			stackView.frame = NSRect(x: 0, y: 0, width: width, height: contentHeight)
			containerView.frame = NSRect(x: 0, y: 0, width: width, height: contentHeight)
			scrollView.documentView?.frame = NSRect(x: 0, y: 0, width: width, height: contentHeight)
			
			height = contentHeight
			
			let visibleHeight = scrollView.contentView.bounds.height
			let topY = max(0, contentHeight - visibleHeight)
			scrollView.contentView.scroll(to: NSPoint(x: 0, y: topY))
			scrollView.reflectScrolledClipView(scrollView.contentView)
			
			scrollView.layoutSubtreeIfNeeded()
		}
	}
	
	// MARK: - Stack View Updates
	private func updateStackView(_ stackView: NSStackView,
								 with text: String,
								 coordinator: Coordinator) {
		let blocks = parseMarkdownBlocks(from: text)
		let existingTextViews = stackView.arrangedSubviews.compactMap { $0 as? NSTextView }
		
		while stackView.arrangedSubviews.count > blocks.count {
		   if let view = stackView.arrangedSubviews.last as? NSTextView {
			   coordinator.textViewBlockTypes.removeValue(forKey: view)
			   view.removeFromSuperview()
		   }
		}
		
		for (index, block) in blocks.enumerated() {
			let blockType: Coordinator.MarkdownBlockType = block.isCode ? .code : .text
			let textView: NSTextView
			
			if index < existingTextViews.count,
			   coordinator.textViewBlockTypes[existingTextViews[index]] == blockType {
				textView = existingTextViews[index]
			} else {
				textView = blockTextView(block, coordinator: coordinator)
				coordinator.textViewBlockTypes[textView] = blockType
				stackView.addArrangedSubview(textView)
			}
			
			switch block {
			case .text(let content):
				let attributedString = applyTextStyles(to: content)
				textView.textStorage?.setAttributedString(attributedString)
			case .code(let content):
				let attributedString = applyCodeStyles(to: content)
				textView.textStorage?.setAttributedString(attributedString)
			}
			
			guard let textContainer = textView.textContainer else { continue }
			let padding: CGFloat = 16
			let stackViewWidth = width - 2 * padding
			let insetWidth = textView.textContainerInset.width * 2
			textContainer.containerSize = NSSize(width: stackViewWidth - insetWidth, height: .greatestFiniteMagnitude)
			textView.layoutManager?.ensureLayout(for: textContainer)
			
			guard let glyphRange = textView.layoutManager?.glyphRange(for: textContainer) else { continue }
			let usedRect = textView.layoutManager?.boundingRect(forGlyphRange: glyphRange, in: textContainer) ?? .zero
			let totalHeight = ceil(usedRect.height + textView.textContainerInset.height * 2)
			
			textView.constraints.forEach { textView.removeConstraint($0) }
			NSLayoutConstraint.activate([
				textView.widthAnchor.constraint(equalToConstant: stackViewWidth),
				textView.heightAnchor.constraint(equalToConstant: totalHeight),
				textView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
				textView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
			])
		}
		
		DispatchQueue.main.async {
			height = stackView.fittingSize.height
		}
	}
	
	// MARK: - Markdown Parsing
	private func parseMarkdownBlocks(from text: String) -> [MarkdownBlock] {
		var blocks: [MarkdownBlock] = []
		var current = ""
		var inCodeBlock = false

		for line in text.components(separatedBy: .newlines) {
			if line.starts(with: "```") {
				if inCodeBlock {
					blocks.append(.code(current.trimmingCharacters(in: .whitespacesAndNewlines)))
					current = ""
					inCodeBlock = false
				} else {
					if !current.isEmpty {
						blocks.append(.text(current.trimmingCharacters(in: .whitespacesAndNewlines)))
						current = ""
					}
					inCodeBlock = true
				}
			} else {
				current += line + "\n"
			}
		}

		if !current.isEmpty {
			blocks.append(.text(current.trimmingCharacters(in: .whitespacesAndNewlines)))
		}

		return blocks
	}
	
	// MARK: - Text View Creation
	private func blockTextView(_ type: MarkdownBlock, coordinator: Coordinator) -> NSTextView {
		let textView: NSTextView
		
		switch type {
		case .text:
			textView = RoundedTextView(codeBackgroundColor: ThemeColors.Light.codeWordBackgroundColor,
									   selectionColor: ThemeColors.Light.selectedTextBackgroundColor,
									   frame: .zero,
									   textContainer: nil)
			textView.wantsLayer = true
			textView.selectedTextAttributes = [NSAttributedString.Key.foregroundColor: NSColor.white]
			textView.layer?.backgroundColor = NSColor.clear.cgColor
		case .code:
			textView = NSTextView()
			textView.wantsLayer = true
			let backgroundColor = isDarkMode ? ThemeColors.Dark.codeDarkBackgroundColor : ThemeColors.Light.codeLightBackgroundColor
			textView.layer?.backgroundColor = backgroundColor.cgColor
			textView.layer?.cornerRadius = 6
			textView.layer?.masksToBounds = true
			textView.textContainerInset = NSSize(width: 4, height: 8)
		}
		textView.delegate = coordinator
		textView.drawsBackground = false
		textView.isEditable = false
		textView.isSelectable = true
		textView.textContainer?.widthTracksTextView = true
		textView.isVerticallyResizable = true
		textView.isHorizontallyResizable = false
		textView.translatesAutoresizingMaskIntoConstraints = false
		
		return textView
	}
	
	// MARK: - Text Styling
	func applyTextStyles(to text: String) -> NSAttributedString {
		let attributedString = NSMutableAttributedString()
		let foregroundColor = isDarkMode ? ThemeColors.Dark.textDarkForegroundColor : ThemeColors.Light.textLightForegroundColor
		let lines = text.split(separator: "\n", omittingEmptySubsequences: false)

		for (index, line) in lines.enumerated() {
			let isLastLine = index == lines.count - 1
			let lineStr = String(line)

			// Preserve empty lines
			if lineStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				if !isLastLine {
					attributedString.append(NSAttributedString(string: "\n"))
				}
				continue
			}

			let trimmedLine = lineStr.trimmingCharacters(in: .whitespaces)
			var processedLine: NSMutableAttributedString

			if trimmedLine.starts(with: "### ") {
				let content = String(trimmedLine.dropFirst(4))
				processedLine = NSMutableAttributedString(
					string: content,
					attributes: [.font: Fonts.header3Font!, .foregroundColor: foregroundColor]
				)
			} else if trimmedLine.starts(with: "## ") {
				let content = String(trimmedLine.dropFirst(3))
				processedLine = NSMutableAttributedString(
					string: content,
					attributes: [.font: Fonts.header2Font!, .foregroundColor: foregroundColor]
				)
			} else if trimmedLine.starts(with: "# ") {
				let content = String(trimmedLine.dropFirst(2))
				processedLine = NSMutableAttributedString(
					string: content,
					attributes: [.font: Fonts.header1Font!, .foregroundColor: foregroundColor]
				)
			} else if trimmedLine.starts(with: "- ") ||
						trimmedLine.starts(with: "* ") ||
						trimmedLine.starts(with: "+ ") {
				let bulletContent = String(trimmedLine.dropFirst(2))
				let styled = applyInlineStylesToLine(bulletContent)
				processedLine = NSMutableAttributedString(string: "• ")
				let fullRange = NSRange(location: 0, length: processedLine.length)
				processedLine.addAttribute(.foregroundColor, value: foregroundColor, range: fullRange)
				processedLine.append(styled)
			} else {
				processedLine = NSMutableAttributedString(attributedString: applyInlineStylesToLine(lineStr))
			}

			if !isLastLine {
				processedLine.append(NSAttributedString(string: "\n"))
			}
			attributedString.append(processedLine)
		}

		return attributedString
	}
	
	private func applyInlineStylesToLine(_ text: String) -> NSAttributedString {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 8
		
		let foregroundColor = isDarkMode ? ThemeColors.Dark.textDarkForegroundColor : ThemeColors.Light.textLightForegroundColor
		let attributedString = NSMutableAttributedString(string: text,
														 attributes: [.font: Fonts.textFont!,
																	  .foregroundColor: foregroundColor,
																	  .paragraphStyle: paragraphStyle])

		// Inline code using backticks
		let codePattern = "`([^`]+)`"
		if let regex = try? NSRegularExpression(pattern: codePattern) {
			let nsRange = NSRange(text.startIndex..., in: text)
			let matches = regex.matches(in: text, range: nsRange)

			for match in matches.reversed() {
				let fullRange = match.range
				let codeRange = match.range(at: 1)
				let codeText = (text as NSString).substring(with: codeRange)

				let codeAttributedString = NSMutableAttributedString()
				let codeWordForeground = isDarkMode ? ThemeColors.Dark.codeWordDarkForegroundColor : ThemeColors.Light.codeWordLightForegroundColor
				
				let leftPadding = NSAttributedString(
					string: "\u{2002}",
					attributes: [
						.font: Fonts.textFont!,
						.foregroundColor: codeWordForeground,
						.init(rawValue: Fonts.isInlineCode): true
					]
				)

				let codePartAttributes: [NSAttributedString.Key: Any] = [
					.font: Fonts.textFont!,
					.foregroundColor: codeWordForeground,
					.init(rawValue: Fonts.isInlineCode): true
				]
				let codePart = NSAttributedString(string: codeText, attributes: codePartAttributes)

				let rightPadding = NSAttributedString(
					string: "\u{2002}",
					attributes: [
						.font: Fonts.textFont!,
						.foregroundColor: codeWordForeground,
						.init(rawValue: Fonts.isInlineCode): true
					]
				)

				codeAttributedString.append(leftPadding)
				codeAttributedString.append(codePart)
				codeAttributedString.append(rightPadding)

				attributedString.replaceCharacters(in: fullRange, with: codeAttributedString)
			}
		}

		// Bold text using double asterisks
		let boldPattern = "\\*\\*(.*?)\\*\\*"
		if let regex = try? NSRegularExpression(pattern: boldPattern) {
			let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
			for match in matches.reversed() {
				let fullRange = match.range
				let capturedRange = match.range(at: 1)
				let boldText = (text as NSString).substring(with: capturedRange)
				let boldAttributedString = NSAttributedString(
					string: boldText,
					attributes: [.font: Fonts.boldTextFont!, .foregroundColor: foregroundColor]
				)
				attributedString.replaceCharacters(in: fullRange, with: boldAttributedString)
			}
		}

		return attributedString
	}
	
	private func applyCodeStyles(to text: String) -> NSAttributedString {
		let styledCode = NSMutableAttributedString(string: text)
		let foregroundColor = isDarkMode ? ThemeColors.Dark.defaultCodeDarkTextColor : ThemeColors.Light.defaultCodeLightTextColor
		styledCode.addAttributes([
			.font: Fonts.codeFont!,
			.foregroundColor: foregroundColor,
		], range: NSRange(location: 0, length: styledCode.length))
		
		// Programming language identifier pattern (word at the start, followed by newline)
		let languagePattern = "^[a-zA-Z]+\\b(?=\\n)"
		if let languageRegex = try? NSRegularExpression(pattern: languagePattern, options: [.anchorsMatchLines]) {
			let languageMatches = languageRegex.matches(in: text, range: NSRange(location: 0, length: text.count))
			for languageMatch in languageMatches {
				styledCode.addAttributes([.foregroundColor: ThemeColors.programmingLanguageTextColor,
										  .font: Fonts.codeLanguageKeywordFont!],
										 range: languageMatch.range)
			}
		}
		
		let keywordPattern = "\\b(let|var|if|else|guard|switch|case|default|for|while|repeat|in|func|return|class|struct|enum|protocol|extension|import|public|private|internal|fileprivate|static|final|override|mutating|throws|throw|try|catch|as|is|init|self|super|nil|true|false|associatedtype|typealias|where|break|continue|defer|def)\\b"
		if let keywordRegex = try? NSRegularExpression(pattern: keywordPattern) {
			styledCode.addCustomAttributes(regex: keywordRegex,
										   with: text,
										   foregroundColor: ThemeColors.codeKeywordTextColor)
		}
		
		let methodPattern = "\\b[a-z][a-zA-Z0-9_]*(?=\\s*\\()"
		if let methodRegex = try? NSRegularExpression(pattern: methodPattern) {
			styledCode.addCustomAttributes(regex: methodRegex,
										   with: text,
										   foregroundColor: ThemeColors.codeMethodTextColor)
		}
		
		// Type or class names
		let typePattern = "\\b[A-Z][a-zA-Z0-9_]*\\b"
		if let typeRegex = try? NSRegularExpression(pattern: typePattern) {
			styledCode.addCustomAttributes(regex: typeRegex,
										   with: text,
										   foregroundColor: ThemeColors.codeTypeTextColor)
		}
		
		let numberPattern = "\\b\\d+(\\.\\d+)?\\b"
		if let numberRegex = try? NSRegularExpression(pattern: numberPattern) {
			styledCode.addCustomAttributes(regex: numberRegex,
										   with: text,
										   foregroundColor: ThemeColors.codeTypeTextColor)
		}
		
		let stringPattern = "\"[^\"]*\""
		if let stringRegex = try? NSRegularExpression(pattern: stringPattern) {
			styledCode.addCustomAttributes(regex: stringRegex,
										   with: text,
										   foregroundColor: ThemeColors.codeStringTextColor)
		}
		
		let commentPatterns = ["(?<!:)//.*$", "/\\*[\\s\\S]*?\\*/", "#.*$"]
		for pattern in commentPatterns {
			if let commentRegex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines) {
				styledCode.addCustomAttributes(regex: commentRegex,
											   with: text,
											   foregroundColor: ThemeColors.codeCommentTextColor)
			}
		}
		
		return styledCode
	}
	
	// MARK: - Markdown Block
	private enum MarkdownBlock {
		case text(String)
		case code(String)
		
		var isCode: Bool {
			switch self {
			case .code: return true
			case .text: return false
			}
		}
	}
}
