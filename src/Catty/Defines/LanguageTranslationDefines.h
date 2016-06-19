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

#define kLocalizedSkip NSLocalizedString(@"Skip", nil)
#define kLocalizedWelcomeToPocketCode NSLocalizedString(@"Welcome to Pocket Code", nil)
#define kLocalizedExploreApps NSLocalizedString(@"Explore apps", nil)
#define kLocalizedCreateAndEdit NSLocalizedString(@"Create & Remix", nil)
#define kLocalizedNewProgram NSLocalizedString(@"New Program", nil)
#define kLocalizedNewMessage NSLocalizedString(@"New Message", nil)
#define kLocalizedBackground NSLocalizedString(@"Background", nil)
#define kLocalizedMyObject NSLocalizedString(@"My Object", @"Title for first (default) object")
#define kLocalizedMyImage NSLocalizedString(@"My Image", @"Default title of imported photo from camera (taken by camera)")
#define kLocalizedMyFirstProgram NSLocalizedString(@"My first program", @"Name of the default catrobat program (used as filename!!)")
#define kLocalizedMole NSLocalizedString(@"Mole", @"Prefix of default catrobat program object names (except background object)")
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
#define kLocalizedChooseSound NSLocalizedString(@"Choose sound", nil)
#define kLocalizedFeaturedPrograms NSLocalizedString(@"Featured Programs", nil)
#define kLocalizedScripts NSLocalizedString(@"Scripts", nil)
#define kLocalizedBackgrounds NSLocalizedString(@"Backgrounds", nil)
#define kLocalizedTapPlusToAdd NSLocalizedString(@"Tap \"+\" to add %@", nil)
#define kLocalizedContinue NSLocalizedString(@"Continue", nil)
#define kLocalizedNew NSLocalizedString(@"New", nil)
#define kLocalizedNewElement NSLocalizedString(@"New...", nil)
#define kLocalizedPrograms NSLocalizedString(@"Programs", nil)
#define kLocalizedHelp NSLocalizedString(@"Help", nil)
#define kLocalizedExplore NSLocalizedString(@"Explore", nil)
#define kLocalizedDeletionMenu NSLocalizedString(@"Deletion Mode", nil)
#define kLocalizedAboutPocketCode NSLocalizedString(@"About Pocket Code", nil)
#define kLocalizedTermsOfUse NSLocalizedString(@"Terms of Use", nil)
#define kLocalizedForgotPassword NSLocalizedString(@"Forgot password", nil)
#define kLocalizedRateUs NSLocalizedString(@"Rate Us", nil)
#define kLocalizedPrivacySettings NSLocalizedString(@"Privacy Settings", nil)
#define kLocalizedVersionLabel NSLocalizedString(@"v", nil)
#define kLocalizedBack NSLocalizedString(@"Back", nil)
#define kLocalizedSourceCodeLicenseButtonLabel NSLocalizedString(@"Pocket Code Source Code License", nil)
#define kLocalizedAboutCatrobatButtonLabel NSLocalizedString(@"About Catrobat", nil)
#define kLocalizedEdit NSLocalizedString(@"Edit", nil)
#define kLocalizedCancel NSLocalizedString(@"Cancel", nil)
#define kLocalizedDone NSLocalizedString(@"Done", nil)
#define kLocalizedUndo NSLocalizedString(@"Undo", @"Button title of alert view to invoke undo if user shakes device")
#define kLocalizedUndoDrawingDescription NSLocalizedString(@"Undo Drawing?", @"Description text in alert view if user shakes the device")
#define kLocalizedUndoTypingDescription NSLocalizedString(@"Undo Typing?", @"Description text in alert view if user shakes the device")
#define kLocalizedSelectAllItems NSLocalizedString(@"Select All", nil)
#define kLocalizedUnselectAllItems NSLocalizedString(@"Unselect All", nil)
#define kLocalizedSaveToPocketCode NSLocalizedString(@"Save to PocketCode", nil)
#define kLocalizedEditSounds NSLocalizedString(@"Edit Sounds",@"Action sheet menu title")
#define kLocalizedEditSound NSLocalizedString(@"Edit Sound",@"Action sheet menu title")
#define kLocalizedEditLooks NSLocalizedString(@"Edit Looks", @"Action sheet menu title")
#define kLocalizedEditLook NSLocalizedString(@"Edit Look", @"Action sheet menu title")
#define kLocalizedEditBackground NSLocalizedString(@"Edit Background", @"Action sheet menu title")
#define kLocalizedEditBackgrounds NSLocalizedString(@"Edit Backgrounds", @"Action sheet menu title")
#define kLocalizedEditScript NSLocalizedString(@"Edit Script", @"Action sheet menu title")
#define kLocalizedEditBrick NSLocalizedString(@"Edit Brick", @"Action sheet menu title")
#define kLocalizedAddLook NSLocalizedString(@"Add look", @"Action sheet menu title")
#define kLocalizedLook NSLocalizedString(@"look", @"LOOK")
#define kLocalizedEditProgram NSLocalizedString(@"Edit Program", nil)
#define kLocalizedEditPrograms NSLocalizedString(@"Edit Programs", nil)
#define kLocalizedEditObject NSLocalizedString(@"Edit Object", nil)
#define kLocalizedAddSound NSLocalizedString(@"Add sound", @"Action sheet menu title")
#define kLocalizedSaveScreenshotTo NSLocalizedString(@"Save Screenshot to", @"Action sheet menu title")
#define kLocalizedSelectBrickCategory NSLocalizedString(@"Select Brick Category", nil)
#define kLocalizedClose NSLocalizedString(@"Close", nil)
#define kLocalizedDeleteBrick NSLocalizedString(@"Delete Brick", nil)
#define kLocalizedDeleteThisBrick NSLocalizedString(@"Delete this Brick?", nil)
#define kLocalizedDeleteTheseBricks NSLocalizedString(@"Delete these Bricks?", nil)
#define kLocalizedDeleteCondition NSLocalizedString(@"Delete Condition", nil)
#define kLocalizedDeleteThisCondition NSLocalizedString(@"Delete this Condition?", nil)
#define kLocalizedDeleteTheseConditions NSLocalizedString(@"Delete these Conditions?", nil)
#define kLocalizedDeleteLoop NSLocalizedString(@"Delete Loop", nil)
#define kLocalizedDeleteThisLoop NSLocalizedString(@"Delete this Loop?", nil)
#define kLocalizedDeleteTheseLoops NSLocalizedString(@"Delete these Loops?", nil)
#define kLocalizedDeleteScript NSLocalizedString(@"Delete Script", nil)
#define kLocalizedDeleteThisScript NSLocalizedString(@"Delete this Script?", nil)
#define kLocalizedDeleteTheseScripts NSLocalizedString(@"Delete these Scripts?", nil)
#define kLocalizedAnimateBrick NSLocalizedString(@"Animate Brick-Parts", nil)
#define kLocalizedCopyBrick NSLocalizedString(@"Copy Brick", nil)
#define kLocalizedEditFormula NSLocalizedString(@"Edit Formula", nil)
#define kLocalizedMoveBrick NSLocalizedString(@"Move Brick", nil)
#define kLocalizedDeleteSounds NSLocalizedString(@"Delete Sounds", nil)
#define kLocalizedMoveSounds NSLocalizedString(@"Move Sounds",nil)
#define kLocalizedHideDetails NSLocalizedString(@"Hide Details", nil)
#define kLocalizedShowDetails NSLocalizedString(@"Show Details", nil)
#define kLocalizedDeleteLooks NSLocalizedString(@"Delete Looks",nil)
#define kLocalizedDeleteBackgrounds NSLocalizedString(@"Delete Backgrounds",nil)
#define kLocalizedMoveLooks NSLocalizedString(@"Move Looks",nil)
#define kLocalizedFromCamera NSLocalizedString(@"From Camera", nil)
#define kLocalizedChooseImage NSLocalizedString(@"Choose image", nil)
#define kLocalizedDrawNewImage NSLocalizedString(@"Draw new image", nil)
#define kLocalizedRename NSLocalizedString(@"Rename", nil)
#define kLocalizedCopy NSLocalizedString(@"Copy", nil)
#define kLocalizedUpload NSLocalizedString(@"Upload", nil)
#define kLocalizedDeleteObjects NSLocalizedString(@"Delete Objects", nil)
#define kLocalizedMoveObjects NSLocalizedString(@"Move Objects",nil)
#define kLocalizedDeletePrograms NSLocalizedString(@"Delete Programs", nil)
#define kLocalizedPocketCodeRecorder NSLocalizedString(@"Pocket Code Recorder", nil)
#define kLocalizedCameraRoll NSLocalizedString(@"Camera Roll", nil)
#define kLocalizedProject NSLocalizedString(@"Project", nil)
#define kLocalizedPlay NSLocalizedString(@"Play", nil)
#define kLocalizedDownload NSLocalizedString(@"Download", nil)
#define kLocalizedMore NSLocalizedString(@"More", nil)
#define kLocalizedDelete NSLocalizedString(@"Delete", nil)
#define kLocalizedAddObject NSLocalizedString(@"Add object", nil)
#define kLocalizedAddImage NSLocalizedString(@"Add image", nil)
#define kLocalizedRenameObject NSLocalizedString(@"Rename object", nil)
#define kLocalizedRenameImage NSLocalizedString(@"Rename image", nil)
#define kLocalizedRenameSound NSLocalizedString(@"Rename sound", nil)
#define kLocalizedDeleteThisObject NSLocalizedString(@"Delete this object", nil)
#define kLocalizedDeleteThisProgram NSLocalizedString(@"Delete this program", nil)
#define kLocalizedDeleteThisLook NSLocalizedString(@"Delete this look", nil)
#define kLocalizedDeleteThisBackground NSLocalizedString(@"Delete this background", nil)
#define kLocalizedDeleteThisSound NSLocalizedString(@"Delete this sound", nil)
#define kLocalizedCopyProgram NSLocalizedString(@"Copy program", nil)
#define kLocalizedRenameProgram NSLocalizedString(@"Rename Program", nil)
#define kLocalizedSetDescription NSLocalizedString(@"Set description", nil)
#define kLocalizedPocketCodeForIOS NSLocalizedString(@"Pocket Code for iOS", nil)
#define kLocalizedProgramName NSLocalizedString(@"Program name", nil)
#define kLocalizedMessage NSLocalizedString(@"Message", nil)
#define kLocalizedDescription NSLocalizedString(@"Description", nil)
#define kLocalizedObjectName NSLocalizedString(@"Object name", nil)
#define kLocalizedImageName NSLocalizedString(@"Image name", nil)
#define kLocalizedSoundName NSLocalizedString(@"Sound name", nil)
#define kLocalizedOK NSLocalizedString(@"OK", nil)
#define kLocalizedYes NSLocalizedString(@"Yes", nil)
#define kLocalizedNo NSLocalizedString(@"No", nil)
#define kLocalizedDeleteProgram NSLocalizedString(@"Delete Program", nil)
#define kLocalizedLoading NSLocalizedString(@"Loading", nil)
#define kLocalizedSaved NSLocalizedString(@"Saved", nil)
#define kLocalizedAuthor NSLocalizedString(@"Author", nil)
#define kLocalizedDownloads NSLocalizedString(@"Downloads", nil)
#define kLocalizedUploaded NSLocalizedString(@"Uploaded", nil)
#define kLocalizedVersion NSLocalizedString(@"Version", nil)
#define kLocalizedViews NSLocalizedString(@"Views", nil)
#define kLocalizedInformation NSLocalizedString(@"Information", nil)
#define kLocalizedMeasure NSLocalizedString(@"Measure", nil)
#define kLocalizedSize NSLocalizedString(@"Size", nil)
#define kLocalizedObject NSLocalizedString(@"Object", nil)
#define kLocalizedObjects NSLocalizedString(@"Objects", nil)
#define kLocalizedBricks NSLocalizedString(@"Bricks", nil)
#define kLocalizedSounds NSLocalizedString(@"Sounds", nil)
#define kLocalizedLastAccess NSLocalizedString(@"Last access", nil)
#define kLocalizedLength NSLocalizedString(@"Length", nil)
#define kLocalizedRecord NSLocalizedString(@"Record", nil)
#define kLocalizedStop NSLocalizedString(@"Stop", nil)
#define kLocalizedRestart NSLocalizedString(@"Restart", nil)
#define kLocalizedScreenshot NSLocalizedString(@"Screenshot", nil)
#define kLocalizedAxes NSLocalizedString(@"Axes", @"Title of icon shown in the side bar to enable or disable an overlayed view to show the origin of the coordinate system and implicitly the display size.")
#define kLocalizedMostDownloaded NSLocalizedString(@"Most Downloaded", nil)
#define kLocalizedMostViewed NSLocalizedString(@"Most Viewed", nil)
#define kLocalizedNewest NSLocalizedString(@"Newest", nil)
#define kLocalizedControl NSLocalizedString(@"Control", nil)
#define kLocalizedMotion NSLocalizedString(@"Motion", nil)
#define kLocalizedSound NSLocalizedString(@"Sound", nil)
#define kLocalizedVariables NSLocalizedString(@"Variables", nil)
#define kLocalizedPhiro NSLocalizedString(@"Phiro", nil)
#define kLocalizedArduino NSLocalizedString(@"Arduino", nil)
#define kLocalizedPhiroBricks NSLocalizedString(@"Use Phiro bricks", nil)
#define kLocalizedArduinoBricks NSLocalizedString(@"Use Arduino bricks", nil)
#define kLocalizedFaceDetection NSLocalizedString(@"Use face detection", nil)
#define kLocalizedFaceDetectionFrontCamera NSLocalizedString(@"Use front camera", nil)
#define kLocalizedFaceDetectionDefaultCamera NSLocalizedString(@"default camera is back camera", nil)
#define kLocalizedDisconnectAllDevices NSLocalizedString(@"Disconnect all devices", nil)
#define kLocalizedRemoveKnownDevices NSLocalizedString(@"Remove known devices", nil)
#define kLocalizedRecording NSLocalizedString(@"Recording", nil)
#define kLocalizedError NSLocalizedString(@"Error", nil)
#define kLocalizedMemoryWarning NSLocalizedString(@"Not enough Memory", nil)
#define kLocalizedReportProgram NSLocalizedString(@"Report as inappropriate", nil)
#define kLocalizedEnterReason NSLocalizedString(@"Enter a reason", nil)
#define kLocalizedLoginToReport NSLocalizedString(@"Please log in to report this program as inappropriate", nil)
#define kLocalizedName NSLocalizedString(@"Name", nil)
#define kLocalizedDownloaded NSLocalizedString(@"Download sucessful", nil)
#define kLocalizedSettings NSLocalizedString(@"Settings", nil)
#define kLocalizedWiFiProgramDownloads NSLocalizedString(@"Download only with WiFi", nil)
#define kLocalizedNoWifiConnection NSLocalizedString(@"Not Connected to a WiFi network, please connect to one or change the settings to download also with mobile data.", nil)

