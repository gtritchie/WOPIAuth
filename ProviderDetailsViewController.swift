import Cocoa

/**
	View controller for displaying and editing `ProviderInfo` properties.
*/
class ProviderDetailsViewController: NSViewController {

	// MARK: Properties
	
	dynamic var provider = ProviderInfo()
	var delegate: ProviderDetailEditing?
	
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
		
		guard isProviderValid(sender) else {
			return
		}
		
		WOPIAuthLogInfo("Info: Added Provider: \(String(provider))")
		WOPIAuthLogInfo("Info: Provider \"\(provider.providerName)\" has not perfomed initial bootstrapper call. \(String(provider.bootstrapInfo))")
		delegate?.addNew(provider)
		delegate = nil
		dismissController(sender)
	}
	
	/// MARK: Helpers
	
	func ShowValidationErrorMessage(sender: NSButton, message: String) {
		let alert = NSAlert()
		alert.messageText = message
		alert.informativeText = NSLocalizedString("Please correct information and try again.", comment: "Provider fields failed validation informativeText")
		alert.addButtonWithTitle(NSLocalizedString("Close", comment: "Confirm Provider close button"))

		alert.beginSheetModalForWindow(sender.window!, completionHandler: { (response) -> Void in })
	}
	
	func isProviderValid(sender: NSButton) -> Bool {
		
		// Cleanup any leading/trailing whitespace
		provider.providerName = provider.providerName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		provider.bootstrapper = provider.bootstrapper.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		provider.clientId = provider.clientId.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		provider.clientSecret = provider.clientSecret.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		provider.redirectUrl = provider.redirectUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
		if provider.providerName.isEmpty || provider.bootstrapper.isEmpty ||
			provider.clientId.isEmpty || provider.clientSecret.isEmpty || provider.redirectUrl.isEmpty {
			
			ShowValidationErrorMessage(sender, message: NSLocalizedString("All fields must contain information.",
				comment: "Message for empty Provider field(s)"))
			return false
		}
		
		guard let nameAvailable = delegate?.providerNameAvailable(provider.providerName)
			where nameAvailable else {
				
			ShowValidationErrorMessage(sender, message: NSLocalizedString("Provider Name must be unique.",
				comment: "Message for duplicate Provider Name value"))
			return false
		}
		
		return true
	}
}
