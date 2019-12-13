/**
 *  Copyright (C) 2010-2019 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

/*
     _       _     _                       _              _         _
    / \   __| | __| |   ___ ___  _ __  ___| |_ __ _ _ __ | |_ ___  | |_ ___
   / _ \ / _` |/ _` |  / __/ _ \| '_ \/ __| __/ _` | '_ \| __/ __| | __/ _ \
  / ___ \ (_| | (_| | | (_| (_) | | | \__ \ || (_| | | | | |_\__ \ | || (_) |
 /_/   \_\__,_|\__,_|  \___\___/|_| |_|___/\__\__,_|_| |_|\__|___/  \__\___/
  _                                            _____                    _       _   _             ____        __ _                   _
 | |    __ _ _ __   __ _ _   _  __ _  __ _  __|_   _| __ __ _ _ __  ___| | __ _| |_(_) ___  _ __ |  _ \  ___ / _(_)_ __   ___  ___  | |__
 | |   / _` | '_ \ / _` | | | |/ _` |/ _` |/ _ \| || '__/ _` | '_ \/ __| |/ _` | __| |/ _ \| '_ \| | | |/ _ \ |_| | '_ \ / _ \/ __| | '_ \
 | |__| (_| | | | | (_| | |_| | (_| | (_| |  __/| || | | (_| | | | \__ \ | (_| | |_| | (_) | | | | |_| |  __/  _| | | | |  __/\__ \_| | | |
 |_____\__,_|_| |_|\__, |\__,_|\__,_|\__, |\___||_||_|  \__,_|_| |_|___/_|\__,_|\__|_|\___/|_| |_|____/ \___|_| |_|_| |_|\___||___(_)_| |_|
                   |___/             |___/
 */

//************************************************************************************************************
//************************************       TERMS/BUZZWORDS      ********************************************
//************************************************************************************************************

