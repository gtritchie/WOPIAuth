WOPIAuth
========

Mac OS X application for testing a specific OAuth2 flow used by a product I worked on. This standalone application is not intended for general-purpose
use, and was written for my own self-education on using Swift to build a Mac OS X application.

It is unsupported and provided as-is.

Usage
-----

1. Launch the application
2. Click + in the lower-left corner to add information for one provider
3. Fill out the sheet (all fields are mandatory except scopes)
4. Click on the provider you added in the sidebar
5. Click + at the bottom of the connections (center) pane (the one with User Name at the top)
6. The auth flow begins, each stage is reported in a sheet
7. Detailed status is reported in the text field
8. If all stages of the flow complete succesfully, the connection is added to the center pane and metadata for the selected connection is shown in the form
9. The Make Authenticated Call button will re-issue the authenticated bootstrapper call using the oauth2 access token and report the results
10. If the provider supports OAuth2 refresh flow, the refresh button is enabled and will perform the refresh flow, obtaining new tokens.

Warnings
--------
The client secret, and the access tokens, are stored unencrypted in user defaults. Some sensitive information may also be displayed in the user interface.

See the Issues for this repo for known issues and a wish-list.
