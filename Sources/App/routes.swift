import Vapor
import Foundation

private let token = ProcessInfo.processInfo.environment["token"]!
let baseURL = URL(string: "https://api.telegram.org/bot\(token)")!

/// Register your application's routes here.
public func routes(_ router: Router) throws {
	router.get { _ in "It works!" }
	
	let controller = BuriBotController()
	// using token so not just anyone can use our hook
	router.post(token, use: controller.update)
}
