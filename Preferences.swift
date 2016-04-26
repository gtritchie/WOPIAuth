
import Foundation

private let providerArrayKey = "arrayOfProvidersKey"
private let activeProviderKey = "activeProviderKey"
private let connectionArrayKey = "arrayOfConnectionsKey"

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
			activeProviderKey : NSKeyedArchiver.archivedDataWithRootObject(ProviderInfo()),
			connectionArrayKey : NSKeyedArchiver.archivedDataWithRootObject([ConnectionInfo]())
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

	/// Currently selected `ProviderInfo`
	static var selectedProvider: ProviderInfo? {
		set {
			let objectData = NSKeyedArchiver.archivedDataWithRootObject(newValue!)
			NSUserDefaults.standardUserDefaults().setObject(objectData, forKey: activeProviderKey)
		}
		get {
			let unarchivedData = NSUserDefaults.standardUserDefaults().dataForKey(activeProviderKey)!
			return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedData) as? ProviderInfo
		}
	}

	/// The array of persisted `ConnectionInfo`s.
	static var connections: [ConnectionInfo]? {
		set {
			let arrayOfObjectsData = NSKeyedArchiver.archivedDataWithRootObject(newValue!)
			NSUserDefaults.standardUserDefaults().setObject(arrayOfObjectsData, forKey: connectionArrayKey)
		}
		get {
			let arrayOfObjectsUnarchivedData = NSUserDefaults.standardUserDefaults().dataForKey(connectionArrayKey)!
			return NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData) as? [ConnectionInfo]
		}
	}
}
