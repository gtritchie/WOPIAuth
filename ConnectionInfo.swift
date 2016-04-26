import Cocoa

/// Version of archived data
private let currentConnectionInfoVersion = 1

/**
	`ConnectionInfo` contains metadata obtained by the sign-in flow against
	a third-party storage service.
*/
@objc class ConnectionInfo: NSObject, NSCoding {
	
	// MARK: Init
	
	override init() {
		super.init()
	}
	
	// MARK: Properties
	
	/// Version of archived `ConnectionInfo`
	var connectionInfoVersion = currentConnectionInfoVersion
	let connectionInfoVersionKey = "connectionInfoVersion"

	/// The Provider Name. Used to lookup the associated `ProviderInfo` object.
	dynamic var providerName: String = ""
	let providerNameKey = "providerName"
	
	/// The UserId for the signed-in user. Unique key for objects of this class.
	dynamic var userId: String = ""
	let userIdKey = "userId"

	/// The UserName for the signed-in user.
	dynamic var userName: String = ""
	let userNameKey = "userName"

	/// The optional friendly-name for the signed-in user.
	dynamic var friendlyName: String = ""
	let friendlyNameKey = "friendlyName"
	
	/// The optional post-auth token issuance endpoint URL for the provider.
	dynamic var postAuthTokenIssuanceURL: String = ""
	let postAuthTokenIssuanceURLKey = "postAuthTokenIssuanceURL"

	/// The optional post-auth session context string.
	dynamic var sessionContext: String = ""
	let sessionContextKey = "sessionContext"

	/// The access-token
	dynamic var accessToken: String = ""
	let accessTokenKey = "accessToken"
	
	/// The expiration time for the access-token in seconds (0 means never expires)
	dynamic var tokenExpiration: Int64 = 0
	let tokenExpirationKey = "tokenExpiration"

	/// The refresh-token
	dynamic var refreshToken: String = ""
	let refreshTokenKey = "refreshToken"
	
	/// Summary of `ConnectionInfo` suitable for logging
	override var description: String {
		get {
			return "[provider=\"\(providerName)\", userId=\"\(userId)\", userName=\"\", friendlyName=\"\", postAuthURL=\"\", sessionContext=\"\", accessToken=\"...\", expiration=\(tokenExpiration), refreshToken=\"...\"]"
		}
	}
	
	// MARK: NSCoding
	
	/// Using `NSCoding` to restore from `NSUserDefaults`
	required init?(coder aDecoder: NSCoder) {
		super.init()
		
		let connectionInfoVersionValue = aDecoder.decodeIntegerForKey(connectionInfoVersionKey)
		guard connectionInfoVersionValue == currentConnectionInfoVersion else {
			print("Unsupported \(connectionInfoVersionKey)")
			return nil
		}

		guard let providerNameStr = aDecoder.decodeObjectForKey(providerNameKey) as? String else {
			print("Failed to unarchive \(providerNameKey)")
			return nil
		}

		guard let userNameStr = aDecoder.decodeObjectForKey(userNameKey) as? String else {
			print("Failed to unarchive \(userNameKey)")
			return nil
		}
		
		guard let friendlyNameStr = aDecoder.decodeObjectForKey(friendlyNameKey) as? String else {
			print("Failed to unarchive \(friendlyNameKey)")
			return nil
		}
		
		guard let postAuthTokenIssuanceURLStr = aDecoder.decodeObjectForKey(postAuthTokenIssuanceURLKey) as? String else {
			print("Failed to unarchive \(postAuthTokenIssuanceURLKey)")
			return nil
		}

		guard let sessionContextStr = aDecoder.decodeObjectForKey(sessionContextKey) as? String else {
			print("Failed to unarchive \(sessionContextKey)")
			return nil
		}

		guard let accessTokenStr = aDecoder.decodeObjectForKey(accessTokenKey) as? String else {
			print("Failed to unarchive \(accessTokenKey)")
			return nil
		}

		guard let tokenExpirationValue = aDecoder.decodeObjectForKey(tokenExpirationKey) as? Int64 else {
			print("Failed to unarchive \(tokenExpirationKey)")
			return nil
		}
		
		guard let refreshTokenStr = aDecoder.decodeObjectForKey(refreshTokenKey) as? String else {
			print("Failed to unarchive \(refreshTokenKey)")
			return nil
		}
		
		self.connectionInfoVersion = connectionInfoVersionValue
		self.providerName = providerNameStr
		self.userName = userNameStr
		self.friendlyName = friendlyNameStr
		self.postAuthTokenIssuanceURL = postAuthTokenIssuanceURLStr
		self.sessionContext = sessionContextStr
		self.accessToken = accessTokenStr
		self.tokenExpiration = tokenExpirationValue
		self.refreshToken = refreshTokenStr
	}
	
	/// Using `NSCoding` to save to `NSUserDefaults`
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeInteger(self.connectionInfoVersion, forKey: connectionInfoVersionKey)
		aCoder.encodeObject(self.providerName, forKey: providerNameKey)
		aCoder.encodeObject(self.userName, forKey: userNameKey)
		aCoder.encodeObject(self.friendlyName, forKey: friendlyNameKey)
		aCoder.encodeObject(self.postAuthTokenIssuanceURL, forKey: postAuthTokenIssuanceURLKey)
		aCoder.encodeObject(self.sessionContext, forKey: sessionContextKey)
		aCoder.encodeObject(self.accessToken, forKey: accessTokenKey)
		aCoder.encodeInt64(self.tokenExpiration, forKey: tokenExpirationKey)
		aCoder.encodeObject(self.refreshToken, forKey: refreshTokenKey)
	}
}