//************************************************************************************************************
//**********************************       SHORT DESCRIPTIONS      *******************************************
//************************************************************************************************************

#define kLocalizedCantRestartProgram NSLocalizedString(@"Can't restart program!", nil)
#define kLocalizedScreenshotSavedToCameraRoll NSLocalizedString(@"Screenshot saved to Camera Roll", nil)
#define kLocalizedScreenshotSavedToProject NSLocalizedString(@"Screenshot saved to project", nil)
#define kLocalizedThisFeatureIsComingSoon NSLocalizedString(@"This feature is coming soon!", nil)
#define kLocalizedNoDescriptionAvailable NSLocalizedString(@"No Description available", nil)
#define kLocalizedNoSearchResults NSLocalizedString(@"No search results", nil)
#define kLocalizedUnableToLoadProgram NSLocalizedString(@"Unable to load program!", nil)
#define kLocalizedThisActionCannotBeUndone NSLocalizedString(@"This action can not be undone!", nil)
#define kLocalizedErrorInternetConnection NSLocalizedString(@"An unknown error occurred. Check your Internet connection.", nil)
#define kLocalizedErrorUnknown NSLocalizedString(@"An unknown error occurred. Please try again later.", nil)
#define kLocalizedInvalidURLGiven NSLocalizedString(@"Invalid URL given!",nil)
#define kLocalizedNoCamera NSLocalizedString(@"No Camera available",nil)
#define kLocalizedImagePickerSourceNotAvailable NSLocalizedString(@"Image source not available",nil)
#define kLocalizedBluetoothPoweredOff NSLocalizedString(@"Bluetooth is turned off. Please turn it on to connect to a Bluetooth device.",nil)
#define kLocalizedBluetoothNotAvailable NSLocalizedString(@"Bluetooth is not available. Either your device does not support Bluetooth 4.0 or your Bluetooth chip is damaged. Please check it by connection to another Bluetooth device in the Settings.",nil)
#define kLocalizedDisconnectBluetoothDevices NSLocalizedString(@"All Bluetooth devices successfully disconnected", nil)
#define kLocalizedRemovedKnownBluetoothDevices NSLocalizedString(@"All known Bluetooth devices successfully removed", nil)

