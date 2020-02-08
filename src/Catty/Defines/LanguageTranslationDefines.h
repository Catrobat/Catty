/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

#define kLocalizedSkip NSLocalizedString(@"Skip", nil)
#define kLocalizedWelcomeToPocketCode NSLocalizedString(@"Welcome to Pocket Code", nil)
#define kLocalizedExploreApps NSLocalizedString(@"Explore apps", nil)
#define kLocalizedCreateAndEdit NSLocalizedString(@"Create & Remix", nil)
#define kLocalizedNewProject NSLocalizedString(@"New project", nil)
#define kLocalizedNewMessage NSLocalizedString(@"New message", nil)
#define kLocalizedBackground NSLocalizedString(@"Background", nil)
#define kLocalizedMyObject NSLocalizedString(@"My object", @"Title for first (default) object")
#define kLocalizedMyImage NSLocalizedString(@"My image", @"Default title of imported photo from camera (taken by camera)")
#define kLocalizedMyFirstProject NSLocalizedString(@"My first project", @"Name of the default catrobat project (used as filename!!)")
#define kLocalizedMole NSLocalizedString(@"Mole", @"Prefix of default catrobat project object names (except background object)")
#define kLocalizedToday NSLocalizedString(@"Today", nil)
#define kLocalizedYesterday NSLocalizedString(@"Yesterday", nil)
#define kLocalizedSunday NSLocalizedString(@"Sunday", nil)
#define kLocalizedMonday NSLocalizedString(@"Monday", nil)
#define kLocalizedTuesday NSLocalizedString(@"Tuesday", nil)
#define kLocalizedWednesday NSLocalizedString(@"Wednesday", nil)
#define kLocalizedThursday NSLocalizedString(@"Thursday", nil)
#define kLocalizedFriday NSLocalizedString(@"Friday", nil)
#define kLocalizedSaturday NSLocalizedString(@"Saturday", nil)
#define kLocalizedSu NSLocalizedString(@"Su", nil)
#define kLocalizedMo NSLocalizedString(@"Mo", nil)
#define kLocalizedTu NSLocalizedString(@"Tu", nil)
#define kLocalizedWe NSLocalizedString(@"We", nil)
#define kLocalizedTh NSLocalizedString(@"Th", nil)
#define kLocalizedFr NSLocalizedString(@"Fr", nil)
#define kLocalizedSa NSLocalizedString(@"Sa", nil)
#define kLocalizedJanuary NSLocalizedString(@"January", nil)
#define kLocalizedFebruary NSLocalizedString(@"February", nil)
#define kLocalizedMarch NSLocalizedString(@"March", nil)
#define kLocalizedApril NSLocalizedString(@"April", nil)
#define kLocalizedJune NSLocalizedString(@"June", nil)
#define kLocalizedJuly NSLocalizedString(@"July", nil)
#define kLocalizedAugust NSLocalizedString(@"August", nil)
#define kLocalizedSeptember NSLocalizedString(@"September", nil)
#define kLocalizedOctober NSLocalizedString(@"October", nil)
#define kLocalizedNovember NSLocalizedString(@"November", nil)
#define kLocalizedDecember NSLocalizedString(@"December", nil)
#define kLocalizedJan NSLocalizedString(@"Jan", nil)
#define kLocalizedFeb NSLocalizedString(@"Feb", nil)
#define kLocalizedMar NSLocalizedString(@"Mar", nil)
#define kLocalizedApr NSLocalizedString(@"Apr", nil)
#define kLocalizedMay NSLocalizedString(@"May", nil)
#define kLocalizedJun NSLocalizedString(@"Jun", nil)
#define kLocalizedJul NSLocalizedString(@"Jul", nil)
#define kLocalizedAug NSLocalizedString(@"Aug", nil)
#define kLocalizedSep NSLocalizedString(@"Sep", nil)
#define kLocalizedOct NSLocalizedString(@"Oct", nil)
#define kLocalizedNov NSLocalizedString(@"Nov", nil)
#define kLocalizedDec NSLocalizedString(@"Dec", nil)
#define kLocalizedPocketCode NSLocalizedString(@"Pocket Code", nil)
#define kLocalizedCategories NSLocalizedString(@"Categories", nil)
#define kLocalizedDetails NSLocalizedString(@"Details", nil)
#define kLocalizedLooks NSLocalizedString(@"Looks", nil)
#define kLocalizedFeaturedProjects NSLocalizedString(@"Featured projects", nil)
#define kLocalizedScripts NSLocalizedString(@"Scripts", nil)
#define kLocalizedBackgrounds NSLocalizedString(@"Backgrounds", nil)
#define kLocalizedTapPlusToAddBackground NSLocalizedString(@"Tap \"+\" to add backgrounds", nil)
#define kLocalizedTapPlusToAddScript NSLocalizedString(@"Tap \"+\" to add scripts", nil)
#define kLocalizedTapPlusToAddSprite NSLocalizedString(@"Tap \"+\" to add actors or objects", nil)
#define kLocalizedTapPlusToAddLook NSLocalizedString(@"Tap \"+\" to add looks", nil)
#define kLocalizedTapPlusToAddSound NSLocalizedString(@"Tap \"+\" to add sounds", nil)
#define kLocalizedContinue NSLocalizedString(@"Continue", nil)
#define kLocalizedContinueProject NSLocalizedString(@"Continue project", nil)
#define kLocalizedNew NSLocalizedString(@"New", nil)
#define kLocalizedNewElement NSLocalizedString(@"New...", nil)
#define kLocalizedProjects NSLocalizedString(@"Projects", nil)
#define kLocalizedProjectsOnDevice NSLocalizedString(@"Projects on device", nil)
#define kLocalizedProject NSLocalizedString(@"Project", nil)
#define kLocalizedHelp NSLocalizedString(@"Help", nil)
#define kLocalizedCatrobatCommunity NSLocalizedString(@"Catrobat community", nil)
#define kLocalizedDeletionMenu NSLocalizedString(@"Deletion mode", nil)
#define kLocalizedAboutPocketCode NSLocalizedString(@"About Pocket Code", nil)
#define kLocalizedTermsOfUse NSLocalizedString(@"Terms of Use and Service", @"Button title at the settings screen to get to the terms of use and service.")
#define kLocalizedForgotPassword NSLocalizedString(@"Forgot password", nil)
#define kLocalizedRateUs NSLocalizedString(@"Rate Us", nil)
#define kLocalizedPrivacySettings NSLocalizedString(@"Privacy Settings", nil)
#define kLocalizedVersionLabel NSLocalizedString(@"iOS.", nil)
#define kLocalizedBack NSLocalizedString(@"Back", nil)
#define kLocalizedSourceCodeLicenseButtonLabel NSLocalizedString(@"Pocket Code Source Code License", nil)
#define kLocalizedAboutCatrobatButtonLabel NSLocalizedString(@"About Catrobat", nil)
#define kLocalizedEdit NSLocalizedString(@"Edit", nil)
#define kLocalizedCancel NSLocalizedString(@"Cancel", nil)
#define kLocalizedDone NSLocalizedString(@"Done", nil)
#define kLocalizedUndo NSLocalizedString(@"Undo", @"Button title of alert view to invoke undo if user shakes device")
#define kLocalizedUndoDrawingDescription NSLocalizedString(@"Undo Drawing?", @"Description text in alert view if user shakes the device")
#define kLocalizedUndoTypingDescription NSLocalizedString(@"Undo Typing?", @"Description text in alert view if user shakes the device")
#define kLocalizedSelectAllItems NSLocalizedString(@"Select all", nil)
#define kLocalizedUnselectAllItems NSLocalizedString(@"Unselect all", nil)
#define kLocalizedSaveToPocketCode NSLocalizedString(@"Save to PocketCode", nil)
#define kLocalizedEditSounds NSLocalizedString(@"Edit sounds",@"Action sheet menu title")
#define kLocalizedEditSound NSLocalizedString(@"Edit sound",@"Action sheet menu title")
#define kLocalizedEditLooks NSLocalizedString(@"Edit looks", @"Action sheet menu title")
#define kLocalizedEditLook NSLocalizedString(@"Edit look", @"Action sheet menu title")
#define kLocalizedEditBackground NSLocalizedString(@"Edit background", @"Action sheet menu title")
#define kLocalizedEditBackgrounds NSLocalizedString(@"Edit backgrounds", @"Action sheet menu title")
#define kLocalizedEditScript NSLocalizedString(@"Edit script", @"Action sheet menu title")
#define kLocalizedEditBrick NSLocalizedString(@"Edit brick", @"Action sheet menu title")
#define kLocalizedAddLook NSLocalizedString(@"Add look", @"Action sheet menu title")
#define kLocalizedLookFilename NSLocalizedString(@"look", @"LOOK")
#define kLocalizedEditProject NSLocalizedString(@"Edit project", nil)
#define kLocalizedEditProjects NSLocalizedString(@"Edit projects", nil)
#define kLocalizedEditObject NSLocalizedString(@"Edit actor or object", nil)
#define kLocalizedAddSound NSLocalizedString(@"Add sound", @"Action sheet menu title")
#define kLocalizedSelectBrickCategory NSLocalizedString(@"Select brick category", nil)
#define kLocalizedClose NSLocalizedString(@"Close", nil)
#define kLocalizedDeleteBrick NSLocalizedString(@"Delete brick", nil)
#define kLocalizedDeleteThisBrick NSLocalizedString(@"Delete this brick?", nil)
#define kLocalizedDeleteTheseBricks NSLocalizedString(@"Delete these bricks?", nil)
#define kLocalizedDeleteCondition NSLocalizedString(@"Delete condition", nil)
#define kLocalizedDeleteThisCondition NSLocalizedString(@"Delete this condition?", nil)
#define kLocalizedDeleteTheseConditions NSLocalizedString(@"Delete these conditions?", nil)
#define kLocalizedDeleteLoop NSLocalizedString(@"Delete loop", nil)
#define kLocalizedDeleteThisLoop NSLocalizedString(@"Delete this loop?", nil)
#define kLocalizedDeleteTheseLoops NSLocalizedString(@"Delete these loops?", nil)
#define kLocalizedDeleteScript NSLocalizedString(@"Delete script", nil)
#define kLocalizedDeleteThisScript NSLocalizedString(@"Delete this script?", nil)
#define kLocalizedDeleteTheseScripts NSLocalizedString(@"Delete these scripts?", nil)
#define kLocalizedAnimateBrick NSLocalizedString(@"Animate brick-parts", nil)
#define kLocalizedCopyBrick NSLocalizedString(@"Copy brick", nil)
#define kLocalizedEditFormula NSLocalizedString(@"Edit formula", nil)
#define kLocalizedMoveBrick NSLocalizedString(@"Move brick", nil)
#define kLocalizedDeleteSounds NSLocalizedString(@"Delete sounds", nil)
#define kLocalizedMoveSounds NSLocalizedString(@"Move sounds",nil)
#define kLocalizedHideDetails NSLocalizedString(@"Hide details", nil)
#define kLocalizedShowDetails NSLocalizedString(@"Show details", nil)
#define kLocalizedDeleteLooks NSLocalizedString(@"Delete looks",nil)
#define kLocalizedDeleteBackgrounds NSLocalizedString(@"Delete backgrounds",nil)
#define kLocalizedMoveLooks NSLocalizedString(@"Move looks",nil)
#define kLocalizedCopyLooks NSLocalizedString(@"Copy looks",nil)
#define kLocalizedFromCamera NSLocalizedString(@"From camera", nil)
#define kLocalizedChooseImage NSLocalizedString(@"Choose image", nil)
#define kLocalizedDrawNewImage NSLocalizedString(@"Draw new image", nil)
#define kLocalizedRename NSLocalizedString(@"Rename", nil)
#define kLocalizedCopy NSLocalizedString(@"Copy", nil)
#define kLocalizedDeleteObjects NSLocalizedString(@"Delete actors or objects", nil)
#define kLocalizedMoveObjects NSLocalizedString(@"Move actors or objects",nil)
#define kLocalizedDeleteProjects NSLocalizedString(@"Delete projects", nil)
#define kLocalizedPocketCodeRecorder NSLocalizedString(@"Pocket Code Recorder", nil)
#define kLocalizedCameraRoll NSLocalizedString(@"Camera roll", nil)
#define kLocalizedOpen NSLocalizedString(@"Open", nil)
#define kLocalizedDownload NSLocalizedString(@"Download", nil)
#define kLocalizedMore NSLocalizedString(@"More", nil)
#define kLocalizedDelete NSLocalizedString(@"Delete", nil)
#define kLocalizedAddObject NSLocalizedString(@"Add actor or object", nil)
#define kLocalizedAddImage NSLocalizedString(@"Add image", nil)
#define kLocalizedRenameObject NSLocalizedString(@"Rename actor or object", nil)
#define kLocalizedRenameImage NSLocalizedString(@"Rename image", nil)
#define kLocalizedRenameSound NSLocalizedString(@"Rename sound", nil)
#define kLocalizedDeleteThisObject NSLocalizedString(@"Delete this actor or object", nil)
#define kLocalizedDeleteThisProject NSLocalizedString(@"Delete this project", nil)
#define kLocalizedDeleteThisLook NSLocalizedString(@"Delete this look", nil)
#define kLocalizedDeleteThisBackground NSLocalizedString(@"Delete this background", nil)
#define kLocalizedDeleteThisSound NSLocalizedString(@"Delete this sound", nil)
#define kLocalizedCopyProject NSLocalizedString(@"Copy project", nil)
#define kLocalizedRenameProject NSLocalizedString(@"Rename project", nil)
#define kLocalizedSetDescription NSLocalizedString(@"Set description", nil)
#define kLocalizedPocketCodeForIOS NSLocalizedString(@"Pocket Code for iOS", nil)
#define kLocalizedProjectName NSLocalizedString(@"Project name", nil)
#define kLocalizedMessage NSLocalizedString(@"Message", nil)
#define kLocalizedDescription NSLocalizedString(@"Description", nil)
#define kLocalizedObjectName NSLocalizedString(@"Object or actor name", nil)
#define kLocalizedImageName NSLocalizedString(@"Image name", nil)
#define kLocalizedSoundName NSLocalizedString(@"Sound name", nil)
#define kLocalizedOK NSLocalizedString(@"OK", nil)
#define kLocalizedYes NSLocalizedString(@"Yes", nil)
#define kLocalizedNo NSLocalizedString(@"No", nil)
#define kLocalizedDeleteProject NSLocalizedString(@"Delete project", nil)
#define kLocalizedLoading NSLocalizedString(@"Loading", nil)
#define kLocalizedSaved NSLocalizedString(@"Saved", nil)
#define kLocalizedSaveError NSLocalizedString(@"Error saving file", nil)
#define kLocalizedAuthor NSLocalizedString(@"Author", nil)
#define kLocalizedDownloads NSLocalizedString(@"Downloads", nil)
#define kLocalizedUploaded NSLocalizedString(@"Uploaded", nil)
#define kLocalizedVersion NSLocalizedString(@"Version", nil)
#define kLocalizedViews NSLocalizedString(@"Views", nil)
#define kLocalizedInformation NSLocalizedString(@"Information", nil)
#define kLocalizedMeasure NSLocalizedString(@"Measure", nil)
#define kLocalizedSize NSLocalizedString(@"Size", nil)
#define kLocalizedObject NSLocalizedString(@"Object", nil)
#define kLocalizedObjects NSLocalizedString(@"Actors and objects", nil)
#define kLocalizedBricks NSLocalizedString(@"Bricks", nil)
#define kLocalizedSounds NSLocalizedString(@"Sounds", nil)
#define kLocalizedLastAccess NSLocalizedString(@"Last access", nil)
#define kLocalizedLength NSLocalizedString(@"Length", nil)
#define kLocalizedRestart NSLocalizedString(@"Restart", nil)
#define kLocalizedPreview NSLocalizedString(@"Preview", nil)
#define kLocalizedAxes NSLocalizedString(@"Axes", @"Title of icon shown in the side bar to enable or disable an overlayed view to show the origin of the coordinate system and implicitly the display size.")
#define kLocalizedMostDownloaded NSLocalizedString(@"Most downloaded", nil)
#define kLocalizedMostViewed NSLocalizedString(@"Most viewed", nil)
#define kLocalizedNewest NSLocalizedString(@"Newest", nil)
#define kLocalizedVariables NSLocalizedString(@"Variables", nil)
#define kLocalizedLists NSLocalizedString(@"Lists", nil)
#define kLocalizedPhiroBricks NSLocalizedString(@"Use Phiro bricks", nil)
#define kLocalizedArduinoBricks NSLocalizedString(@"Arduino extension", nil)
#define kLocalizedFrontCamera NSLocalizedString(@"Front camera", nil)
#define kLocalizedDisconnectAllDevices NSLocalizedString(@"Disconnect all devices", nil)
#define kLocalizedRemoveKnownDevices NSLocalizedString(@"Remove known devices", nil)
#define kLocalizedRecording NSLocalizedString(@"Recording", nil)
#define kLocalizedError NSLocalizedString(@"Error", nil)
#define kLocalizedMemoryWarning NSLocalizedString(@"Not enough Memory", nil)
#define kLocalizedReportProject NSLocalizedString(@"Report as inappropriate", nil)
#define kLocalizedEnterReason NSLocalizedString(@"Enter a reason", nil)
#define kLocalizedLoginToReport NSLocalizedString(@"Please log in to report this project as inappropriate", nil)
#define kLocalizedName NSLocalizedString(@"Name", nil)
#define kLocalizedDownloaded NSLocalizedString(@"Download successful", nil)
#define kLocalizedSettings NSLocalizedString(@"Settings", nil)
#define kLocalizedOff NSLocalizedString(@"off", nil)
#define kLocalizedOn NSLocalizedString(@"on", nil)
#define kLocalizedCameraBack NSLocalizedString(@"back", nil)
#define kLocalizedCameraFront NSLocalizedString(@"front", nil)
#define kLocalizedMoreInformation NSLocalizedString(@"More information", nil)

