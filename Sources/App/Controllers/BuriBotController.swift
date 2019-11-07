import Vapor
import HandyOperators

private let decoder = JSONDecoder() <- {
	$0.dateDecodingStrategy = .secondsSince1970
}

final class BuriBotController {
	var highestUpdateHandled = ID<Update>(0)
	
	let sessionManager = SessionManager()
	
	func update(request: Request) throws -> Future<HTTPStatus> {
		try request.content
			.decode(json: Update.self, using: decoder)
			.map { try self.handle($0, request: request) }
			.transform(to: .ok)
	}
	
	private func handle(_ update: Update, request: Request) throws -> Future<HTTPStatus> {
		guard update.id > highestUpdateHandled
			else { return request.next().newSucceededFuture(result: .ok) }
		highestUpdateHandled = update.id
		
		return try UpdateHandler(handling: update, using: sessionManager, request: request).handleUpdate()
	}
}
