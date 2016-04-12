import Cocoa

/**
	`BootstrapInfo` contains metadata returned by an unauthenticated call
	to the WOPI bootstrapper endpoint.
*/
class BootstrapInfo: NSObject {

	// MARK: Properties
	
	/// The authorization URL for the provider.
	dynamic var authorizationURL: String = ""

	/// The token issuance endpoint URL for the provider.
	dynamic var tokenIssuanceURL: String = ""

	/// The Microsoft-supplied internal name for the provider.
	dynamic var providerID: String = ""
}