//************************************************************************************************************
//**********************************       SHORT DESCRIPTIONS      *******************************************
//************************************************************************************************************

#define kLocalizedCantRestartProject NSLocalizedString(@"Can't restart project!", nil)
#define kLocalizedThisFeatureIsComingSoon NSLocalizedString(@"This feature is coming soon!", nil)
#define kLocalizedNoDescriptionAvailable NSLocalizedString(@"No description available", nil)
#define kLocalizedNoSearchResults NSLocalizedString(@"No search results", nil)
#define kLocalizedUnableToLoadProject NSLocalizedString(@"Unable to load project!", nil)
#define kLocalizedThisActionCannotBeUndone NSLocalizedString(@"This action can not be undone!", nil)
#define kLocalizedErrorInternetConnection NSLocalizedString(@"An unknown error occurred. Check your Internet connection.", nil)
#define kLocalizedErrorUnknown NSLocalizedString(@"An unknown error occurred. Please try again later.", nil)
#define kLocalizedInvalidURLGiven NSLocalizedString(@"Invalid URL given!",nil)
#define kLocalizedNoCamera NSLocalizedString(@"No camera available",nil)
#define kLocalizedImagePickerSourceNotAvailable NSLocalizedString(@"Image source not available",nil)
#define kLocalizedBluetoothPoweredOff NSLocalizedString(@"Bluetooth is turned off. Please turn it on to connect to a Bluetooth device.",nil)
#define kLocalizedBluetoothNotAvailable NSLocalizedString(@"Bluetooth is not available. Either your device does not support Bluetooth 4.0 or your Bluetooth chip is damaged. Please check it by connection to another Bluetooth device in the Settings.",nil)
#define kLocalizedDisconnectBluetoothDevices NSLocalizedString(@"All Bluetooth devices successfully disconnected", nil)
#define kLocalizedRemovedKnownBluetoothDevices NSLocalizedString(@"All known Bluetooth devices successfully removed", nil)
#define kLocalizedArduinoBricksDescription NSLocalizedString(@"Allow the app to control Arduino boards", nil)