//************************************************************************************************************
//**********************************       LONG DESCRIPTIONS      ********************************************
//************************************************************************************************************

#define kLocalizedWelcomeDescription NSLocalizedString(@"Pocket Code let's you play great games and run other fantastic apps like for instance presentations, quizzes and so on.", nil)
#define kLocalizedExploreDescription NSLocalizedString(@"By switching to the section \"Explore\" you can discover more interesting programs from people all over the world.", nil)
#define kLocalizedCreateAndEditDescription NSLocalizedString(@"You are also able to build your own apps, remix existing ones and share them with your friends and other exciting people around the world.", nil)
#define kLocalizedAboutPocketCodeDescription NSLocalizedString(@"Pocket Code is a programming environment for iOS for the visual programming language Catrobat. The code of Pocket Code is mostly under GNU AGPL v3 licence. For further information to the licence please visit following links:", nil)
#define kLocalizedTermsOfUseDescription NSLocalizedString(@"In order to be allowed to use Pocket Code and other executables offered by the Catrobat project, you must agree to our Terms of Use and strictly follow them when you use Pocket Code and our other executables. Please see the link below for their precise formulation.", nil)
#define kLocalizedNotEnoughFreeMemoryDescription NSLocalizedString(@"Not enough free memory to download this program. Please delete some of your programs", nil)
#define kLocalizedEnterYourProgramNameHere NSLocalizedString(@"Enter your program name here...", @"Placeholder for program-name input field")
#define kLocalizedEnterNameForImportedProgramTitle NSLocalizedString(@"Import File", @"Title of prompt shown when a *.catrobat file is imported from a third-party app.")
#define kLocalizedEnterYourProgramDescriptionHere NSLocalizedString(@"Enter your program description here...", @"Placeholder for program-description input field")
#define kLocalizedEnterYourMessageHere NSLocalizedString(@"Enter your message here...", @"Placeholder for message input field")
#define kLocalizedEnterYourVariableNameHere NSLocalizedString(@"Enter your variable name here...", @"Placeholder for variable input field")
#define kLocalizedEnterYourObjectNameHere NSLocalizedString(@"Enter your object name here...", @"Placeholder for add object-name input field")
#define kLocalizedEnterYourImageNameHere NSLocalizedString(@"Enter your image name here...", @"Placeholder for add image-name input field")
#define kLocalizedEnterYourSoundNameHere NSLocalizedString(@"Enter your sound name here...", @"Placeholder for add sound-name input field")
#define kLocalizedNoImportedSoundsFoundTitle NSLocalizedString(@"No imported sounds found", @"Title of AlertView if the user tries to import a sound but no sound has been imported using iTunes.")
#define kLocalizedNoImportedSoundsFoundDescription NSLocalizedString(@"Please connect your iPhone to your PC/Mac and use iTunes FileSharing to import sound files into the PocketCode app.", @"Description of AlertView if the user tries to import a sound but no sound has been imported using iTunes.")
#define kLocalizedNoOrTooShortInputDescription NSLocalizedString(@"No input. Please enter at least %lu character(s).", nil)
#define kLocalizedTooLongInputDescription NSLocalizedString(@"The input is too long. Please enter maximal %lu character(s).", nil)
#define kLocalizedSpaceInputDescription NSLocalizedString(@"Only space is not allowed. Please enter at least %lu other character(s).", nil)
#define kLocalizedSpecialCharInputDescription NSLocalizedString(@"Only special characters are not allowed. Please enter at least %lu other character(s).", nil)
#define kLocalizedBlockedCharInputDescription NSLocalizedString(@"The name contains blocked characters. Please try again!", nil)
#define kLocalizedInvalidInputDescription NSLocalizedString(@"Invalid input entered, try again.", nil)
#define kLocalizedProgramNameAlreadyExistsDescription NSLocalizedString(@"A program with the same name already exists, try again.", nil)
#define kLocalizedInvalidDescriptionDescription NSLocalizedString(@"The description contains invalid characters, try again.", nil)
#define kLocalizedObjectNameAlreadyExistsDescription NSLocalizedString(@"An object with the same name already exists, try again.", nil)
#define kLocalizedMessageAlreadyExistsDescription NSLocalizedString(@"A message with the same name already exists, try again.", nil)
#define kLocalizedInvalidImageNameDescription NSLocalizedString(@"No or invalid image name entered, try again.", nil)
#define kLocalizedInvalidSoundNameDescription NSLocalizedString(@"No or invalid sound name entered, try again.", nil)
#define kLocalizedImageNameAlreadyExistsDescription NSLocalizedString(@"An image with the same name already exists, try again.", nil)
#define kLocalizedUnableToPlaySoundDescription NSLocalizedString(@"Unable to play that sound!\nMaybe this is no valid sound or the file is corrupt.", nil)
#define kLocalizedDeviceIsInMutedStateIPhoneDescription NSLocalizedString(@"Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the left side of your iPhone and tap on play again.", nil)
#define kLocalizedDeviceIsInMutedStateIPadDescription NSLocalizedString(@"Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the right side of your iPad and tap on play again.", nil)
#define kLocalizedProgramAlreadyDownloadedDescription NSLocalizedString(@"You have already downloaded this program!", nil)
#define kLocalizedNoAccesToImagesCheckSettingsDescription NSLocalizedString(@"Pocket Code has no access to your images. To permit access, tap settings and activate images. Your drawing will automatically be saved to PocketCode for you.", nil)
#define kLocalizedNoAccesToCameraCheckSettingsDescription NSLocalizedString(@"Pocket Code has no access to your camera. To permit access, tap settings and activate camera. Your drawing will automatically be saved to PocketCode for you.", nil)
#define kLocalizedNoAccesToMicrophoneCheckSettingsDescription NSLocalizedString(@"Pocket Code has no access to your microphone. To permit access, tap settings and activate microphone.", nil)

