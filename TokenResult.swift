import Foundation

/**
	`TokenResult` contains results from successful token exchange.
*/
class TokenResult {
	var accessToken: String = ""
	var tokenExpiration: Int32 = 0
	var refreshToken: String = ""
	
	/**
		Parse JSON response from token endpoint
	*/
	func populateFromResponseData(data: NSData) throws {
		let topLevelDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
		guard let token = topLevelDict["access_token"] as? String else {
			throw errorWithMessage("Unable to extract access_token")
		}
		guard !token.isEmpty else {
			throw errorWithMessage("Empty access_token")
		}
		
		let expiration = topLevelDict["expires_in"] as? NSNumber
		let refresh = topLevelDict["refresh_token"] as? String
		
		accessToken = token
		WOPIAuthLogInfo("Access token received")
		if expiration != nil {
			WOPIAuthLogInfo("Expiration time received")
			tokenExpiration = expiration!.intValue
		}
		if refresh != nil {
			WOPIAuthLogInfo("Refresh token received")
			refreshToken = refresh!
		}
	}
	
	/// Return an `NSError` object with this object
	func errorWithMessage(localizedDescription: String) -> NSError {
		WOPIAuthLogError(localizedDescription)
		return NSError(domain: "Token Result", code: 1, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}

}