//************************************************************************************************************
//**********************************       LONG DESCRIPTIONS      ********************************************
//************************************************************************************************************

#define kLocalizedWelcomeDescription NSLocalizedString(@"Pocket Code let's you play great games and run other fantastic apps like for instance presentations, quizzes and so on.", nil)
#define kLocalizedExploreDescription NSLocalizedString(@"By switching to the section \"Explore\" you can discover more interesting projects from people all over the world.", nil)
#define kLocalizedCreateAndEditDescription NSLocalizedString(@"You are also able to build your own apps, remix existing ones and share them with your friends and other exciting people around the world.", nil)
#define kLocalizedAboutPocketCodeDescription NSLocalizedString(@"Pocket Code is a programming environment for iOS for the visual programming language Catrobat. The code of Pocket Code is mostly under GNU AGPL v3 licence. For further information to the licence please visit following links:", nil)
#define kLocalizedTermsOfUseDescription NSLocalizedString(@"In order to be allowed to use Pocket Code and other executables offered by the Catrobat project, you must agree to our Terms of Use and strictly follow them when you use Pocket Code and our other executables. Please see the link below for their precise formulation.", nil)
#define kLocalizedNotEnoughFreeMemoryDescription NSLocalizedString(@"Not enough free memory to download this project. Please delete some of your projects", nil)
#define kLocalizedProjectNotFound NSLocalizedString(@"The requested project can not be found. Please choose a different one.", nil)
#define kLocalizedInvalidZip NSLocalizedString(@"The requested project can not be loaded. Please try again later.", nil)
#define kLocalizedEnterYourProjectNameHere NSLocalizedString(@"Enter your project name here...", @"Placeholder for project-name input field")
#define kLocalizedEnterNameForImportedProjectTitle NSLocalizedString(@"Import File", @"Title of prompt shown when a *.catrobat file is imported from a third-party app.")
#define kLocalizedEnterYourProjectDescriptionHere NSLocalizedString(@"Enter your project description here...", @"Placeholder for project-description input field")
#define kLocalizedEnterYourMessageHere NSLocalizedString(@"Enter your message here...", @"Placeholder for message input field")
#define kLocalizedEnterYourVariableNameHere NSLocalizedString(@"Enter your variable name here...", @"Placeholder for variable input field")
#define kLocalizedEnterYourListNameHere NSLocalizedString(@"Enter your list name here...", @"Placeholder for list input field")
#define kLocalizedEnterYourObjectNameHere NSLocalizedString(@"Enter your object name here...", @"Placeholder for add object-name input field")
#define kLocalizedEnterYourImageNameHere NSLocalizedString(@"Enter your image name here...", @"Placeholder for add image-name input field")
#define kLocalizedEnterYourSoundNameHere NSLocalizedString(@"Enter your sound name here...", @"Placeholder for add sound-name input field")
#define kLocalizedNoOrTooShortInputDescription NSLocalizedString(@"Please enter at least %lu character(s).", nil)
#define kLocalizedTooLongInputDescription NSLocalizedString(@"The input is too long. Please enter maximal %lu character(s).", nil)
#define kLocalizedSpaceInputDescription NSLocalizedString(@"Only space is not allowed. Please enter at least %lu other character(s).", nil)
#define kLocalizedSpecialCharInputDescription NSLocalizedString(@"Only special characters are not allowed. Please enter at least %lu other character(s).", nil)
#define kLocalizedBlockedCharInputDescription NSLocalizedString(@"The name contains blocked characters. Please try again!", nil)
#define kLocalizedInvalidInputDescription NSLocalizedString(@"Invalid input entered, try again.", nil)
#define kLocalizedProjectNameAlreadyExistsDescription NSLocalizedString(@"A project with the same name already exists, try again.", nil)
#define kLocalizedInvalidDescriptionDescription NSLocalizedString(@"The description contains invalid characters, try again.", nil)
#define kLocalizedObjectNameAlreadyExistsDescription NSLocalizedString(@"An object with the same name already exists, try again.", nil)
#define kLocalizedMessageAlreadyExistsDescription NSLocalizedString(@"A message with the same name already exists, try again.", nil)
#define kLocalizedInvalidImageNameDescription NSLocalizedString(@"No or invalid image name entered, try again.", nil)
#define kLocalizedInvalidSoundNameDescription NSLocalizedString(@"No or invalid sound name entered, try again.", nil)
#define kLocalizedImageNameAlreadyExistsDescription NSLocalizedString(@"An image with the same name already exists, try again.", nil)
#define kLocalizedUnableToPlaySoundDescription NSLocalizedString(@"Unable to play that sound!\nMaybe this is no valid sound or the file is corrupt.", nil)
#define kLocalizedDeviceIsInMutedStateIPhoneDescription NSLocalizedString(@"Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the left side of your iPhone and tap on play again.", nil)
#define kLocalizedDeviceIsInMutedStateIPadDescription NSLocalizedString(@"Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the right side of your iPad and tap on play again.", nil)
#define kLocalizedProjectAlreadyDownloadedDescription NSLocalizedString(@"You have already downloaded this project!", nil)
#define kLocalizedNoAccesToImagesCheckSettingsDescription NSLocalizedString(@"Pocket Code has no access to your images. To permit access, tap settings and activate images. Your drawing will automatically be saved to PocketCode for you.", nil)
#define kLocalizedNoAccesToCameraCheckSettingsDescription NSLocalizedString(@"Pocket Code has no access to your camera. To permit access, tap settings and activate camera. Your drawing will automatically be saved to PocketCode for you.", nil)
#define kLocalizedNoAccesToMicrophoneCheckSettingsDescription NSLocalizedString(@"Pocket Code has no access to your microphone. To permit access, tap settings and activate microphone.", nil)
#define kLocalizedUnsupportedElementsDescription NSLocalizedString(@"Following features used in this project are not compatible with this version of Pocket Code:", nil)

