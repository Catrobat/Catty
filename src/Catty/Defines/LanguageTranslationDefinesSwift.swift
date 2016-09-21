/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
let kLocalizedNewProgram = NSLocalizedString("New Program", comment: "")
let kLocalizedNewMessage = NSLocalizedString("New Message", comment: "")
let kLocalizedBackground = NSLocalizedString("Background", comment: "")
let kLocalizedMyObject = NSLocalizedString("My Object", comment: "Title for first (default) object")
let kLocalizedMyImage = NSLocalizedString("My Image", comment: "Default title of imported photo from camera (taken by camera)")
let kLocalizedMyFirstProgram = NSLocalizedString("My first program", comment: "Name of the default catrobat program (used as filename!!)")
let kLocalizedMole = NSLocalizedString("Mole", comment: "Prefix of default catrobat program object names (except background object)")
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
let kLocalizedChooseSound = NSLocalizedString("Choose sound", comment: "")
let kLocalizedFeaturedPrograms = NSLocalizedString("Featured Programs", comment: "")
let kLocalizedScripts = NSLocalizedString("Scripts", comment: "")
let kLocalizedBackgrounds = NSLocalizedString("Backgrounds", comment: "")
let kLocalizedTapPlusToAdd = NSLocalizedString("Tap \"+\" to add %", comment: "")
let kLocalizedContinue = NSLocalizedString("Continue", comment: "")
let kLocalizedNew = NSLocalizedString("New", comment: "")
let kLocalizedNewElement = NSLocalizedString("New...", comment: "")
let kLocalizedPrograms = NSLocalizedString("Programs", comment: "")
let kLocalizedHelp = NSLocalizedString("Help", comment: "")
let kLocalizedExplore = NSLocalizedString("Explore", comment: "")
let kLocalizedDeletionMenu = NSLocalizedString("Deletion Mode", comment: "")
let kLocalizedAboutPocketCode = NSLocalizedString("About Pocket Code", comment: "")
let kLocalizedTermsOfUse = NSLocalizedString("Terms of Use", comment: "")
let kLocalizedForgotPassword = NSLocalizedString("Forgot password", comment: "")
let kLocalizedRateUs = NSLocalizedString("Rate Us", comment: "")
let kLocalizedPrivacySettings = NSLocalizedString("Privacy Settings", comment: "")
let kLocalizedVersionLabel = NSLocalizedString("v", comment: "")
let kLocalizedBack = NSLocalizedString("Back", comment: "")
let kLocalizedSourceCodeLicenseButtonLabel = NSLocalizedString("Pocket Code Source Code License", comment: "")
let kLocalizedAboutCatrobatButtonLabel = NSLocalizedString("About Catrobat", comment: "")
let kLocalizedEdit = NSLocalizedString("Edit", comment: "")
let kLocalizedCancel = NSLocalizedString("Cancel", comment: "")
let kLocalizedDone = NSLocalizedString("Done", comment: "")
let kLocalizedUndo = NSLocalizedString("Undo", comment: "Button title of alert view to invoke undo if user shakes device")
let kLocalizedUndoDrawingDescription = NSLocalizedString("Undo Drawing?", comment: "Description text in alert view if user shakes the device")
let kLocalizedUndoTypingDescription = NSLocalizedString("Undo Typing?", comment: "Description text in alert view if user shakes the device")
let kLocalizedSelectAllItems = NSLocalizedString("Select All", comment: "")
let kLocalizedUnselectAllItems = NSLocalizedString("Unselect All", comment: "")
let kLocalizedSaveToPocketCode = NSLocalizedString("Save to PocketCode", comment: "")
let kLocalizedEditSounds = NSLocalizedString("Edit Sounds", comment: "Action sheet menu title")
let kLocalizedEditSound = NSLocalizedString("Edit Sound", comment: "Action sheet menu title")
let kLocalizedEditLooks = NSLocalizedString("Edit Looks", comment: "Action sheet menu title")
let kLocalizedEditLook = NSLocalizedString("Edit Look", comment: "Action sheet menu title")
let kLocalizedEditBackground = NSLocalizedString("Edit Background", comment: "Action sheet menu title")
let kLocalizedEditBackgrounds = NSLocalizedString("Edit Backgrounds", comment: "Action sheet menu title")
let kLocalizedEditScript = NSLocalizedString("Edit Script", comment: "Action sheet menu title")
let kLocalizedEditBrick = NSLocalizedString("Edit Brick", comment: "Action sheet menu title")
let kLocalizedAddLook = NSLocalizedString("Add look", comment: "Action sheet menu title")
let kLocalizedLook = NSLocalizedString("look", comment: "LOOK")
let kLocalizedEditProgram = NSLocalizedString("Edit Program", comment: "")
let kLocalizedEditPrograms = NSLocalizedString("Edit Programs", comment: "")
let kLocalizedEditObject = NSLocalizedString("Edit Object", comment: "")
let kLocalizedAddSound = NSLocalizedString("Add sound", comment: "Action sheet menu title")
let kLocalizedSaveScreenshotTo = NSLocalizedString("Save Screenshot to", comment: "Action sheet menu title")
let kLocalizedSelectBrickCategory = NSLocalizedString("Select Brick Category", comment: "")
let kLocalizedClose = NSLocalizedString("Close", comment: "")
let kLocalizedDeleteBrick = NSLocalizedString("Delete Brick", comment: "")
let kLocalizedDeleteThisBrick = NSLocalizedString("Delete this Brick?", comment: "")
let kLocalizedDeleteTheseBricks = NSLocalizedString("Delete these Bricks?", comment: "")
let kLocalizedDeleteCondition = NSLocalizedString("Delete Condition", comment: "")
let kLocalizedDeleteThisCondition = NSLocalizedString("Delete this Condition?", comment: "")
let kLocalizedDeleteTheseConditions = NSLocalizedString("Delete these Conditions?", comment: "")
let kLocalizedDeleteLoop = NSLocalizedString("Delete Loop", comment: "")
let kLocalizedDeleteThisLoop = NSLocalizedString("Delete this Loop?", comment: "")
let kLocalizedDeleteTheseLoops = NSLocalizedString("Delete these Loops?", comment: "")
let kLocalizedDeleteScript = NSLocalizedString("Delete Script", comment: "")
let kLocalizedDeleteThisScript = NSLocalizedString("Delete this Script?", comment: "")
let kLocalizedDeleteTheseScripts = NSLocalizedString("Delete these Scripts?", comment: "")
let kLocalizedAnimateBrick = NSLocalizedString("Animate Brick-Parts", comment: "")
let kLocalizedCopyBrick = NSLocalizedString("Copy Brick", comment: "")
let kLocalizedEditFormula = NSLocalizedString("Edit Formula", comment: "")
let kLocalizedMoveBrick = NSLocalizedString("Move Brick", comment: "")
let kLocalizedDeleteSounds = NSLocalizedString("Delete Sounds", comment: "")
let kLocalizedMoveSounds = NSLocalizedString("Move Sounds", comment: "")
let kLocalizedHideDetails = NSLocalizedString("Hide Details", comment: "")
let kLocalizedShowDetails = NSLocalizedString("Show Details", comment: "")
let kLocalizedDeleteLooks = NSLocalizedString("Delete Looks", comment: "")
let kLocalizedDeleteBackgrounds = NSLocalizedString("Delete Backgrounds", comment: "")
let kLocalizedMoveLooks = NSLocalizedString("Move Looks", comment: "")
let kLocalizedCopyLooks = NSLocalizedString("Copy Looks", comment: "")
let kLocalizedFromCamera = NSLocalizedString("From Camera", comment: "")
let kLocalizedChooseImage = NSLocalizedString("Choose image", comment: "")
let kLocalizedDrawNewImage = NSLocalizedString("Draw new image", comment: "")
let kLocalizedRename = NSLocalizedString("Rename", comment: "")
let kLocalizedCopy = NSLocalizedString("Copy", comment: "")
let kLocalizedUpload = NSLocalizedString("Upload", comment: "")
let kLocalizedDeleteObjects = NSLocalizedString("Delete Objects", comment: "")
let kLocalizedMoveObjects = NSLocalizedString("Move Objects", comment: "")
let kLocalizedDeletePrograms = NSLocalizedString("Delete Programs", comment: "")
let kLocalizedPocketCodeRecorder = NSLocalizedString("Pocket Code Recorder", comment: "")
let kLocalizedCameraRoll = NSLocalizedString("Camera Roll", comment: "")
let kLocalizedProject = NSLocalizedString("Project", comment: "")
let kLocalizedPlay = NSLocalizedString("Play", comment: "")
let kLocalizedDownload = NSLocalizedString("Download", comment: "")
let kLocalizedMore = NSLocalizedString("More", comment: "")
let kLocalizedDelete = NSLocalizedString("Delete", comment: "")
let kLocalizedAddObject = NSLocalizedString("Add object", comment: "")
let kLocalizedAddImage = NSLocalizedString("Add image", comment: "")
let kLocalizedRenameObject = NSLocalizedString("Rename object", comment: "")
let kLocalizedRenameImage = NSLocalizedString("Rename image", comment: "")
let kLocalizedRenameSound = NSLocalizedString("Rename sound", comment: "")
let kLocalizedDeleteThisObject = NSLocalizedString("Delete this object", comment: "")
let kLocalizedDeleteThisProgram = NSLocalizedString("Delete this program", comment: "")
let kLocalizedDeleteThisLook = NSLocalizedString("Delete this look", comment: "")
let kLocalizedDeleteThisBackground = NSLocalizedString("Delete this background", comment: "")
let kLocalizedDeleteThisSound = NSLocalizedString("Delete this sound", comment: "")
let kLocalizedCopyProgram = NSLocalizedString("Copy program", comment: "")
let kLocalizedRenameProgram = NSLocalizedString("Rename Program", comment: "")
let kLocalizedSetDescription = NSLocalizedString("Set description", comment: "")
let kLocalizedPocketCodeForIOS = NSLocalizedString("Pocket Code for iOS", comment: "")
let kLocalizedProgramName = NSLocalizedString("Program name", comment: "")
let kLocalizedMessage = NSLocalizedString("Message", comment: "")
let kLocalizedDescription = NSLocalizedString("Description", comment: "")
let kLocalizedObjectName = NSLocalizedString("Object name", comment: "")
let kLocalizedImageName = NSLocalizedString("Image name", comment: "")
let kLocalizedSoundName = NSLocalizedString("Sound name", comment: "")
let kLocalizedOK = NSLocalizedString("OK", comment: "")
let kLocalizedYes = NSLocalizedString("Yes", comment: "")
let kLocalizedNo = NSLocalizedString("No", comment: "")
let kLocalizedDeleteProgram = NSLocalizedString("Delete Program", comment: "")
let kLocalizedLoading = NSLocalizedString("Loading", comment: "")
let kLocalizedSaved = NSLocalizedString("Saved", comment: "")
let kLocalizedAuthor = NSLocalizedString("Author", comment: "")
let kLocalizedDownloads = NSLocalizedString("Downloads", comment: "")
let kLocalizedUploaded = NSLocalizedString("Uploaded", comment: "")
let kLocalizedVersion = NSLocalizedString("Version", comment: "")
let kLocalizedViews = NSLocalizedString("Views", comment: "")
let kLocalizedInformation = NSLocalizedString("Information", comment: "")
let kLocalizedMeasure = NSLocalizedString("Measure", comment: "")
let kLocalizedSize = NSLocalizedString("Size", comment: "")
let kLocalizedObject = NSLocalizedString("Object", comment: "")
let kLocalizedObjects = NSLocalizedString("Objects", comment: "")
let kLocalizedBricks = NSLocalizedString("Bricks", comment: "")
let kLocalizedSounds = NSLocalizedString("Sounds", comment: "")
let kLocalizedLastAccess = NSLocalizedString("Last access", comment: "")
let kLocalizedLength = NSLocalizedString("Length", comment: "")
let kLocalizedRecord = NSLocalizedString("Record", comment: "")
let kLocalizedStop = NSLocalizedString("Stop", comment: "")
let kLocalizedRestart = NSLocalizedString("Restart", comment: "")
let kLocalizedScreenshot = NSLocalizedString("Screenshot", comment: "")
let kLocalizedAxes = NSLocalizedString("Axes", comment: "Title of icon shown in the side bar to enable or disable an overlayed view to show the origin of the coordinate system and implicitly the display size.")
let kLocalizedMostDownloaded = NSLocalizedString("Most Downloaded", comment: "")
let kLocalizedMostViewed = NSLocalizedString("Most Viewed", comment: "")
let kLocalizedNewest = NSLocalizedString("Newest", comment: "")
let kLocalizedControl = NSLocalizedString("Control", comment: "")
let kLocalizedMotion = NSLocalizedString("Motion", comment: "")
let kLocalizedSound = NSLocalizedString("Sound", comment: "")
let kLocalizedVariables = NSLocalizedString("Variables", comment: "")
let kLocalizedPhiro = NSLocalizedString("Phiro", comment: "")
let kLocalizedArduino = NSLocalizedString("Arduino", comment: "")
let kLocalizedPhiroBricks = NSLocalizedString("Use Phiro bricks", comment: "")
let kLocalizedArduinoBricks = NSLocalizedString("Use Arduino bricks", comment: "")
let kLocalizedFaceDetection = NSLocalizedString("Use face detection", comment: "")
let kLocalizedFaceDetectionCamera = NSLocalizedString("Face detection camera", comment: "")
let kLocalizedFaceDetectionDefaultCamera = NSLocalizedString("default camera is back camera", comment: "")
let kLocalizedBackCamera = NSLocalizedString("Back camera", comment: "")
let kLocalizedFrontCamera = NSLocalizedString("Front camera", comment: "")
let kLocalizedDisconnectAllDevices = NSLocalizedString("Disconnect all devices", comment: "")
let kLocalizedRemoveKnownDevices = NSLocalizedString("Remove known devices", comment: "")
let kLocalizedRecording = NSLocalizedString("Recording", comment: "")
let kLocalizedError = NSLocalizedString("Error", comment: "")
let kLocalizedMemoryWarning = NSLocalizedString("Not enough Memory", comment: "")
let kLocalizedReportProgram = NSLocalizedString("Report as inappropriate", comment: "")
let kLocalizedEnterReason = NSLocalizedString("Enter a reason", comment: "")
let kLocalizedLoginToReport = NSLocalizedString("Please log in to report this program as inappropriate", comment: "")
let kLocalizedName = NSLocalizedString("Name", comment: "")
let kLocalizedDownloaded = NSLocalizedString("Download sucessful", comment: "")
let kLocalizedSettings = NSLocalizedString("Settings", comment: "")
let kLocalizedWiFiProgramDownloads = NSLocalizedString("Download only with WiFi", comment: "")
let kLocalizedNoWifiConnection = NSLocalizedString("Not Connected to a WiFi network, please connect to one or change the settings to download also with mobile data.", comment: "")

