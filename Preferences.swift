
import Foundation

private let providerArrayKey = "arrayOfProvidersKey"

/**
	Helper class for reading and saving user settings.
*/
class Preferences {
	
	init() {
		registerDefaultPreferences()
	}
	
	private func registerDefaultPreferences() {
		let defaults = [
			providerArrayKey : NSKeyedArchiver.archivedDataWithRootObject([ProviderInfo]()),
		]
		
		NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
	}
	
	
	/// Return the array of persisted `ProviderInfo`s.
	static var providers: [ProviderInfo]? {
		set {
			let arrayOfObjectsData = NSKeyedArchiver.archivedDataWithRootObject(newValue!)
			NSUserDefaults.standardUserDefaults().setObject(arrayOfObjectsData, forKey: providerArrayKey)
		}
		get {
			let arrayOfObjectsUnarchivedData = NSUserDefaults.standardUserDefaults().dataForKey(providerArrayKey)!
			return NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData) as? [ProviderInfo]
		}
	}
}
