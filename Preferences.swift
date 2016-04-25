
import Foundation

private let providerArrayKey = "arrayOfProvidersKey"
private let selectedProviderKey = "selectedProviderKey'"

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
			selectedProviderKey : NSKeyedArchiver.archivedDataWithRootObject(String())
		]
		
		NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
	}
	
	
	/// The array of persisted `ProviderInfo`s.
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
	
	/// The `ProviderName` of the selected `ProviderInfo` object.
	static var selectedProviderName: String? {
		set {
			NSUserDefaults.standardUserDefaults().setObject(newValue!, forKey: selectedProviderKey)
		}
		get {
			return NSUserDefaults.standardUserDefaults().objectForKey(providerArrayKey) as? String
		}
	}

}
