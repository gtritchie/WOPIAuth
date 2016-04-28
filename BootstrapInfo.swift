import Cocoa

/// Version of archived data
private let currentBootstrapInfoVersion = 1

/**
	`BootstrapInfo` contains metadata returned by an unauthenticated call
	to the WOPI bootstrapper endpoint.
*/
@objc class BootstrapInfo: NSObject, NSCoding {

	// MARK: Init
	
	override init() {
		super.init()
	}
	
	func populateFromAuthenticateHeader(header: String) -> Bool {
		
		WOPIAuthLogInfo("WWW-Authenticate: \(header)")
		
		// Replace all "Bearer" with nothing; this is dubious but is what Office clients are doing
		let trimHeader = header.stringByReplacingOccurrencesOfString("Bearer", withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	
		let separators = NSCharacterSet(charactersInString: "=,")
		let tokens: [String] = trimHeader.componentsSeparatedByCharactersInSet(separators)
		
		var nameValue = [String: String]()

		// TODO: I'm pretty sure there's a much tidier way to do all of this
		var lastKey = ""
		for (index, token) in tokens.enumerate() {
			var trimmedToken = token.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			trimmedToken = trimmedToken.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
			
			if index % 2 == 0 {
				lastKey = trimmedToken
				nameValue[trimmedToken] = ""
			} else {
				nameValue[lastKey] = trimmedToken
			}
		}

		guard let authUri = nameValue["authorization_uri"] else {
			WOPIAuthLogError("No authorization_uri in WWW-Authenticated header")
			return false
		}
		guard let tokenUri = nameValue["tokenIssuance_uri"] else {
			WOPIAuthLogError("No tokenIssuance_uri in WWW-Authenticated header")
			return false
		}
		
		authorizationURL = authUri
		tokenIssuanceURL = tokenUri
		
		if let provId = nameValue["providerID"] {
			providerID = provId
		}
		
		return true
	}
	
	// MARK: Properties

	/// Version of archived `BootstrapInfo`
	var bootstrapInfoVersion = currentBootstrapInfoVersion
	let bootstrapInfoVersionKey = "bootstrapInfoVersion"

	/// The authorization URL for the provider.
	dynamic var authorizationURL: String = ""
	let authorizationURLKey = "authorizationURL"

	/// The token issuance endpoint URL for the provider.
	dynamic var tokenIssuanceURL: String = ""
	let tokenIssuanceURLKey = "tokenIssuanceURL"

	/// The Microsoft-supplied internal name for the provider.
	dynamic var providerID: String = ""
	let providerIDKey = "providerID"
	
	/// Summary of `BootstrapInfo` suitable for logging
	override var description: String {
		get {
			return "[authUrl=\"\(authorizationURL)\", tokenUrl=\"\(tokenIssuanceURL)\", providerID=\"\(providerID)\"]"
		}
	}

	// MARK: NSCoding
	
	/// Using `NSCoding` to restore from `NSUserDefaults`
	required init?(coder aDecoder: NSCoder) {
		super.init()
		
		let bootstrapInfoVersionValue = aDecoder.decodeIntegerForKey(bootstrapInfoVersionKey)
		guard bootstrapInfoVersionValue == currentBootstrapInfoVersion else {
			print("Unsupported \(bootstrapInfoVersionKey)")
			return nil
		}

		guard let authorizationURLStr = aDecoder.decodeObjectForKey(authorizationURLKey) as? String else {
			print("Failed to unarchive \(authorizationURLKey)")
			return nil
		}
		
		guard let tokenIssuanceURLStr = aDecoder.decodeObjectForKey(tokenIssuanceURLKey) as? String else {
			print("Failed to unarchive \(tokenIssuanceURLKey)")
			return nil
		}
		
		guard let providerIDStr = aDecoder.decodeObjectForKey(providerIDKey) as? String else {
			print("Failed to unarchive \(providerIDKey)")
			return nil
		}
		
		self.bootstrapInfoVersion = bootstrapInfoVersionValue
		self.authorizationURL = authorizationURLStr
		self.tokenIssuanceURL = tokenIssuanceURLStr
		self.providerID = providerIDStr
	}
	
	/// Using `NSCoding` to save to `NSUserDefaults`
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeInteger(self.bootstrapInfoVersion, forKey: bootstrapInfoVersionKey)
		aCoder.encodeObject(self.authorizationURL, forKey: authorizationURLKey)
		aCoder.encodeObject(self.tokenIssuanceURL, forKey: tokenIssuanceURLKey)
		aCoder.encodeObject(self.providerID, forKey: providerIDKey)
	}
}
