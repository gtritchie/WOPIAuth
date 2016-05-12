import Cocoa

/**
	Protocol for an object that wants to show information on a single `ConnectionInfo` object.
*/
protocol ConnectionViewing {
	var selectedConnection: ConnectionInfo? { get set }
}

extension NSViewController {
	func notifyChildrenOfSelectedConnection(selectedConnection: ConnectionInfo?) {
		for child in childViewControllers {
			if var childConnectionViewer = child as? ConnectionViewing {
				childConnectionViewer.selectedConnection = selectedConnection
			}
		}
	}
}
