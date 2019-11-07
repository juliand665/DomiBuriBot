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

private struct UpdateHandler {
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
	
	private func handleCommand(_ command: String) throws -> Result {
		switch command {
		case "/start":
			if session.guessesMade.isEmpty {
				return try sendMarkdownMessage(
					"""
					🤖 Looks like you've found me! But can you find and solve the other 9 riddles hidden in the chat?
					
					Whenever you think you've solved a riddle, just send me your guess and I'll validate it :)
					"""
				)
			} else {
				if session.hasSolvedEverything {
					return try sendMarkdownMessage(
						"""
						Want to continue guessing? You've already solved all the riddles, so you'll have to run /clear in order to start over.
						"""
					)
				} else {
					return try sendMarkdownMessage(
						"""
						Time to continue guessing!
						So far, you've solved *\(session.solvedRiddles.count)/\(Riddle.all.count)* riddles.
						"""
					)
				}
			}
		case "/clear":
			session.clear()
			return try sendMarkdownMessage(
				"""
				🗑 Cleared \(session.solvedRiddles.count) solved riddles.
				"""
			)
		case "/guesses":
			return try sendMarkdownMessage(
				"""
				You've made *\(session.guessesMade.count)* guesses (in no particular order):
				\(session.guessesMade.map { "• \($0)" }.joined(separator: "\n"))
				"""
			)
		case "/riddles":
			return try sendMarkdownMessage(
				"""
				You've solved *\(session.solvedRiddles.count)/\(Riddle.all.count)* riddles (in no particular order):
				\(session.solvedRiddles.map { "• \($0)" }.joined(separator: "\n"))
				"""
			)
		default:
			print("unknown command: \"\(command)\"")
			
			return try sendMarkdownMessage(
				"""
				🤷‍♀️ Unknown command: "\(command)"
				"""
			)
		}
	}
	
	private func handleGuess(_ guess: String) throws -> Result {
		switch session.makeGuess(guess) {
		case .alreadySolved(let riddle):
			return try sendMarkdownMessage(
				"""
				🙅‍♀️ You've already solved the "\(riddle.name)" riddle!
				"""
			)
		case .guessCorrect(let riddle):
			let hasSolvedEverything = session.hasSolvedEverything
			let guessCount = session.guessesMade.count
			
			return try sendMarkdownMessage(
				"""
				🕵️‍♂️ Nice! You've solved the "\(riddle.name)" riddle.
				You're now at *\(session.solvedRiddles.count)/\(Riddle.all.count)* riddles solved.
				"""
			).flatMap { response in
				if hasSolvedEverything {
					return try self.sendMarkdownMessage(
						"""
						🎉 Wow!! You've solved *all* the riddles in \(guessCount) unique guesses.
						
						You know what that means! It's time for your real gift…
						"""
					)
				} else {
					return self.ok()
				}
			}
		case .alreadyTried:
			return try sendMarkdownMessage(
				"""
				♻️ You've already tried to guess "\(guess)". (Guesses are case-insensitive!)
				"""
			)
		case .guessIncorrect:
			return try sendMarkdownMessage(
				"""
				🚫 Sorry; that's not the correct answer to any riddle.
				"""
			)
		}
	}
	
	private func sendMarkdownMessage(_ message: String) throws -> Result {
		try request.client()
			.sendMarkdownMessage(message, in: chat)
			.transform(to: .ok)
	}
	
	private func ok() -> Result {
		request.next().newSucceededFuture(result: .ok)
	}
}
