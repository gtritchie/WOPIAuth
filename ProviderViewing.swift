import Cocoa

/**
	Protocol for an object that wants to show information on a single `ProtocolInfo` object.
*/
protocol ProviderViewing {
	var selectedProvider: ProviderInfo? { get set }
}
