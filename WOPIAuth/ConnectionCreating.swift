import Cocoa

/**
	Protocol for an object that adds a new `ConnectionInfo` for a given `ProviderInfo`
*/
protocol ConnectionCreating {
	var provider: ProviderInfo? { get set }
	var connections: [ConnectionInfo]? { get set }
}