//************************************************************************************************************
//*******************************       BRICK TITLE TRANSLATIONS      ****************************************
//************************************************************************************************************


// control bricks
#define kLocalizedWhenProgramStarted NSLocalizedString(@"When program started", nil)
#define kLocalizedWhenTapped NSLocalizedString(@"When tapped", nil)
#define kLocalizedWaitNSeconds NSLocalizedString(@"Wait %@ second(s)", nil)
#define kLocalizedVibrateNSeconds NSLocalizedString(@"Vibrate %@ second(s)", nil)
#define kLocalizedWhenIReceive NSLocalizedString(@"When I receive\n%@", nil)
#define kLocalizedBroadcast NSLocalizedString(@"Broadcast\n%@", nil)
#define kLocalizedBroadcastAndWait NSLocalizedString(@"Broadcast and wait\n%@", nil)
#define kLocalizedNote NSLocalizedString(@"Note %@", nil)
#define kLocalizedForever NSLocalizedString(@"Forever", nil)
#define kLocalizedIfIsTrueThen NSLocalizedString(@"If %@ is true then", nil)
#define kLocalizedElse NSLocalizedString(@"Else", nil)
#define kLocalizedEndIf NSLocalizedString(@"End If", nil)
#define kLocalizedRepeatNTimes NSLocalizedString(@"Repeat %@ times", nil)
#define kLocalizedEndOfLoop NSLocalizedString(@"End of Loop", nil)

