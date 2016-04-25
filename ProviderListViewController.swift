import Cocoa

/**
	Controller to manage display and editing of `ProviderInfo` objects.
*/
class ProviderListViewController: NSViewController,	ProviderDetailEditor, NSTableViewDelegate {

	// MARK: Outlets
	
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var arrayController: NSArrayController!

	// MARK: Properties
	
	/// List of `ProviderInfo`s
	var providers = Preferences.providers
	
	/// Currently selected `ProviderInfo`
	var selectedProvider = Preferences.selectedProvider
	
	/// Must match identifier of segue from `ProviderListViewController` to `ProviderDetailViewController`
	let AddProviderDetailSegueIdentifier = "AddProviderDetail"
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		switch segue.identifier! {
			
		case AddProviderDetailSegueIdentifier:
			let destination = segue.destinationController as! ProviderDetailsViewController
			destination.delegate = self

		default:
			print("Unknown segue: \(segue.identifier)")
		}
	}
	
	// MARK: Life Cycle
	
	override func viewWillAppear() {

		super.viewWillAppear()
		
		if let defaultProvider = Preferences.selectedProvider where !defaultProvider.providerName.isEmpty {
			if let defaultRow = providers?.indexOf({$0.providerName == defaultProvider.providerName}) {
				let indices = NSIndexSet(index: defaultRow)
				tableView.selectRowIndexes(indices, byExtendingSelection: false)
				tableView.scrollRowToVisible(defaultRow)
			}
		}
	}
	
	// MARK: ProviderDetailEditProtocol
	
	func providerNameAvailable(providerName: String) -> Bool {
		if providers != nil {
			if providers!.indexOf({$0.providerName == providerName}) != nil {
				return false
			}
		}
		return true
	}
		
	func addNew(provider: ProviderInfo) {
		arrayController.addObject(provider)
		Preferences.providers = providers
	}
		
	func updateExisting(provider: ProviderInfo) {
	}
	
	// MARK: NSTableViewDelegate
	
	func tableViewSelectionDidChange(notification: NSNotification) {
		let row = tableView.selectedRow
		if row == -1 {
			Preferences.selectedProvider = nil
			return
		}
		
		if let activeProvider = providers?[row] {
			Preferences.selectedProvider = activeProvider
		}
	}
	
	// MARK: Actions
	
	@IBAction func deleteSelectedProvider(sender: AnyObject) {
		let alert = NSAlert()
		alert.messageText = NSLocalizedString("Do you really want to remove this provider?", comment: "Confirm Provider delete messageText")
		alert.informativeText = NSLocalizedString("All information about this provider will be permanently deleted.", comment: "Confirm Provider delete informativeText")
		alert.addButtonWithTitle(NSLocalizedString("Remove", comment: "Confirm Provider delete remove button"))
		alert.addButtonWithTitle(NSLocalizedString("Cancel", comment: "Confirm Provider delete cancel button"))
		let window = sender.window!
		alert.beginSheetModalForWindow(window, completionHandler: { (response) -> Void in
			
			switch response {
			
			case NSAlertFirstButtonReturn:
				WOPIAuthLogError("Removed provider")
				self.arrayController.remove(sender)
				Preferences.providers = self.providers
				break
				
			default:
				break
			}
			
		})
	}
	
	@IBAction func addNewProvider(sender: AnyObject) {
		self.performSegueWithIdentifier(AddProviderDetailSegueIdentifier, sender: self)
	}
}