//************************************************************************************************************
//*******************************       BRICK TITLE TRANSLATIONS      ****************************************
//************************************************************************************************************

// control bricks
#define kLocalizedScript NSLocalizedString(@"Script", nil)
#define kLocalizedWhenProjectStarted NSLocalizedString(@"When project started", nil)
#define kLocalizedWhenTapped NSLocalizedString(@"When tapped", nil)
#define kLocalizedTouchDown NSLocalizedString(@"When stage is tapped", nil)
#define kLocalizedWait NSLocalizedString(@"Wait", nil)
#define kLocalizedSecond NSLocalizedString(@"second ", nil)
#define kLocalizedSeconds NSLocalizedString(@"seconds ", nil)
#define kLocalizedVibrateFor NSLocalizedString(@"Vibrate for", nil)
#define kLocalizedWhenYouReceive NSLocalizedString(@"When you receive", nil)
#define kLocalizedBroadcast NSLocalizedString(@"Broadcast", nil)
#define kLocalizedBroadcastAndWait NSLocalizedString(@"Broadcast and wait", nil)
#define kLocalizedNote NSLocalizedString(@"Note", nil)
#define kLocalizedForever NSLocalizedString(@"Forever", nil)
#define kLocalizedIfBegin NSLocalizedString(@"If", nil)
#define kLocalizedIfBeginSecondPart NSLocalizedString(@"is true then", nil)
#define kLocalizedElse NSLocalizedString(@"Else", nil)
#define kLocalizedEndIf NSLocalizedString(@"End if", nil)
#define kLocalizedWaitUntil NSLocalizedString(@"Wait until", nil)
#define kLocalizedRepeat NSLocalizedString(@"Repeat", nil)
#define kLocalizedRepeatUntil NSLocalizedString(@"Repeat until", nil)
#define kLocalizedUntilIsTrue NSLocalizedString(@"is true", nil)
#define kLocalizedTime NSLocalizedString(@"time", nil)
#define kLocalizedTimes NSLocalizedString(@"times", nil)
#define kLocalizedEndOfLoop NSLocalizedString(@"End of Loop", nil)

