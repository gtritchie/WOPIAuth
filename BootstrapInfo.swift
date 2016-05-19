import Foundation

/// Version of archived data
private let currentBootstrapInfoVersion = 1

/**
	`BootstrapInfo` contains metadata returned by an unauthenticated call
	to the WOPI bootstrapper endpoint.
*/
class BootstrapInfo: ModelInfo, NSCoding {

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
	
	/// Summary of `BootstrapInfo` suitable for logging
	override var description: String {
		get {
			return "[authUrl=\"\(authorizationURL)\", tokenUrl=\"\(tokenIssuanceURL)\"]"
		}
	}

	// MARK: Init
	
	override init() {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init()
		guard loadFromDecoder(aDecoder) else {
			return nil
		}
	}
	
	required init(instance: BootstrapInfo) {
		super.init()
		self.bootstrapInfoVersion = instance.bootstrapInfoVersion
		self.authorizationURL = instance.authorizationURL
		self.tokenIssuanceURL = instance.tokenIssuanceURL
	}
	
	func populateFromAuthenticateHeader(header: String) -> Bool {
		
		WOPIAuthLogInfo("WWW-Authenticate: \(header)")
		
		// Replace all "Bearer" with nothing; this is dubious but is what Office clients are doing
		var trimHeader = header.stringByReplacingOccurrencesOfString("Bearer", withString: "")
		trimHeader = trimHeader.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	
		let separators = NSCharacterSet(charactersInString: "=,")
		let tokens: [String] = trimHeader.componentsSeparatedByCharactersInSet(separators)
		
		var nameValue = [String: String]()

		// TODO: Pretty sure there's a Swiftier way to do all of this
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
		
		return true
	}

	// MARK: NSCoding
	
	func loadFromDecoder(aDecoder: NSCoder) -> Bool {
		
		let bootstrapInfoVersionValue = aDecoder.decodeIntegerForKey(bootstrapInfoVersionKey)
		guard bootstrapInfoVersionValue == currentBootstrapInfoVersion else {
			WOPIAuthLogError("Unsupported \(bootstrapInfoVersionKey)")
			return false
		}

		let authorizationURLStr = aDecoder.decodeObjectForKey(authorizationURLKey) as! String
		let tokenIssuanceURLStr = aDecoder.decodeObjectForKey(tokenIssuanceURLKey) as! String
		
		self.bootstrapInfoVersion = bootstrapInfoVersionValue
		self.authorizationURL = authorizationURLStr
		self.tokenIssuanceURL = tokenIssuanceURLStr
		return true
	}
	
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeInteger(self.bootstrapInfoVersion, forKey: bootstrapInfoVersionKey)
		aCoder.encodeObject(self.authorizationURL, forKey: authorizationURLKey)
		aCoder.encodeObject(self.tokenIssuanceURL, forKey: tokenIssuanceURLKey)
	}
	
	// MARK: KVC Validation
	
	func validateAuthorizationURL(authURLStringPointer: AutoreleasingUnsafeMutablePointer<NSString?>) throws {
		try validateAuthorizationURLString(authURLStringPointer.memory as? String)
	}

	func validateTokenIssuanceURL(tokenURLStringPointer: AutoreleasingUnsafeMutablePointer<NSString?>) throws {
		try validateTokenIssuanceURLString(tokenURLStringPointer.memory as? String)
	}
	
	// MARK: Validation
	
	func validateAuthorizationURLString(authURL: String?) throws {
		let authURLString = try getNonEmptyString(authURL,
		                                         errorMessage: NSLocalizedString("Authorization URL cannot be empty.",
													comment: "Error message for empty Authorization URL"))
		let url = try getValidURLComponents(authURLString,
		                                    errorMessage: NSLocalizedString("Authorization URL must be a valid URL.",
												comment: "Error message for invalid Authorization URL"))
		try verifyUrlSchemeHttps(url,
		                         errorMessage: NSLocalizedString("Authorization URL must use https.",
									comment: "Error message for non-https Authorization URL"))
	}

	func validateTokenIssuanceURLString(tokenURL: String?) throws {
		let tokenURLString = try getNonEmptyString(tokenURL,
		                                          errorMessage: NSLocalizedString("Token Issuance URL cannot be empty.",
													comment: "Error message for empty Token Issuance URL"))
		let url = try getValidURLComponents(tokenURLString,
		                                    errorMessage: NSLocalizedString("Token Issuance URL must be a valid URL.",
												comment: "Error message for invalid Token Issuance URL"))
		try verifyUrlSchemeHttps(url,
		                         errorMessage: NSLocalizedString("Token Issuance URL must use https.",
									comment: "Error message for non-https Token Issuance URL"))
	}

	/**
		Validate contents of `BootstrapInfo` object. Throws an NSError for first problem found.
	*/
	override func validate() throws {
		try super.validate()
		try validateAuthorizationURLString(authorizationURL)
		try validateTokenIssuanceURLString(tokenIssuanceURL)
	}
}

func == (left: BootstrapInfo, right: BootstrapInfo) -> Bool {
	return left.bootstrapInfoVersion == right.bootstrapInfoVersion &&
		left.authorizationURL == right.authorizationURL &&
		left.tokenIssuanceURL == right.tokenIssuanceURL
}

func != (left: BootstrapInfo, right: BootstrapInfo) -> Bool {
	return !(left == right)
}
