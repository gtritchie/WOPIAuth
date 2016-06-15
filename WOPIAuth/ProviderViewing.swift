//
//  ProviderViewing.swift
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
	Protocol for an object that shows information on a single `ProviderInfo` object.
*/
protocol ProviderViewing {
	var selectedProvider: ProviderInfo? { get set }
	func renameProvider(providerName: String)
}

extension NSViewController {
	func notifyChildrenOfSelectedProvider(selectedProvider: ProviderInfo?) {
		for child in childViewControllers {
			if var childProviderViewer = child as? ProviderViewing {
				childProviderViewer.selectedProvider = selectedProvider
			}
		}
	}

	func notifyChildrenOfRenamedProvider(providerName: String) {
		for child in childViewControllers {
			if let childProviderViewer = child as? ProviderViewing {
				childProviderViewer.renameProvider(providerName)
			}
		}
	}
}