// motion bricks
#define kLocalizedPlaceAt NSLocalizedString(@"Place at\nX: %@ Y: %@", nil)
#define kLocalizedSetX NSLocalizedString(@"Set X to %@", nil)
#define kLocalizedSetY NSLocalizedString(@"Set Y to %@", nil)
#define kLocalizedChangeX NSLocalizedString(@"Change X by %@", nil)
#define kLocalizedChangeY NSLocalizedString(@"Change Y by %@", nil)
#define kLocalizedIfIsTrueThenOnEdgeBounce NSLocalizedString(@"If on edge, bounce", nil)
#define kLocalizedMoveNSteps NSLocalizedString(@"Move %@ step(s)", nil)
#define kLocalizedTurnLeft NSLocalizedString(@"Turn left %@°", nil)
#define kLocalizedTurnRight NSLocalizedString(@"Turn right %@°", nil)
#define kLocalizedPointInDirection NSLocalizedString(@"Point in direction %@°", nil)
#define kLocalizedPointTowards NSLocalizedString(@"Point towards\n%@", nil)
#define kLocalizedGlideTo NSLocalizedString(@"Glide %@ second(s)\nto X: %@ Y: %@", nil)
#define kLocalizedGoNStepsBack NSLocalizedString(@"Go back %@ layer(s)", nil)
#define kLocalizedComeToFront NSLocalizedString(@"Go to front", nil)

// look bricks
#define kLocalizedSetLook NSLocalizedString(@"Switch to look\n%@", nil)
#define kLocalizedSetBackground NSLocalizedString(@"Set background\n%@", nil)
#define kLocalizedNextLook NSLocalizedString(@"Next look", nil)
#define kLocalizedNextBackground NSLocalizedString(@"Next background", nil)
#define kLocalizedSetSizeTo NSLocalizedString(@"Set size to %@\%", nil)
#define kLocalizedChangeSizeByN NSLocalizedString(@"Change size by %@\%", nil)
#define kLocalizedHide NSLocalizedString(@"Hide", nil)
#define kLocalizedShow NSLocalizedString(@"Show", nil)
#define kLocalizedLedOn NSLocalizedString(@"Flashlight on", nil)
#define kLocalizedLedOff NSLocalizedString(@"Flashlight off", nil)
#define kLocalizedSetTransparency NSLocalizedString(@"Set transparency\nto %@\%", nil)
#define kLocalizedChangeTransparencyByN NSLocalizedString(@"Change transparency\nby %@\%", nil)
#define kLocalizedSetBrightness NSLocalizedString(@"Set brightness to %@\%", nil)
#define kLocalizedChangeBrightnessByN NSLocalizedString(@"Change brightness\nby %@\%", nil)
#define kLocalizedClearGraphicEffect NSLocalizedString(@"Clear graphic effects", nil)

