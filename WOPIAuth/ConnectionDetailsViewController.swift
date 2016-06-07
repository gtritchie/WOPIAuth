import Cocoa

/**
	Controller to manage detailed display of one `ConnectionInfo` object.
*/
class ConnectionDetailsViewController: NSViewController, ConnectionViewing, ProviderViewing {

	// MARK: Outlets
	
	@IBOutlet weak var refreshButton: NSButton!
	@IBOutlet weak var refreshProgress: NSProgressIndicator!
	@IBOutlet weak var authCallButton: NSButton!
	@IBOutlet weak var stopButton: NSButton!

	// MARK: Properties
	
	var activeFetcher: Fetcher?

	// MARK: ConnectionViewing Protocol
	
	/// Currently selected `ConnectionInfo`
	dynamic var selectedConnection: ConnectionInfo? {
		didSet {
			stopCurrentRequest(self)
			notifyChildrenOfSelectedConnection(selectedConnection)
			setRefreshButtonState()
			setAuthCallButtonState()
		}
	}
	
	// MARK: ProviderViewing Protocol
	
	/// Currently selected `ProviderInfo`
	var selectedProvider: ProviderInfo? {
		didSet {
			stopCurrentRequest(self)
			notifyChildrenOfSelectedProvider(selectedProvider)
		}
	}
	
	func renameProvider(providerName: String) {
		stopCurrentRequest(self)
		notifyChildrenOfRenamedProvider(providerName)
	}

	// MARK: Actions
	
	@IBAction func makeAuthenticatedCall(sender: NSButton) {
		guard let profileUrl = NSURL(string: selectedProvider!.bootstrapper) else {
			WOPIAuthLogInfo("Malformed profile endpoint URL: \"\(selectedProvider!.bootstrapper)\"")
			return
		}
		
		let profileFetcher = ProfileFetcher(profileUrl: profileUrl,
		                                    accessToken: selectedConnection!.accessToken,
		                                    sessionContext: selectedConnection!.sessionContext)
		startRequest(sender, profileFetcher)
		profileFetcher.fetchProfileUsingCompletionHandler { (result) in
			switch result {
			case .Success(let profileResult):
				self.selectedConnection!.userId = profileResult.userId
				self.selectedConnection!.userName = profileResult.signInName
				self.selectedConnection!.friendlyName = profileResult.friendlyName
				NotifyConnectionInfoChanged()
				WOPIAuthLogInfo("Successful authenticated profile call")
			case .Failure(let error):
				WOPIAuthLogNSError(error)
			}
			self.stopCurrentRequest(sender)
		}
	}
	
	@IBAction func refreshTokens(sender: NSButton) {
		
	}
	
	@IBAction func stopRequest(sender: AnyObject) {
		activeFetcher?.cancel()
		stopCurrentRequest(sender)
		WOPIAuthLogWarning("User cancelled request")
	}
	
	// MARK: Utility
	
	func setRefreshButtonState() {
		var enabled = false
		if let connection = selectedConnection where
				(connection.tokenExpiration > 0 && !connection.refreshToken.isEmpty) {
			if selectedProvider != nil {
				enabled = true
			}
		}
		refreshButton.enabled = enabled
	}
	
	func setAuthCallButtonState() {
		var enabled = false
		if let connection = selectedConnection where !connection.accessToken.isEmpty {
			if selectedProvider != nil {
				enabled = true
			}
		}
		authCallButton.enabled = enabled
	}
	
	func startRequest(sender: AnyObject, _ fetcher: Fetcher) {
		activeFetcher = fetcher
		refreshButton.enabled = false
		authCallButton.enabled = false
		refreshProgress!.hidden = false
		stopButton.hidden = false
		refreshProgress!.startAnimation(sender)

	}
	
	func stopCurrentRequest(sender: AnyObject) {
		self.activeFetcher = nil
		self.refreshProgress!.hidden = true
		self.refreshProgress!.stopAnimation(sender)
		setRefreshButtonState()
		setAuthCallButtonState()
		stopButton.hidden = true
	}
}