let kLocalizedSkip = NSLocalizedString("Skip", comment: "")
let kLocalizedWelcomeToPocketCode = NSLocalizedString("Welcome to Pocket Code", comment: "")
let kLocalizedExploreApps = NSLocalizedString("Explore apps", comment: "")
let kLocalizedCreateAndEdit = NSLocalizedString("Create & Remix", comment: "")
let kLocalizedNewProject = NSLocalizedString("New project", comment: "")
let kLocalizedNewMessage = NSLocalizedString("New message", comment: "")
let kLocalizedBackground = NSLocalizedString("Background", comment: "")
let kLocalizedMyObject = NSLocalizedString("My object", comment: "Title for first (default) object")
let kLocalizedMyImage = NSLocalizedString("My image", comment: "Default title of imported photo from camera (taken by camera)")
let kLocalizedMyFirstProject = NSLocalizedString("My first project", comment: "Name of the default catrobat project (used as filename!!)")
let kLocalizedMole = NSLocalizedString("Mole", comment: "Prefix of default catrobat project object names (except background object)")
let kLocalizedToday = NSLocalizedString("Today", comment: "")
let kLocalizedYesterday = NSLocalizedString("Yesterday", comment: "")
let kLocalizedSunday = NSLocalizedString("Sunday", comment: "")
let kLocalizedMonday = NSLocalizedString("Monday", comment: "")
let kLocalizedTuesday = NSLocalizedString("Tuesday", comment: "")
let kLocalizedWednesday = NSLocalizedString("Wednesday", comment: "")
let kLocalizedThursday = NSLocalizedString("Thursday", comment: "")
let kLocalizedFriday = NSLocalizedString("Friday", comment: "")
let kLocalizedSaturday = NSLocalizedString("Saturday", comment: "")
let kLocalizedSu = NSLocalizedString("Su", comment: "")
let kLocalizedMo = NSLocalizedString("Mo", comment: "")
let kLocalizedTu = NSLocalizedString("Tu", comment: "")
let kLocalizedWe = NSLocalizedString("We", comment: "")
let kLocalizedTh = NSLocalizedString("Th", comment: "")
let kLocalizedFr = NSLocalizedString("Fr", comment: "")
let kLocalizedSa = NSLocalizedString("Sa", comment: "")
let kLocalizedJanuary = NSLocalizedString("January", comment: "")
let kLocalizedFebruary = NSLocalizedString("February", comment: "")
let kLocalizedMarch = NSLocalizedString("March", comment: "")
let kLocalizedApril = NSLocalizedString("April", comment: "")
let kLocalizedJune = NSLocalizedString("June", comment: "")
let kLocalizedJuly = NSLocalizedString("July", comment: "")
let kLocalizedAugust = NSLocalizedString("August", comment: "")
let kLocalizedSeptember = NSLocalizedString("September", comment: "")
let kLocalizedOctober = NSLocalizedString("October", comment: "")
let kLocalizedNovember = NSLocalizedString("November", comment: "")
let kLocalizedDecember = NSLocalizedString("December", comment: "")
let kLocalizedJan = NSLocalizedString("Jan", comment: "")
let kLocalizedFeb = NSLocalizedString("Feb", comment: "")
let kLocalizedMar = NSLocalizedString("Mar", comment: "")
let kLocalizedApr = NSLocalizedString("Apr", comment: "")
let kLocalizedMay = NSLocalizedString("May", comment: "")
let kLocalizedJun = NSLocalizedString("Jun", comment: "")
let kLocalizedJul = NSLocalizedString("Jul", comment: "")
let kLocalizedAug = NSLocalizedString("Aug", comment: "")
let kLocalizedSep = NSLocalizedString("Sep", comment: "")
let kLocalizedOct = NSLocalizedString("Oct", comment: "")
let kLocalizedNov = NSLocalizedString("Nov", comment: "")
let kLocalizedDec = NSLocalizedString("Dec", comment: "")
let kLocalizedPocketCode = NSLocalizedString("Pocket Code", comment: "")
let kLocalizedCategories = NSLocalizedString("Categories", comment: "")
let kLocalizedDetails = NSLocalizedString("Details", comment: "")
let kLocalizedLooks = NSLocalizedString("Looks", comment: "")
let kLocalizedFeaturedProjects = NSLocalizedString("Featured projects", comment: "")
let kLocalizedScripts = NSLocalizedString("Scripts", comment: "")
let kLocalizedBackgrounds = NSLocalizedString("Backgrounds", comment: "")
let kLocalizedTapPlusToAddBackground = NSLocalizedString("Tap \"+\" to add backgrounds", comment: "")
let kLocalizedTapPlusToAddScript = NSLocalizedString("Tap \"+\" to add scripts", comment: "")
let kLocalizedTapPlusToAddSprite = NSLocalizedString("Tap \"+\" to add actors or objects", comment: "")
let kLocalizedTapPlusToAddLook = NSLocalizedString("Tap \"+\" to add looks", comment: "")
let kLocalizedTapPlusToAddSound = NSLocalizedString("Tap \"+\" to add sounds", comment: "")
let kLocalizedContinue = NSLocalizedString("Continue", comment: "")
let kLocalizedNew = NSLocalizedString("New", comment: "")
let kLocalizedNewElement = NSLocalizedString("New...", comment: "")
let kLocalizedProjects = NSLocalizedString("Projects", comment: "")
let kLocalizedProject = NSLocalizedString("Project", comment: "")
let kLocalizedHelp = NSLocalizedString("Help", comment: "")
let kLocalizedExplore = NSLocalizedString("Explore", comment: "")
let kLocalizedDeletionMenu = NSLocalizedString("Deletion mode", comment: "")
let kLocalizedAboutPocketCode = NSLocalizedString("About Pocket Code", comment: "")
let kLocalizedTermsOfUse = NSLocalizedString("Terms of Use and Service", comment: "Button title at the settings screen to get to the terms of use and service.")
let kLocalizedForgotPassword = NSLocalizedString("Forgot password", comment: "")
let kLocalizedRateUs = NSLocalizedString("Rate Us", comment: "")
let kLocalizedPrivacySettings = NSLocalizedString("Privacy Settings", comment: "")
let kLocalizedVersionLabel = NSLocalizedString("iOS.", comment: "")
let kLocalizedBack = NSLocalizedString("Back", comment: "")
let kLocalizedSourceCodeLicenseButtonLabel = NSLocalizedString("Pocket Code Source Code License", comment: "")
let kLocalizedAboutCatrobatButtonLabel = NSLocalizedString("About Catrobat", comment: "")
let kLocalizedEdit = NSLocalizedString("Edit", comment: "")
let kLocalizedCancel = NSLocalizedString("Cancel", comment: "")
let kLocalizedDone = NSLocalizedString("Done", comment: "")
let kLocalizedUndo = NSLocalizedString("Undo", comment: "Button title of alert view to invoke undo if user shakes device")
let kLocalizedUndoDrawingDescription = NSLocalizedString("Undo Drawing?", comment: "Description text in alert view if user shakes the device")
let kLocalizedUndoTypingDescription = NSLocalizedString("Undo Typing?", comment: "Description text in alert view if user shakes the device")
let kLocalizedSelectAllItems = NSLocalizedString("Select all", comment: "")
let kLocalizedUnselectAllItems = NSLocalizedString("Unselect all", comment: "")
let kLocalizedSaveToPocketCode = NSLocalizedString("Save to PocketCode", comment: "")
let kLocalizedEditSounds = NSLocalizedString("Edit sounds", comment: "Action sheet menu title")
let kLocalizedEditSound = NSLocalizedString("Edit sound", comment: "Action sheet menu title")
let kLocalizedEditLooks = NSLocalizedString("Edit looks", comment: "Action sheet menu title")
let kLocalizedEditLook = NSLocalizedString("Edit look", comment: "Action sheet menu title")
let kLocalizedEditBackground = NSLocalizedString("Edit background", comment: "Action sheet menu title")
let kLocalizedEditBackgrounds = NSLocalizedString("Edit backgrounds", comment: "Action sheet menu title")
let kLocalizedEditScript = NSLocalizedString("Edit script", comment: "Action sheet menu title")
let kLocalizedEditBrick = NSLocalizedString("Edit brick", comment: "Action sheet menu title")
let kLocalizedAddLook = NSLocalizedString("Add look", comment: "Action sheet menu title")
let kLocalizedLookFilename = NSLocalizedString("look", comment: "LOOK")
let kLocalizedEditProject = NSLocalizedString("Edit project", comment: "")
let kLocalizedEditProjects = NSLocalizedString("Edit projects", comment: "")
let kLocalizedEditObject = NSLocalizedString("Edit actor or object", comment: "")
let kLocalizedAddSound = NSLocalizedString("Add sound", comment: "Action sheet menu title")
let kLocalizedSelectBrickCategory = NSLocalizedString("Select brick category", comment: "")
let kLocalizedClose = NSLocalizedString("Close", comment: "")
let kLocalizedDeleteBrick = NSLocalizedString("Delete brick", comment: "")
let kLocalizedDeleteThisBrick = NSLocalizedString("Delete this brick?", comment: "")
let kLocalizedDeleteTheseBricks = NSLocalizedString("Delete these bricks?", comment: "")
let kLocalizedDeleteCondition = NSLocalizedString("Delete condition", comment: "")
let kLocalizedDeleteThisCondition = NSLocalizedString("Delete this condition?", comment: "")
let kLocalizedDeleteTheseConditions = NSLocalizedString("Delete these conditions?", comment: "")
let kLocalizedDeleteLoop = NSLocalizedString("Delete loop", comment: "")
let kLocalizedDeleteThisLoop = NSLocalizedString("Delete this loop?", comment: "")
let kLocalizedDeleteTheseLoops = NSLocalizedString("Delete these loops?", comment: "")
let kLocalizedDeleteScript = NSLocalizedString("Delete script", comment: "")
let kLocalizedDeleteThisScript = NSLocalizedString("Delete this script?", comment: "")
let kLocalizedDeleteTheseScripts = NSLocalizedString("Delete these scripts?", comment: "")
let kLocalizedAnimateBrick = NSLocalizedString("Animate brick-parts", comment: "")
let kLocalizedCopyBrick = NSLocalizedString("Copy brick", comment: "")
let kLocalizedEditFormula = NSLocalizedString("Edit formula", comment: "")
let kLocalizedMoveBrick = NSLocalizedString("Move brick", comment: "")
let kLocalizedDeleteSounds = NSLocalizedString("Delete sounds", comment: "")
let kLocalizedMoveSounds = NSLocalizedString("Move sounds", comment: "")
let kLocalizedHideDetails = NSLocalizedString("Hide details", comment: "")
let kLocalizedShowDetails = NSLocalizedString("Show details", comment: "")
let kLocalizedDeleteLooks = NSLocalizedString("Delete looks", comment: "")
let kLocalizedDeleteBackgrounds = NSLocalizedString("Delete backgrounds", comment: "")
let kLocalizedMoveLooks = NSLocalizedString("Move looks", comment: "")
let kLocalizedCopyLooks = NSLocalizedString("Copy looks", comment: "")
let kLocalizedFromCamera = NSLocalizedString("From camera", comment: "")
let kLocalizedChooseImage = NSLocalizedString("Choose image", comment: "")
let kLocalizedDrawNewImage = NSLocalizedString("Draw new image", comment: "")
let kLocalizedRename = NSLocalizedString("Rename", comment: "")
let kLocalizedCopy = NSLocalizedString("Copy", comment: "")
let kLocalizedUpload = NSLocalizedString("Upload", comment: "")
let kLocalizedDeleteObjects = NSLocalizedString("Delete actors or objects", comment: "")
let kLocalizedMoveObjects = NSLocalizedString("Move actors or objects", comment: "")
let kLocalizedDeleteProjects = NSLocalizedString("Delete projects", comment: "")
let kLocalizedPocketCodeRecorder = NSLocalizedString("Pocket Code Recorder", comment: "")
let kLocalizedCameraRoll = NSLocalizedString("Camera roll", comment: "")
let kLocalizedOpen = NSLocalizedString("Open", comment: "")
let kLocalizedDownload = NSLocalizedString("Download", comment: "")
let kLocalizedMore = NSLocalizedString("More", comment: "")
let kLocalizedDelete = NSLocalizedString("Delete", comment: "")
let kLocalizedAddObject = NSLocalizedString("Add actor or object", comment: "")
let kLocalizedAddImage = NSLocalizedString("Add image", comment: "")
let kLocalizedRenameObject = NSLocalizedString("Rename actor or object", comment: "")
let kLocalizedRenameImage = NSLocalizedString("Rename image", comment: "")
let kLocalizedRenameSound = NSLocalizedString("Rename sound", comment: "")
let kLocalizedDeleteThisObject = NSLocalizedString("Delete this actor or object", comment: "")
let kLocalizedDeleteThisProject = NSLocalizedString("Delete this project", comment: "")
let kLocalizedDeleteThisLook = NSLocalizedString("Delete this look", comment: "")
let kLocalizedDeleteThisBackground = NSLocalizedString("Delete this background", comment: "")
let kLocalizedDeleteThisSound = NSLocalizedString("Delete this sound", comment: "")
let kLocalizedCopyProject = NSLocalizedString("Copy project", comment: "")
let kLocalizedRenameProject = NSLocalizedString("Rename project", comment: "")
let kLocalizedSetDescription = NSLocalizedString("Set description", comment: "")
let kLocalizedPocketCodeForIOS = NSLocalizedString("Pocket Code for iOS", comment: "")
let kLocalizedProjectName = NSLocalizedString("Project name", comment: "")
let kLocalizedMessage = NSLocalizedString("Message", comment: "")
let kLocalizedDescription = NSLocalizedString("Description", comment: "")
let kLocalizedObjectName = NSLocalizedString("Object or actor name", comment: "")
let kLocalizedImageName = NSLocalizedString("Image name", comment: "")
let kLocalizedSoundName = NSLocalizedString("Sound name", comment: "")
let kLocalizedOK = NSLocalizedString("OK", comment: "")
let kLocalizedYes = NSLocalizedString("Yes", comment: "")
let kLocalizedNo = NSLocalizedString("No", comment: "")
let kLocalizedDeleteProject = NSLocalizedString("Delete project", comment: "")
let kLocalizedLoading = NSLocalizedString("Loading", comment: "")
let kLocalizedSaved = NSLocalizedString("Saved", comment: "")
let kLocalizedSaveError = NSLocalizedString("Error saving file", comment: "")
let kLocalizedAuthor = NSLocalizedString("Author", comment: "")
let kLocalizedDownloads = NSLocalizedString("Downloads", comment: "")
let kLocalizedUploaded = NSLocalizedString("Uploaded", comment: "")
let kLocalizedVersion = NSLocalizedString("Version", comment: "")
let kLocalizedViews = NSLocalizedString("Views", comment: "")
let kLocalizedInformation = NSLocalizedString("Information", comment: "")
let kLocalizedMeasure = NSLocalizedString("Measure", comment: "")
let kLocalizedSize = NSLocalizedString("Size", comment: "")
let kLocalizedObject = NSLocalizedString("Object", comment: "")
let kLocalizedObjects = NSLocalizedString("Actors or objects", comment: "")
let kLocalizedBricks = NSLocalizedString("Bricks", comment: "")
let kLocalizedSounds = NSLocalizedString("Sounds", comment: "")
let kLocalizedLastAccess = NSLocalizedString("Last access", comment: "")
let kLocalizedLength = NSLocalizedString("Length", comment: "")
let kLocalizedRestart = NSLocalizedString("Restart", comment: "")
let kLocalizedPreview = NSLocalizedString("Preview", comment: "")
let kLocalizedAxes = NSLocalizedString("Axes", comment: "Title of icon shown in the side bar to enable or disable an overlayed view to show the origin of the coordinate system and implicitly the display size.")
let kLocalizedMostDownloaded = NSLocalizedString("Most downloaded", comment: "")
let kLocalizedMostViewed = NSLocalizedString("Most viewed", comment: "")
let kLocalizedNewest = NSLocalizedString("Newest", comment: "")
let kLocalizedVariables = NSLocalizedString("Variables", comment: "")
let kLocalizedLists = NSLocalizedString("Lists", comment: "")
let kLocalizedPhiroBricks = NSLocalizedString("Use Phiro bricks", comment: "")
let kLocalizedArduinoBricks = NSLocalizedString("Use Arduino bricks", comment: "")
let kLocalizedFrontCamera = NSLocalizedString("Front camera", comment: "")
let kLocalizedDisconnectAllDevices = NSLocalizedString("Disconnect all devices", comment: "")
let kLocalizedRemoveKnownDevices = NSLocalizedString("Remove known devices", comment: "")
let kLocalizedRecording = NSLocalizedString("Recording", comment: "")
let kLocalizedError = NSLocalizedString("Error", comment: "")
let kLocalizedMemoryWarning = NSLocalizedString("Not enough Memory", comment: "")
let kLocalizedReportProject = NSLocalizedString("Report as inappropriate", comment: "")
let kLocalizedEnterReason = NSLocalizedString("Enter a reason", comment: "")
let kLocalizedLoginToReport = NSLocalizedString("Please log in to report this project as inappropriate", comment: "")
let kLocalizedName = NSLocalizedString("Name", comment: "")
let kLocalizedDownloaded = NSLocalizedString("Download successful", comment: "")
let kLocalizedSettings = NSLocalizedString("Settings", comment: "")
let kLocalizedOff = NSLocalizedString("off", comment: "")
let kLocalizedOn = NSLocalizedString("on", comment: "")
let kLocalizedCameraBack = NSLocalizedString("back", comment: "")
let kLocalizedCameraFront = NSLocalizedString("front", comment: "")
let kLocalizedMoreInformation = NSLocalizedString("More information", comment: "")

