//
//  SingleTextView.swift
//  InteractiveTextViewDemo
//
//  Created by Omar Torres on 4/19/25.
//

import SwiftUI
import InteractiveTextView

private let markdownSample = """
# Email AI agent

This AI agent is a Python script that connects to a Gmail account via IMAP, fetches unread emails, and generates simple responses using a basic natural language processing approach with the nltk library. It scans the email content, identifies key phrases, and crafts a short, contextually relevant reply. The script is designed for **demo purposes**, so it prints the email details and suggested responses to the console rather than sending them. It uses environment variables for secure credential handling and requires the user to set up a Gmail App Password.
```python
import imaplib
import email
from email.header import decode_header
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
import os
from dotenv import load_dotenv

# Download NLTK data
nltk.download('punkt')
nltk.download('stopwords')

# Load environment variables
load_dotenv()
EMAIL = os.getenv('EMAIL')
PASSWORD = os.getenv('PASSWORD')  # Use Gmail App Password

def connect_to_email():
	mail = imaplib.IMAP4_SSL("imap.gmail.com")
	mail.login(EMAIL, PASSWORD)
	mail.select("inbox")
	return mail

def fetch_unread_emails(mail):
	_, message_numbers = mail.search(None, 'UNSEEN')
	emails = []
	for num in message_numbers[0].split():
		_, msg_data = mail.fetch(num, '(RFC822)')
		email_body = msg_data[0][1]
		msg = email.message_from_bytes(email_body)
		emails.append(msg)
	return emails

def decode_email_subject(subject):
	decoded_subject = decode_header(subject)[0][0]
	if isinstance(decoded_subject, bytes):
		return decoded_subject.decode()
	return decoded_subject

def get_email_body(msg):
	if msg.is_multipart():
		for part in msg.walk():
			if part.get_content_type() == "text/plain":
				return part.get_payload(decode=True).decode()
	else:
		return msg.get_payload(decode=True).decode()
	return ""

def generate_response(email_body):
	tokens = word_tokenize(email_body.lower())
	stop_words = set(stopwords.words('english'))
	keywords = [word for word in tokens if word.isalpha() and word not in stop_words]
	
	if any(keyword in keywords for keyword in ['meeting', 'schedule', 'call']):
		return "Thanks for your email! I'm available for a meeting. Please suggest a time."
	elif any(keyword in keywords for keyword in ['question', 'help', 'query']):
		return "Thanks for reaching out! Could you clarify your question so I can assist better?"
	else:
		return "Thank you for your email! I'll get back to you soon."

def main():
	mail = connect_to_email()
	unread_emails = fetch_unread_emails(mail)
	
	if not unread_emails:
		print("No unread emails found.")
		return
	
	for msg in unread_emails:
		subject = decode_email_subject(msg['subject'])
		sender = msg['from']
		body = get_email_body(msg)
		response = generate_response(body)
		
		print(f"Email from: {sender}")
		print(f"Subject: {subject}")
		print(f"Body: {body[:100]}...")  # Truncate for brevity
		print(f"Suggested Response: {response}")
	
	mail.logout()

if __name__ == "__main__":
	main()
```
To use this script:

1. Install dependencies: `pip install python-dotenv nltk`
2. Create a .env file with EMAIL=your_email@gmail.com and PASSWORD=your_app_password
3. Enable IMAP in Gmail settings and generate an App Password
4. Run the script: `python email_agent.py`
The script connects to Gmail, retrieves unread emails, extracts their content, and generates simple responses based on keywords like "meeting" or "question." It’s a minimal demo, so responses are basic and printed to the console. For production, **you’d need to enhance security**, add email sending functionality, and improve response generation with a more advanced NLP model.
"""

struct SingleTextView: View {
	@State private var markdownText = markdownSample
	@State private var highlightedText: String = ""
	@State private var buttonPosition: CGPoint = .zero
	@State private var height: CGFloat = 0
	
	private var width: CGFloat {
		(NSScreen.main?.visibleFrame.width ?? 0) / 2
	}
	
    var body: some View {
		VStack {
			InteractiveTextView(height: $height,
								highlightedText: $highlightedText,
								buttonPosition: $buttonPosition,
								text: markdownText,
								buttonText: "Explain",
								width: width,
								onButtonAction: { selectedText in
									print("Do something here with the selected text: \(selectedText)")
								})
			.frame(maxWidth: width, maxHeight: height)
			.padding(.vertical)
			.cornerRadius(8)
		}
    }
}

#Preview {
	SingleTextView()
}
