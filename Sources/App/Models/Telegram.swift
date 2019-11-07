import Foundation

enum Telegram {
	struct Update: Codable {
		/// The update‘s unique identifier. Update identifiers start from a certain positive number and increase sequentially. This ID becomes especially handy if you’re using Webhooks, since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order. If there are no new updates for at least a week, then identifier of the next update will be chosen randomly instead of sequentially.
		var id: Int
		
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
	
	struct Message: Codable {
		var id: Int
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
	
	struct Chat: Codable {
		var id: Int
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
	
	struct Sticker: Codable {
		var id: Int
		
		var emoji: String
		var setName: String
		
		enum CodingKeys: String, CodingKey {
			case id = "file_id"
			
			case emoji
			case setName = "set_name"
		}
	}
	
	struct SetWebhook: Encodable {
		/// HTTPS url to send updates to. Use an empty string to remove webhook integration
		var url: String
		
		/// Maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery, 1-100. Defaults to 40. Use lower values to limit the load on your bot‘s server, and higher values to increase your bot’s throughput.
		var maxConnections: Int?
		/**
		List the types of updates you want your bot to receive. For example, specify [“message”, “edited_channel_post”, “callback_query”] to only receive updates of these types. See Update for a complete list of available update types. Specify an empty list to receive all updates regardless of type (default). If not specified, the previous setting will be used.
		
		Please note that this parameter doesn't affect updates created before the call to the setWebhook, so unwanted updates may be received for a short period of time.
		*/
		var allowedUpdates: [Update.Kind]?
		
		enum CodingKeys: String, CodingKey {
			case url
			
			case maxConnections = "max_connections"
			case allowedUpdates = "allowed_updates"
		}
	}
}