//************************************************************************************************************
//**********************************       SHORT DESCRIPTIONS      *******************************************
//************************************************************************************************************

let kLocalizedCantRestartProject = NSLocalizedString("Can't restart project!", comment: "")
let kLocalizedThisFeatureIsComingSoon = NSLocalizedString("This feature is coming soon!", comment: "")
let kLocalizedNoDescriptionAvailable = NSLocalizedString("No description available", comment: "")
let kLocalizedNoSearchResults = NSLocalizedString("No search results", comment: "")
let kLocalizedUnableToLoadProject = NSLocalizedString("Unable to load project!", comment: "")
let kLocalizedThisActionCannotBeUndone = NSLocalizedString("This action can not be undone!", comment: "")
let kLocalizedErrorInternetConnection = NSLocalizedString("An unknown error occurred. Check your Internet connection.", comment: "")
let kLocalizedErrorUnknown = NSLocalizedString("An unknown error occurred. Please try again later.", comment: "")
let kLocalizedInvalidURLGiven = NSLocalizedString("Invalid URL given!", comment: "")
let kLocalizedNoCamera = NSLocalizedString("No camera available", comment: "")
let kLocalizedImagePickerSourceNotAvailable = NSLocalizedString("Image source not available", comment: "")
let kLocalizedBluetoothPoweredOff = NSLocalizedString("Bluetooth is turned off. Please turn it on to connect to a Bluetooth device.", comment: "")
let kLocalizedBluetoothNotAvailable = NSLocalizedString("Bluetooth is not available. Either your device does not support Bluetooth 4.0 or your Bluetooth chip is damaged. Please check it by connection to another Bluetooth device in the Settings.", comment: "")
let kLocalizedDisconnectBluetoothDevices = NSLocalizedString("All Bluetooth devices successfully disconnected", comment: "")
let kLocalizedRemovedKnownBluetoothDevices = NSLocalizedString("All known Bluetooth devices successfully removed", comment: "")

//************************************************************************************************************
//**********************************       LONG DESCRIPTIONS      ********************************************
//************************************************************************************************************

