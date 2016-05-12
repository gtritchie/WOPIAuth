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
		self.arrayController.remove(sender)
		Preferences.connections = self.connections
		if var parent = parentViewController as? ConnectionViewing {
			parent.selectedConnection = nil
		}
	}
	
	// MARK: ProviderViewing Protocol
	
	/// Currently selected `ProviderInfo`
	var selectedProvider: ProviderInfo? {
		didSet {
			if let provider = selectedProvider {
				addButton.enabled = !provider.providerName.isEmpty
				let args = ["providerName", provider.providerName]
				arrayController.filterPredicate =  NSPredicate(format: "%K MATCHES %@", argumentArray: args)
			}
			for child in childViewControllers {
				if var childProviderViewer = child as? ProviderViewing {
					childProviderViewer.selectedProvider = selectedProvider
				}
			}
			notifyParentOfSelectedConnection()
		}
	}
	
	// MARK: Properties
	
	/// List of `ConnectionInfo`s
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
		notifyParentOfSelectedConnection()
	}
	
	// MARK: ConnectionContaining
	/// Add `provider` to the list of `ProviderInfo` objects.
	func addNew(connection: ConnectionInfo) {
		arrayController.addObject(connection)
		Preferences.connections = connections
	}
	
	func notifyParentOfSelectedConnection() {
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
