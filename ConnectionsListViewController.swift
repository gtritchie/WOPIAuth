import Cocoa

/**
	Controller to manage creation and display of `ConnectionInfo` objects.
*/
class ConnectionsListViewController: NSViewController, NSTableViewDelegate, ProviderViewing {
	
	// MARK: Outlets
	
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var arrayController: NSArrayController!

	// MARK: Actions
	
	@IBAction func deleteSelectedConnection(sender: AnyObject) {
		WOPIAuthLogError("Removed connection")
		self.arrayController.remove(sender)
		Preferences.connections = self.connections
	}
	
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
	
	// MARK: Properties
	
	/// List of `ConnectionInfo`s
	var connections = Preferences.connections
	
	// MARK: NSTableViewDelegate
	
	/// When selection changes, update selected item preference and notify parent view
	func tableViewSelectionDidChange(notification: NSNotification) {
		let row = tableView.selectedRow
		var activeConnection: ConnectionInfo?
		if row != -1 {
			activeConnection = connections?[row]
		}
		if var parent = parentViewController as? ConnectionViewing {
			parent.selectedConnection = activeConnection
		}
	}
}
