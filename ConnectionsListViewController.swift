import Cocoa

/**
	Controller to manage creation and display of `ConnectionInfo` objects.
*/
class ConnectionsListViewController: NSViewController, NSTableViewDelegate, ProviderViewing {
	
	// MARK: Outlets
	
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var arrayController: NSArrayController!

	// MARK: ProviderViewing Protocol
	
	/// Currently selected `ProviderInfo`
	var selectedProvider: ProviderInfo? {
		didSet {
			print("connection split view controller got new provider")
			for child in childViewControllers {
				if var childProviderViewer = child as? ProviderViewing {
					childProviderViewer.selectedProvider = selectedProvider
				}
			}
		}
	}
	
	// MARK: Properties
	
	/// List of `ConnectionInfo`s
	var connections = Preferences.connections
	
}
