import Cocoa

/**
	Methods to control creation and editing of ProviderDetail records.
*/
protocol ProviderDetailEditor {

	/// Returns `true` if `protocolId` is a unique protocol identifier.
	func protocolIdAvailable(protocolId: String) -> Bool

	/// Add `provider` to the list of `ProviderInfo` objects.
	func addNew(provider: ProviderInfo)
	
	/// Update metadata for an existing `ProviderInfo` object using `provider`.
	func updateExisting(provider: ProviderInfo)
}