//************************************************************************************************************
//**********************************       SHORT DESCRIPTIONS      *******************************************
//************************************************************************************************************

let kLocalizedCantRestartProgram = NSLocalizedString("Can't restart program!", comment: "")
let kLocalizedScreenshotSavedToCameraRoll = NSLocalizedString("Screenshot saved to Camera Roll", comment: "")
let kLocalizedScreenshotSavedToProject = NSLocalizedString("Screenshot saved to project", comment: "")
let kLocalizedThisFeatureIsComingSoon = NSLocalizedString("This feature is coming soon!", comment: "")
let kLocalizedNoDescriptionAvailable = NSLocalizedString("No Description available", comment: "")
let kLocalizedNoSearchResults = NSLocalizedString("No search results", comment: "")
let kLocalizedUnableToLoadProgram = NSLocalizedString("Unable to load program!", comment: "")
let kLocalizedThisActionCannotBeUndone = NSLocalizedString("This action can not be undone!", comment: "")
let kLocalizedErrorInternetConnection = NSLocalizedString("An unknown error occurred. Check your Internet connection.", comment: "")
let kLocalizedErrorUnknown = NSLocalizedString("An unknown error occurred. Please try again later.", comment: "")
let kLocalizedInvalidURLGiven = NSLocalizedString("Invalid URL given!", comment: "")
let kLocalizedNoCamera = NSLocalizedString("No Camera available", comment: "")
let kLocalizedImagePickerSourceNotAvailable = NSLocalizedString("Image source not available", comment: "")
let kLocalizedBluetoothPoweredOff = NSLocalizedString("Bluetooth is turned off. Please turn it on to connect to a Bluetooth device.", comment: "")
let kLocalizedBluetoothNotAvailable = NSLocalizedString("Bluetooth is not available. Either your device does not support Bluetooth 4.0 or your Bluetooth chip is damaged. Please check it by connection to another Bluetooth device in the Settings.", comment: "")
let kLocalizedDisconnectBluetoothDevices = NSLocalizedString("All Bluetooth devices successfully disconnected", comment: "")
let kLocalizedRemovedKnownBluetoothDevices = NSLocalizedString("All known Bluetooth devices successfully removed", comment: "")

