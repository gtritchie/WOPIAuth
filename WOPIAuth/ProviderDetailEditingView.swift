import Foundation

/**
	Implement for an object that will communicate with a `ProviderDetailEditing` object.
*/
protocol ProviderDetailEditingView {
	var providerContainer: ProviderDetailEditing? { get set }
	var providerToEdit: ProviderInfo? { get set }
}
