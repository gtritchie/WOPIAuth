import Foundation

/// Version of archived data
private let currentProviderInfoVersion = 1

/**
	`ProviderInfo` contains information needed to perform auth for
	one Third Party Provider. The `ProviderInfo.bootstrapper` field
	is treated as the primary unique key.
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
	
	/// The Provider Name. For display purposes only.
	dynamic var providerName: String?
	let providerNameKey = "providerName"

	/// The WOPI bootstrap endpoint URL. This is treated as the primary unique key.
	dynamic var bootstrapper: String?
	let bootstrapperKey = "bootstrapper"
	
	/// The OAuth2 Client ID issued by the provider for Microsoft Office.
	dynamic var clientId: String?
	let clientIdKey = "clientId"
	
	/// The OAuth2 Client Secret issued by the provider for Microsoft Office.
	dynamic var clientSecret: String?
	let clientSecretKey = "clientSecret"
	
	/**
		The redirect URL used to indicate that authorization has completed and
		is returning an authorization_code via the code URL parameter.
	*/
	dynamic var redirectUrl: String?
	let redirectUrlKey = "redirectUrl"
	
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
}
