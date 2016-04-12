import Foundation

/**
	`ProviderInfo` contains information needed to perform auth for
	one Third Party Provider.
*/
class ProviderInfo: NSObject {
	
	// MARK: Properties
	
	/// The Microsoft-supplied internal name for the provider.
	dynamic var providerId: String = "PROVIDER ID"

	/// The short user-visible name for the provider.
	dynamic var providerName: String = "PROVIDER NAME"
	
	/// The WOPI bootstrap endpoint URL.
	dynamic var bootstrapper: String = "BOOT"
	
	/// The OAuth2 Client ID issued by the provider for Microsoft Office.
	dynamic var clientId: String = "CID"
	
	/// The OAuth2 Client Secret issued by the provider for Microsoft Office.
	dynamic var clientSecret: String = "SECRET"
	
	/**
		The redirect URL used to indicate that authorization has completed and
		is returning an authorization_code via the code URL parameter.
	*/
	dynamic var redirectUrl: String = "REDIR"
}
