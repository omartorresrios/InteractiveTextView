//
//  MultipleTextViews.swift
//  InteractiveTextViewDemo
//
//  Created by Omar Torres on 4/20/25.
//

import SwiftUI
import InteractiveTextView

private let messages = ["""
What’s the best way to learn Python in 2025?
""",
"""
In 2025, start with interactive platforms like Codecademy or freeCodeCamp for Python basics. Then, build projects like a web scraper or a simple game using libraries like BeautifulSoup or Pygame. Join communities on X for real-time tips and updates.
Here is a very simple Python code for you to understand:
```python
# Get the user's name
name = input("What is your name? ")

# Get the user's favorite number
favorite_number = int(input("What is your favorite number? "))

# Double the favorite number
doubled_number = favorite_number * 2

# Print a personalized message
print("Hello, " + name + "! Your favorite number is " + str(favorite_number) + ".")
print("Did you know that " + str(favorite_number) + " doubled is " + str(doubled_number) + "?")
```
""",
"""
Can you recommend 3 sci-fi books?
""",
"""
Here are 3 great sci-fi books for you:
- **Project Hail Mary** by Andy Weir: A gripping, science-heavy story about a lone astronaut on a mission to save Earth.
- **Dune** by Frank Herbert: A classic tale of politics, religion, and survival on the desert planet of Arrakis.
- **The Three-Body Problem** by Liu Cixin: A mind-bending story about humanity's first contact with an alien civilization.
""",
"""
How do I make a quick healthy breakfast?
""",
"""
Here’s how to make a quick healthy breakfast smoothie in 4 steps:
1. Gather your ingredients: spinach, banana, protein powder, and almond milk.
2. Add 1 cup of spinach, 1 banana, 1 scoop of protein powder, and 1 cup of almond milk to a blender.
3. Blend everything on high speed for 30 seconds until smooth.
4. Pour into a glass and enjoy—it takes just 5 minutes and is nutrient-packed!
""",
"""
What’s the weather like on Mars today?
""",
"""
Mars weather varies, but expect around -80°F (-62°C) near the equator, with dust storms possible. Check NASA’s InSight data on X for real-time updates.
"""]

struct MultipleTextViews: View {
	@State private var highlightedText: String = ""
	@State private var buttonPosition: CGPoint = .zero
	@State private var heights: [String: CGFloat] = [:]
	@Environment(\.colorScheme) var colorScheme
	
	private var width: CGFloat {
		(NSScreen.main?.visibleFrame.width ?? 800) / 2
	}
	
	private var backgroundColor: Color {
		colorScheme == .dark ? .black.opacity(0.5) : .gray.opacity(0.3)
	}
	
	var body: some View {
		ScrollView {
			LazyVStack(alignment: .center, spacing: 8) {
				ForEach(messages, id: \.self) { message in
					InteractiveTextView(
						height: Binding(
							get: { heights[message, default: 50] },
							set: { heights[message] = $0 }
						),
						highlightedText: $highlightedText,
						buttonPosition: $buttonPosition,
						text: message,
						width: width
					)
					.frame(minHeight: heights[message, default: 50])
					.frame(maxWidth: width, alignment: .center)
					.padding(.vertical)
					.background(backgroundColor)
					.cornerRadius(8)
				}
			}
		}
		.frame(width: width)
		.padding()
		.frame(maxWidth: .infinity)
	}
}

#Preview {
    MultipleTextViews()
}
