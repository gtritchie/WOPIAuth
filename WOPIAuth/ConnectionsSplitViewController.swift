import Cocoa

/**
	`NSSplitViewController` subclass for the splitter between connection list and 
	connection properties. This class manages tracking the currently selected `ProviderInfo`
	object, and owns the master list of all `ConnectionInfo` objects.
*/
class ConnectionsSplitViewController: NSSplitViewController, ProviderViewing, ConnectionViewing {
	
	
	// MARK: ProviderViewing Protocol
	
	/// Currently selected `ProviderInfo`
	var selectedProvider: ProviderInfo? {
		didSet {
			notifyChildrenOfSelectedProvider(selectedProvider)
		}
	}

	func renameProvider(providerName: String) {
		notifyChildrenOfRenamedProvider(providerName)
	}
	
	// MARK: ConnectionViewing Protocol
	
	/// Currently selected `ConnectionInfo`
	var selectedConnection: ConnectionInfo? {
		didSet {
			notifyChildrenOfSelectedConnection(selectedConnection)
		}
	}

	// MARK: Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let provider = Preferences.selectedProvider
		self.selectedProvider = provider
	}
	
	// For some reason, setting this in the Storyboard doesn't work, have to
	// do it in code.
	override func awakeFromNib() {
		super.awakeFromNib()
		splitView.autosaveName = "ConnectionsSplitAutoSave"
	}
}