// sound bricks
#define kLocalizedPlaySound NSLocalizedString(@"Start sound\n%@", nil)
#define kLocalizedStopAllSounds NSLocalizedString(@"Stop all sounds", nil)
#define kLocalizedSetVolumeTo NSLocalizedString(@"Set volume to %@\%", nil)
#define kLocalizedChangeVolumeByN NSLocalizedString(@"Change volume by %@", nil)
#define kLocalizedSpeak NSLocalizedString(@"Speak %@", nil)

// variable bricks
#define kLocalizedSetVariable NSLocalizedString(@"Set variable\n%@\nto %@", nil)
#define kLocalizedChangeVariable NSLocalizedString(@"Change variable\n%@\nby %@", nil)
#define kLocalizedShowVariable NSLocalizedString(@"Show variable\n%@\nx: %@ y:%@", nil)
#define kLocalizedHideVariable NSLocalizedString(@"Hide variable\n%@\n", nil)


#define kLocalizedAddCommentHere NSLocalizedString(@"add comment here...", nil)
#define kLocalizedMessage1 NSLocalizedString(@"message 1", nil)
#define kLocalizedHello NSLocalizedString(@"Hello !", nil)

// phiro bricks
#define kLocalizedStopPhiroMotor NSLocalizedString(@"Stop Phiro Motor\n%@", nil)
#define kLocalizedPhiroMoveForward NSLocalizedString(@"Move Phiro Motor forward\n%@\n Speed %@\%", nil)
#define kLocalizedPhiroMoveBackward NSLocalizedString(@"Move Phiro Motor backward\n%@\n Speed %@\%", nil)
#define kLocalizedPhiroRGBLight NSLocalizedString(@"Set Phiro Light\n%@\n Red %@ Green %@ Blue %@", nil)
#define kLocalizedPhiroPlayTone NSLocalizedString(@"play Phiro Tone\n%@\n Duration %@ seconds", nil)
#define kLocalizedPhiroIfLogic NSLocalizedString(@"If %@ is true then", nil)


// Arduino bricks
#define kLocalizedArduinoSendDigitalValue NSLocalizedString(@"Arduino send digital\nPin:%@ Value:%@", nil)
#define kLocalizedArduinoSendPWMValue NSLocalizedString(@"Arduino send PWM\nPin:%@ Value:%@", nil)


//************************************************************************************************************
//**********************************       Login/Upload            *******************************************
//************************************************************************************************************

#define kLocalizedLogin NSLocalizedString(@"Login", nil)
#define kLocalizedUsername NSLocalizedString(@"Username", nil)
#define kLocalizedPassword NSLocalizedString(@"Password", nil)
#define kLocalizedEmail NSLocalizedString(@"Email", nil)
#define kLocalizedRegister NSLocalizedString(@"Create an account", nil)
#define kLocalizedLoginOrRegister NSLocalizedString(@"Login/Register", nil)
#define kLocalizedUploadProgram NSLocalizedString(@"Upload Program", nil)
#define kLocalizedLoginUsernameNecessary NSLocalizedString(@"Username is necessary!", nil)
#define kLocalizedLoginEmailNotValid NSLocalizedString(@"Email is not valid!", nil)
#define kLocalizedLoginPasswordNotValid NSLocalizedString(@"Password is not vaild! \n It has to contain at least 6 characters/symbols", nil)
#define kLocalizedUploadProgramNecessary NSLocalizedString(@"Program Name is necessary!", nil)
#define kLocalizedTermsAgreementPart NSLocalizedString(@"By registering you agree to our", nil)
#define kLocalizedUploadSuccessful NSLocalizedString(@"Upload successful", nil)
#define kLocalizedRegistrationSuccessful NSLocalizedString(@"Registration successful", nil)
#define kLocalizedLoginSuccessful NSLocalizedString(@"Login successful", nil)
#define kUploadSelectedProgram NSLocalizedString(@"Upload Selected Program", nil)
#define kLocalizedUploadProblem NSLocalizedString(@"Problems occured while Uploading your program", nil)
#define kLocalizedUploadSelectProgram NSLocalizedString(@"Please select a program to upload", nil)
#define kLocalizedTitleLogin NSLocalizedString(@"GOOD TO SEE YOU",nil)
#define kLocalizedTitleRegister NSLocalizedString(@"GOOD TO SEE YOU",nil)
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
#define kLocalizedPaintBrush NSLocalizedString(@"brush", @"paint")
#define kLocalizedPaintEraser NSLocalizedString(@"eraser", @"paint")
#define kLocalizedPaintResize NSLocalizedString(@"resize", @"paint")
#define kLocalizedPaintPipette NSLocalizedString(@"pipette", @"paint")
#define kLocalizedPaintMirror NSLocalizedString(@"mirror", @"paint")
#define kLocalizedPaintImage NSLocalizedString(@"image", @"paint")
#define kLocalizedPaintLine NSLocalizedString(@"line", @"paint")
#define kLocalizedPaintRect NSLocalizedString(@"rectangle / square", @"paint")
#define kLocalizedPaintCircle NSLocalizedString(@"ellipse / circle", @"paint")
#define kLocalizedPaintStamp NSLocalizedString(@"stamp", @"paint")
#define kLocalizedPaintRotate NSLocalizedString(@"rotate", @"paint")
#define kLocalizedPaintFill NSLocalizedString(@"fill", @"paint")
#define kLocalizedPaintZoom NSLocalizedString(@"zoom", @"paint")
#define kLocalizedPaintPointer NSLocalizedString(@"pointer", @"paint")
#define kLocalizedPaintTextTool NSLocalizedString(@"text", @"paint")
#define kLocalizedPaintSaveChanges NSLocalizedString(@"Do you want to save the changes", @"paint")
#define kLocalizedPaintMenuButtonTitle NSLocalizedString(@"Menu", @"paint")
#define kLocalizedPaintSelect NSLocalizedString(@"Select option:", @"paint")
#define kLocalizedPaintSave NSLocalizedString(@"Save to CameraRoll", @"paint")
#define kLocalizedPaintClose NSLocalizedString(@"Close Paint", @"paint")
#define kLocalizedPaintNewCanvas NSLocalizedString(@"New Canvas", @"paint")
#define kLocalizedPaintPickItem NSLocalizedString(@"Please pick an item", @"paint")
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
#define kLocalizedPaintTextAlert NSLocalizedString(@"Please enter a text!", @"paint")
//************************************************************************************************************
//************************************       FormulaEditor        ********************************************
//************************************************************************************************************

