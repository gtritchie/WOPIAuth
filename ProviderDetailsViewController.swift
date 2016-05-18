import Cocoa

/**
	View controller for displaying and editing `ProviderInfo` properties.
*/
class ProviderDetailsViewController: NSViewController, ProviderDetailEditingView {

	// MARK: Outlets
	
	@IBOutlet var objectController: NSObjectController!
	
	// MARK: Properties
	
	dynamic var provider = ProviderInfo()
	
	// MARK: Life Cycle
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		if providerToEdit != nil {
			provider = ProviderInfo(instance: providerToEdit!)
		}
    }
	
	// MARK: Actions
	
	@IBAction func cancel(sender: NSButton) {
		objectController.discardEditing()
		dismissController(sender)
	}
	
	@IBAction func save(sender: NSButton) {
		if objectController.commitEditing() == true {
			guard isProviderValid(sender) else {
				return
			}
			providerContainer?.addNew(provider)
			dismissController(sender)
		}
	}
	
	// MARK: ProviderDetailEditingView

	var providerContainer: ProviderDetailEditing?
	var providerToEdit: ProviderInfo?

	// MARK: Helpers
	
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
		do {
			try provider.validate()
		} catch let error as NSError {
			ShowValidationErrorMessage(sender, message: error.localizedDescription)
			return false
		}
		
		guard let nameAvailable = providerContainer?.providerNameAvailable(provider.providerName)
			where nameAvailable else {

			ShowValidationErrorMessage(sender, message: NSLocalizedString("Provider Name must be unique.",
				comment: "Message for trying to add item with duplicate Provider Name value"))
			return false
		}
		
		return true
	}
}
