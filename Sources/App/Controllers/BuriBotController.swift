import Vapor
import HandyOperators

private let decoder = JSONDecoder() <- {
	$0.dateDecodingStrategy = .secondsSince1970
}

final class BuriBotController {
	var highestUpdateHandled = 0
	
	func update(request: Request) throws -> Future<HTTPStatus> {
		try request.content
			.decode(json: Telegram.Update.self, using: decoder)
			.map { try self.handle($0, request: request) }
			.transform(to: .ok)
	}
	
	private func handle(_ update: Telegram.Update, request: Request) throws -> Future<HTTPStatus> {
		guard update.id > highestUpdateHandled else { throw Abort(.badRequest) }
		highestUpdateHandled = update.id
		
		if let message = update.message {
			print("got message", message)
			return try request.client()
				.sendMarkdownMessage(
					"i hear you saying \"\(message.text ?? "<something without text>")\", and i just don't care tbh",
					in: message.chat)
				.transform(to: .ok)
		} else if let message = update.editedMessage {
			print("got edited message", message)
			return try request.client()
				.sendMarkdownMessage("editing is _cheating_!", in: message.chat)
				.transform(to: .ok)
		} else {
			print("unknown update type")
			dump(update)
			return request.next().newSucceededFuture(result: .ok)
		}
	}
}
