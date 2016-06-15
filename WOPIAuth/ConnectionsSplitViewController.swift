//
//  ConnectionsSplitViewController.swift
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