//************************************************************************************************************
//**********************************       LONG DESCRIPTIONS      ********************************************
//************************************************************************************************************

let kLocalizedWelcomeDescription = NSLocalizedString("Pocket Code let's you play great games and run other fantastic apps like for instance presentations, quizzes and so on.", comment: "")
let kLocalizedExploreDescription = NSLocalizedString("By switching to the section \"Explore\" you can discover more interesting programs from people all over the world.", comment: "")
let kLocalizedCreateAndEditDescription = NSLocalizedString("You are also able to build your own apps, remix existing ones and share them with your friends and other exciting people around the world.", comment: "")
let kLocalizedAboutPocketCodeDescription = NSLocalizedString("Pocket Code is a programming environment for iOS for the visual programming language Catrobat. The code of Pocket Code is mostly under GNU AGPL v3 licence. For further information to the licence please visit following links:", comment: "")
let kLocalizedTermsOfUseDescription = NSLocalizedString("In order to be allowed to use Pocket Code and other executables offered by the Catrobat project, you must agree to our Terms of Use and strictly follow them when you use Pocket Code and our other executables. Please see the link below for their precise formulation.", comment: "")
let kLocalizedNotEnoughFreeMemoryDescription = NSLocalizedString("Not enough free memory to download this program. Please delete some of your programs", comment: "")
let kLocalizedEnterYourProgramNameHere = NSLocalizedString("Enter your program name here...", comment: "Placeholder for program-name input field")
let kLocalizedEnterNameForImportedProgramTitle = NSLocalizedString("Import File", comment: "Title of prompt shown when a *.catrobat file is imported from a third-party app.")
let kLocalizedEnterYourProgramDescriptionHere = NSLocalizedString("Enter your program description here...", comment: "Placeholder for program-description input field")
let kLocalizedEnterYourMessageHere = NSLocalizedString("Enter your message here...", comment: "Placeholder for message input field")
let kLocalizedEnterYourVariableNameHere = NSLocalizedString("Enter your variable name here...", comment: "Placeholder for variable input field")
let kLocalizedEnterYourObjectNameHere = NSLocalizedString("Enter your object name here...", comment: "Placeholder for add object-name input field")
let kLocalizedEnterYourImageNameHere = NSLocalizedString("Enter your image name here...", comment: "Placeholder for add image-name input field")
let kLocalizedEnterYourSoundNameHere = NSLocalizedString("Enter your sound name here...", comment: "Placeholder for add sound-name input field")
let kLocalizedNoImportedSoundsFoundTitle = NSLocalizedString("No imported sounds found", comment: "Title of AlertView if the user tries to import a sound but no sound has been imported using iTunes.")
let kLocalizedNoImportedSoundsFoundDescription = NSLocalizedString("Please connect your iPhone to your PC/Mac and use iTunes FileSharing to import sound files into the PocketCode app.", comment: "Description of AlertView if the user tries to import a sound but no sound has been imported using iTunes.")
let kLocalizedNoOrTooShortInputDescription = NSLocalizedString("No input. Please enter at least %lu character(s).", comment: "")
let kLocalizedTooLongInputDescription = NSLocalizedString("The input is too long. Please enter maximal %lu character(s).", comment: "")
let kLocalizedSpaceInputDescription = NSLocalizedString("Only space is not allowed. Please enter at least %lu other character(s).", comment: "")
let kLocalizedSpecialCharInputDescription = NSLocalizedString("Only special characters are not allowed. Please enter at least %lu other character(s).", comment: "")
let kLocalizedBlockedCharInputDescription = NSLocalizedString("The name contains blocked characters. Please try again!", comment: "")
let kLocalizedInvalidInputDescription = NSLocalizedString("Invalid input entered, try again.", comment: "")
let kLocalizedProgramNameAlreadyExistsDescription = NSLocalizedString("A program with the same name already exists, try again.", comment: "")
let kLocalizedInvalidDescriptionDescription = NSLocalizedString("The description contains invalid characters, try again.", comment: "")
let kLocalizedObjectNameAlreadyExistsDescription = NSLocalizedString("An object with the same name already exists, try again.", comment: "")
let kLocalizedMessageAlreadyExistsDescription = NSLocalizedString("A message with the same name already exists, try again.", comment: "")
let kLocalizedInvalidImageNameDescription = NSLocalizedString("No or invalid image name entered, try again.", comment: "")
let kLocalizedInvalidSoundNameDescription = NSLocalizedString("No or invalid sound name entered, try again.", comment: "")
let kLocalizedImageNameAlreadyExistsDescription = NSLocalizedString("An image with the same name already exists, try again.", comment: "")
let kLocalizedUnableToPlaySoundDescription = NSLocalizedString("Unable to play that sound!\nMaybe this is no valid sound or the file is corrupt.", comment: "")
let kLocalizedDeviceIsInMutedStateIPhoneDescription = NSLocalizedString("Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the left side of your iPhone and tap on play again.", comment: "")
let kLocalizedDeviceIsInMutedStateIPadDescription = NSLocalizedString("Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the right side of your iPad and tap on play again.", comment: "")
let kLocalizedProgramAlreadyDownloadedDescription = NSLocalizedString("You have already downloaded this program!", comment: "")
let kLocalizedNoAccesToImagesCheckSettingsDescription = NSLocalizedString("Pocket Code has no access to your images. To permit access, tap settings and activate images. Your drawing will automatically be saved to PocketCode for you.", comment: "")
let kLocalizedNoAccesToCameraCheckSettingsDescription = NSLocalizedString("Pocket Code has no access to your camera. To permit access, tap settings and activate camera. Your drawing will automatically be saved to PocketCode for you.", comment: "")
let kLocalizedNoAccesToMicrophoneCheckSettingsDescription = NSLocalizedString("Pocket Code has no access to your microphone. To permit access, tap settings and activate microphone.", comment: "")