#define kUIActionSheetTitleSelectLogicalOperator NSLocalizedString(@"Select logical operator", nil)
#define kUIActionSheetTitleSelectMathematicalFunction NSLocalizedString(@"Select mathematical function", nil)
#define kUIFENumbers NSLocalizedString(@"Numbers", nil)
#define kUIFELogic NSLocalizedString(@"Logic", nil)
#define kUIFEVar NSLocalizedString(@"New", nil)
#define kUIFETake NSLocalizedString(@"Choose", nil)
#define kUIFEMath NSLocalizedString(@"Math", nil)
#define kUIFEObject NSLocalizedString(@"Object", nil)
#define kUIFESensor NSLocalizedString(@"Sensors", nil)
#define kUIFEVariable NSLocalizedString(@"Variables", nil)
#define kUIFECompute NSLocalizedString(@"Compute", nil)
#define kUIFEDone NSLocalizedString(@"Done", nil)
#define kUIFEError NSLocalizedString(@"Error", nil)
#define kUIFEtooLongFormula NSLocalizedString(@"Formula too long!", nil)
#define kUIFEResult NSLocalizedString(@"Result", nil)
#define kUIFEComputed NSLocalizedString(@"Computed result is %.2f", nil)
#define kUIFEComputedTrue NSLocalizedString(@"Computed result is TRUE", nil)
#define kUIFEComputedFalse NSLocalizedString(@"Computed result is FALSE", nil)
#define kUIFENewVar NSLocalizedString(@"New Variable", nil)
#define kUIFENewVarExists NSLocalizedString(@"Name already exists. Please choose another", nil)
#define kUIFEonly15Char NSLocalizedString(@"only 15 characters allowed", nil)
#define kUIFEVarName NSLocalizedString(@"Variable name:", nil)
#define kUIFEProgramVars NSLocalizedString(@"Program variables:", nil)
#define kUIFEObjectVars NSLocalizedString(@"Object variables:", nil)
#define kUIFEDeleteVarBeingUsed NSLocalizedString(@"This variable can not be deleted because it is still in use.", nil)
#define kUIFEActionVar NSLocalizedString(@"Variable type", nil)
#define kUIFEActionVarObj NSLocalizedString(@"for this object", nil)
#define kUIFEActionVarPro NSLocalizedString(@"for all objects", nil)
#define kUIFEChangesSaved NSLocalizedString(@"Changes saved!", nil)
#define kUIFEChangesDiscarded NSLocalizedString(@"Changes discarded!", nil)
#define kUIFESyntaxError NSLocalizedString(@"Syntax Error!", nil)

#define kUIFEFunctionSqrt NSLocalizedString(@"sqrt", nil)
#define kUIFEFunctionTrue NSLocalizedString(@"true", nil)
#define kUIFEFunctionFalse NSLocalizedString(@"false", nil)
#define kUIFEFunctionLetter NSLocalizedString(@"letter", nil)
#define kUIFEFunctionJoin NSLocalizedString(@"join", nil)
#define kUIFEFunctionLength NSLocalizedString(@"length", nil)
#define kUIFEFunctionFloor NSLocalizedString(@"floor", nil)
#define kUIFEFunctionCeil NSLocalizedString(@"ceil", nil)

#define kUIFEOperatorAnd NSLocalizedString(@"and", nil)
#define kUIFEOperatorNot NSLocalizedString(@"not", nil)
#define kUIFEOperatorOr NSLocalizedString(@"or", nil)

#define kUIFEObjectTransparency NSLocalizedString(@"transparency", nil)
#define kUIFEObjectBrightness NSLocalizedString(@"brightness", nil)
#define kUIFEObjectSize NSLocalizedString(@"size", nil)
#define kUIFEObjectDirection NSLocalizedString(@"direction", nil)
#define kUIFEObjectLayer NSLocalizedString(@"layer", nil)
#define kUIFEObjectPositionX NSLocalizedString(@"pos_x", nil)
#define kUIFEObjectPositionY NSLocalizedString(@"pos_y", nil)

#define kUIFESensorCompass NSLocalizedString(@"compass", nil)
#define kUIFESensorLoudness NSLocalizedString(@"loudness", nil)
#define kUIFESensorAccelerationX NSLocalizedString(@"acceleration_x", nil)
#define kUIFESensorAccelerationY NSLocalizedString(@"acceleration_y", nil)
#define kUIFESensorAccelerationZ NSLocalizedString(@"acceleration_z", nil)
#define kUIFESensorInclinationX NSLocalizedString(@"inclination_x", nil)
#define kUIFESensorInclinationY NSLocalizedString(@"inclination_y", nil)
#define kUIFESensorPhiroFrontLeft NSLocalizedString(@"phiro_front_left", nil)
#define kUIFESensorPhiroFrontRight NSLocalizedString(@"phiro_front_right", nil)
#define kUIFESensorPhiroSideLeft NSLocalizedString(@"phiro_side_left", nil)
#define kUIFESensorPhiroSideRight NSLocalizedString(@"phiro_side_right", nil)
#define kUIFESensorPhiroBottomLeft NSLocalizedString(@"phiro_bottom_left", nil)
#define kUIFESensorPhiroBottomRight NSLocalizedString(@"phiro_bottom_right", nil)

