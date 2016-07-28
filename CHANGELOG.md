Changelog
=========

### 1.0.7 (2016-07-27)

- Fix [Token request does not include redirect_uri as per oauth2 spec](https://github.com/gtritchie/WOPIAuth/issues/8)

### 1.0.6 (2016-06-18)

- Fix [The Refresh button doesn't show the progress control or the Stop Request button](https://github.com/gtritchie/WOPIAuth/issues/1)
- Progress control in web view while loading sign-in page

### 1.0.5 (2016-06-15)

- First release on GitHub

### 1.0.5 (2016-??-??)

- Under development

### 1.0.4 (2016-06-10)

- Implement the refresh flow button

### 1.0.3 (2016-06-09)

- Disable App Transport Security to allow non-https redirect during sign-in flow (yuck); issue a warning if this happens
- Log redirects as they happen
- Treat absense of token_type: bearer in token endpoint response as an error

### 1.0.2 (2016-06-07)

- Stop logging client secret

### 1.0.1 (2016-06-07)

- Initial release