//************************************************************************************************************
//*******************************       BRICK TITLE TRANSLATIONS      ****************************************
//************************************************************************************************************


// control bricks
let kLocalizedWhenProgramStarted = NSLocalizedString("When program started", comment: "")
let kLocalizedWhenTapped = NSLocalizedString("When tapped", comment: "")
let kLocalizedWaitNSeconds = NSLocalizedString("Wait %@ second(s)", comment: "")
let kLocalizedVibrateNSeconds = NSLocalizedString("Vibrate %@ second(s)", comment: "")
let kLocalizedWhenIReceive = NSLocalizedString("When I receive\n%", comment: "")
let kLocalizedBroadcast = NSLocalizedString("Broadcast\n%", comment: "")
let kLocalizedBroadcastAndWait = NSLocalizedString("Broadcast and wait\n%", comment: "")
let kLocalizedNote = NSLocalizedString("Note %", comment: "")
let kLocalizedForever = NSLocalizedString("Forever", comment: "")
let kLocalizedIfIsTrueThen = NSLocalizedString("If %@ is true then", comment: "")
let kLocalizedElse = NSLocalizedString("Else", comment: "")
let kLocalizedEndIf = NSLocalizedString("End If", comment: "")
let kLocalizedRepeatNTimes = NSLocalizedString("Repeat %@ times", comment: "")
let kLocalizedEndOfLoop = NSLocalizedString("End of Loop", comment: "")

