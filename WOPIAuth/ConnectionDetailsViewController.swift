//
//  ConnectionDetailsViewController.swift
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

import Cocoa

/**
	Controller to manage detailed display of one `ConnectionInfo` object.
*/
class ConnectionDetailsViewController: NSViewController, ConnectionViewing, ProviderViewing {

	// MARK: Outlets
	
	@IBOutlet weak var refreshButton: NSButton!
	@IBOutlet weak var refreshProgress: NSProgressIndicator!
	@IBOutlet weak var authCallButton: NSButton!
	@IBOutlet weak var stopButton: NSButton!

	// MARK: Properties
	
	var activeFetcher: Fetcher?

	// MARK: ConnectionViewing Protocol
	
	/// Currently selected `ConnectionInfo`
	dynamic var selectedConnection: ConnectionInfo? {
		didSet {
			stopCurrentRequest(self)
			notifyChildrenOfSelectedConnection(selectedConnection)
			setRefreshButtonState()
			setAuthCallButtonState()
		}
	}
	
	// MARK: ProviderViewing Protocol
	
	/// Currently selected `ProviderInfo`
	var selectedProvider: ProviderInfo? {
		didSet {
			stopCurrentRequest(self)
			notifyChildrenOfSelectedProvider(selectedProvider)
		}
	}
	
	func renameProvider(providerName: String) {
		stopCurrentRequest(self)
		notifyChildrenOfRenamedProvider(providerName)
	}

	// MARK: Actions
	
	@IBAction func makeAuthenticatedCall(sender: NSButton) {
		guard let profileUrl = NSURL(string: selectedProvider!.bootstrapper) else {
			WOPIAuthLogInfo("Malformed profile endpoint URL: \"\(selectedProvider!.bootstrapper)\"")
			return
		}
		
		let profileFetcher = ProfileFetcher(profileUrl: profileUrl,
		                                    accessToken: selectedConnection!.accessToken,
		                                    sessionContext: selectedConnection!.sessionContext)
		startRequest(sender, profileFetcher)
		profileFetcher.fetchProfileUsingCompletionHandler { (result) in
			switch result {
			case .Success(let profileResult):
				self.selectedConnection!.userId = profileResult.userId
				self.selectedConnection!.userName = profileResult.signInName
				self.selectedConnection!.friendlyName = profileResult.friendlyName
				NotifyConnectionInfoChanged()
				WOPIAuthLogInfo("Successful authenticated profile call")
			case .Failure(let error):
				WOPIAuthLogNSError(error)
			}
			self.stopCurrentRequest(sender)
		}
	}
	
	@IBAction func refreshTokens(sender: NSButton) {
		
		var tokenEndpointUrl = selectedConnection!.bootstrapInfo.tokenIssuanceURL
		if !selectedConnection!.postAuthTokenIssuanceURL.isEmpty {
			tokenEndpointUrl = selectedConnection!.postAuthTokenIssuanceURL
			WOPIAuthLogInfo("Using post-auth token exchange URL: \(tokenEndpointUrl)")
		} else {
			WOPIAuthLogInfo("Using standard token exchange URL: \(tokenEndpointUrl)")
		}
		
		guard let tokenUrl = NSURL(string: tokenEndpointUrl) else {
			WOPIAuthLogError("Malformed token endpoint URL: \"\(tokenEndpointUrl)\"")
			return
		}

		
		let tokenFetcher = TokenFetcher(tokenURL: tokenUrl, clientId: selectedProvider!.clientId,
		                                clientSecret: selectedProvider!.clientSecret,
		                                authCode: selectedConnection!.refreshToken,
		                                sessionContext: selectedConnection!.sessionContext)
		activeFetcher = tokenFetcher
		tokenFetcher.fetchTokensUsingCompletionHandler(forRefresh: true) { (result) in
			switch result {
			case .Success(let tokenResult):
				self.selectedConnection!.accessToken = tokenResult.accessToken
				self.selectedConnection!.tokenExpiration = tokenResult.tokenExpiration
				self.selectedConnection!.expiresAt = nil
				if tokenResult.tokenExpiration > 0 {
					self.selectedConnection!.expiresAt = NSDate().dateByAddingTimeInterval(NSTimeInterval(tokenResult.tokenExpiration))
				}
				self.selectedConnection!.refreshToken = tokenResult.refreshToken
				NotifyConnectionInfoChanged()
				WOPIAuthLogInfo("Successful exchange of Refresh Token")
			case .Failure(let error):
				WOPIAuthLogNSError(error)
			}
			self.stopCurrentRequest(sender)
		}
	}
	
	@IBAction func stopRequest(sender: AnyObject) {
		activeFetcher?.cancel()
		stopCurrentRequest(sender)
		WOPIAuthLogWarning("User cancelled request")
	}
	
	// MARK: Utility
	
	func setRefreshButtonState() {
		var enabled = false
		if let connection = selectedConnection where
				(connection.tokenExpiration > 0 && !connection.refreshToken.isEmpty) {
			if selectedProvider != nil {
				enabled = true
			}
		}
		refreshButton.enabled = enabled
	}
	
	func setAuthCallButtonState() {
		var enabled = false
		if let connection = selectedConnection where !connection.accessToken.isEmpty {
			if selectedProvider != nil {
				enabled = true
			}
		}
		authCallButton.enabled = enabled
	}
	
	func startRequest(sender: AnyObject, _ fetcher: Fetcher) {
		activeFetcher = fetcher
		refreshButton.enabled = false
		authCallButton.enabled = false
		refreshProgress!.hidden = false
		stopButton.hidden = false
		refreshProgress!.startAnimation(sender)

	}
	
	func stopCurrentRequest(sender: AnyObject) {
		self.activeFetcher = nil
		self.refreshProgress!.hidden = true
		self.refreshProgress!.stopAnimation(sender)
		setRefreshButtonState()
		setAuthCallButtonState()
		stopButton.hidden = true
	}
}
