import Foundation

/**
	`TokenResult` contains results from successful token exchange.
*/
class TokenResult {
	var accessToken: String = ""
	var tokenExpiration: Int64 = 0
	var refreshToken: String = ""
}
