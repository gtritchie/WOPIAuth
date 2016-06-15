//
//  ClientInfo.swift
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

/**
	`ClientInfo` contains metadata used to identity the calling client.
*/
class ClientInfo: ModelInfo {

	// MARK: Properties
	
	/// Which culture such as `en-US` to send in the request header.
	dynamic var culture: String = "en-US"
	
	/// Which build string to send in the request header.
	dynamic var clientBuild: String = "16.0.7030"
	
	/// Which client platform string to send in the request header.
	dynamic var clientPlatform: String = "iOS"
}
