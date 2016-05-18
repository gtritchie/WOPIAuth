import Cocoa

/**
	Controller to manage detailed display of one `ConnectionInfo` and one `ProviderInfo` objects.
*/
class ConnectionDetailsViewController: NSViewController, ProviderViewing, ConnectionViewing {

	// MARK: Outlets
	
	@IBOutlet weak var refreshButton: NSButton!
	@IBOutlet weak var refreshProgress: NSProgressIndicator!
	
	// MARK: ProviderViewing Protocol
	
	/// Currently selected `ProviderInfo`
	dynamic var selectedProvider: ProviderInfo? {
		didSet {
			notifyChildrenOfSelectedProvider(selectedProvider)
		}
	}

	func renameProvider(providerName: String) {
		notifyChildrenOfRenamedProvider(providerName)
	}
	
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
