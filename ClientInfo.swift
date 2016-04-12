import Cocoa


/**
	`ClientInfo` contains metadata used to identity the calling client.
*/
class ClientInfo: NSObject {

	// MARK: Properties
	
	/// Which culture such as `en-US` to send in the request header.
	dynamic var culture: String = "en-US"
	
	/// Which build string to send in the request header.
	dynamic var clientBuild: String = "1234"
	
	/// Which client platform string to send in the request header.
	dynamic var clientPlatform: String = "iOS"
}
