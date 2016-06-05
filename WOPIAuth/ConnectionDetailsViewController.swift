import Cocoa

/**
	Controller to manage detailed display of one `ConnectionInfo` object.
*/
class ConnectionDetailsViewController: NSViewController, ConnectionViewing {

	// MARK: Outlets
	
	@IBOutlet weak var refreshButton: NSButton!
	@IBOutlet weak var refreshProgress: NSProgressIndicator!
	@IBOutlet weak var authCallButton: NSButton!
	
	// MARK: ConnectionViewing Protocol
	
	/// Currently selected `ConnectionInfo`
	dynamic var selectedConnection: ConnectionInfo? {
		didSet {
			notifyChildrenOfSelectedConnection(selectedConnection)
			setRefreshButtonState()
			setAuthCallButtonState()
		}
	}
	
	// MARK: Actions
	
	@IBAction func makeAuthenticatedCall(sender: NSButton) {
	
	}
	
	
	@IBAction func refreshTokens(sender: NSButton) {
		
	}
	
	// MARK: Utility
	
	func setRefreshButtonState() {
		var enabled = false
		if let connection = selectedConnection where
				(connection.tokenExpiration > 0 && !connection.refreshToken.isEmpty) {
			enabled = true
		}
		refreshButton.enabled = enabled
	}
	
	func setAuthCallButtonState() {
		var enabled = false
		if let connection = selectedConnection where !connection.accessToken.isEmpty {
			enabled = true
		}
		authCallButton.enabled = enabled
	}
}
