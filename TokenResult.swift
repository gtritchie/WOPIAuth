import Foundation

/**
	`TokenResult` contains results from successful token exchange.
*/
class TokenResult {
	var accessToken: String = ""
	var tokenExpiration: Int64 = 0
	var refreshToken: String = ""
	
	/**
		Parse JSON response from token endpoint
	*/
	func populateFromResponseData(data: NSData) -> Bool {
		do {
			let topLevelDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
			guard let token = topLevelDict["access_token"] as? String else {
				WOPIAuthLogError("Unable to extract access_token")
				return false
			}
			let expiration = topLevelDict["expires_in"] as? NSNumber
			let refresh = topLevelDict["refresh_token"] as? String
			
			accessToken = token
			WOPIAuthLogInfo("Access token received")
			if expiration != nil {
				WOPIAuthLogInfo("Expiration time received")
				tokenExpiration = expiration!.longLongValue
			}
			if refresh != nil {
				WOPIAuthLogInfo("Refresh token received")
				refreshToken = refresh!
			}
		}
		catch {
			return false
		}
		return true
	}
}
