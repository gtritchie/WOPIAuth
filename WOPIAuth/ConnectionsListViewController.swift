import Cocoa

/// Notification used to signal modification of item in array of `ConnectionInfo` objects.
let ConnectionInfoModifiedNotification = "com.microsoft.office.WOPIAuth.ConnectionInfoModified"

/**
	Signal that `ConnectionInfo` has been changed.
*/
func NotifyConnectionInfoChanged() {
	let notificationCenter = NSNotificationCenter.defaultCenter()
	notificationCenter.postNotificationName(ConnectionInfoModifiedNotification, object: nil, userInfo: nil)
}

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
			filterConnectionsForSelectedProvider()
			notifyChildrenOfSelectedProvider(selectedProvider)
			notifyParentOfSelectedConnection()
		}
	}

	func renameProvider(oldProviderName: String) {
		notifyChildrenOfRenamedProvider(oldProviderName)
		deleteConnectionsWithProviderName(oldProviderName)
	}

	func deleteConnectionsWithProviderName(providerName: String) {
		let connectionsCopy = connections!
		for element in connectionsCopy {
			if element.providerName == providerName {
				arrayController.removeObject(element)
			}
		}
		Preferences.connections = self.connections
	}

	// MARK: Properties
	
	/// List of `ConnectionInfo`s
	dynamic var connections = Preferences.connections

	/// Must match identifier of segue from `ProviderListViewController` to `ProviderDetailViewController`
	let InvokeAuthFlowSegue = "InvokeWOPIAuthFlow"

	/// Filters tableview to only show connections associated with selected provider
	dynamic var predicate: NSPredicate = NSPredicate(value: false)
	
	private var changedConnectionInfoObserver: NSObjectProtocol?

	// MARK: Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let notificationCenter = NSNotificationCenter.defaultCenter()
		self.changedConnectionInfoObserver = notificationCenter.addObserverForName(ConnectionInfoModifiedNotification, object: nil, queue: nil) { note in
			self.performSelectorOnMainThread(#selector(self.didReceiveConnectionInfoModifiedNotification(_:)), withObject: note, waitUntilDone: true)
		}
	}
	
	deinit {
		if let observer = self.changedConnectionInfoObserver {
			let notificationCenter = NSNotificationCenter.defaultCenter()
			notificationCenter.removeObserver(observer)
		}
	}
	
	// MARK: Notifications
	
	/**
		One or more of the `ConnectionInfo` objects we are holding may have changed, so re-persist them.
	*/
	func didReceiveConnectionInfoModifiedNotification(note: NSNotification) {
		Preferences.connections = connections
	}

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
		WOPIAuthLogInfo("Adding connection \(connection.description)")
		WOPIAuthLogInfo("Adding bootstrapper \(connection.bootstrapInfo.description)")
		arrayController.addObject(connection)
		Preferences.connections = connections
		filterConnectionsForSelectedProvider()
	}
	
	// MARK: Helpers
	
	func notifyParentOfSelectedConnection() {
		let selectedConnection = arrayController.selectedObjects.first as? ConnectionInfo
		if var parent = parentViewController as? ConnectionViewing {
			parent.selectedConnection = selectedConnection
		}
	}

	func filterConnectionsForSelectedProvider() {
		if let provider = selectedProvider {
			addButton.enabled = !provider.providerName.isEmpty
			let args = ["providerName", provider.providerName]
			predicate = NSPredicate(format: "%K MATCHES %@", argumentArray: args)
		}
		else {
			predicate = NSPredicate(value: false)
		}
	}
}
