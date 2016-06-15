//
//  Preferences.swift
//  WOPIAuth
//
//  Copyright 2016 Gary Ritchie
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

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
