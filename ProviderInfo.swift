import Foundation

/// Version of archived `ProviderInfo` data
let currentProviderInfoVersion = 1

/**
	`ProviderInfo` contains information needed to perform auth for
	a Third Party Provider.
*/
class ProviderInfo: ModelInfo, NSCoding {
	
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
	
	required init(instance: ProviderInfo) {
		super.init()
		setPropertiesFrom(instance)
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
	
	/// The optional OAuth2 scope string
	dynamic var scope: String?
	let scopeKey = "scope"
	
	/// Summary of `ProviderInfo` suitable for logging
	override var description: String {
		get {
			
			return "[providerName=\"\(providerName)\", bootstrapper=\"\(bootstrapper)\", " +
				"clientId=\"\(clientId)\", clientSecret=\"*\", redirectUrl=\"\(redirectUrl)\", scope=\"\(unwrapStringReplaceNilWithEmpty(scope))\"]"
		}
	}
	
	func setPropertiesFrom(instance: ProviderInfo) {
		self.providerInfoVersion = instance.providerInfoVersion
		self.providerName = instance.providerName
		self.bootstrapper = instance.bootstrapper
		self.clientId = instance.clientId
		self.clientSecret = instance.clientSecret
		self.redirectUrl = instance.redirectUrl
		self.scope = instance.scope
	}
		
	// MARK: NSCoding
	
	/// Using `NSCoding` to restore from `NSUserDefaults`
	func loadFromDecoder(aDecoder: NSCoder) -> Bool {
		let providerInfoVersionValue = aDecoder.decodeIntegerForKey(providerInfoVersionKey)
		guard providerInfoVersionValue == currentProviderInfoVersion else {
		
		WOPIAuthLogError("Unsupported \(providerInfoVersionKey)")
			return false
		}
		
		let providerNameStr = aDecoder.decodeObjectForKey(providerNameKey) as! String
		let bootstrapperStr = aDecoder.decodeObjectForKey(bootstrapperKey) as! String
		let clientIdStr = aDecoder.decodeObjectForKey(clientIdKey) as! String
		let clientSecretStr = aDecoder.decodeObjectForKey(clientSecretKey) as! String
		let redirectUrlStr = aDecoder.decodeObjectForKey(redirectUrlKey) as! String
		let scopeStr = aDecoder.decodeObjectForKey(scopeKey) as! String?
		
		self.providerInfoVersion = providerInfoVersionValue
		self.providerName = providerNameStr
		self.bootstrapper = bootstrapperStr
		self.clientId = clientIdStr
		self.clientSecret = clientSecretStr
		self.redirectUrl = redirectUrlStr
		self.scope = scopeStr
		return true
	}
	
	/// Using `NSCoding` to save to `NSUserDefaults`
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeInteger(self.providerInfoVersion, forKey: providerInfoVersionKey)
		aCoder.encodeObject(self.providerName, forKey: providerNameKey)
		aCoder.encodeObject(self.bootstrapper, forKey: bootstrapperKey)
		aCoder.encodeObject(self.clientId, forKey: clientIdKey)
		aCoder.encodeObject(self.clientSecret, forKey: clientSecretKey)
		aCoder.encodeObject(self.redirectUrl, forKey: redirectUrlKey)
		aCoder.encodeObject(self.scope, forKey: scopeKey)
	}
	
	// MARK: KVC Validation
	
	func validateProviderName(providerStringPointer: AutoreleasingUnsafeMutablePointer<NSString?>) throws {
		try validateProviderNameString(providerStringPointer.memory as? String)
	}

	func validateBootstrapper(bootstrapperStringPointer: AutoreleasingUnsafeMutablePointer<NSString?>) throws {
		try validateBootstrapperString(bootstrapperStringPointer.memory as? String)
	}

	func validateClientId(clientIdStringPointer: AutoreleasingUnsafeMutablePointer<NSString?>) throws {
		try validateClientIdString(clientIdStringPointer.memory as? String)
	}

