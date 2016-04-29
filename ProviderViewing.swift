import Cocoa

/**
	Protocol for an object that shows information on a single `ProviderInfo` object.
*/
protocol ProviderViewing {
	var selectedProvider: ProviderInfo? { get set }
}
