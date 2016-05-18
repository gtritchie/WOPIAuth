import Cocoa

/**
	Protocol for an object that can add a new `ConnectionInfo`.
*/
protocol ConnectionContaining {
	
	/// Add `connection` to the list of `ConnectionInfo` objects.
	func addNew(connection: ConnectionInfo)
}
