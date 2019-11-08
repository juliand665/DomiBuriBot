import Vapor
import HandyOperators

struct Subscription {
	/// the chat to send updates to
	var chat: Chat
	/// the user whose updates we're subscribed to, or nil for everyone
	var username: String?
}

var subscription: Subscription?

struct UpdateHandler {
	typealias Result = Future<HTTPStatus>
	
	let request: Request
	let update: Update
	
	let message: Message
	let session: Session
	
	var chat: Chat { message.chat }
	
	init(handling update: Update, using sessionManager: SessionManager, request: Request) throws {
		self.request = request
		self.update = update
		
		try self.message = update.message ?? update.editedMessage ??? Abort(.notAcceptable)
		self.session = sessionManager.session(for: message.chat)
	}
	
	func handleUpdate() throws -> Result {
		if let message = update.message {
			if let text = message.text {
				print("got message:", text)
				
				if text.hasPrefix("/") {
					return try handleCommand(text)
				} else {
					return try handleGuess(text)
				}
			} else {
				print("got non-text message")
				dump(message)
				
				return try sendMarkdownMessage("📝 All the answers can be expressed as plain text!")
			}
		} else if let message = update.editedMessage {
			print("got edited message", message)
			
			return try sendMarkdownMessage("😤 Editing is _cheating_!")
		} else {
			print("unknown update type")
			dump(update)
			return ok()
		}
	}
	
	func sendMarkdownMessage(_ message: String) throws -> Result {
		try request.client()
			.sendMarkdownMessage(message, in: chat)
			.map { _ in try self.updateSubscriber(forMessage: message) }
			.transform(to: .ok)
	}
	
	private func updateSubscriber(forMessage message: String) throws -> Result {
		guard let subscription = subscription else { return ok() }
		
		guard false
			|| subscription.username == nil
			|| subscription.username == self.message.sender?.username
			else { return ok() }
		
		func quote(_ text: String) -> String {
			text.components(separatedBy: "\n").map { "> \($0)" }.joined(separator: "\n")
		}
		
		let update = """
		@\(self.message.sender?.username ?? "<sender without username>"):
		\(quote(self.message.text ?? "<message without text>"))
		reply:
		\(quote(message))
		"""
		
		return try request.client()
			.sendMarkdownMessage(update, in: subscription.chat)
			.transform(to: .ok)
			.mapIfError { _ in .ok } // ignore errors because this is secondary functionality
	}
	
	func sendFile(id: String) throws -> Result {
		try request.client()
			.sendDocument(id: id, in: chat)
			.transform(to: .ok)
	}
	
	func ok() -> Result {
		request.next().newSucceededFuture(result: .ok)
	}
}
