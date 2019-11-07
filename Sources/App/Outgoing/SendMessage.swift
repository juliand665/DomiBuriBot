import Vapor

struct SendableMessage: Codable {
	var chatID: Int // could also be string but fuck union types amirite
	var text: String
	
	var parseMode: ParseMode?
	var disableWebPagePreview: Bool?
	var disableNotification: Bool?
	var replyToMessageID: Int?
	// replyMarkup is a thing too
	
	enum CodingKeys: String, CodingKey {
		case chatID = "chat_id"
		case text
		
		case parseMode = "parse_mode"
		case disableWebPagePreview = "disable_web_page_preview"
		case disableNotification = "disable_notification"
		case replyToMessageID = "reply_to_message_id"
	}
	
	enum ParseMode: String, Codable {
		case markdown, html
	}
}

extension Client {
	func sendMessage(_ message: SendableMessage) throws -> Future<Response> {
		post(baseURL.appendingPathComponent("sendMessage")) { body in
			try body.content.encode(json: message)
		}
	}
	
	func sendMarkdownMessage(_ message: String, in chat: Telegram.Chat) throws -> Future<Response> {
		try sendMessage(SendableMessage(chatID: chat.id, text: message, parseMode: .markdown))
	}
}
