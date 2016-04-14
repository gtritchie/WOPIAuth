
import Foundation

private let providersKey = "providers"

/**
	Helper class for reading and saving user settings.
*/
class Preferences {
	
	init() {
		registerDefaultPreferences()
	}
	
	private func registerDefaultPreferences() {
		let defaults = [
			providersKey : [ProviderInfo](),
		]
		
		NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
	}
	
	
	/// Return the array of persisted `ProviderInfo`s.
	static var providers: [ProviderInfo]? {
		set {
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: providersKey)
		}
		get {
			return NSUserDefaults.standardUserDefaults().objectForKey(providersKey) as? [ProviderInfo]
		}
	}
}