// motion bricks
let kLocalizedPlaceAt = NSLocalizedString("Place at\nX: %@ Y: %", comment: "")
let kLocalizedSetX = NSLocalizedString("Set X to %", comment: "")
let kLocalizedSetY = NSLocalizedString("Set Y to %", comment: "")
let kLocalizedChangeX = NSLocalizedString("Change X by %", comment: "")
let kLocalizedChangeY = NSLocalizedString("Change Y by %", comment: "")
let kLocalizedIfIsTrueThenOnEdgeBounce = NSLocalizedString("If on edge, bounce", comment: "")
let kLocalizedMoveNSteps = NSLocalizedString("Move %@ step(s)", comment: "")
let kLocalizedTurnLeft = NSLocalizedString("Turn left %@°", comment: "")
let kLocalizedTurnRight = NSLocalizedString("Turn right %@°", comment: "")
let kLocalizedPointInDirection = NSLocalizedString("Point in direction %@°", comment: "")
let kLocalizedPointTowards = NSLocalizedString("Point towards\n%", comment: "")
let kLocalizedGlideTo = NSLocalizedString("Glide %@ second(s)\nto X: %@ Y: %", comment: "")
let kLocalizedGoNStepsBack = NSLocalizedString("Go back %@ layer(s)", comment: "")
let kLocalizedComeToFront = NSLocalizedString("Go to front", comment: "")

