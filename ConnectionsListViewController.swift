import Cocoa

/**
	Controller to manage creation and display of `ConnectionInfo` objects.
*/
class ConnectionsListViewController: NSViewController, NSTableViewDelegate, ProviderViewing, ConnectionContaining {
	
	// MARK: Outlets
	
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var arrayController: NSArrayController!
	@IBOutlet weak var addButton: NSButton!

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
			if let provider = selectedProvider {
				addButton.enabled = !provider.providerName.isEmpty
			}
			for child in childViewControllers {
				if var childProviderViewer = child as? ProviderViewing {
					childProviderViewer.selectedProvider = selectedProvider
				}
			}
		}
	}
	
	// MARK: Properties
	
	/// List of `ConnectionInfo`s for current provider
	var connections = Preferences.connections

	/// Must match identifier of segue from `ProviderListViewController` to `ProviderDetailViewController`
	let InvokeAuthFlowSegue = "InvokeWOPIAuthFlow"

	// MARK: Segue
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		switch segue.identifier! {
			
		case InvokeAuthFlowSegue:
			var destination = segue.destinationController as! ConnectionCreating
			destination.provider = selectedProvider
			destination.container = self
			
		default:
			print("Unknown segue: \(segue.identifier)")
		}
	}
	
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
	
	// MARK: ConnectionContaining
	/// Add `provider` to the list of `ProviderInfo` objects.
	func addNew(connection: ConnectionInfo) {
		arrayController.addObject(connection)
		Preferences.connections = connections
	}
	
}
