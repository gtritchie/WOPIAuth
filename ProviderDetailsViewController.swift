import Cocoa

/**
	View controller for displaying and editing `ProviderInfo` properties.
*/
class ProviderDetailsViewController: NSViewController {

	// MARK: Properties
	
	dynamic var provider = ProviderInfo()
	var delegate: ProviderDetailEditor?
	
	// MARK: Life Cycle
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	// MARK: Actions
	
	@IBAction func cancel(sender: NSButton) {
		delegate = nil
		dismissController(sender)
	}
	
	@IBAction func save(sender: NSButton) {
		WOPIAuthLogInfo("Added Provider")
		delegate?.addNew(provider)
		delegate = nil
		dismissController(sender)
	}
}
