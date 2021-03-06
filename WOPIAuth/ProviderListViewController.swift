//
//  ProviderListViewController.swift
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
	Controller to manage creation, display and editing of `ProviderInfo` objects.
*/
class ProviderListViewController: NSViewController,	ProviderDetailEditing, NSTableViewDelegate {

	// MARK: Outlets
	
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var arrayController: NSArrayController!

	// MARK: Properties
	
	/// List of `ProviderInfo`s
	var providers = Preferences.providers
	
	/// Must match identifier of segue from `ProviderListViewController` to `ProviderDetailViewController`
	let AddProviderDetailSegueIdentifier = "AddProviderDetail"
	let EditProviderDetailSegueIdentier = "EditProviderDetail"
	
	// MARK: Segue
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		switch segue.identifier! {
			
		case AddProviderDetailSegueIdentifier:
			var destination = segue.destinationController as! ProviderDetailEditingView
			destination.providerContainer = self
			destination.providerToEdit = nil
			
		case EditProviderDetailSegueIdentier:
			var destination = segue.destinationController as! ProviderDetailEditingView
			destination.providerContainer = self
			destination.providerToEdit = arrayController.selectedObjects.first as! ProviderInfo?

		default:
			print("Unknown segue: \(segue.identifier)")
		}
	}
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		switch identifier {
		case EditProviderDetailSegueIdentier:
			if isProviderSelected() {
				return true
			} else {
				NSBeep()
				return false
			}
		default:
			return true
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
	
	func setActiveProvider(activeProvider: ProviderInfo?) {
		Preferences.selectedProvider = activeProvider
		if var parent = parentViewController as? ProviderViewing {
			parent.selectedProvider = activeProvider
		}
	}
	
	func renameProvider(providerName: String) {
		if let parent = parentViewController as? ProviderViewing {
			parent.renameProvider(providerName)
		}
	}
	
	// MARK: ProviderDetailEditing Protocol
	
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
		if let activeProvider = arrayController.selectedObjects.first as! ProviderInfo? {
			if activeProvider.providerName != provider.providerName {
				renameProvider(activeProvider.providerName)
			}
			activeProvider.setPropertiesFrom(provider)
			setActiveProvider(activeProvider)
			Preferences.providers = providers
		}
	}
	
	// MARK: NSTableViewDelegate
	
	/// When selection changes, update selected item preference and notify parent view
	func tableViewSelectionDidChange(notification: NSNotification) {
		let row = tableView.selectedRow
		var activeProvider: ProviderInfo = ProviderInfo()
		if row != -1 {
			activeProvider = arrayController.selectedObjects.first as! ProviderInfo
		}
		setActiveProvider(activeProvider)
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
				self.deleteProvider(sender)
				break
				
			default:
				break
			}
			
		})
	}
	
	@IBAction func addNewProvider(sender: AnyObject) {
		self.performSegueWithIdentifier(AddProviderDetailSegueIdentifier, sender: self)
	}
	
	@IBAction func editCurrentProvider(sender: AnyObject) {
		self.performSegueWithIdentifier(EditProviderDetailSegueIdentier, sender: self)
	}
	
	// MARK: Helpers
	
	/// Delete selected `ProviderInfo`
	func deleteProvider(sender: AnyObject) {
		self.arrayController.remove(sender)
		Preferences.providers = self.providers
		if self.tableView.selectedRow == -1 {
			self.setActiveProvider(ProviderInfo())
		}
	}

	override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
		switch menuItem.action {
		case #selector(editCurrentProvider(_:)):
			return isProviderSelected()
		default:
			return super.validateMenuItem(menuItem)
		}
	}
	
	func isProviderSelected() -> Bool {
		return arrayController.selectedObjects.count > 0
	}
}