let kLocalizedWelcomeDescription = NSLocalizedString("Pocket Code let's you play great games and run other fantastic apps like for instance presentations, quizzes and so on.", comment: "")
let kLocalizedExploreDescription = NSLocalizedString("By switching to the section \"Explore\" you can discover more interesting projects from people all over the world.", comment: "")
let kLocalizedCreateAndEditDescription = NSLocalizedString("You are also able to build your own apps, remix existing ones and share them with your friends and other exciting people around the world.", comment: "")
let kLocalizedAboutPocketCodeDescription = NSLocalizedString("Pocket Code is a programming environment for iOS for the visual programming language Catrobat. The code of Pocket Code is mostly under GNU AGPL v3 licence. For further information to the licence please visit following links:", comment: "")
let kLocalizedTermsOfUseDescription = NSLocalizedString("In order to be allowed to use Pocket Code and other executables offered by the Catrobat project, you must agree to our Terms of Use and strictly follow them when you use Pocket Code and our other executables. Please see the link below for their precise formulation.", comment: "")
let kLocalizedNotEnoughFreeMemoryDescription = NSLocalizedString("Not enough free memory to download this project. Please delete some of your projects", comment: "")
let kLocalizedProjectNotFound = NSLocalizedString("The requested project can not be found. Please choose a different one.", comment: "")
let kLocalizedInvalidZip = NSLocalizedString("The requested project can not be loaded. Please try again later.", comment: "")
let kLocalizedEnterYourProjectNameHere = NSLocalizedString("Enter your project name here...", comment: "Placeholder for project-name input field")
let kLocalizedEnterNameForImportedProjectTitle = NSLocalizedString("Import File", comment: "Title of prompt shown when a *.catrobat file is imported from a third-party app.")
let kLocalizedEnterYourProjectDescriptionHere = NSLocalizedString("Enter your project description here...", comment: "Placeholder for project-description input field")
let kLocalizedEnterYourMessageHere = NSLocalizedString("Enter your message here...", comment: "Placeholder for message input field")
let kLocalizedEnterYourVariableNameHere = NSLocalizedString("Enter your variable name here...", comment: "Placeholder for variable input field")
let kLocalizedEnterYourListNameHere = NSLocalizedString("Enter your list name here...", comment: "Placeholder for list input field")
let kLocalizedEnterYourObjectNameHere = NSLocalizedString("Enter your object name here...", comment: "Placeholder for add object-name input field")
let kLocalizedEnterYourImageNameHere = NSLocalizedString("Enter your image name here...", comment: "Placeholder for add image-name input field")
let kLocalizedEnterYourSoundNameHere = NSLocalizedString("Enter your sound name here...", comment: "Placeholder for add sound-name input field")
let kLocalizedNoOrTooShortInputDescription = NSLocalizedString("No input. Please enter at least %lu character(s).", comment: "")
let kLocalizedTooLongInputDescription = NSLocalizedString("The input is too long. Please enter maximal %lu character(s).", comment: "")
let kLocalizedSpaceInputDescription = NSLocalizedString("Only space is not allowed. Please enter at least %lu other character(s).", comment: "")
let kLocalizedSpecialCharInputDescription = NSLocalizedString("Only special characters are not allowed. Please enter at least %lu other character(s).", comment: "")
let kLocalizedBlockedCharInputDescription = NSLocalizedString("The name contains blocked characters. Please try again!", comment: "")
let kLocalizedInvalidInputDescription = NSLocalizedString("Invalid input entered, try again.", comment: "")
let kLocalizedProjectNameAlreadyExistsDescription = NSLocalizedString("A project with the same name already exists, try again.", comment: "")
let kLocalizedInvalidDescriptionDescription = NSLocalizedString("The description contains invalid characters, try again.", comment: "")
let kLocalizedObjectNameAlreadyExistsDescription = NSLocalizedString("An object with the same name already exists, try again.", comment: "")
let kLocalizedMessageAlreadyExistsDescription = NSLocalizedString("A message with the same name already exists, try again.", comment: "")
let kLocalizedInvalidImageNameDescription = NSLocalizedString("No or invalid image name entered, try again.", comment: "")
let kLocalizedInvalidSoundNameDescription = NSLocalizedString("No or invalid sound name entered, try again.", comment: "")
let kLocalizedImageNameAlreadyExistsDescription = NSLocalizedString("An image with the same name already exists, try again.", comment: "")
let kLocalizedUnableToPlaySoundDescription = NSLocalizedString("Unable to play that sound!\nMaybe this is no valid sound or the file is corrupt.", comment: "")
let kLocalizedDeviceIsInMutedStateIPhoneDescription = NSLocalizedString("Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the left side of your iPhone and tap on play again.", comment: "")
let kLocalizedDeviceIsInMutedStateIPadDescription = NSLocalizedString("Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the right side of your iPad and tap on play again.", comment: "")
let kLocalizedProjectAlreadyDownloadedDescription = NSLocalizedString("You have already downloaded this project!", comment: "")
let kLocalizedNoAccesToImagesCheckSettingsDescription = NSLocalizedString("Pocket Code has no access to your images. To permit access, tap settings and activate images. Your drawing will automatically be saved to PocketCode for you.", comment: "")
let kLocalizedNoAccesToCameraCheckSettingsDescription = NSLocalizedString("Pocket Code has no access to your camera. To permit access, tap settings and activate camera. Your drawing will automatically be saved to PocketCode for you.", comment: "")
let kLocalizedNoAccesToMicrophoneCheckSettingsDescription = NSLocalizedString("Pocket Code has no access to your microphone. To permit access, tap settings and activate microphone.", comment: "")
let kLocalizedUnsupportedElementsDescription = NSLocalizedString("Following features used in this project are not compatible with this version of Pocket Code:", comment: "")

//************************************************************************************************************
//*******************************       BRICK TITLE TRANSLATIONS      ****************************************
//************************************************************************************************************

// control bricks
let kLocalizedScript = NSLocalizedString("Script", comment: "")
let kLocalizedWhenProjectStarted = NSLocalizedString("When project started", comment: "")
let kLocalizedWhenTapped = NSLocalizedString("When tapped", comment: "")
let kLocalizedTouchDown = NSLocalizedString("When stage is tapped", comment: "")
let kLocalizedWait = NSLocalizedString("Wait", comment: "")
let kLocalizedSecond = NSLocalizedString("second ", comment: "")
let kLocalizedSeconds = NSLocalizedString("seconds ", comment: "")
let kLocalizedVibrateFor = NSLocalizedString("Vibrate for", comment: "")
let kLocalizedWhenYouReceive = NSLocalizedString("When you receive", comment: "")
let kLocalizedBroadcast = NSLocalizedString("Broadcast", comment: "")
let kLocalizedBroadcastAndWait = NSLocalizedString("Broadcast and wait", comment: "")
let kLocalizedNote = NSLocalizedString("Note", comment: "")
let kLocalizedForever = NSLocalizedString("Forever", comment: "")
let kLocalizedIfBegin = NSLocalizedString("If", comment: "")
let kLocalizedIfBeginSecondPart = NSLocalizedString("is true then", comment: "")
let kLocalizedElse = NSLocalizedString("Else", comment: "")
let kLocalizedEndIf = NSLocalizedString("End if", comment: "")
let kLocalizedWaitUntil = NSLocalizedString("Wait until", comment: "")
let kLocalizedRepeat = NSLocalizedString("Repeat", comment: "")
let kLocalizedRepeatUntil = NSLocalizedString("Repeat until", comment: "")
let kLocalizedUntilIsTrue = NSLocalizedString("is true", comment: "")
let kLocalizedTime = NSLocalizedString("time", comment: "")
let kLocalizedTimes = NSLocalizedString("times", comment: "")
let kLocalizedEndOfLoop = NSLocalizedString("End of Loop", comment: "")

// motion bricks
let kLocalizedPlaceAt = NSLocalizedString("Place at ", comment: "")
let kLocalizedXLabel = NSLocalizedString("x: ", comment: "")
let kLocalizedYLabel = NSLocalizedString("y: ", comment: "")
let kLocalizedSetX = NSLocalizedString("Set x to ", comment: "")
let kLocalizedSetY = NSLocalizedString("Set y to ", comment: "")
let kLocalizedChangeXBy = NSLocalizedString("Change x by ", comment: "")
let kLocalizedChangeYBy = NSLocalizedString("Change y by ", comment: "")
let kLocalizedIfIsTrueThenOnEdgeBounce = NSLocalizedString("If on edge, bounce", comment: "")
let kLocalizedMove = NSLocalizedString("Move", comment: "")
let kLocalizedStep = NSLocalizedString("step", comment: "")
let kLocalizedSteps = NSLocalizedString("steps", comment: "")
let kLocalizedTurnLeft = NSLocalizedString("Turn left", comment: "")
let kLocalizedTurnRight = NSLocalizedString("Turn right", comment: "")
let kLocalizedDegrees = NSLocalizedString("degrees", comment: "")
let kLocalizedPointInDirection = NSLocalizedString("Point in direction", comment: "")
let kLocalizedPointTowards = NSLocalizedString("Point towards", comment: "")
let kLocalizedGlide = NSLocalizedString("Glide", comment: "")
let kLocalizedToX = NSLocalizedString("to x:", comment: "")
let kLocalizedGoBack = NSLocalizedString("Go back", comment: "")
let kLocalizedLayer = NSLocalizedString("layer", comment: "")
let kLocalizedLayers = NSLocalizedString("layers", comment: "")
let kLocalizedComeToFront = NSLocalizedString("Go to front", comment: "")

