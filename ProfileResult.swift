import Foundation

/**
	`ProfileResult` contains results from successful profile call. The
	profile is obtained with an authenticated call to the bootstrapper.
*/
class ProfileResult {
	var userId: String = ""
	var signInName: String = ""
	var friendlyName: String = ""
	var ecosystemUrl: String = ""
	
	/**
		Parse JSON response from profile endpoint
	*/
	func populateFromResponseData(data: NSData) -> Bool {
		do {
			let topLevelDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
			guard let id = topLevelDict["UserId"] as? String else {
				WOPIAuthLogError("Unable to extract userId")
				return false
			}
			let name = topLevelDict["SignInName"] as? String
			let friendly = topLevelDict["UserFriendlyName"] as? String
			let eco = topLevelDict["EcosystemUrl"] as? String
			
			userId = id
			if name != nil {
				signInName = name!
			}
			if friendly != nil {
				friendlyName = friendly!
			}
			if eco != nil {
				ecosystemUrl = eco!
			}
		}
		catch {
			return false
		}
		return true
	}
}
