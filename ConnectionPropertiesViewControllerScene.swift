import Cocoa

/**
	Controller to manage detailed display of one `ConnectionInfo` and one `ProviderInfo` objects.
*/
class ConnectionPropertiesViewController: NSViewController, NSTableViewDelegate, ProviderViewing, ConnectionViewing {
	
	// MARK: Outlets
	
	@IBOutlet weak var tableView: NSTableView!
	
	// MARK: ProviderViewing Protocol
	
	/// Currently selected `ProviderInfo`
	var selectedProvider: ProviderInfo? {
		didSet {
			for child in childViewControllers {
				if var childProviderViewer = child as? ProviderViewing {
					childProviderViewer.selectedProvider = selectedProvider
				}
			}
		}
	}
	
	// MARK: ConnectionViewing Protocol
	
	/// Currently selected `ConnectionInfo`
	var selectedConnection: ConnectionInfo? {
		didSet {
			for child in childViewControllers {
				if var childConnectionViewer = child as? ConnectionViewing {
					childConnectionViewer.selectedConnection = selectedConnection
				}
			}
		}
	}
}
