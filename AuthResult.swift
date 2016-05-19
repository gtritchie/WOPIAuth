import Foundation

/**
	`AuthResult` contains results from successful sign-in.
*/
class AuthResult {
	
	/// OAuth2 auth_code
	var authCode: String?
	
	/// Optional post-auth tokenIssuanceURL
	var postAuthTokenIssuanceURL: String = ""
	
	/// Which client platform string to send in the request header.
	var sessionContext: String = ""
	
	/// Contents of error response
	var error: String = ""
	var errorDescription: String = ""
	var errorURI: String = ""
}