// motion bricks
#define kLocalizedPlaceAt NSLocalizedString(@"Place at ", nil)
#define kLocalizedXLabel NSLocalizedString(@"x: ", nil)
#define kLocalizedYLabel NSLocalizedString(@"y: ", nil)
#define kLocalizedSetX NSLocalizedString(@"Set x to ", nil)
#define kLocalizedSetY NSLocalizedString(@"Set y to ", nil)
#define kLocalizedChangeXBy NSLocalizedString(@"Change x by ", nil)
#define kLocalizedChangeYBy NSLocalizedString(@"Change y by ", nil)
#define kLocalizedIfIsTrueThenOnEdgeBounce NSLocalizedString(@"If on edge, bounce", nil)
#define kLocalizedMove NSLocalizedString(@"Move", nil)
#define kLocalizedStep NSLocalizedString(@"step", nil)
#define kLocalizedSteps NSLocalizedString(@"steps", nil)
#define kLocalizedTurnLeft NSLocalizedString(@"Turn left", nil)
#define kLocalizedTurnRight NSLocalizedString(@"Turn right", nil)
#define kLocalizedDegrees NSLocalizedString(@"degrees", nil)
#define kLocalizedPointInDirection NSLocalizedString(@"Point in direction", nil)
#define kLocalizedPointTowards NSLocalizedString(@"Point towards", nil)
#define kLocalizedGlide NSLocalizedString(@"Glide", nil)
#define kLocalizedToX NSLocalizedString(@"to x:", nil)
#define kLocalizedGoBack NSLocalizedString(@"Go back", nil)
#define kLocalizedLayer NSLocalizedString(@"layer", nil)
#define kLocalizedLayers NSLocalizedString(@"layers", nil)
#define kLocalizedComeToFront NSLocalizedString(@"Go to front", nil)

// look bricks
#define kLocalizedLook NSLocalizedString(@"Look", nil)
#define kLocalizedSetLook NSLocalizedString(@"Switch to look", nil)
#define kLocalizedSetBackground NSLocalizedString(@"Set background", nil)
#define kLocalizedNextLook NSLocalizedString(@"Next look", nil)
#define kLocalizedNextBackground NSLocalizedString(@"Next background", nil)
#define kLocalizedPreviousLook NSLocalizedString(@"Previous look", nil)
#define kLocalizedPreviousBackground NSLocalizedString(@"Previous background", nil)
#define kLocalizedSetSizeTo NSLocalizedString(@"Set size to", nil)
#define kLocalizedChangeSizeByN NSLocalizedString(@"Change size by", nil)
#define kLocalizedHide NSLocalizedString(@"Hide", nil)
#define kLocalizedShow NSLocalizedString(@"Show", nil)
#define kLocalizedLedOn NSLocalizedString(@"Flashlight on", nil)
#define kLocalizedLedOff NSLocalizedString(@"Flashlight off", nil)
#define kLocalizedSetTransparency NSLocalizedString(@"Set transparency ", nil)
#define kLocalizedChangeTransparency NSLocalizedString(@"Change transparency ", nil)
#define kLocalizedSetBrightness NSLocalizedString(@"Set brightness ", nil)
#define kLocalizedChangeBrightness NSLocalizedString(@"Change brightness ", nil)
#define kLocalizedTo NSLocalizedString(@"to", nil)
#define kLocalizedBy NSLocalizedString(@"by", nil)
#define kLocalizedClearGraphicEffect NSLocalizedString(@"Clear graphic effects", nil)
#define kLocalizedSetColor NSLocalizedString(@"Set color ", nil)
#define kLocalizedChangeColor NSLocalizedString(@"Change color ", nil)
#define kLocalizedFlash NSLocalizedString(@"Turn flashlight", nil)
#define kLocalizedCamera NSLocalizedString(@"Turn camera", nil)
#define kLocalizedChooseCamera NSLocalizedString(@"Use camera", nil)
#define kLocalizedFor NSLocalizedString(@"for", nil)

// sound bricks
#define kLocalizedSound NSLocalizedString(@"Sound", nil)
#define kLocalizedPlaySound NSLocalizedString(@"Start sound", nil)
#define kLocalizedPlaySoundAndWait NSLocalizedString(@"Start sound and wait", nil)
#define kLocalizedStopAllSounds NSLocalizedString(@"Stop all sounds", nil)
#define kLocalizedSetVolumeTo NSLocalizedString(@"Set volume to", nil)
#define kLocalizedChangeVolumeBy NSLocalizedString(@"Change volume by", nil)
#define kLocalizedSay NSLocalizedString(@"Say", nil)
#define kLocalizedThink NSLocalizedString(@"Think", nil)
#define kLocalizedSpeak NSLocalizedString(@"Speak", nil)
#define kLocalizedAndWait NSLocalizedString(@"and wait", nil)

// variable
#define kLocalizedSetVariable NSLocalizedString(@"Set variable", nil)
#define kLocalizedChangeVariable NSLocalizedString(@"Change variable", nil)
#define kLocalizedShowVariable NSLocalizedString(@"Show variable", nil)
#define kLocalizedHideVariable NSLocalizedString(@"Hide variable", nil)
#define kLocalizedAt NSLocalizedString(@"at ", nil)

//userlist
#define kLocalizedUserListAdd NSLocalizedString(@"Add", nil)
#define kLocalizedUserListTo NSLocalizedString(@"to list", nil)
#define kLocalizedUserListDeleteItemFrom NSLocalizedString(@"Delete item from list", nil)
#define kLocalizedUserListAtPosition NSLocalizedString(@"at position", nil)
#define kLocalizedUserListInsert NSLocalizedString(@"Insert", nil)
#define kLocalizedUserListInto NSLocalizedString(@"into list", nil)
#define kLocalizedUserListReplaceItemInList NSLocalizedString(@"Replace item in list", nil)
#define kLocalizedUserListWith NSLocalizedString(@"with", nil)

//Note
#define kLocalizedNoteAddCommentHere NSLocalizedString(@"add comment here...", nil)

//Bubble
#define kLocalizedHello NSLocalizedString(@"Hello!", nil)
#define kLocalizedHmmmm NSLocalizedString(@"Hmmmm!", nil)

// Broadcast
#define kLocalizedBroadcastMessage1 NSLocalizedString(@"message 1", nil)

// phiro bricks
#define kLocalizedStopPhiroMotor NSLocalizedString(@"Stop Phiro motor", nil)
#define kLocalizedPhiroSpeed NSLocalizedString(@"Speed", nil)
#define kLocalizedPhiroMoveForward NSLocalizedString(@"Move Phiro motor forward", nil)
#define kLocalizedPhiroMoveBackward NSLocalizedString(@"Move Phiro motor backward", nil)
#define kLocalizedPhiroRGBLight NSLocalizedString(@"Set Phiro light", nil)
#define kLocalizedPhiroRGBLightRed NSLocalizedString(@"red", nil)
#define kLocalizedPhiroRGBLightGreen NSLocalizedString(@"green", nil)
#define kLocalizedPhiroRGBLightBlue NSLocalizedString(@"blue", nil)
#define kLocalizedPhiroPlayTone NSLocalizedString(@"Play Phiro music\n", nil)
#define kLocalizedPhiroPlayDuration NSLocalizedString(@"Duration", nil)
#define kLocalizedPhiroSecondsToPlay NSLocalizedString(@"seconds", nil)
#define kLocalizedPhiroIfLogic NSLocalizedString(@"If", nil)
#define kLocalizedPhiroThenLogic NSLocalizedString(@"is true then", nil)

// Arduino bricks
#define kLocalizedArduinoSetDigitalValue NSLocalizedString(@"Set Arduino digital pin", nil)
#define kLocalizedArduinoSetPinValueTo NSLocalizedString(@"to", nil)
#define kLocalizedArduinoSendPWMValue NSLocalizedString(@"Set Arduino PWM~ pin", nil)

//Unsupported elements
#define kLocalizedUnsupportedElements NSLocalizedString(@"Unsupported Elements", nil)
#define kLocalizedUnsupportedBrick NSLocalizedString(@"Unsupported Brick:", nil)
#define kLocalizedUnsupportedScript NSLocalizedString(@"Unsupported Script:", nil)