// look bricks
let kLocalizedSetLook = NSLocalizedString("Switch to look\n%", comment: "")
let kLocalizedSetBackground = NSLocalizedString("Set background\n%", comment: "")
let kLocalizedNextLook = NSLocalizedString("Next look", comment: "")
let kLocalizedNextBackground = NSLocalizedString("Next background", comment: "")
let kLocalizedSetSizeTo = NSLocalizedString("Set size to %@%", comment: "")
let kLocalizedChangeSizeByN = NSLocalizedString("Change size by %@%", comment: "")
let kLocalizedHide = NSLocalizedString("Hide", comment: "")
let kLocalizedShow = NSLocalizedString("Show", comment: "")
let kLocalizedLedOn = NSLocalizedString("Flashlight on", comment: "")
let kLocalizedLedOff = NSLocalizedString("Flashlight off", comment: "")
let kLocalizedSetTransparency = NSLocalizedString("Set transparency\nto %@%", comment: "")
let kLocalizedChangeTransparencyByN = NSLocalizedString("Change transparency\nby %@%", comment: "")
let kLocalizedSetBrightness = NSLocalizedString("Set brightness to %@%", comment: "")
let kLocalizedChangeBrightnessByN = NSLocalizedString("Change brightness\nby %@%", comment: "")
let kLocalizedClearGraphicEffect = NSLocalizedString("Clear graphic effects", comment: "")
let kLocalizedSetColor = NSLocalizedString("Set color to %", comment: "")
let kLocalizedChangeColorByN = NSLocalizedString("Change color by %", comment: "")

// sound bricks
let kLocalizedPlaySound = NSLocalizedString("Start sound\n%", comment: "")
let kLocalizedStopAllSounds = NSLocalizedString("Stop all sounds", comment: "")
let kLocalizedSetVolumeTo = NSLocalizedString("Set volume to %@%", comment: "")
let kLocalizedChangeVolumeByN = NSLocalizedString("Change volume by %", comment: "")
let kLocalizedSpeak = NSLocalizedString("Speak %", comment: "")

// variable bricks
let kLocalizedSetVariable = NSLocalizedString("Set variable\n%@\nto %", comment: "")
let kLocalizedChangeVariable = NSLocalizedString("Change variable\n%@\nby %", comment: "")
let kLocalizedShowVariable = NSLocalizedString("Show variable\n%@\nx: %@ y:%", comment: "")
let kLocalizedHideVariable = NSLocalizedString("Hide variable\n%", comment: "")


let kLocalizedAddCommentHere = NSLocalizedString("add comment here...", comment: "")
let kLocalizedMessage1 = NSLocalizedString("message 1", comment: "")
let kLocalizedHello = NSLocalizedString("Hello !", comment: "")

// phiro bricks
let kLocalizedStopPhiroMotor = NSLocalizedString("Stop Phiro Motor\n%", comment: "")
let kLocalizedPhiroMoveForward = NSLocalizedString("Move Phiro Motor forward\n%@\n Speed %@%", comment: "")
let kLocalizedPhiroMoveBackward = NSLocalizedString("Move Phiro Motor backward\n%@\n Speed %@%", comment: "")
let kLocalizedPhiroRGBLight = NSLocalizedString("Set Phiro Light\n%@\n Red %@ Green %@ Blue %", comment: "")
let kLocalizedPhiroPlayTone = NSLocalizedString("play Phiro Tone\n%@\n Duration %@ seconds", comment: "")
let kLocalizedPhiroIfLogic = NSLocalizedString("If %@ is true then", comment: "")


// Arduino bricks
let kLocalizedArduinoSendDigitalValue = NSLocalizedString("Arduino send digital\nPin:%@ Value:%", comment: "")
let kLocalizedArduinoSendPWMValue = NSLocalizedString("Arduino send PWM\nPin:%@ Value:%", comment: "")


//************************************************************************************************************
//**********************************       Login/Upload            *******************************************
//************************************************************************************************************

let kLocalizedLogin = NSLocalizedString("Login", comment: "")
let kLocalizedUsername = NSLocalizedString("Username", comment: "")
let kLocalizedPassword = NSLocalizedString("Password", comment: "")
let kLocalizedEmail = NSLocalizedString("Email", comment: "")
let kLocalizedRegister = NSLocalizedString("Create account", comment: "")
let kLocalizedLoginOrRegister = NSLocalizedString("Login/Register", comment: "")
let kLocalizedUploadProgram = NSLocalizedString("Upload Program", comment: "")
let kLocalizedLoginUsernameNecessary = NSLocalizedString("Username is necessary!", comment: "")
let kLocalizedLoginEmailNotValid = NSLocalizedString("Email is not valid!", comment: "")
let kLocalizedLoginPasswordNotValid = NSLocalizedString("Password is not vaild! \n It has to contain at least 6 characters/symbols", comment: "")
let kLocalizedUploadProgramNecessary = NSLocalizedString("Program Name is necessary!", comment: "")
let kLocalizedTermsAgreementPart = NSLocalizedString("By registering you agree to our", comment: "")
let kLocalizedUploadSuccessful = NSLocalizedString("Upload successful", comment: "")
let kLocalizedRegistrationSuccessful = NSLocalizedString("Registration successful", comment: "")
let kLocalizedLoginSuccessful = NSLocalizedString("Login successful", comment: "")
let kUploadSelectedProgram = NSLocalizedString("Upload Selected Program", comment: "")
let kLocalizedUploadProblem = NSLocalizedString("Problems occured while Uploading your program", comment: "")
let kLocalizedUploadSelectProgram = NSLocalizedString("Please select a program to upload", comment: "")
let kLocalizedTitleLogin = NSLocalizedString("GOOD TO SEE YOU", comment: "")
let kLocalizedTitleRegister = NSLocalizedString("GOOD TO SEE YOU", comment: "")
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
let kLocalizedPaintSave = NSLocalizedString("Save to CameraRoll", comment: "paint")
let kLocalizedPaintClose = NSLocalizedString("Close Paint", comment: "paint")
let kLocalizedPaintNewCanvas = NSLocalizedString("New Canvas", comment: "paint")
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
let kLocalizedPaintTextAlert = NSLocalizedString("Please enter a text!", comment: "paint")
//************************************************************************************************************
//************************************       FormulaEditor        ********************************************
//************************************************************************************************************

