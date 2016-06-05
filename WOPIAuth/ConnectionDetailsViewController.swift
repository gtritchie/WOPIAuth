import Cocoa

/**
	Controller to manage detailed display of one `ConnectionInfo` object.
*/
class ConnectionDetailsViewController: NSViewController, ConnectionViewing {

	// MARK: Outlets
	
	@IBOutlet weak var refreshButton: NSButton!
	@IBOutlet weak var refreshProgress: NSProgressIndicator!
	
	// MARK: ConnectionViewing Protocol
	
	/// Currently selected `ConnectionInfo`
	dynamic var selectedConnection: ConnectionInfo? {
		didSet {
			notifyChildrenOfSelectedConnection(selectedConnection)
			setRefreshButtonState()
		}
	}
	
	// MARK: Utility
	
	func setRefreshButtonState() {
		var enabled = false
		if let connection = selectedConnection where !connection.refreshToken.isEmpty {
			enabled = true
		}
		refreshButton.enabled = enabled
	}
}
