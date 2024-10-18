fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios create_build

```sh
[bundle exec] fastlane ios create_build
```

Create an ipa build (options: scheme)

### ios build_catty

```sh
[bundle exec] fastlane ios build_catty
```

Create builds at CI pipeline

### ios upload_to_browserstack

```sh
[bundle exec] fastlane ios upload_to_browserstack
```

Upload Development Build to Browserstack

### ios unittests

```sh
[bundle exec] fastlane ios unittests
```

Run Unittests

### ios tests

```sh
[bundle exec] fastlane ios tests
```

Run tests

### ios crowdin_upload

```sh
[bundle exec] fastlane ios crowdin_upload
```

Upload Translations to Crowdin

### ios crowdin_download

```sh
[bundle exec] fastlane ios crowdin_download
```

Download all Translations from Crowdin

### ios update_translations

```sh
[bundle exec] fastlane ios update_translations
```

Update lane for Crowdin translations

### ios crashylytics_update_dsyms

```sh
[bundle exec] fastlane ios crashylytics_update_dsyms
```

Download dSYMs from Apple and upload to Firebase Crashlytics

### ios release

```sh
[bundle exec] fastlane ios release
```

Release Pocket Code to Testflight

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Generate localized screenshots for Pocket Code

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
