import Cocoa

/**
	Protocol for an object that shows information on a single `ProviderInfo` object.
*/
protocol ProviderViewing {
	var selectedProvider: ProviderInfo? { get set }
}

extension NSViewController {
	func notifyChildrenOfSelectedProvider(selectedProvider: ProviderInfo?) {
		for child in childViewControllers {
			if var childProviderViewer = child as? ProviderViewing {
				childProviderViewer.selectedProvider = selectedProvider
			}
		}
	}
}
