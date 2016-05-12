import Cocoa

/**
	`NSSplitViewController` subclass for the splitter between sidebar and right-side
	of the program. This class manages tracking the currently selected `ProviderInfo`
	object, and informs the right pane of the selection.
*/
class SidebarSplitViewController: NSSplitViewController, ProviderViewing {


	// MARK: ProviderViewing Protocol
	
	/// Currently selected `ProviderInfo`
	var selectedProvider: ProviderInfo? {
		didSet {
			notifyChildrenOfSelectedProvider(selectedProvider)
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
		splitView.autosaveName = "SidebarSplitAutoSave"
	}
}