//************************************************************************************************************
//**********************************       Login/Upload            *******************************************
//************************************************************************************************************

#define kLocalizedLogin NSLocalizedString(@"Login", nil)
#define kLocalizedLogout NSLocalizedString(@"Logout", nil)
#define kLocalizedUsername NSLocalizedString(@"Username", nil)
#define kLocalizedPassword NSLocalizedString(@"Password", nil)
#define kLocalizedConfirmPassword NSLocalizedString(@"Confirm password", nil)
#define kLocalizedEmail NSLocalizedString(@"Email", nil)
#define kLocalizedRegister NSLocalizedString(@"Create account", nil)
#define kLocalizedUploadProject NSLocalizedString(@"Upload project", nil)
#define kLocalizedLoginUsernameNecessary NSLocalizedString(@"Username must not be blank", nil)
#define kLocalizedLoginEmailNotValid NSLocalizedString(@"Your email seems to be invalid", nil)
#define kLocalizedLoginPasswordNotValid NSLocalizedString(@"Password is not vaild! \n It has to contain at least 6 characters/symbols", nil)
#define kLocalizedRegisterPasswordConfirmationNoMatch NSLocalizedString(@"Passwords do not match", nil)
#define kLocalizedUploadProjectNecessary NSLocalizedString(@"Project Name is necessary!", nil)
#define kLocalizedTermsAgreementPart NSLocalizedString(@"By registering you agree to our", nil)
#define kLocalizedUploadSuccessful NSLocalizedString(@"Upload successful", nil)
#define kLocalizedRegistrationSuccessful NSLocalizedString(@"Registration successful", nil)
#define kLocalizedLoginSuccessful NSLocalizedString(@"Login successful", nil)
#define kUploadSelectedProject NSLocalizedString(@"Upload selected project", nil)
#define kLocalizedUploadProblem NSLocalizedString(@"Problems occured while uploading your project", nil)
#define kLocalizedUploadSelectProject NSLocalizedString(@"Please select a project to upload", nil)
#define kLocalizedNoWhitespaceAllowed NSLocalizedString(@"No whitespace character allowed",nil)
#define kLocalizedAuthenticationFailed NSLocalizedString(@"Authentication failed",nil)

#define kLocalizedInfoLogin NSLocalizedString(@"Login",nil)
#define kLocalizedInfoRegister NSLocalizedString(@"Register",nil)

//************************************************************************************************************
//************************************       PAINT                ********************************************
//************************************************************************************************************

#define kLocalizedPaintWidth NSLocalizedString(@"Width selection", @"paint")
#define kLocalizedPaintRed NSLocalizedString(@"Red", @"paint")
#define kLocalizedPaintGreen NSLocalizedString(@"Green", @"paint")
#define kLocalizedPaintBlue NSLocalizedString(@"Blue", @"paint")
#define kLocalizedPaintAlpha NSLocalizedString(@"Alpha", @"paint")
#define kLocalizedPaintBrush NSLocalizedString(@"Brush", @"paint")
#define kLocalizedPaintEraser NSLocalizedString(@"Eraser", @"paint")
#define kLocalizedPaintResize NSLocalizedString(@"Resize", @"paint")
#define kLocalizedPaintPipette NSLocalizedString(@"Pipette", @"paint")
#define kLocalizedPaintMirror NSLocalizedString(@"Mirror", @"paint")
#define kLocalizedPaintImage NSLocalizedString(@"Image", @"paint")
#define kLocalizedPaintLine NSLocalizedString(@"Line", @"paint")
#define kLocalizedPaintRect NSLocalizedString(@"Rectangle / Square", @"paint")
#define kLocalizedPaintCircle NSLocalizedString(@"Ellipse / Circle", @"paint")
#define kLocalizedPaintStamp NSLocalizedString(@"Stamp", @"paint")
#define kLocalizedPaintRotate NSLocalizedString(@"Rotate", @"paint")
#define kLocalizedPaintFill NSLocalizedString(@"Fill", @"paint")
#define kLocalizedPaintZoom NSLocalizedString(@"Zoom", @"paint")
#define kLocalizedPaintPointer NSLocalizedString(@"Pointer", @"paint")
#define kLocalizedPaintTextTool NSLocalizedString(@"Text", @"paint")
#define kLocalizedPaintSaveChanges NSLocalizedString(@"Do you want to save the changes", @"paint")
#define kLocalizedPaintMenuButtonTitle NSLocalizedString(@"Menu", @"paint")
#define kLocalizedPaintSelect NSLocalizedString(@"Select option:", @"paint")
#define kLocalizedPaintSave NSLocalizedString(@"Save to cameraRoll", @"paint")
#define kLocalizedPaintClose NSLocalizedString(@"Close Paint", @"paint")
#define kLocalizedPaintNewCanvas NSLocalizedString(@"New canvas", @"paint")
#define kLocalizedPaintPickTool NSLocalizedString(@"Please pick a tool", @"paint")
#define kLocalizedPaintNoCrop NSLocalizedString(@"Nothing to crop!", @"paint")
#define kLocalizedPaintAskNewCanvas NSLocalizedString(@"Do you really want to delete the current drawing?", @"paint")
#define kLocalizedPaintRound NSLocalizedString(@"round", @"paint")
#define kLocalizedPaintSquare NSLocalizedString(@"square", @"paint")
#define kLocalizedPaintPocketPaint NSLocalizedString(@"Pocket Paint", @"paint")
#define kLocalizedPaintStamped NSLocalizedString(@"Stamped", @"paint")
#define kLocalizedPaintInserted NSLocalizedString(@"Inserted", @"paint")
#define kLocalizedPaintText NSLocalizedString(@"Text:", @"paint")
#define kLocalizedPaintAttributes NSLocalizedString(@"Attributes:", @"paint")
#define kLocalizedPaintBold NSLocalizedString(@"bold", @"paint")
#define kLocalizedPaintItalic NSLocalizedString(@"italic", @"paint")
#define kLocalizedPaintUnderline NSLocalizedString(@"underline", @"paint")
#define kLocalizedPaintTextAlert NSLocalizedString(@"Please enter a text.", @"paint")

//************************************************************************************************************
//************************************       FormulaEditor        ********************************************
//************************************************************************************************************

