fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios create_build
```
fastlane ios create_build
```
Create an ipa build (options: scheme)
### ios build_catty
```
fastlane ios build_catty
```
Create builds at CI pipeline
### ios upload_to_browserstack
```
fastlane ios upload_to_browserstack
```
Upload Development Build to Browserstack
### ios tests
```
fastlane ios tests
```
Run tests
### ios test_reports
```
fastlane ios test_reports
```
Collate all test reports
### ios crowdin_upload
```
fastlane ios crowdin_upload
```
Upload Translations to Crowdin
### ios crowdin_download
```
fastlane ios crowdin_download
```
Download all Translations from Crowdin
### ios update_translations
```
fastlane ios update_translations
```
Update lane for Crowdin translations
### ios release
```
fastlane ios release
```
Release Pocket Code to Testflight

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
