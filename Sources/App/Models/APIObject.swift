import Foundation

protocol APIObject: Codable {
	var id: ID<Self> { get }
}

struct ID<Object> where Object: APIObject {
	var rawValue: Int
	
	init(_ rawValue: Int) {
		self.rawValue = rawValue
	}
}

extension ID: Codable {
	init(from decoder: Decoder) throws {
		rawValue = try .init(from: decoder)
	}
	
	func encode(to encoder: Encoder) throws {
		try rawValue.encode(to: encoder)
	}
}

extension ID: Hashable {}

extension ID: Comparable {
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}

extension ID: CustomStringConvertible {
	var description: String {
		return rawValue.description
	}
}
