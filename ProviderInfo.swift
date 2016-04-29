import Foundation

/// Version of archived `ProviderInfo` data
private let currentProviderInfoVersion = 1

/**
	`ProviderInfo` contains information needed to perform auth for
	a Third Party Provider.
*/
@objc class ProviderInfo: NSObject, NSCoding {
	
	// MARK: Init
	
	override init() {
		super.init()
	}
	
	// MARK: Properties
	
	/// Version of archived `ProviderInfo`
	var providerInfoVersion = currentProviderInfoVersion
	let providerInfoVersionKey = "providerInfoVersion"
	
	/// The Provider Name. For display purposes only, and treated as a unique key in this application.
	dynamic var providerName: String = ""
	let providerNameKey = "providerName"

	/// The WOPI bootstrap endpoint URL. This is treated as the primary unique key.
	dynamic var bootstrapper: String = ""
	let bootstrapperKey = "bootstrapper"
	
	/// The OAuth2 Client ID issued by the provider for Microsoft Office.
	dynamic var clientId: String = ""
	let clientIdKey = "clientId"
	
	/// The OAuth2 Client Secret issued by the provider for Microsoft Office.
	dynamic var clientSecret: String = ""
	let clientSecretKey = "clientSecret"
	
	/**
		The redirect URL used to indicate that authorization has completed and
		is returning an authorization_code via the code URL parameter.
	*/
	dynamic var redirectUrl: String = ""
	let redirectUrlKey = "redirectUrl"
	
	/// Summary of `ProviderInfo` suitable for logging
	override var description: String {
		get {
			return "[providerName=\"\(providerName)\", bootstrapper=\"\(bootstrapper)\", clientId=\"\(clientId)\", clientSecret=\"***\", redirectUrl=\"\(redirectUrl)\"]"
		}
	}
		
	// MARK: NSCoding
	
	/// Using `NSCoding` to restore from `NSUserDefaults`
	required init?(coder aDecoder: NSCoder) {
		super.init()
		
		let providerInfoVersionValue = aDecoder.decodeIntegerForKey(providerInfoVersionKey)
		guard providerInfoVersionValue == currentProviderInfoVersion else {
				
			print("Unsupported \(providerInfoVersionKey)")
			return nil
		}

		guard let providerNameStr = aDecoder.decodeObjectForKey(providerNameKey) as? String else {
			print("Failed to unarchive \(providerNameKey)")
			return nil
		}
	
		guard let bootstrapperStr = aDecoder.decodeObjectForKey(bootstrapperKey) as? String else {
			print("Failed to unarchive \(bootstrapperKey)")
			return nil
		}
		
		guard let clientIdStr = aDecoder.decodeObjectForKey(clientIdKey) as? String else {
			print("Failed to unarchive \(clientIdKey)")
			return nil
		}

		guard let clientSecretStr = aDecoder.decodeObjectForKey(clientSecretKey) as? String else {
			print("Failed to unarchive \(clientSecretKey)")
			return nil
		}

		guard let redirectUrlStr = aDecoder.decodeObjectForKey(redirectUrlKey) as? String else {
			print("Failed to unarchive \(redirectUrlKey)")
			return nil
		}
		
		self.providerInfoVersion = providerInfoVersionValue
		self.providerName = providerNameStr
		self.bootstrapper = bootstrapperStr
		self.clientId = clientIdStr
		self.clientSecret = clientSecretStr
		self.redirectUrl = redirectUrlStr
		
		trimSpaces()
		validate()
	}
	
	/// Using `NSCoding` to save to `NSUserDefaults`
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeInteger(self.providerInfoVersion, forKey: providerInfoVersionKey)
		aCoder.encodeObject(self.providerName, forKey: providerNameKey)
		aCoder.encodeObject(self.bootstrapper, forKey: bootstrapperKey)
		aCoder.encodeObject(self.clientId, forKey: clientIdKey)
		aCoder.encodeObject(self.clientSecret, forKey: clientSecretKey)
		aCoder.encodeObject(self.redirectUrl, forKey: redirectUrlKey)
	}
	
	// MARK: Validation
	
	/// Trim all leading and trailing whitespace from text fields
	func trimSpaces() {
		providerName = providerName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		bootstrapper = bootstrapper.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		clientId = clientId.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		clientSecret = clientSecret.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		redirectUrl = redirectUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	}
	
	func validateNonEmpty() -> Bool {
		guard !providerName.isEmpty else {
			WOPIAuthLogError("ProviderName cannot be empty")
			return false
		}
		
		guard !bootstrapper.isEmpty else {
			WOPIAuthLogError("Boostrapper cannot be empty")
			return false
		}

		guard !clientId.isEmpty else {
			WOPIAuthLogError("ClientId cannot be empty")
			return false
		}
		
		guard !clientSecret.isEmpty else {
			WOPIAuthLogError("ClientSecret cannot be empty")
			return false
		}

		guard !redirectUrl.isEmpty else {
			WOPIAuthLogError("RedirectUri cannot be empty")
			return false
		}

		return true
	}
	
	/**
		Validate contents of `ProviderInfo` object. Logs an error message for first problem found.
	
		- Returns: True if valid, False if invalid
	*/
	func validate() -> Bool {
		guard validateNonEmpty() else {
			return false
		}
		
		guard let bootstrapperUrl = NSURLComponents(string: bootstrapper) else {
			WOPIAuthLogError("Bootstrapper must be a valid URL: \(bootstrapper)")
			return false
		}
		
		guard bootstrapperUrl.scheme == "https" else {
			WOPIAuthLogError("Bootstrapper must use https scheme: \(bootstrapper)")
			return false
		}
		
		let bootstrapperSuffix = "/wopibootstrapper"
		guard let bootstrapperPath = bootstrapperUrl.path where bootstrapperPath.hasSuffix(bootstrapperSuffix) else {
			WOPIAuthLogError("Bootstrapper must end with \(bootstrapperSuffix): \(bootstrapper)")
			return false
		}
		
		if NSURLComponents(string: redirectUrl) == nil {
			WOPIAuthLogError("RedirectUri must be a valid URI: \(redirectUrl)")
			return false
		}
		
		return true
	}
}
