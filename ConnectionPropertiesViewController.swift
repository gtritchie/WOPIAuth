import Cocoa

/**
	Controller to manage detailed display of one `ConnectionInfo` and one `ProviderInfo` objects.
*/
class ConnectionPropertiesViewController: NSViewController, NSTableViewDelegate, ProviderViewing, ConnectionViewing {
	
	// MARK: Outlets
	
	@IBOutlet weak var tableView: NSTableView!
	
	// MARK: ProviderViewing Protocol
	
	/// Currently selected `ProviderInfo`
	var selectedProvider: ProviderInfo? {
		didSet {
			for child in childViewControllers {
				if var childProviderViewer = child as? ProviderViewing {
					childProviderViewer.selectedProvider = selectedProvider
				}
			}
			tableView.reloadData()
		}
	}
	
	// MARK: ConnectionViewing Protocol
	
	/// Currently selected `ConnectionInfo`
	var selectedConnection: ConnectionInfo? {
		didSet {
			for child in childViewControllers {
				if var childConnectionViewer = child as? ConnectionViewing {
					childConnectionViewer.selectedConnection = selectedConnection
				}
			}
			tableView.reloadData()
		}
	}
	
	// MARK: NSTableViewDataSource
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		var rowCount = 0
		if selectedProvider != nil {
			rowCount = 5
		}
		
//		if selectedConnection != nil {
//			rowCount += 1
//		}
		return rowCount
	}
	
	func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
		switch row {
		case 0:
			switch tableColumn!.identifier {
			case "Property":
				return "Provider Name"
			case "Value":
				return selectedProvider!.providerName
			case "Source":
				return "Provider Info"
			default:
				return "Unknown"
			}
		case 1:
			switch tableColumn!.identifier {
			case "Property":
				return "Bootstrapper"
			case "Value":
				return selectedProvider!.bootstrapper
			case "Source":
				return "Provider Info"
			default:
				return "Unknown"
			}
		case 2:
			switch tableColumn!.identifier {
			case "Property":
				return "Client ID"
			case "Value":
				return selectedProvider!.clientId
			case "Source":
				return "Provider Info"
			default:
				return "Unknown"
			}
			
		case 3:
			switch tableColumn!.identifier {
			case "Property":
				return "Client Secret"
			case "Value":
				return "****"
			case "Source":
				return "Provider Info"
			default:
				return "Unknown"
			}
		case 4:
			switch tableColumn!.identifier {
			case "Property":
				return "Redirect URL"
			case "Value":
				return selectedProvider!.redirectUrl
			case "Source":
				return "Provider Info"
			default:
				return "Unknown"
			}
		default:
			return "Unknown"
		}
	}
}
