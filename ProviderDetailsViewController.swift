import Cocoa

/**
	View controller for displaying and editing `ProviderInfo` properties.
*/
class ProviderDetailsViewController: NSViewController {

	// MARK: Outlets
	
	@IBOutlet var objectController: NSObjectController!
	
	// MARK: Properties
	
	dynamic var provider = ProviderInfo()
	var delegate: ProviderDetailEditing?
	
	// MARK: Life Cycle
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	// MARK: Actions
	
	@IBAction func cancel(sender: NSButton) {
		objectController.discardEditing()
		delegate = nil
		dismissController(sender)
	}
	
	@IBAction func save(sender: NSButton) {
		if objectController.commitEditing() == true {
			guard isProviderValid(sender) else {
				return
			}
			delegate?.addNew(provider)
			delegate = nil
			dismissController(sender)
		}
	}
	
	/// MARK: Helpers
	
	func ShowValidationErrorMessage(sender: NSButton, message: String) {
		let alert = NSAlert()
		alert.messageText = message
		alert.informativeText = NSLocalizedString("Please correct information and try again.",
		                                          comment: "Provider fields failed validation informativeText")
		alert.addButtonWithTitle(NSLocalizedString("Close", comment: "Confirm Provider close button"))

		alert.beginSheetModalForWindow(sender.window!, completionHandler: { (response) -> Void in })
	}
	
	func isProviderValid(sender: NSButton) -> Bool {
		
		provider.trimSpaces()
		if !provider.validate() {
			ShowValidationErrorMessage(sender, message: NSLocalizedString("Invalid or missing information entered. Correct and try again.",
				comment: "Message for failure of provider metadata validation"))
			return false
		}
		
		guard let nameAvailable = delegate?.providerNameAvailable(provider.providerName)
			where nameAvailable else {
				
			ShowValidationErrorMessage(sender, message: NSLocalizedString("Provider Name must be unique.",
				comment: "Message for trying to add item with duplicate Provider Name value"))
			return false
		}
		
		return true
	}
}
