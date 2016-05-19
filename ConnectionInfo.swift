import Foundation

/// Version of archived data
private let currentConnectionInfoVersion = 1

/**
	`ConnectionInfo` contains metadata obtained by the sign-in flow against
	a third-party storage service.
*/
class ConnectionInfo: ModelInfo, NSCoding {
	
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
	
	required init(instance: ConnectionInfo) {
		super.init()
		self.connectionInfoVersion = instance.connectionInfoVersion
		self.providerName = instance.providerName
		self.userId = instance.userId
		self.userName = instance.userName
		self.friendlyName = instance.friendlyName
		self.postAuthTokenIssuanceURL = instance.postAuthTokenIssuanceURL
		self.sessionContext = instance.sessionContext
		self.accessToken = instance.accessToken
		self.tokenExpiration = instance.tokenExpiration
		self.refreshToken = instance.refreshToken
		self.bootstrapInfo = BootstrapInfo(instance: instance.bootstrapInfo)
	}
	
	// MARK: Properties
	
	/// Version of archived `ConnectionInfo`
	var connectionInfoVersion = currentConnectionInfoVersion
	let connectionInfoVersionKey = "connectionInfoVersion"

	/// The Provider Name. Used to lookup the associated `ProviderInfo` object.
	dynamic var providerName: String = ""
	let providerNameKey = "providerName"
	
	/// The UserId for the signed-in user.
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
	
	/// Information obtained from an unauthenticated bootstrapper call
	dynamic var bootstrapInfo: BootstrapInfo = BootstrapInfo()
	let bootstrapInfoKey = "bootstrapInfo"	

	/// Summary of `ConnectionInfo` suitable for logging
	override var description: String {
		get {
			return "[provider=\"\(providerName)\", userId=\"\(userId)\", userName=\"\", " +
				"friendlyName=\"\", postAuthURL=\"\", sessionContext=\"\", accessToken=\"...\", " +
				"expiration=\(tokenExpiration), refreshToken=\"...\"]"
		}
	}
	
	// MARK: NSCoding
	
	/// Using `NSCoding` to restore from `NSUserDefaults`
	func loadFromDecoder(aDecoder: NSCoder) -> Bool {
		
		let connectionInfoVersionValue = aDecoder.decodeIntegerForKey(connectionInfoVersionKey)
		guard connectionInfoVersionValue == currentConnectionInfoVersion else {
			print("Unsupported \(connectionInfoVersionKey)")
			return false
		}

		let providerNameStr = aDecoder.decodeObjectForKey(providerNameKey) as! String
		let userIdStr = aDecoder.decodeObjectForKey(userIdKey) as! String
		let userNameStr = aDecoder.decodeObjectForKey(userNameKey) as! String
		let friendlyNameStr = aDecoder.decodeObjectForKey(friendlyNameKey) as! String
		let postAuthTokenIssuanceURLStr = aDecoder.decodeObjectForKey(postAuthTokenIssuanceURLKey) as! String
		let sessionContextStr = aDecoder.decodeObjectForKey(sessionContextKey) as! String
		let accessTokenStr = aDecoder.decodeObjectForKey(accessTokenKey) as! String
		let tokenExpirationValue = aDecoder.decodeInt64ForKey(tokenExpirationKey)
		let refreshTokenStr = aDecoder.decodeObjectForKey(refreshTokenKey) as! String
		let bootstrapInfoObj = aDecoder.decodeObjectForKey(bootstrapInfoKey) as! BootstrapInfo
		
		self.connectionInfoVersion = connectionInfoVersionValue
		self.providerName = providerNameStr
		self.userId = userIdStr
		self.userName = userNameStr
		self.friendlyName = friendlyNameStr
		self.postAuthTokenIssuanceURL = postAuthTokenIssuanceURLStr
		self.sessionContext = sessionContextStr
		self.accessToken = accessTokenStr
		self.tokenExpiration = tokenExpirationValue
		self.refreshToken = refreshTokenStr
		self.bootstrapInfo = bootstrapInfoObj
		return true
	}
	
	/// Using `NSCoding` to save to `NSUserDefaults`
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeInteger(self.connectionInfoVersion, forKey: connectionInfoVersionKey)
		aCoder.encodeObject(self.providerName, forKey: providerNameKey)
		aCoder.encodeObject(self.userId, forKey: userIdKey)
		aCoder.encodeObject(self.userName, forKey: userNameKey)
		aCoder.encodeObject(self.friendlyName, forKey: friendlyNameKey)
		aCoder.encodeObject(self.postAuthTokenIssuanceURL, forKey: postAuthTokenIssuanceURLKey)
		aCoder.encodeObject(self.sessionContext, forKey: sessionContextKey)
		aCoder.encodeObject(self.accessToken, forKey: accessTokenKey)
		aCoder.encodeInt64(self.tokenExpiration, forKey: tokenExpirationKey)
		aCoder.encodeObject(self.refreshToken, forKey: refreshTokenKey)
		aCoder.encodeObject(self.bootstrapInfo, forKey: bootstrapInfoKey)
	}
}

func == (left: ConnectionInfo, right: ConnectionInfo) -> Bool {
	return left.connectionInfoVersion == right.connectionInfoVersion &&
		left.providerName == right.providerName &&
		left.userId == right.userId &&
		left.userName == right.userName &&
		left.friendlyName == right.friendlyName &&
		left.postAuthTokenIssuanceURL == right.postAuthTokenIssuanceURL &&
		left.sessionContext == right.sessionContext &&
		left.accessToken == right.accessToken &&
		left.tokenExpiration == right.tokenExpiration &&
		left.refreshToken == right.refreshToken &&
		left.bootstrapInfo == right.bootstrapInfo
}

func != (left: ConnectionInfo, right: ConnectionInfo) -> Bool {
	return !(left == right)
}
