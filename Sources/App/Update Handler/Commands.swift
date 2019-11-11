import Foundation

extension UpdateHandler {
	func handleCommand(_ command: String) throws -> Result {
		let parts = command.components(separatedBy: " ")
		let name = parts.first!
		let args = parts.dropFirst()
		
		switch name {
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
		case "/hint":
			let unsolved = Riddle.all.subtracting(session.solvedRiddles)
			if let random = unsolved.randomElement() {
				return try sendMarkdownMessage(
					"""
					Here's a hint to a random unsolved riddle (you have \(unsolved.count) left):
					
					\(random.name)
					"""
				)
			} else {
				return try sendMarkdownMessage(
					"""
					You've already solved all the riddles! No hints for you.
					"""
				)
			}
		case "/clear":
			let clearedRiddles = session.solvedRiddles.count
			session.clear()
			return try sendMarkdownMessage(
				"""
				🗑 Cleared \(clearedRiddles) solved riddles.
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
		case "/almostcomplete":
			session.solvedRiddles = Riddle.all.filter { $0.answer != "i" }
			return try sendMarkdownMessage(
				"""
				You had better not be using this to cheat! All riddles except the i one have been solved for you.
				"""
			)
		case "/subscribe" where message.sender?.isAdmin == true:
			let target = args.first
			subscription = Subscription(chat: chat, username: target)
			
			return try sendMarkdownMessage(
				"""
				Subscribed to updates from \(target ?? "everyone")!
				"""
			)
		case "/unsubscribe" where message.sender?.isAdmin == true:
			subscription = nil
			
			return try sendMarkdownMessage(
				"""
				Unsubscribed from updates!
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
}

private extension User {
	var isAdmin: Bool {
		username == "juliand665"
	}
}