// look bricks
let kLocalizedLook = NSLocalizedString("Look", comment: "")
let kLocalizedSetLook = NSLocalizedString("Switch to look", comment: "")
let kLocalizedSetBackground = NSLocalizedString("Set background", comment: "")
let kLocalizedNextLook = NSLocalizedString("Next look", comment: "")
let kLocalizedNextBackground = NSLocalizedString("Next background", comment: "")
let kLocalizedPreviousLook = NSLocalizedString("Previous look", comment: "")
let kLocalizedPreviousBackground = NSLocalizedString("Previous background", comment: "")
let kLocalizedSetSizeTo = NSLocalizedString("Set size to", comment: "")
let kLocalizedChangeSizeByN = NSLocalizedString("Change size by", comment: "")
let kLocalizedHide = NSLocalizedString("Hide", comment: "")
let kLocalizedShow = NSLocalizedString("Show", comment: "")
let kLocalizedLedOn = NSLocalizedString("Flashlight on", comment: "")
let kLocalizedLedOff = NSLocalizedString("Flashlight off", comment: "")
let kLocalizedSetTransparency = NSLocalizedString("Set transparency ", comment: "")
let kLocalizedChangeTransparency = NSLocalizedString("Change transparency ", comment: "")
let kLocalizedSetBrightness = NSLocalizedString("Set brightness ", comment: "")
let kLocalizedChangeBrightness = NSLocalizedString("Change brightness ", comment: "")
let kLocalizedTo = NSLocalizedString("to", comment: "")
let kLocalizedBy = NSLocalizedString("by", comment: "")
let kLocalizedClearGraphicEffect = NSLocalizedString("Clear graphic effects", comment: "")
let kLocalizedSetColor = NSLocalizedString("Set color ", comment: "")
let kLocalizedChangeColor = NSLocalizedString("Change color ", comment: "")
let kLocalizedFlash = NSLocalizedString("Turn flashlight", comment: "")
let kLocalizedCamera = NSLocalizedString("Turn camera", comment: "")
let kLocalizedChooseCamera = NSLocalizedString("Use camera", comment: "")
let kLocalizedFor = NSLocalizedString("for", comment: "")

// sound bricks
let kLocalizedSound = NSLocalizedString("Sound", comment: "")
let kLocalizedPlaySound = NSLocalizedString("Start sound", comment: "")
let kLocalizedPlaySoundAndWait = NSLocalizedString("Start sound and wait", comment: "")
let kLocalizedStopAllSounds = NSLocalizedString("Stop all sounds", comment: "")
let kLocalizedSetVolumeTo = NSLocalizedString("Set volume to", comment: "")
let kLocalizedChangeVolumeBy = NSLocalizedString("Change volume by", comment: "")
let kLocalizedSay = NSLocalizedString("Say", comment: "")
let kLocalizedThink = NSLocalizedString("Think", comment: "")
let kLocalizedSpeak = NSLocalizedString("Speak", comment: "")
let kLocalizedAndWait = NSLocalizedString("and wait", comment: "")

// variable
let kLocalizedSetVariable = NSLocalizedString("Set variable", comment: "")
let kLocalizedChangeVariable = NSLocalizedString("Change variable", comment: "")
let kLocalizedShowVariable = NSLocalizedString("Show variable", comment: "")
let kLocalizedHideVariable = NSLocalizedString("Hide variable", comment: "")
let kLocalizedAt = NSLocalizedString("at ", comment: "")

//userlist
let kLocalizedUserListAdd = NSLocalizedString("Add", comment: "")
let kLocalizedUserListTo = NSLocalizedString("to list", comment: "")
let kLocalizedUserListDeleteItemFrom = NSLocalizedString("Delete item from list", comment: "")
let kLocalizedUserListAtPosition = NSLocalizedString("at position", comment: "")
let kLocalizedUserListInsert = NSLocalizedString("Insert", comment: "")
let kLocalizedUserListInto = NSLocalizedString("into list", comment: "")
let kLocalizedUserListReplaceItemInList = NSLocalizedString("Replace item in list", comment: "")
let kLocalizedUserListWith = NSLocalizedString("with", comment: "")

//Note
let kLocalizedNoteAddCommentHere = NSLocalizedString("add comment here...", comment: "")

//Bubble
let kLocalizedHello = NSLocalizedString("Hello!", comment: "")
let kLocalizedHmmmm = NSLocalizedString("Hmmmm!", comment: "")

// Broadcast
let kLocalizedBroadcastMessage1 = NSLocalizedString("message 1", comment: "")

// phiro bricks
let kLocalizedStopPhiroMotor = NSLocalizedString("Stop Phiro motor", comment: "")
let kLocalizedPhiroSpeed = NSLocalizedString("Speed", comment: "")
let kLocalizedPhiroMoveForward = NSLocalizedString("Move Phiro motor forward", comment: "")
let kLocalizedPhiroMoveBackward = NSLocalizedString("Move Phiro motor backward", comment: "")
let kLocalizedPhiroRGBLight = NSLocalizedString("Set Phiro light", comment: "")
let kLocalizedPhiroRGBLightRed = NSLocalizedString("red", comment: "")
let kLocalizedPhiroRGBLightGreen = NSLocalizedString("green", comment: "")
let kLocalizedPhiroRGBLightBlue = NSLocalizedString("blue", comment: "")
let kLocalizedPhiroPlayTone = NSLocalizedString("Play Phiro music\n", comment: "")
let kLocalizedPhiroPlayDuration = NSLocalizedString("Duration", comment: "")
let kLocalizedPhiroSecondsToPlay = NSLocalizedString("seconds", comment: "")
let kLocalizedPhiroIfLogic = NSLocalizedString("If", comment: "")
let kLocalizedPhiroThenLogic = NSLocalizedString("is true then", comment: "")

// Arduino bricks
let kLocalizedArduinoSetDigitalValue = NSLocalizedString("Set Arduino digital pin", comment: "")
let kLocalizedArduinoSetPinValueTo = NSLocalizedString("to", comment: "")
let kLocalizedArduinoSendPWMValue = NSLocalizedString("Set Arduino PWM~ pin", comment: "")

//Unsupported elements
let kLocalizedUnsupportedElements = NSLocalizedString("Unsupported Elements", comment: "")
let kLocalizedUnsupportedBrick = NSLocalizedString("Unsupported Brick:", comment: "")
let kLocalizedUnsupportedScript = NSLocalizedString("Unsupported Script:", comment: "")

//************************************************************************************************************
//**********************************       Login/Upload            *******************************************
//************************************************************************************************************