#define kUIActionSheetTitleSelectLogicalOperator NSLocalizedString(@"Select logical operator", nil)
#define kUIActionSheetTitleSelectMathematicalFunction NSLocalizedString(@"Select mathematical function", nil)
#define kUIFENumbers NSLocalizedString(@"Numbers", nil)
#define kUIFELogic NSLocalizedString(@"Logic", nil)
#define kUIFEVar NSLocalizedString(@"New", nil)
#define kUIFETake NSLocalizedString(@"Choose", nil)
#define kUIFEDelete NSLocalizedString(@"Delete", nil)
#define kUIFEMath NSLocalizedString(@"Math", nil)
#define kUIFEObject NSLocalizedString(@"Object", nil)
#define kUIFESensor NSLocalizedString(@"Sensors", nil)
#define kUIFEVariable NSLocalizedString(@"Variables", nil)
#define kUIFEVariableList NSLocalizedString(@"Var/List", nil)
#define kUIFECompute NSLocalizedString(@"Compute", nil)
#define kUIFEDone NSLocalizedString(@"Done", nil)
#define kUIFEError NSLocalizedString(@"Error", nil)
#define kUIFEtooLongFormula NSLocalizedString(@"Formula too long!", nil)
#define kUIFEResult NSLocalizedString(@"Result", nil)
#define kUIFEComputed NSLocalizedString(@"Computed result is %.2f", nil)
#define kUIFEComputedTrue NSLocalizedString(@"Computed result is TRUE", nil)
#define kUIFEComputedFalse NSLocalizedString(@"Computed result is FALSE", nil)
#define kUIFENewVar NSLocalizedString(@"New variable", nil)
#define kUIFENewList NSLocalizedString(@"New list", nil)
#define kUIFENewVarExists NSLocalizedString(@"Name already exists.", nil)
#define kUIFEonly15Char NSLocalizedString(@"only 15 characters allowed", nil)
#define kUIFEVarName NSLocalizedString(@"Variable name:", nil)
#define kUIFEListName NSLocalizedString(@"List name:", nil)
#define kUIFEOtherName NSLocalizedString(@"Please choose another name:", nil)
#define kUIFEAddNewText NSLocalizedString(@"Abc", nil)

#define kUIFEProjectVars NSLocalizedString(@"Project variables:", nil)
#define kUIFEObjectVars NSLocalizedString(@"Object variables:", nil)
#define kUIFEProjectLists NSLocalizedString(@"Project lists:", nil)
#define kUIFEObjectLists NSLocalizedString(@"Object lists:", nil)
#define kUIFEDeleteVarBeingUsed NSLocalizedString(@"This variable can not be deleted because it is still in use.", nil)
#define kUIFEActionVar NSLocalizedString(@"Variable type", nil)
#define kUIFEActionList NSLocalizedString(@"List type", nil)
#define kUIFEActionVarObj NSLocalizedString(@"for this actor or object", nil)
#define kUIFEActionVarPro NSLocalizedString(@"for all actors or objects", nil)
#define kUIFEChangesSaved NSLocalizedString(@"Changes saved.", nil)
#define kUIFEChangesDiscarded NSLocalizedString(@"Changes discarded.", nil)
#define kUIFESyntaxError NSLocalizedString(@"Syntax Error!", nil)
#define kUIFEEmptyInput NSLocalizedString(@"Empty input!", nil)

#define kUIFEVarOrList NSLocalizedString(@"Variable or list", nil)

#define kUIFEFunctionSqrt NSLocalizedString(@"sqrt", nil)
#define kUIFEFunctionTrue NSLocalizedString(@"true", nil)
#define kUIFEFunctionFalse NSLocalizedString(@"false", nil)
#define kUIFEFunctionLetter NSLocalizedString(@"letter", nil)
#define kUIFEFunctionJoin NSLocalizedString(@"join", nil)
#define kUIFEFunctionLength NSLocalizedString(@"length", nil)
#define kUIFEFunctionFloor NSLocalizedString(@"floor", nil)
#define kUIFEFunctionCeil NSLocalizedString(@"ceil", nil)
#define kUIFEFunctionNumberOfItems NSLocalizedString(@"number of items", nil)
#define kUIFEFunctionElement NSLocalizedString(@"element", nil)
#define kUIFEFunctionContains NSLocalizedString(@"contains", nil)

#define kUIFEFunctionScreenIsTouched NSLocalizedString(@"stage is touched", nil)
#define kUIFEFunctionScreenTouchX NSLocalizedString(@"stage touch x", nil)
#define kUIFEFunctionScreenTouchY NSLocalizedString(@"stage touch y", nil)

#define kUIFEOperatorAnd NSLocalizedString(@"and", nil)
#define kUIFEOperatorNot NSLocalizedString(@"not", nil)
#define kUIFEOperatorOr NSLocalizedString(@"or", nil)

#define kUIFEObjectTransparency NSLocalizedString(@"transparency", nil)
#define kUIFEObjectBrightness NSLocalizedString(@"brightness", nil)
#define kUIFEObjectColor NSLocalizedString(@"color", nil)
#define kUIFEObjectLookNumber NSLocalizedString(@"look number", nil)
#define kUIFEObjectLookName NSLocalizedString(@"look name", nil)
#define kUIFEObjectBackgroundNumber NSLocalizedString(@"background number", nil)
#define kUIFEObjectBackgroundName NSLocalizedString(@"background name", nil)
#define kUIFEObjectSize NSLocalizedString(@"size", nil)
#define kUIFEObjectDirection NSLocalizedString(@"direction", nil)
#define kUIFEObjectLayer NSLocalizedString(@"layer", nil)
#define kUIFEObjectPositionX NSLocalizedString(@"position x", nil)
#define kUIFEObjectPositionY NSLocalizedString(@"position y", nil)

#define kUIFESensorDateYear NSLocalizedString(@"year", nil)
#define kUIFESensorDateMonth NSLocalizedString(@"month", nil)
#define kUIFESensorDateDay NSLocalizedString(@"day", nil)
#define kUIFESensorDateWeekday NSLocalizedString(@"weekday", nil)
#define kUIFESensorTimeHour NSLocalizedString(@"hour", nil)
#define kUIFESensorTimeMinute NSLocalizedString(@"minute", nil)
#define kUIFESensorTimeSecond NSLocalizedString(@"second", nil)

#define kUIFESensorCompass NSLocalizedString(@"compass", nil)
#define kUIFESensorLoudness NSLocalizedString(@"loudness", nil)
#define kUIFESensorAccelerationX NSLocalizedString(@"acceleration x", nil)
#define kUIFESensorAccelerationY NSLocalizedString(@"acceleration y", nil)
#define kUIFESensorAccelerationZ NSLocalizedString(@"acceleration z", nil)
#define kUIFESensorInclinationX NSLocalizedString(@"inclination x", nil)
#define kUIFESensorInclinationY NSLocalizedString(@"inclination y", nil)
#define kUIFESensorLatitude NSLocalizedString(@"latitude", nil)
#define kUIFESensorLongitude NSLocalizedString(@"longitude", nil)
#define kUIFESensorLocationAccuracy NSLocalizedString(@"location accuracy", nil)
#define kUIFESensorAltitude NSLocalizedString(@"altitude", nil)
#define kUIFESensorFingerTouched NSLocalizedString(@"stage is touched", nil)
#define kUIFESensorFingerX NSLocalizedString(@"stage touch x", nil)
#define kUIFESensorFingerY NSLocalizedString(@"stage touch y", nil)
#define kUIFESensorLastFingerIndex NSLocalizedString(@"last stage touch index", nil)
#define kUIFESensorPhiroFrontLeft NSLocalizedString(@"phiro front left", nil)
#define kUIFESensorPhiroFrontRight NSLocalizedString(@"phiro front right", nil)
#define kUIFESensorPhiroSideLeft NSLocalizedString(@"phiro side left", nil)
#define kUIFESensorPhiroSideRight NSLocalizedString(@"phiro side right", nil)
#define kUIFESensorPhiroBottomLeft NSLocalizedString(@"phiro bottom left", nil)
#define kUIFESensorPhiroBottomRight NSLocalizedString(@"phiro bottom right", nil)

#define kUIFESensorArduinoAnalog NSLocalizedString(@"arduino analog", nil)