#define kUIFESensorArduinoAnalog NSLocalizedString(@"arduino_analog", nil)

#define kUIFESensorArduinoDigital NSLocalizedString(@"arduino_digital", nil)

#define kLocalizedSensorCompass NSLocalizedString(@"compass", nil)
#define kLocalizedSensorAcceleration NSLocalizedString(@"acceleration-sensor", nil)
#define kLocalizedSensorRotation NSLocalizedString(@"gyro-sensor", nil)
#define kLocalizedSensorMagnetic NSLocalizedString(@"magnetic-sensor", nil)
#define kLocalizedVibration NSLocalizedString(@"vibration", nil)
#define kLocalizedSensorLoudness NSLocalizedString(@"loudness", nil)
#define kLocalizedSensorLED NSLocalizedString(@"LED", nil)
#define kLocalizedNotAvailable NSLocalizedString(@"not available. Continue anyway?", nil)

#define kUIFESensorFaceDetected NSLocalizedString(@"face_detected", nil)
#define kUIFESensorFaceSize NSLocalizedString(@"facesize", nil)
#define kUIFESensorFaceX NSLocalizedString(@"faceposition_x", nil)
#define kUIFESensorFaceY NSLocalizedString(@"faceposition_y", nil)

//************************************************************************************************************
//************************************       BrickCategoryTitles        ********************************************
//************************************************************************************************************
#define kUIFENewText NSLocalizedString(@"New Text", nil)
#define kUIFETextMessage NSLocalizedString(@"Text message:", nil)
#define kUIFavouritesTitle NSLocalizedString(@"Frequently Used", @"Title of View where the user can see the frequently used bricks.")
#define kUIScriptTitle NSLocalizedString(@"Script", nil);
#define kUIControlTitle NSLocalizedString(@"Control", nil);
#define kUIMotionTitle  NSLocalizedString(@"Motion", nil);
#define kUISoundTitle  NSLocalizedString(@"Sound", nil);
#define kUILookTitle  NSLocalizedString(@"Look", nil);
#define kUIVariableTitle  NSLocalizedString(@"Variable", nil);
#define kUIArduinoTitle  NSLocalizedString(@"Arduino", nil);
#define kUIPhiroTitle  NSLocalizedString(@"Phiro", nil);


//************************************************************************************************************
//************************************       PhiroDefines         ********************************************
//************************************************************************************************************


#define kLocalizedPhiroBoth  NSLocalizedString(@"Both", nil)
#define kLocalizedPhiroLeft  NSLocalizedString(@"Left", nil)
#define kLocalizedPhiroRight  NSLocalizedString(@"Right", nil)

#define kLocalizedPhiroDO  NSLocalizedString(@"DO", nil)
#define kLocalizedPhiroRE  NSLocalizedString(@"RE", nil)
#define kLocalizedPhiroMI  NSLocalizedString(@"MI", nil)
#define kLocalizedPhiroFA  NSLocalizedString(@"FA", nil)
#define kLocalizedPhiroSO  NSLocalizedString(@"SO", nil)
#define kLocalizedPhiroLA  NSLocalizedString(@"LA", nil)
#define kLocalizedPhiroTI  NSLocalizedString(@"TI", nil)


#define klocalizedBluetoothSearch NSLocalizedString(@"Search", @"bluetooth")
#define klocalizedBluetoothKnown NSLocalizedString(@"Known devices", @"bluetooth")
#define klocalizedBluetoothSelectPhiro NSLocalizedString(@"Select Phiro", @"bluetooth")
#define klocalizedBluetoothSelectArduino NSLocalizedString(@"Select Arduino", @"bluetooth")
#define klocalizedBluetoothConnectionNotPossible NSLocalizedString(@"Connection not possible", @"bluetooth")
#define klocalizedBluetoothConnectionTryResetting NSLocalizedString(@"Please try resetting the device and try again.", @"bluetooth")
#define klocalizedBluetoothConnectionFailed NSLocalizedString(@"Connection failed", @"bluetooth")
#define klocalizedBluetoothCannotConnect NSLocalizedString(@"Cannot connect to device, please try resetting the device and try again.", @"bluetooth")
#define klocalizedBluetoothNotResponding NSLocalizedString(@"Cannot connect to device. The device is not responding.", @"bluetooth")
#define klocalizedBluetoothConnectionLost NSLocalizedString(@"Connection Lost", @"bluetooth")
#define klocalizedBluetoothDisconnected NSLocalizedString(@"Device disconnected.", @"bluetooth")


//************************************************************************************************************
//************************************       MediaLibrary        *********************************************
//************************************************************************************************************
#define kLocalizedMediaLibrary NSLocalizedString(@"Media Library", nil)



//************************************************************************************************************
//****************************************       Debug        ************************************************
//************************************************************************************************************
#define kLocalizedDebugModeTitle NSLocalizedString(@"Debug mode", nil)
#define kLocalizedStartedInDebugMode NSLocalizedString(@"Pocket Code has been started in debug mode.", nil)



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
