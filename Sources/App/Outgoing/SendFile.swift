import Vapor

struct SendDocument: Codable {
	var chatID: ID<Chat> // could also be string but fuck union types amirite
	var document: String
	
	var caption: String?
	
	enum CodingKeys: String, CodingKey {
		case chatID = "chat_id"
		case document
	}
}

extension Client {
	func sendDocument(_ document: SendDocument) throws -> Future<Response> {
		post(baseURL.appendingPathComponent("sendDocument")) { body in
			try body.content.encode(json: document)
		}
	}
	
	func sendDocument(id: String, in chat: Chat) throws -> Future<Response> {
		try sendDocument(SendDocument(chatID: chat.id, document: id))
	}
}
