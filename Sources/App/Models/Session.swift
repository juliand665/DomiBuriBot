import Foundation
import HandyOperators

final class SessionManager {
	private(set) var sessions: [ID<Chat>: Session] = [:]
	
	func session(for chat: Chat) -> Session {
		sessions[chat.id] ?? (
			Session() <- {
				sessions[chat.id] = $0
			}
		)
	}
}

final class Session {
	var solvedRiddles: Set<Riddle> = []
	var guessesMade: Set<String> = []
	
	var hasSolvedEverything: Bool {
		solvedRiddles.count == Riddle.all.count
	}
	
	func makeGuess(_ guess: String) -> GuessResult {
		print("making guess \(guess)")
		
		defer {
			guessesMade.insert(guess.lowercased())
			validate()
		}
		
		if let solved = solvedRiddles.first(where: { $0.accepts(guess) }) {
			return .alreadySolved(solved)
		} else if let solved = Riddle.all.first(where: { $0.accepts(guess) }) {
			solvedRiddles.insert(solved)
			return .guessCorrect(solved)
		} else if guessesMade.contains(guess) {
			return .alreadyTried
		} else {
			return .guessIncorrect
		}
	}
	
	func validate() {
		assert(solvedRiddles.allSatisfy { Riddle.all.contains($0) })
	}
	
	func clear() {
		solvedRiddles = []
		guessesMade = []
	}
	
	enum GuessResult {
		case alreadySolved(Riddle)
		case guessCorrect(Riddle)
		case alreadyTried
		case guessIncorrect
	}
}