let kLocalizedLogin = NSLocalizedString("Login", comment: "")
let kLocalizedLogout = NSLocalizedString("Logout", comment: "")
let kLocalizedUsername = NSLocalizedString("Username", comment: "")
let kLocalizedPassword = NSLocalizedString("Password", comment: "")
let kLocalizedConfirmPassword = NSLocalizedString("Confirm password", comment: "")
let kLocalizedEmail = NSLocalizedString("Email", comment: "")
let kLocalizedRegister = NSLocalizedString("Create account", comment: "")
let kLocalizedUploadProject = NSLocalizedString("Upload project", comment: "")
let kLocalizedLoginUsernameNecessary = NSLocalizedString("Username must not be blank", comment: "")
let kLocalizedLoginEmailNotValid = NSLocalizedString("Your email seems to be invalid", comment: "")
let kLocalizedLoginPasswordNotValid = NSLocalizedString("Password is not vaild! \n It has to contain at least 6 characters/symbols", comment: "")
let kLocalizedRegisterPasswordConfirmationNoMatch = NSLocalizedString("Passwords do not match", comment: "")
let kLocalizedUploadProjectNecessary = NSLocalizedString("Project Name is necessary!", comment: "")
let kLocalizedTermsAgreementPart = NSLocalizedString("By registering you agree to our", comment: "")
let kLocalizedUploadSuccessful = NSLocalizedString("Upload successful", comment: "")
let kLocalizedRegistrationSuccessful = NSLocalizedString("Registration successful", comment: "")
let kLocalizedLoginSuccessful = NSLocalizedString("Login successful", comment: "")
let kUploadSelectedProject = NSLocalizedString("Upload selected project", comment: "")
let kLocalizedUploadProblem = NSLocalizedString("Problems occured while uploading your project", comment: "")
let kLocalizedUploadSelectProject = NSLocalizedString("Please select a project to upload", comment: "")
let kLocalizedNoWhitespaceAllowed = NSLocalizedString("No whitespace character allowed", comment: "")
let kLocalizedAuthenticationFailed = NSLocalizedString("Authentication failed", comment: "")

let kLocalizedInfoLogin = NSLocalizedString("Login", comment: "")
let kLocalizedInfoRegister = NSLocalizedString("Register", comment: "")

//************************************************************************************************************
//************************************       PAINT                ********************************************
//************************************************************************************************************

let kLocalizedPaintWidth = NSLocalizedString("Width selection", comment: "paint")
let kLocalizedPaintRed = NSLocalizedString("Red", comment: "paint")
let kLocalizedPaintGreen = NSLocalizedString("Green", comment: "paint")
let kLocalizedPaintBlue = NSLocalizedString("Blue", comment: "paint")
let kLocalizedPaintAlpha = NSLocalizedString("Alpha", comment: "paint")
let kLocalizedPaintBrush = NSLocalizedString("Brush", comment: "paint")
let kLocalizedPaintEraser = NSLocalizedString("Eraser", comment: "paint")
let kLocalizedPaintResize = NSLocalizedString("Resize", comment: "paint")
let kLocalizedPaintPipette = NSLocalizedString("Pipette", comment: "paint")
let kLocalizedPaintMirror = NSLocalizedString("Mirror", comment: "paint")
let kLocalizedPaintImage = NSLocalizedString("Image", comment: "paint")
let kLocalizedPaintLine = NSLocalizedString("Line", comment: "paint")
let kLocalizedPaintRect = NSLocalizedString("Rectangle / Square", comment: "paint")
let kLocalizedPaintCircle = NSLocalizedString("Ellipse / Circle", comment: "paint")
let kLocalizedPaintStamp = NSLocalizedString("Stamp", comment: "paint")
let kLocalizedPaintRotate = NSLocalizedString("Rotate", comment: "paint")
let kLocalizedPaintFill = NSLocalizedString("Fill", comment: "paint")
let kLocalizedPaintZoom = NSLocalizedString("Zoom", comment: "paint")
let kLocalizedPaintPointer = NSLocalizedString("Pointer", comment: "paint")
let kLocalizedPaintTextTool = NSLocalizedString("Text", comment: "paint")
let kLocalizedPaintSaveChanges = NSLocalizedString("Do you want to save the changes", comment: "paint")
let kLocalizedPaintMenuButtonTitle = NSLocalizedString("Menu", comment: "paint")
let kLocalizedPaintSelect = NSLocalizedString("Select option:", comment: "paint")
let kLocalizedPaintSave = NSLocalizedString("Save to cameraRoll", comment: "paint")
let kLocalizedPaintClose = NSLocalizedString("Close Paint", comment: "paint")
let kLocalizedPaintNewCanvas = NSLocalizedString("New canvas", comment: "paint")
let kLocalizedPaintPickTool = NSLocalizedString("Please pick a tool", comment: "paint")
let kLocalizedPaintNoCrop = NSLocalizedString("Nothing to crop!", comment: "paint")
let kLocalizedPaintAskNewCanvas = NSLocalizedString("Do you really want to delete the current drawing?", comment: "paint")
let kLocalizedPaintRound = NSLocalizedString("round", comment: "paint")
let kLocalizedPaintSquare = NSLocalizedString("square", comment: "paint")
let kLocalizedPaintPocketPaint = NSLocalizedString("Pocket Paint", comment: "paint")
let kLocalizedPaintStamped = NSLocalizedString("Stamped", comment: "paint")
let kLocalizedPaintInserted = NSLocalizedString("Inserted", comment: "paint")
let kLocalizedPaintText = NSLocalizedString("Text:", comment: "paint")
let kLocalizedPaintAttributes = NSLocalizedString("Attributes:", comment: "paint")
let kLocalizedPaintBold = NSLocalizedString("bold", comment: "paint")
let kLocalizedPaintItalic = NSLocalizedString("italic", comment: "paint")
let kLocalizedPaintUnderline = NSLocalizedString("underline", comment: "paint")
let kLocalizedPaintTextAlert = NSLocalizedString("Please enter a text.", comment: "paint")

//************************************************************************************************************
//************************************       FormulaEditor        ********************************************
//************************************************************************************************************

let kUIActionSheetTitleSelectLogicalOperator = NSLocalizedString("Select logical operator", comment: "")
let kUIActionSheetTitleSelectMathematicalFunction = NSLocalizedString("Select mathematical function", comment: "")
let kUIFENumbers = NSLocalizedString("Numbers", comment: "")
let kUIFELogic = NSLocalizedString("Logic", comment: "")
let kUIFEVar = NSLocalizedString("New", comment: "")
let kUIFETake = NSLocalizedString("Choose", comment: "")
let kUIFEDelete = NSLocalizedString("Delete", comment: "")
let kUIFEMath = NSLocalizedString("Math", comment: "")
let kUIFEObject = NSLocalizedString("Object", comment: "")
let kUIFESensor = NSLocalizedString("Sensors", comment: "")
let kUIFEVariable = NSLocalizedString("Variables", comment: "")
let kUIFEVariableList = NSLocalizedString("Var/List", comment: "")
let kUIFECompute = NSLocalizedString("Compute", comment: "")
let kUIFEDone = NSLocalizedString("Done", comment: "")
let kUIFEError = NSLocalizedString("Error", comment: "")
let kUIFEtooLongFormula = NSLocalizedString("Formula too long!", comment: "")
let kUIFEResult = NSLocalizedString("Result", comment: "")
let kUIFEComputed = NSLocalizedString("Computed result is %.2f", comment: "")
let kUIFEComputedTrue = NSLocalizedString("Computed result is TRUE", comment: "")
let kUIFEComputedFalse = NSLocalizedString("Computed result is FALSE", comment: "")
let kUIFENewVar = NSLocalizedString("New variable", comment: "")
let kUIFENewList = NSLocalizedString("New list", comment: "")
let kUIFENewVarExists = NSLocalizedString("Name already exists.", comment: "")
let kUIFEonly15Char = NSLocalizedString("only 15 characters allowed", comment: "")
let kUIFEVarName = NSLocalizedString("Variable name:", comment: "")
let kUIFEListName = NSLocalizedString("List name:", comment: "")
let kUIFEOtherName = NSLocalizedString("Please choose another name:", comment: "")
let kUIFEAddNewText = NSLocalizedString("Abc", comment: "")

