import Foundation

/**
	Methods to control creation and editing of ProviderDetail records.
*/
protocol ProviderDetailEditing {

	/// Returns `true` if `providerName` is a unique providerName identifier.
	func providerNameAvailable(providerName: String) -> Bool

	/// Add `provider` to the list of `ProviderInfo` objects.
	func addNew(provider: ProviderInfo)
	
	/// Update metadata for an existing `ProviderInfo` object using `provider`.
	func updateExisting(provider: ProviderInfo)
}
