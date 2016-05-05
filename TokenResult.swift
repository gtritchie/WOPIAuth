import Foundation

/**
	`TokenResult` contains results from successful token exchange.
*/
class TokenResult {
	var accessToken: String = ""
	var tokenExpiration: Int64 = 0
	var refreshToken: String = ""
	
	func populateFromResponseData(data: NSData?) -> Bool {
		accessToken = "token hardcoded"
		tokenExpiration = 314
		refreshToken = "refresh hardcoded"
		return true
	}
}
