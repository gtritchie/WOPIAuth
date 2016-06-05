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
