import Vapor
import HandyOperators

struct UpdateHandler {
	typealias Result = Future<HTTPStatus>
	
	let request: Request
	let update: Update
	
	let chat: Chat
	let session: Session
	
	init(handling update: Update, using sessionManager: SessionManager, request: Request) throws {
		self.request = request
		self.update = update
		
		try self.chat = nil
			?? update.message?.chat
			?? update.editedMessage?.chat
			??? Abort(.notAcceptable)
		self.session = sessionManager.session(for: chat)
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
			.transform(to: .ok)
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
