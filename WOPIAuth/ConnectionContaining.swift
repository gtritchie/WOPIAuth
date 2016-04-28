import Cocoa

/**
	Protocol for an object that can add a new `ConnectionInfo`.
*/
protocol ConnectionContaining {
	
	/// Add `provider` to the list of `ProviderInfo` objects.
	func addNew(connection: ConnectionInfo)
}
