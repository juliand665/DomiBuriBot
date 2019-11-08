import Foundation

struct Riddle {
	static let all: Set<Riddle> = [
		Riddle(name: "drake integral", answer: "i"),
		Riddle(name: "profile pics", answer: "chocolate"),
		Riddle(name: "voice message", answer: "beatles"),
		Riddle(name: "me and the boys", answer: "electro"),
		Riddle(name: "sticker pack", answer: "twitter"),
		Riddle(name: "morse diacritics", answer: "umulig"),
		Riddle(name: "emoji movie title", answer: "interstellar"),
		Riddle(name: "location building", answer: "cab"),
		Riddle(name: "weird word", answer: "autobus"),
	]
	
	let name: String
	let answer: String
	
	func accepts(_ guess: String) -> Bool {
		answer.lowercased() == guess.lowercased()
	}
}

extension Riddle: Codable {}
extension Riddle: Hashable {}

extension Riddle: CustomStringConvertible {
	var description: String {
		"\(name) (answer: \(answer))"
	}
}
