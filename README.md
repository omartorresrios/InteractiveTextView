# InteractiveTextView

A SwiftUI view for macOS that renders markdown text with selectable text blocks. Built for displaying markdown content with interactive features, such as highlighting selected text and positioning an actionable button at the selection's bounding rectangle.
`InteractiveTextView` was originally developed for a macOS LLM chat interface, where markdown rendering and text selection were critical for displaying conversations and enabling user interactions. Now, it’s available as a Swift package for any macOS app that needs to render markdown—whether in a single view or as part of a chat-like conversation list.

## Features
- **Markdown Rendering**: Supports basic markdown syntax, including headers, lists, inline code, bold text, and code blocks with syntax highlighting.
- **Text Selection**: Allows users to select text blocks, with the selected text and its bounding rectangle position exposed for custom actions.
- **Dynamic Layout**: Automatically adjusts height based on content, perfect for use in scrollable views like chat interfaces.
- **Theming Support**: Adapts to light and dark modes using SwiftUI’s `colorScheme` environment.
- **Customizable**: Easily integrate into your SwiftUI app with configurable width and bindings for height, selected text, and button position.

## Installation
Add `InteractiveTextView` to your project using Swift Package Manager.

1. In Xcode, go to `File > Add Packages...`.
2. Enter the repository URL:  https://github.com/omartorresrios/InteractiveTextView.git
3. Specify the version or branch you want to use, then click `Add Package`.

## Usage
### Use Case: Single standalone TextView
Here’s how to use `InteractiveTextView` in your SwiftUI app:
<img width="969" alt="Screenshot 2025-04-21 at 11 03 50 PM" src="https://github.com/user-attachments/assets/cd954796-ef04-43c7-af6d-e1a284cbd37d" />

### Use Case: Chat Interface
For a chat-like interface with multiple messages, you can use `InteractiveTextView` inside a `ScrollView`:
<img width="777" alt="Screenshot 2025-04-21 at 11 04 45 PM" src="https://github.com/user-attachments/assets/311b8693-9ec0-4d51-85c1-a506ddd72b52" />

## Demos
You can look at the demos inside the Example folder and start tinkering! Here are some screenshots:

### Single TextView
https://github.com/user-attachments/assets/cdb2a6cf-958d-4ea6-9ac7-86811b575ea6

### Chat Interface (multile TextViews)
https://github.com/user-attachments/assets/365eb98d-0aec-47be-bd1d-2f89e63774fe

### Dark Mode
**Only text**

<img width="626" alt="Screenshot 2025-04-21 at 7 58 02 PM" src="https://github.com/user-attachments/assets/0e730389-161b-4a17-aae7-ba24453fdb6f" />


**Only code**

<img width="632" alt="Screenshot 2025-04-21 at 7 57 32 PM" src="https://github.com/user-attachments/assets/4ea3e12b-f1b1-40f6-a2c3-bd516b762141" />


**Text and code**

<img width="923" alt="Screenshot 2025-04-21 at 7 58 25 PM" src="https://github.com/user-attachments/assets/b0dab916-ffa9-4707-bc4b-4d4ebd5acc3c" />

### Actionable button
One of the coolest features is that you can highlight text, retrieve its value, and perform actions with by clicking a button.
<img width="266" alt="Screenshot 2025-04-21 at 8 02 20 PM" src="https://github.com/user-attachments/assets/739f7474-0623-4cee-b5d4-6f20b6bac25c" />

## Requirements
- macOS 12.0 or later
- Swift 5.5 or later
- Xcode 13 or later

## What's coming
There are a lot of cool stuff I want to add, such as:
- Customize the actionable button (font, text color, backgrond color).
- Custom fonts, text and background colors.
- Create some default palette colors.
- Expand/collapse `InteractiveTextView`
- And more!

Also, if you have more ideas, please hit me up, and we’ll chat about how we can make it even more powerful!

## Contributing
Contributions are welcome! If you’d like to improve `InteractiveTextView`, please:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

## License
`InteractiveTextView` is available under the MIT License. See the LICENSE file for more details.
