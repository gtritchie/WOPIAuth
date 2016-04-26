import Cocoa

/**
	Protocol for an object that wants to show information on a single `ConnectionInfo` object.
*/
protocol ConnectionViewing {
	var selectedConnection: ConnectionInfo? { get set }
}