let kUIActionSheetTitleSelectLogicalOperator = NSLocalizedString("Select logical operator", comment: "")
let kUIActionSheetTitleSelectMathematicalFunction = NSLocalizedString("Select mathematical function", comment: "")
let kUIFENumbers = NSLocalizedString("Numbers", comment: "")
let kUIFELogic = NSLocalizedString("Logic", comment: "")
let kUIFEVar = NSLocalizedString("New", comment: "")
let kUIFETake = NSLocalizedString("Choose", comment: "")
let kUIFEMath = NSLocalizedString("Math", comment: "")
let kUIFEObject = NSLocalizedString("Object", comment: "")
let kUIFESensor = NSLocalizedString("Sensors", comment: "")
let kUIFEVariable = NSLocalizedString("Variables", comment: "")
let kUIFECompute = NSLocalizedString("Compute", comment: "")
let kUIFEDone = NSLocalizedString("Done", comment: "")
let kUIFEError = NSLocalizedString("Error", comment: "")
let kUIFEtooLongFormula = NSLocalizedString("Formula too long!", comment: "")
let kUIFEResult = NSLocalizedString("Result", comment: "")
let kUIFEComputed = NSLocalizedString("Computed result is %.2f", comment: "")
let kUIFEComputedTrue = NSLocalizedString("Computed result is TRUE", comment: "")
let kUIFEComputedFalse = NSLocalizedString("Computed result is FALSE", comment: "")
let kUIFENewVar = NSLocalizedString("New Variable", comment: "")
let kUIFENewVarExists = NSLocalizedString("Name already exists. Please choose another", comment: "")
let kUIFEonly15Char = NSLocalizedString("only 15 characters allowed", comment: "")
let kUIFEVarName = NSLocalizedString("Variable name:", comment: "")
let kUIFEProgramVars = NSLocalizedString("Program variables:", comment: "")
let kUIFEObjectVars = NSLocalizedString("Object variables:", comment: "")
let kUIFEDeleteVarBeingUsed = NSLocalizedString("This variable can not be deleted because it is still in use.", comment: "")
let kUIFEActionVar = NSLocalizedString("Variable type", comment: "")
let kUIFEActionVarObj = NSLocalizedString("for this object", comment: "")
let kUIFEActionVarPro = NSLocalizedString("for all objects", comment: "")
let kUIFEChangesSaved = NSLocalizedString("Changes saved!", comment: "")
let kUIFEChangesDiscarded = NSLocalizedString("Changes discarded!", comment: "")
let kUIFESyntaxError = NSLocalizedString("Syntax Error!", comment: "")

let kUIFEFunctionSqrt = NSLocalizedString("sqrt", comment: "")
let kUIFEFunctionTrue = NSLocalizedString("true", comment: "")
let kUIFEFunctionFalse = NSLocalizedString("false", comment: "")
let kUIFEFunctionLetter = NSLocalizedString("letter", comment: "")
let kUIFEFunctionJoin = NSLocalizedString("join", comment: "")
let kUIFEFunctionLength = NSLocalizedString("length", comment: "")
let kUIFEFunctionFloor = NSLocalizedString("floor", comment: "")
let kUIFEFunctionCeil = NSLocalizedString("ceil", comment: "")

let kUIFEOperatorAnd = NSLocalizedString("and", comment: "")
let kUIFEOperatorNot = NSLocalizedString("not", comment: "")
let kUIFEOperatorOr = NSLocalizedString("or", comment: "")

let kUIFEObjectTransparency = NSLocalizedString("transparency", comment: "")
let kUIFEObjectBrightness = NSLocalizedString("brightness", comment: "")
let kUIFEObjectSize = NSLocalizedString("size", comment: "")
let kUIFEObjectDirection = NSLocalizedString("direction", comment: "")
let kUIFEObjectLayer = NSLocalizedString("layer", comment: "")
let kUIFEObjectPositionX = NSLocalizedString("pos_x", comment: "")
let kUIFEObjectPositionY = NSLocalizedString("pos_y", comment: "")

let kUIFESensorCompass = NSLocalizedString("compass", comment: "")
let kUIFESensorLoudness = NSLocalizedString("loudness", comment: "")
let kUIFESensorAccelerationX = NSLocalizedString("acceleration_x", comment: "")
let kUIFESensorAccelerationY = NSLocalizedString("acceleration_y", comment: "")
let kUIFESensorAccelerationZ = NSLocalizedString("acceleration_z", comment: "")
let kUIFESensorInclinationX = NSLocalizedString("inclination_x", comment: "")
let kUIFESensorInclinationY = NSLocalizedString("inclination_y", comment: "")
let kUIFESensorPhiroFrontLeft = NSLocalizedString("phiro_front_left", comment: "")
let kUIFESensorPhiroFrontRight = NSLocalizedString("phiro_front_right", comment: "")
let kUIFESensorPhiroSideLeft = NSLocalizedString("phiro_side_left", comment: "")
let kUIFESensorPhiroSideRight = NSLocalizedString("phiro_side_right", comment: "")
let kUIFESensorPhiroBottomLeft = NSLocalizedString("phiro_bottom_left", comment: "")
let kUIFESensorPhiroBottomRight = NSLocalizedString("phiro_bottom_right", comment: "")

