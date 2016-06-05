import Cocoa

/**
	`NSSplitViewController` subclass for the splitter between top and bottom of
	right pane of the program.
*/
class RightPaneSplitViewController: NSSplitViewController, ProviderViewing {

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

	// MARK: Life Cycle
	
	// For some reason, setting this in the Storyboard doesn't work, have to
	// do it in code.
	override func awakeFromNib() {
		super.awakeFromNib()
		splitView.autosaveName = "RightPaneSplitAutoSave"
	}
    
}
