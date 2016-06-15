//
//  ProviderDetailsViewController.swift
//  WOPIAuth
//
//  Copyright 2016 Gary Ritchie
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

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
			
			if providerToEdit != nil {
				saveProviderAndDismiss(sender)
			} else if isProviderNameAvailable(sender) {
				providerContainer?.addNew(provider)
				dismissController(sender)
			}
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
		return true
	}
	
	func isProviderNameAvailable(sender: NSButton) -> Bool {
		guard let nameAvailable = providerContainer?.providerNameAvailable(provider.providerName)
			where nameAvailable else {

			ShowValidationErrorMessage(sender, message: NSLocalizedString("Provider Name must be unique.",
				comment: "Message for trying to add item with duplicate Provider Name value"))
			return false
		}
		return true
	}
	
	func saveProviderAndDismiss(sender: NSButton) {
		
		// If provider name was not changed, save and dismiss
		if providerToEdit!.providerName == provider.providerName {
			self.saveEditedProvider(sender)
			return
		}
		
		let alert = NSAlert()
		alert.messageText = NSLocalizedString("Rename this provider?", comment: "Confirm Provider rename messageText")
		alert.informativeText = NSLocalizedString("All existing connections will be permanently deleted.", comment: "Confirm Provider rename delete connections informativeText")
		alert.addButtonWithTitle(NSLocalizedString("Rename", comment: "Confirm Provider rename button"))
		alert.addButtonWithTitle(NSLocalizedString("Cancel", comment: "Confirm Provider rename cancel button"))
		let window = sender.window!
		alert.beginSheetModalForWindow(window, completionHandler: { (response) -> Void in
			
			switch response {
				
			case NSAlertFirstButtonReturn:
				self.saveEditedProvider(sender)
				break
				
			default:
				break
			}
			
		})
	}
	
	func saveEditedProvider(sender: NSButton) {
		providerContainer?.updateExisting(provider)
		dismissController(sender)
	}
}