let kUIFEProjectVars = NSLocalizedString("Project variables:", comment: "")
let kUIFEObjectVars = NSLocalizedString("Object variables:", comment: "")
let kUIFEProjectLists = NSLocalizedString("Project lists:", comment: "")
let kUIFEObjectLists = NSLocalizedString("Object lists:", comment: "")
let kUIFEDeleteVarBeingUsed = NSLocalizedString("This variable can not be deleted because it is still in use.", comment: "")
let kUIFEActionVar = NSLocalizedString("Variable type", comment: "")
let kUIFEActionList = NSLocalizedString("List type", comment: "")
let kUIFEActionVarObj = NSLocalizedString("for this actor or object", comment: "")
let kUIFEActionVarPro = NSLocalizedString("for all actors or objects", comment: "")
let kUIFEChangesSaved = NSLocalizedString("Changes saved.", comment: "")
let kUIFEChangesDiscarded = NSLocalizedString("Changes discarded.", comment: "")
let kUIFESyntaxError = NSLocalizedString("Syntax Error!", comment: "")
let kUIFEEmptyInput = NSLocalizedString("Empty input!", comment: "")

let kUIFEVarOrList = NSLocalizedString("Variable or list", comment: "")

let kUIFEFunctionSqrt = NSLocalizedString("sqrt", comment: "")
let kUIFEFunctionTrue = NSLocalizedString("true", comment: "")
let kUIFEFunctionFalse = NSLocalizedString("false", comment: "")
let kUIFEFunctionLetter = NSLocalizedString("letter", comment: "")
let kUIFEFunctionJoin = NSLocalizedString("join", comment: "")
let kUIFEFunctionLength = NSLocalizedString("length", comment: "")
let kUIFEFunctionFloor = NSLocalizedString("floor", comment: "")
let kUIFEFunctionCeil = NSLocalizedString("ceil", comment: "")
let kUIFEFunctionNumberOfItems = NSLocalizedString("number of items", comment: "")
let kUIFEFunctionElement = NSLocalizedString("element", comment: "")
let kUIFEFunctionContains = NSLocalizedString("contains", comment: "")

let kUIFEFunctionScreenIsTouched = NSLocalizedString("stage is touched", comment: "")
let kUIFEFunctionScreenTouchX = NSLocalizedString("stage touch x", comment: "")
let kUIFEFunctionScreenTouchY = NSLocalizedString("stage touch y", comment: "")

let kUIFEOperatorAnd = NSLocalizedString("and", comment: "")
let kUIFEOperatorNot = NSLocalizedString("not", comment: "")
let kUIFEOperatorOr = NSLocalizedString("or", comment: "")

let kUIFEObjectTransparency = NSLocalizedString("transparency", comment: "")
let kUIFEObjectBrightness = NSLocalizedString("brightness", comment: "")
let kUIFEObjectColor = NSLocalizedString("color", comment: "")
let kUIFEObjectLookNumber = NSLocalizedString("look number", comment: "")
let kUIFEObjectLookName = NSLocalizedString("look name", comment: "")
let kUIFEObjectBackgroundNumber = NSLocalizedString("background number", comment: "")
let kUIFEObjectBackgroundName = NSLocalizedString("background name", comment: "")
let kUIFEObjectSize = NSLocalizedString("size", comment: "")
let kUIFEObjectDirection = NSLocalizedString("direction", comment: "")
let kUIFEObjectLayer = NSLocalizedString("layer", comment: "")
let kUIFEObjectPositionX = NSLocalizedString("position x", comment: "")
let kUIFEObjectPositionY = NSLocalizedString("position y", comment: "")

let kUIFESensorDateYear = NSLocalizedString("year", comment: "")
let kUIFESensorDateMonth = NSLocalizedString("month", comment: "")
let kUIFESensorDateDay = NSLocalizedString("day", comment: "")
let kUIFESensorDateWeekday = NSLocalizedString("weekday", comment: "")
let kUIFESensorTimeHour = NSLocalizedString("hour", comment: "")
let kUIFESensorTimeMinute = NSLocalizedString("minute", comment: "")
let kUIFESensorTimeSecond = NSLocalizedString("second", comment: "")

let kUIFESensorCompass = NSLocalizedString("compass", comment: "")
let kUIFESensorLoudness = NSLocalizedString("loudness", comment: "")
let kUIFESensorAccelerationX = NSLocalizedString("acceleration x", comment: "")
let kUIFESensorAccelerationY = NSLocalizedString("acceleration y", comment: "")
let kUIFESensorAccelerationZ = NSLocalizedString("acceleration z", comment: "")
let kUIFESensorInclinationX = NSLocalizedString("inclination x", comment: "")
let kUIFESensorInclinationY = NSLocalizedString("inclination y", comment: "")
let kUIFESensorLatitude = NSLocalizedString("latitude", comment: "")
let kUIFESensorLongitude = NSLocalizedString("longitude", comment: "")
let kUIFESensorLocationAccuracy = NSLocalizedString("location accuracy", comment: "")
let kUIFESensorAltitude = NSLocalizedString("altitude", comment: "")
let kUIFESensorFingerTouched = NSLocalizedString("stage is touched", comment: "")
let kUIFESensorFingerX = NSLocalizedString("stage touch x", comment: "")
let kUIFESensorFingerY = NSLocalizedString("stage touch y", comment: "")
let kUIFESensorLastFingerIndex = NSLocalizedString("last stage touch index", comment: "")
let kUIFESensorPhiroFrontLeft = NSLocalizedString("phiro front left", comment: "")
let kUIFESensorPhiroFrontRight = NSLocalizedString("phiro front right", comment: "")
let kUIFESensorPhiroSideLeft = NSLocalizedString("phiro side left", comment: "")
let kUIFESensorPhiroSideRight = NSLocalizedString("phiro side right", comment: "")
let kUIFESensorPhiroBottomLeft = NSLocalizedString("phiro bottom left", comment: "")
let kUIFESensorPhiroBottomRight = NSLocalizedString("phiro bottom right", comment: "")

let kUIFESensorArduinoAnalog = NSLocalizedString("arduino analog", comment: "")

let kUIFESensorArduinoDigital = NSLocalizedString("arduino digital", comment: "")

let kLocalizedSensorCompass = NSLocalizedString("compass", comment: "")
let kLocalizedSensorLocation = NSLocalizedString("location", comment: "")
let kLocalizedSensorDeviceMotion = NSLocalizedString("device motion-sensor", comment: "")
let kLocalizedSensorAcceleration = NSLocalizedString("acceleration-sensor", comment: "")
let kLocalizedSensorRotation = NSLocalizedString("gyro-sensor", comment: "")
let kLocalizedSensorMagnetic = NSLocalizedString("magnetic-sensor", comment: "")
let kLocalizedVibration = NSLocalizedString("vibration", comment: "")
let kLocalizedSensorLoudness = NSLocalizedString("loudness", comment: "")
let kLocalizedSensorLED = NSLocalizedString("LED", comment: "")
let kLocalizedNotAvailable = NSLocalizedString("not available. Continue anyway?", comment: "")

let kUIFESensorFaceDetected = NSLocalizedString("face detected", comment: "")
let kUIFESensorFaceSize = NSLocalizedString("facesize", comment: "")
let kUIFESensorFaceX = NSLocalizedString("faceposition x", comment: "")
let kUIFESensorFaceY = NSLocalizedString("faceposition y", comment: "")

