import Foundation

private let fileIDs = ProcessInfo.processInfo.environment["fileIDs"]!.components(separatedBy: ":")

extension UpdateHandler {
	func handleGuess(_ guess: String) throws -> Result {
		switch session.makeGuess(guess) {
		case .alreadySolvedEverything:
			return try sendMarkdownMessage(
				"""
				✅ You've already solved all the riddles!
				
				Want to continue guessing? You'll have to run /clear in order to start over.
				"""
			)
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
						🎉 Wow!! You've solved *all* the riddles in *\(guessCount)* unique guesses.
						
						You know what that means! It's time for your real gift…
						"""
					).flatMap { response in
						.reduce(.ok, try fileIDs.map(self.sendFile(id:)), eventLoop: self.request.eventLoop) { old, new in old }
					}
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
}