#define kUIFESensorArduinoDigital NSLocalizedString(@"arduino digital", nil)

#define kLocalizedSensorCompass NSLocalizedString(@"compass", nil)
#define kLocalizedSensorLocation NSLocalizedString(@"location", nil)
#define kLocalizedSensorDeviceMotion NSLocalizedString(@"device motion-sensor", nil)
#define kLocalizedSensorAcceleration NSLocalizedString(@"acceleration-sensor", nil)
#define kLocalizedSensorRotation NSLocalizedString(@"gyro-sensor", nil)
#define kLocalizedSensorMagnetic NSLocalizedString(@"magnetic-sensor", nil)
#define kLocalizedVibration NSLocalizedString(@"vibration", nil)
#define kLocalizedSensorLoudness NSLocalizedString(@"loudness", nil)
#define kLocalizedSensorLED NSLocalizedString(@"LED", nil)
#define kLocalizedNotAvailable NSLocalizedString(@"not available. Continue anyway?", nil)

#define kUIFESensorFaceDetected NSLocalizedString(@"face detected", nil)
#define kUIFESensorFaceSize NSLocalizedString(@"facesize", nil)
#define kUIFESensorFaceX NSLocalizedString(@"faceposition x", nil)
#define kUIFESensorFaceY NSLocalizedString(@"faceposition y", nil)

#define kUIFEUnknownElementType NSLocalizedString(@"Unknown Element", nil)

#define kUIFENewText NSLocalizedString(@"New text", nil)
#define kUIFETextMessage NSLocalizedString(@"Text message:", nil)

//************************************************************************************************************
//************************************       BrickCategoryTitles        **************************************
//************************************************************************************************************

#define kLocalizedCategoryFrequentlyUsed NSLocalizedString(@"Frequently used", @"Title of View where the user can see the frequently used bricks.")
#define kLocalizedCategoryControl NSLocalizedString(@"Control", nil)
#define kLocalizedCategoryMotion NSLocalizedString(@"Motion", nil)
#define kLocalizedCategoryLook NSLocalizedString(@"Look", nil)
#define kLocalizedCategorySound NSLocalizedString(@"Sound", nil)
#define kLocalizedCategoryVariable NSLocalizedString(@"Variable", nil)
#define kLocalizedCategoryArduino NSLocalizedString(@"Arduino", nil)
#define kLocalizedCategoryPhiro NSLocalizedString(@"Phiro", nil)

//************************************************************************************************************
//************************************       PhiroDefines         ********************************************
//************************************************************************************************************

#define kLocalizedPhiroBoth NSLocalizedString(@"Both", nil)
#define kLocalizedPhiroLeft NSLocalizedString(@"Left", nil)
#define kLocalizedPhiroRight NSLocalizedString(@"Right", nil)

#define kLocalizedPhiroDO NSLocalizedString(@"DO", nil)
#define kLocalizedPhiroRE NSLocalizedString(@"RE", nil)
#define kLocalizedPhiroMI NSLocalizedString(@"MI", nil)
#define kLocalizedPhiroFA NSLocalizedString(@"FA", nil)
#define kLocalizedPhiroSO NSLocalizedString(@"SO", nil)
#define kLocalizedPhiroLA NSLocalizedString(@"LA", nil)
#define kLocalizedPhiroTI NSLocalizedString(@"TI", nil)

#define klocalizedBluetoothSearch NSLocalizedString(@"Search", @"bluetooth")
#define klocalizedBluetoothKnown NSLocalizedString(@"Known devices", @"bluetooth")
#define klocalizedBluetoothSelectPhiro NSLocalizedString(@"Select Phiro", @"bluetooth")
#define klocalizedBluetoothSelectArduino NSLocalizedString(@"Select Arduino", @"bluetooth")
#define klocalizedBluetoothConnectionNotPossible NSLocalizedString(@"Connection not possible", @"bluetooth")
#define klocalizedBluetoothConnectionTryResetting NSLocalizedString(@"Please try resetting the device and try again.", @"bluetooth")
#define klocalizedBluetoothConnectionFailed NSLocalizedString(@"Connection failed", @"bluetooth")
#define klocalizedBluetoothCannotConnect NSLocalizedString(@"Cannot connect to device, please try resetting the device and try again.", @"bluetooth")
#define klocalizedBluetoothNotResponding NSLocalizedString(@"Cannot connect to device. The device is not responding.", @"bluetooth")
#define klocalizedBluetoothConnectionLost NSLocalizedString(@"Connection lost", @"bluetooth")
#define klocalizedBluetoothDisconnected NSLocalizedString(@"Device disconnected.", @"bluetooth")

//************************************************************************************************************
//************************************       MediaLibrary        *********************************************
//************************************************************************************************************

#define kLocalizedMediaLibrary NSLocalizedString(@"Media library", nil)
#define kLocalizedMediaLibraryConnectionIssueTitle NSLocalizedString(@"Connection failed", nil)
#define kLocalizedMediaLibraryConnectionIssueMessage NSLocalizedString(@"Cannot connect to the media library. Please check your internet connection.", nil)
#define kLocalizedMediaLibraryImportFailedTitle NSLocalizedString(@"Failed to import item", nil)
#define kLocalizedMediaLibraryImportFailedMessage NSLocalizedString(@"The following item could not be imported from the media library:", nil)
#define kLocalizedMediaLibrarySoundLoadFailureTitle NSLocalizedString(@"Failed to load sound", nil)
#define kLocalizedMediaLibrarySoundLoadFailureMessage NSLocalizedString(@"The sound item cannot be loaded", nil)
#define kLocalizedMediaLibrarySoundPlayFailureTitle NSLocalizedString(@"Failed to play sound", nil)
#define kLocalizedMediaLibrarySoundPlayFailureMessage NSLocalizedString(@"The sound item cannot be played", nil)

//************************************************************************************************************
//**********************************       FeaturedProjects        *******************************************
//************************************************************************************************************

#define kLocalizedFeaturedProjectsLoadFailureTitle NSLocalizedString(@"Failed to load featured projects", nil)
#define kLocalizedFeaturedProjectsLoadFailureMessage NSLocalizedString(@"The featured projects cannot be loaded", nil)

//************************************************************************************************************
//***********************************       ChartProjects        *********************************************
//************************************************************************************************************

#define kLocalizedChartProjectsLoadFailureTitle NSLocalizedString(@"Failed to load recent projects", nil)
#define kLocalizeChartProjectsLoadFailureMessage NSLocalizedString(@"The recent projects cannot be loaded", nil)

//************************************************************************************************************
//**************************************       Networking        *********************************************
//************************************************************************************************************

#define kLocalizedServerTimeoutIssueTitle NSLocalizedString(@"Connection failed", nil)
#define kLocalizedServerTimeoutIssueMessage NSLocalizedString(@"Server is taking to long to respond, please try again later.", nil)
#define kLocalizedUnexpectedErrorTitle NSLocalizedString(@"Unexpected Error", nil)
#define kLocalizedUnexpectedErrorMessage NSLocalizedString(@"Unexpected Error, please try again later.", nil)

//************************************************************************************************************
//****************************************       Debug        ************************************************
//************************************************************************************************************
#define kLocalizedDebugMode NSLocalizedString(@"debug", nil)

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