	func validateClientSecret(clientSecretStringPointer: AutoreleasingUnsafeMutablePointer<NSString?>) throws {
		try validateClientSecretString(clientSecretStringPointer.memory as? String)
	}

	func validateRedirectUrl(redirectUrlStringPointer: AutoreleasingUnsafeMutablePointer<NSString?>) throws {
		try validateRedirectUrlString(redirectUrlStringPointer.memory as? String)
	}

	func validateScope(scopeStringPointer: AutoreleasingUnsafeMutablePointer<NSString?>) throws {
		// No restrictions on scope string
	}

	// MARK: Validation
	
	func validateProviderNameString(providerName: String?) throws {
			try getNonEmptyString(providerName,
			                      errorMessage: NSLocalizedString("Provider Name cannot be empty.",
									comment: "Error message for empty ProviderName"))
	}
	
	func validateBootstrapperString(bootstrapper: String?) throws {
		let bootstrapper = try getNonEmptyString(bootstrapper,
		                                         errorMessage: NSLocalizedString("Bootstrapper URL cannot be empty.",
													comment: "Error message for empty Bootstrapper URL"))
		let url = try getValidURLComponents(bootstrapper,
		                                    errorMessage: NSLocalizedString("Bootstrapper must be a valid URL.",
												comment: "Error message for invalid Bootstrapper URL"))
		try verifyUrlSchemeHttps(url,
		                         errorMessage: NSLocalizedString("Bootstrapper URL must use https.",
									comment: "Error message for non-https Bootstrapper URL"))
	}

	func validateClientIdString(clientId: String?) throws {
		try getNonEmptyString(clientId,
		                      errorMessage: NSLocalizedString("Client ID cannot be empty.",
								comment: "Error message for empty ClientId"))
	}

	func validateClientSecretString(clientSecret: String?) throws {
		try getNonEmptyString(clientSecret,
		                      errorMessage: NSLocalizedString("Client Secret cannot be empty.",
								comment: "Error message for empty ClientSecret"))
	}
	
	func validateRedirectUrlString(redirectUrl: String?) throws {
		let redir = try getNonEmptyString(redirectUrl,
		                      errorMessage: NSLocalizedString("Redirect URL cannot be empty.",
								comment: "Error message for empty RedirectUrl"))
		let url = try getValidURLComponents(redir,
		                                    errorMessage: NSLocalizedString("Redirect URL must be a valid URL.",
												comment: "Error message for invalid Redirect URL"))
		try verifyUrlSchemeHttps(url,
		                         errorMessage: NSLocalizedString("Redirect URL must use https.",
									comment: "Error message for non-https Redirect URL"))
	}
	
	func validateScopeString(scope: String?) throws {
		// No restrictions on scope string
	}
	
	/**
		Validate contents of `ProviderInfo` object. Throws an NSError for first problem found.
	*/
	override func validate() throws {
		try super.validate()
		try validateProviderNameString(providerName)
		try validateBootstrapperString(bootstrapper)
		try validateClientIdString(clientId)
		try validateClientSecretString(clientSecret)
		try validateRedirectUrlString(redirectUrl)
		try validateScopeString(scope)
	}
	
	/// Trim all leading and trailing whitespace from text fields
	func trimSpaces() {
		providerName = providerName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		bootstrapper = bootstrapper.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		clientId = clientId.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		clientSecret = clientSecret.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		redirectUrl = redirectUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		scope = scope?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	}
}

func == (left: ProviderInfo, right: ProviderInfo) -> Bool {
	return left.providerInfoVersion == right.providerInfoVersion &&
		left.providerName == right.providerName &&
		left.clientId == right.clientId &&
		left.clientSecret == right.clientSecret &&
		left.redirectUrl == right.redirectUrl &&
		left.bootstrapper == right.bootstrapper &&
		left.scope == right.scope
}

func != (left: ProviderInfo, right: ProviderInfo) -> Bool {
	return !(left == right)
}
