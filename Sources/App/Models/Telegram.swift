import Foundation

// various pieces of data the telegram api gives us

struct Update: APIObject {
	/// The update‘s unique identifier. Update identifiers start from a certain positive number and increase sequentially. This ID becomes especially handy if you’re using Webhooks, since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order. If there are no new updates for at least a week, then identifier of the next update will be chosen randomly instead of sequentially.
	var id: ID<Update>
	
	var message: Message?
	var editedMessage: Message?
	// there's a bunch more but i don't need them rn: https://core.telegram.org/bots/api#update
	
	enum CodingKeys: String, CodingKey {
		case id = "update_id"
		
		case message
		case editedMessage = "edited_message"
	}
	
	enum Kind: String, Codable {
		case message
		case editedMessage = "edited_message"
	}
}

struct Message: APIObject {
	var id: ID<Message>
	var date: Date // unix timestamp
	var chat: Chat
	
	var text: String?
	var sticker: Sticker?
	
	enum CodingKeys: String, CodingKey {
		case id = "message_id"
		case date
		case chat
		
		case text
		case sticker
	}
}

struct Chat: APIObject {
	var id: ID<Chat>
	var type: Kind
	
	var username: String?
	var firstName: String?
	var lastName: String?
	
	enum CodingKeys: String, CodingKey {
		case id
		case type
		
		case username
		case firstName = "first_name"
		case lastName = "last_name"
	}
	
	enum Kind: String, Codable {
		case `private`, group, supergroup, channel
	}
}

struct Sticker: APIObject {
	var id: ID<Sticker>
	
	var emoji: String
	var setName: String
	
	enum CodingKeys: String, CodingKey {
		case id = "file_id"
		
		case emoji
		case setName = "set_name"
	}
}
