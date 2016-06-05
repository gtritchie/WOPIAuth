import Foundation

/**
	`ProfileResult` contains results from successful profile call. The
	profile is obtained with an authenticated call to the bootstrapper.
*/
class ProfileResult {
	var userId: String = ""
	var signInName: String = ""
	var friendlyName: String = ""
	
	/**
		Create a `ProfileResult` by parsing response, or throw an error.
	*/
	static func createFromResponse(data: NSData?, response: NSURLResponse?, error: NSError?) throws -> ProfileResult {
		guard let data = data else {
			guard let error = error else {
				throw errorWithMessage("Unable to get data from profile response")
			}
			throw error
		}
		
		guard let response = response as? NSHTTPURLResponse else {
			logErrorBody(data)
			throw errorWithMessage("App Issue: Unexpected response object")
		}
		
		guard response.statusCode == 200 else {
			logErrorBody(data)
			throw self.errorWithMessage("Token endpoint responded with \(response.statusCode)")
		}
		
		let info = ProfileResult()
		try info.populateFromResponseData(data)
		return info
	}
	
	
	/**
		Parse JSON response from profile endpoint
	*/
	func populateFromResponseData(data: NSData) throws {
		let topLevelDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
		guard let id = topLevelDict["UserId"] as? String else {
			throw ProfileResult.errorWithMessage("Unable to extract userId")
		}
		guard !id.isEmpty else {
			throw TokenResult.errorWithMessage("Empty UserId")
		}
		
		let name = topLevelDict["SignInName"] as? String
		let friendly = topLevelDict["UserFriendlyName"] as? String
		
		userId = id
		if name != nil {
			signInName = name!
		}
		if friendly != nil {
			friendlyName = friendly!
		}
	}
	
	/// Return an `NSError` object with message
	static func errorWithMessage(localizedDescription: String) -> NSError {
		WOPIAuthLogError(localizedDescription)
		return NSError(domain: "Profile Result", code: 1, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
	}

	static func logErrorBody(data: NSData) {
		WOPIAuthLogError("Profile call unsuccessful. Body of response follows.")
		if data.length == 0 {
			WOPIAuthLogError("<no response body>")
			return
		}
		
		if let body = NSString(data: data, encoding: NSUTF8StringEncoding) {
			WOPIAuthLogError(body as String)
		}
	}

}