let kUIFESensorArduinoAnalog = NSLocalizedString("arduino_analog", comment: "")

let kUIFESensorArduinoDigital = NSLocalizedString("arduino_digital", comment: "")

let kLocalizedSensorCompass = NSLocalizedString("compass", comment: "")
let kLocalizedSensorAcceleration = NSLocalizedString("acceleration-sensor", comment: "")
let kLocalizedSensorRotation = NSLocalizedString("gyro-sensor", comment: "")
let kLocalizedSensorMagnetic = NSLocalizedString("magnetic-sensor", comment: "")
let kLocalizedVibration = NSLocalizedString("vibration", comment: "")
let kLocalizedSensorLoudness = NSLocalizedString("loudness", comment: "")
let kLocalizedSensorLED = NSLocalizedString("LED", comment: "")
let kLocalizedNotAvailable = NSLocalizedString("not available. Continue anyway?", comment: "")

let kUIFESensorFaceDetected = NSLocalizedString("face_detected", comment: "")
let kUIFESensorFaceSize = NSLocalizedString("facesize", comment: "")
let kUIFESensorFaceX = NSLocalizedString("faceposition_x", comment: "")
let kUIFESensorFaceY = NSLocalizedString("faceposition_y", comment: "")

//************************************************************************************************************
//************************************       BrickCategoryTitles        ********************************************
//************************************************************************************************************
let kUIFENewText = NSLocalizedString("New Text", comment: "")
let kUIFETextMessage = NSLocalizedString("Text message:", comment: "")
let kUIFavouritesTitle = NSLocalizedString("Frequently Used", comment: "Title of View where the user can see the frequently used bricks.")
let kUIScriptTitle = NSLocalizedString("Script", comment: "");
let kUIControlTitle = NSLocalizedString("Control", comment: "");
let kUIMotionTitle  = NSLocalizedString("Motion", comment: "");
let kUISoundTitle  = NSLocalizedString("Sound", comment: "");
let kUILookTitle  = NSLocalizedString("Look", comment: "");
let kUIVariableTitle  = NSLocalizedString("Variable", comment: "");
let kUIArduinoTitle  = NSLocalizedString("Arduino", comment: "");
let kUIPhiroTitle  = NSLocalizedString("Phiro", comment: "");


//************************************************************************************************************
//************************************       PhiroDefines         ********************************************
//************************************************************************************************************


let kLocalizedPhiroBoth  = NSLocalizedString("Both", comment: "")
let kLocalizedPhiroLeft  = NSLocalizedString("Left", comment: "")
let kLocalizedPhiroRight  = NSLocalizedString("Right", comment: "")

let kLocalizedPhiroDO  = NSLocalizedString("DO", comment: "")
let kLocalizedPhiroRE  = NSLocalizedString("RE", comment: "")
let kLocalizedPhiroMI  = NSLocalizedString("MI", comment: "")
let kLocalizedPhiroFA  = NSLocalizedString("FA", comment: "")
let kLocalizedPhiroSO  = NSLocalizedString("SO", comment: "")
let kLocalizedPhiroLA  = NSLocalizedString("LA", comment: "")
let kLocalizedPhiroTI  = NSLocalizedString("TI", comment: "")


let klocalizedBluetoothSearch = NSLocalizedString("Search", comment: "bluetooth")
let klocalizedBluetoothKnown = NSLocalizedString("Known devices", comment: "bluetooth")
let klocalizedBluetoothSelectPhiro = NSLocalizedString("Select Phiro", comment: "bluetooth")
let klocalizedBluetoothSelectArduino = NSLocalizedString("Select Arduino", comment: "bluetooth")
let klocalizedBluetoothConnectionNotPossible = NSLocalizedString("Connection not possible", comment: "bluetooth")
let klocalizedBluetoothConnectionTryResetting = NSLocalizedString("Please try resetting the device and try again.", comment: "bluetooth")
let klocalizedBluetoothConnectionFailed = NSLocalizedString("Connection failed", comment: "bluetooth")
let klocalizedBluetoothCannotConnect = NSLocalizedString("Cannot connect to device, please try resetting the device and try again.", comment: "bluetooth")
let klocalizedBluetoothNotResponding = NSLocalizedString("Cannot connect to device. The device is not responding.", comment: "bluetooth")
let klocalizedBluetoothConnectionLost = NSLocalizedString("Connection Lost", comment: "bluetooth")
let klocalizedBluetoothDisconnected = NSLocalizedString("Device disconnected.", comment: "bluetooth")


//************************************************************************************************************
//************************************       MediaLibrary        *********************************************
//************************************************************************************************************
let kLocalizedMediaLibrary = NSLocalizedString("Media Library", comment: "")



//************************************************************************************************************
//****************************************       Debug        ************************************************
//************************************************************************************************************
let kLocalizedDebugModeTitle = NSLocalizedString("Debug mode", comment: "")
let kLocalizedStartedInDebugMode = NSLocalizedString("Pocket Code has been started in debug mode.", comment: "")



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