let kUIFEUnknownElementType = NSLocalizedString("Unknown Element", comment: "")

let kUIFENewText = NSLocalizedString("New text", comment: "")
let kUIFETextMessage = NSLocalizedString("Text message:", comment: "")

//************************************************************************************************************
//************************************       BrickCategoryTitles        **************************************
//************************************************************************************************************

let kLocalizedCategoryFrequentlyUsed = NSLocalizedString("Frequently used", comment: "Title of View where the user can see the frequently used bricks.")
let kLocalizedCategoryControl = NSLocalizedString("Control", comment: "")
let kLocalizedCategoryMotion = NSLocalizedString("Motion", comment: "")
let kLocalizedCategoryLook = NSLocalizedString("Look", comment: "")
let kLocalizedCategorySound = NSLocalizedString("Sound", comment: "")
let kLocalizedCategoryVariable = NSLocalizedString("Variable", comment: "")
let kLocalizedCategoryArduino = NSLocalizedString("Arduino", comment: "")
let kLocalizedCategoryPhiro = NSLocalizedString("Phiro", comment: "")

//************************************************************************************************************
//************************************       PhiroDefines         ********************************************
//************************************************************************************************************

let kLocalizedPhiroBoth = NSLocalizedString("Both", comment: "")
let kLocalizedPhiroLeft = NSLocalizedString("Left", comment: "")
let kLocalizedPhiroRight = NSLocalizedString("Right", comment: "")

let kLocalizedPhiroDO = NSLocalizedString("DO", comment: "")
let kLocalizedPhiroRE = NSLocalizedString("RE", comment: "")
let kLocalizedPhiroMI = NSLocalizedString("MI", comment: "")
let kLocalizedPhiroFA = NSLocalizedString("FA", comment: "")
let kLocalizedPhiroSO = NSLocalizedString("SO", comment: "")
let kLocalizedPhiroLA = NSLocalizedString("LA", comment: "")
let kLocalizedPhiroTI = NSLocalizedString("TI", comment: "")

let klocalizedBluetoothSearch = NSLocalizedString("Search", comment: "bluetooth")
let klocalizedBluetoothKnown = NSLocalizedString("Known devices", comment: "bluetooth")
let klocalizedBluetoothSelectPhiro = NSLocalizedString("Select Phiro", comment: "bluetooth")
let klocalizedBluetoothSelectArduino = NSLocalizedString("Select Arduino", comment: "bluetooth")
let klocalizedBluetoothConnectionNotPossible = NSLocalizedString("Connection not possible", comment: "bluetooth")
let klocalizedBluetoothConnectionTryResetting = NSLocalizedString("Please try resetting the device and try again.", comment: "bluetooth")
let klocalizedBluetoothConnectionFailed = NSLocalizedString("Connection failed", comment: "bluetooth")
let klocalizedBluetoothCannotConnect = NSLocalizedString("Cannot connect to device, please try resetting the device and try again.", comment: "bluetooth")
let klocalizedBluetoothNotResponding = NSLocalizedString("Cannot connect to device. The device is not responding.", comment: "bluetooth")
let klocalizedBluetoothConnectionLost = NSLocalizedString("Connection lost", comment: "bluetooth")
let klocalizedBluetoothDisconnected = NSLocalizedString("Device disconnected.", comment: "bluetooth")

//************************************************************************************************************
//************************************       MediaLibrary        *********************************************
//************************************************************************************************************

let kLocalizedMediaLibrary = NSLocalizedString("Media library", comment: "")
let kLocalizedMediaLibraryConnectionIssueTitle = NSLocalizedString("Connection failed", comment: "")
let kLocalizedMediaLibraryConnectionIssueMessage = NSLocalizedString("Cannot connect to the media library. Please check your internet connection.", comment: "")
let kLocalizedMediaLibraryImportFailedTitle = NSLocalizedString("Failed to import item", comment: "")
let kLocalizedMediaLibraryImportFailedMessage = NSLocalizedString("The following item could not be imported from the media library:", comment: "")
let kLocalizedMediaLibrarySoundLoadFailureTitle = NSLocalizedString("Failed to load sound", comment: "")
let kLocalizedMediaLibrarySoundLoadFailureMessage = NSLocalizedString("The sound item cannot be loaded", comment: "")
let kLocalizedMediaLibrarySoundPlayFailureTitle = NSLocalizedString("Failed to play sound", comment: "")
let kLocalizedMediaLibrarySoundPlayFailureMessage = NSLocalizedString("The sound item cannot be played", comment: "")

//************************************************************************************************************
//**********************************       FeaturedProjects        *******************************************
//************************************************************************************************************

let kLocalizedFeaturedProjectsLoadFailureTitle = NSLocalizedString("Failed to load featured projects", comment: "")
let kLocalizedFeaturedProjectsLoadFailureMessage = NSLocalizedString("The featured projects cannot be loaded", comment: "")

//************************************************************************************************************
//***********************************       ChartProjects        *********************************************
//************************************************************************************************************

let kLocalizedChartProjectsLoadFailureTitle = NSLocalizedString("Failed to load recent projects", comment: "")
let kLocalizeChartProjectsLoadFailureMessage = NSLocalizedString("The recent projects cannot be loaded", comment: "")

//************************************************************************************************************
//**************************************       Networking        *********************************************
//************************************************************************************************************

let kLocalizedServerTimeoutIssueTitle = NSLocalizedString("Connection failed", comment: "")
let kLocalizedServerTimeoutIssueMessage = NSLocalizedString("Server is taking to long to respond, please try again later.", comment: "")
let kLocalizedUnexpectedErrorTitle = NSLocalizedString("Unexpected Error", comment: "")
let kLocalizedUnexpectedErrorMessage = NSLocalizedString("Unexpected Error, please try again later.", comment: "")

//************************************************************************************************************
//****************************************       Debug        ************************************************
//************************************************************************************************************
let kLocalizedDebugMode = NSLocalizedString("debug", comment: "")

/*
     _       _     _                       _              _         _
    / \   __| | __| |   ___ ___  _ __  ___| |_ __ _ _ __ | |_ ___  | |_ ___
   / _ \ / _` |/ _` |  / __/ _ \| '_ \/ __| __/ _` | '_ \| __/ __| | __/ _ \
  / ___ \ (_| | (_| | | (_| (_) | | | \__ \ || (_| | | | | |_\__ \ | || (_) |
 /_/   \_\__,_|\__,_|  \___\___/|_| |_|___/\__\__,_|_| |_|\__|___/  \__\___/
  _                                            _____                    _       _   _             ____        __ _                   _
 | |    __ _ _ __   __ _ _   _  __ _  __ _  __|_   _| __ __ _ _ __  ___| | __ _| |_(_) ___  _ __ |  _ \  ___ / _(_)_ __   ___  ___  | |__
 | |   / _` | '_ \ / _` | | | |/ _` |/ _` |/ _ \| || '__/ _` | '_ \/ __| |/ _` | __| |/ _ \| '_ \| | | |/ _ \ |_| | '_ \ / _ \/ __| | '_ \
 | |__| (_| | | | | (_| | |_| | (_| | (_| |  __/| || | | (_| | | | \__ \ | (_| | |_| | (_) | | | | |_| |  __/  _| | | | |  __/\__ \_| | | |
 |_____\__,_|_| |_|\__, |\__,_|\__,_|\__, |\___||_||_|  \__,_|_| |_|___/_|\__,_|\__|_|\___/|_| |_|____/ \___|_| |_|_| |_|\___||___(_)_| |_|
                   |___/             |___/
*/
