/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

//************************************************************************************************************
//************************************       TERMS/BUZZWORDS      ********************************************
//************************************************************************************************************

#define kLocalizedSkip NSLocalizedString(@"Skip", nil)
#define kLocalizedWelcomeToPocketCode NSLocalizedString(@"Welcome to Pocket Code", nil)
#define kLocalizedExploreApps NSLocalizedString(@"Explore apps", nil)
#define kLocalizedUpcomingVersion NSLocalizedString(@"Upcoming version", nil)
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
#define kLocalizedMay NSLocalizedString(@"May", nil)
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
#define kLocalizedExplore NSLocalizedString(@"Explore", nil)
#define kLocalizedHelp NSLocalizedString(@"Help", nil)
#define kLocalizedDetails NSLocalizedString(@"Details", nil)
#define kLocalizedLooks NSLocalizedString(@"Looks", nil)
#define kLocalizedSounds NSLocalizedString(@"Sounds", nil)
#define kLocalizedChooseSound NSLocalizedString(@"Choose sound", nil)
#define kLocalizedPrograms NSLocalizedString(@"Programs", nil)
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
#define kLocalizedUpload NSLocalizedString(@"Upload", nil)
#define kLocalizedDeletionMenu NSLocalizedString(@"Deletion Mode", nil)
#define kLocalizedAboutPocketCode NSLocalizedString(@"About Pocket Code", nil)
#define kLocalizedTermsOfUse NSLocalizedString(@"Terms of Use", nil)
#define kLocalizedForgotPassword NSLocalizedString(@"Forgot password", nil)
#define kLocalizedRateUs NSLocalizedString(@"Rate Us", nil)
#define kLocalizedVersionLabel NSLocalizedString(@"v", nil)
#define kLocalizedBack NSLocalizedString(@"Back", nil)
#define kLocalizedSourceCodeLicenseButtonLabel NSLocalizedString(@"Pocket Code Source Code License", nil)
#define kLocalizedAboutCatrobatButtonLabel NSLocalizedString(@"About Catrobat", nil)
#define kLocalizedEdit NSLocalizedString(@"Edit", nil)
#define kLocalizedCancel NSLocalizedString(@"Cancel", nil)
#define kLocalizedSelectAllItems NSLocalizedString(@"Select All", nil)
#define kLocalizedUnselectAllItems NSLocalizedString(@"Unselect All", nil)
#define kLocalizedDelete NSLocalizedString(@"Delete", nil)
#define kLocalizedSaveToPocketCode NSLocalizedString(@"Save to PocketCode", nil)
#define kLocalizedEditSounds NSLocalizedString(@"Edit Sounds",@"Action sheet menu title")
#define kLocalizedEditSound NSLocalizedString(@"Edit Sound",@"Action sheet menu title")
#define kLocalizedEditLooks NSLocalizedString(@"Edit Looks", @"Action sheet menu title")
#define kLocalizedEditLook NSLocalizedString(@"Edit Look", @"Action sheet menu title")
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
#define kLocalizedDeleteCondition NSLocalizedString(@"Delete Condition", nil)
#define kLocalizedDeleteLoop NSLocalizedString(@"Delete Loop", nil)
#define kLocalizedDeleteScript NSLocalizedString(@"Delete Script", nil)
#define kLocalizedAnimateBrick NSLocalizedString(@"Animate Brick", nil)
#define kLocalizedCopyBrick NSLocalizedString(@"Copy Brick", nil)
#define kLocalizedEditFormula NSLocalizedString(@"Edit Formula", nil)
#define kLocalizedMoveBrick NSLocalizedString(@"Move Brick", nil)
#define kLocalizedDeleteSounds NSLocalizedString(@"Delete Sounds", nil)
#define kLocalizedHideDetails NSLocalizedString(@"Hide Details", nil)
#define kLocalizedShowDetails NSLocalizedString(@"Show Details", nil)
#define kLocalizedDeleteLooks NSLocalizedString(@"Delete Looks",nil)
#define kLocalizedFromCamera NSLocalizedString(@"From Camera", nil)
#define kLocalizedChooseImage NSLocalizedString(@"Choose image", nil)
#define kLocalizedDrawNewImage NSLocalizedString(@"Draw new image", nil)
#define kLocalizedRename NSLocalizedString(@"Rename", nil)
#define kLocalizedRenameProgram NSLocalizedString(@"Rename Program", nil)
#define kLocalizedCopy NSLocalizedString(@"Copy", nil)
#define kLocalizedDescription NSLocalizedString(@"Description", nil)
#define kLocalizedUpload NSLocalizedString(@"Upload", nil)
#define kLocalizedDeleteObjects NSLocalizedString(@"Delete Objects", nil)
#define kLocalizedDeletePrograms NSLocalizedString(@"Delete Programs", nil)
#define kLocalizedPocketCodeRecorder NSLocalizedString(@"Pocket Code Recorder", nil)
#define kLocalizedChooseSound NSLocalizedString(@"Choose sound", nil)
#define kLocalizedCameraRoll NSLocalizedString(@"Camera Roll", nil)
#define kLocalizedProject NSLocalizedString(@"Project", nil)
#define kLocalizedDelete NSLocalizedString(@"Delete", nil)
#define kLocalizedControl NSLocalizedString(@"Control", nil)
#define kLocalizedMotion NSLocalizedString(@"Motion", nil)
#define kLocalizedSound NSLocalizedString(@"Sound", nil)
#define kLocalizedLooks NSLocalizedString(@"Looks", nil)
#define kLocalizedVariables NSLocalizedString(@"Variables", nil)
#define kLocalizedPlay NSLocalizedString(@"Play", nil)
#define kLocalizedDownload NSLocalizedString(@"Download", nil)
#define kLocalizedMore NSLocalizedString(@"More", nil)
#define kLocalizedDelete NSLocalizedString(@"Delete", nil)
#define kLocalizedAddObject NSLocalizedString(@"Add object", nil)
#define kLocalizedAddImage NSLocalizedString(@"Add image", nil)
#define kLocalizedRenameObject NSLocalizedString(@"Rename object", nil)
#define kLocalizedRenameImage NSLocalizedString(@"Rename image", nil)
#define kLocalizedRenameSound NSLocalizedString(@"Rename sound", nil)
#define kLocalizedDeleteThisProgram NSLocalizedString(@"Delete this program", nil)
#define kLocalizedDeleteThisObject NSLocalizedString(@"Delete this object", nil)
#define kLocalizedDeleteThisProgram NSLocalizedString(@"Delete this program", nil)
#define kLocalizedDeleteThisLook NSLocalizedString(@"Delete this look", nil)
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
#define kLocalizedScripts NSLocalizedString(@"Scripts", nil)
#define kLocalizedBricks NSLocalizedString(@"Bricks", nil)
#define kLocalizedLooks NSLocalizedString(@"Looks", nil)
#define kLocalizedSounds NSLocalizedString(@"Sounds", nil)
#define kLocalizedLastAccess NSLocalizedString(@"Last access", nil)
#define kLocalizedSize NSLocalizedString(@"Size", nil)
#define kLocalizedLength NSLocalizedString(@"Length", nil)
#define kLocalizedBack NSLocalizedString(@"Back", nil)
#define kLocalizedRestart NSLocalizedString(@"Restart", nil)
#define kLocalizedContinue NSLocalizedString(@"Continue", nil)
#define kLocalizedScreenshot NSLocalizedString(@"Screenshot", nil)
#define kLocalizedAxes NSLocalizedString(@"Axes", @"Title of icon shown in the side bar to enable or disable an overlayed view to show the origin of the coordinate system and implicitly the display size.")
#define kLocalizedMostDownloaded NSLocalizedString(@"Most Downloaded", nil)
#define kLocalizedMostViewed NSLocalizedString(@"Most Viewed", nil)
#define kLocalizedNewest NSLocalizedString(@"Newest", nil)
#define kLocalizedControl NSLocalizedString(@"Control", nil)
#define kLocalizedMotion NSLocalizedString(@"Motion", nil)
#define kLocalizedSound NSLocalizedString(@"Sound", nil)
#define kLocalizedLooks NSLocalizedString(@"Looks", nil)
#define kLocalizedVariables NSLocalizedString(@"Variables", nil)
#define kLocalizedRecording NSLocalizedString(@"Recording", nil)
#define kLocalizedError NSLocalizedString(@"Error", nil)
#define kLocalizedMemoryWarning NSLocalizedString(@"Not enough Memory", nil)
#define kLocalizedReportProgram NSLocalizedString(@"Report as inappropriate", nil)
#define kLocalizedRecording NSLocalizedString(@"Recording", nil)
#define kLocalizedName NSLocalizedString(@"Name", nil)
#define kLocalizedDownloaded NSLocalizedString(@"Download sucessful", nil)

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
#define kLocalizedNoInternetConnectionAvailable NSLocalizedString(@"No internet connection available.", nil)
#define kLocalizedSlowInternetConnection NSLocalizedString(@"Slow Internet Connection!",nil)
#define kLocalizedInvalidURLGiven NSLocalizedString(@"Invalid URL given!",nil)
#define kLocalizedNoCamera NSLocalizedString(@"No Camera available",nil)

//************************************************************************************************************
//**********************************       LONG DESCRIPTIONS      ********************************************
//************************************************************************************************************

#define kLocalizedWelcomeDescription NSLocalizedString(@"Pocket Code let's you play great games and run other fantastic apps like for instance presentations, quizzes and so on.", nil)
#define kLocalizedExploreDescription NSLocalizedString(@"By switching to the section \"Explore\" you can discover much more interesting stuff.", nil)
#define kLocalizedUpcomingVersionDescription NSLocalizedString(@"You are also able to build your own apps, edit existing ones and share them with your friends and other exciting people.", nil)
#define kLocalizedAboutPocketCodeDescription NSLocalizedString(@"Pocket Code is a programming environment for iOS for the visual programming language Catrobat. The code of Pocket Code is mostly under GNU AGPL v3 licence. For further information to the licence please visit following links:", nil)
#define kLocalizedTermsOfUseDescription NSLocalizedString(@"In order to be allowed to use Pocket Code and other executables offered by the Catrobat project, you must agree to our Terms of Use and strictly follow them when you use Pocket Code and our other executables. Please see the link below for their precise formulation.", nil)
#define kLocalizedNotEnoughFreeMemoryDescription NSLocalizedString(@"Not enough free memory to download this program. Please delete some of your programs", nil)
#define kLocalizedEnterYourProgramNameHere NSLocalizedString(@"Enter your program name here...", @"Placeholder for program-name input field")
#define kLocalizedEnterYourProgramDescriptionHere NSLocalizedString(@"Enter your program description here...", @"Placeholder for program-description input field")
#define kLocalizedEnterYourMessageHere NSLocalizedString(@"Enter your message here...", @"Placeholder for message input field")
#define kLocalizedEnterYourVariableNameHere NSLocalizedString(@"Enter your variable name here...", @"Placeholder for variable input field")
#define kLocalizedEnterYourObjectNameHere NSLocalizedString(@"Enter your object name here...", @"Placeholder for add object-name input field")
#define kLocalizedEnterYourImageNameHere NSLocalizedString(@"Enter your image name here...", @"Placeholder for add image-name input field")
#define kLocalizedEnterYourSoundNameHere NSLocalizedString(@"Enter your sound name here...", @"Placeholder for add sound-name input field")
#define kLocalizedNoImportedSoundsFoundTitle NSLocalizedString(@"No imported sounds found", @"Title of AlertView if the user tries to import a sound but no sound has been imported using iTunes.")
#define kLocalizedNoImportedSoundsFoundDescription NSLocalizedString(@"Please connect your iPhone to your PC/Mac and use iTunes FileSharing to import sound files into the PocketCode app.", @"Description of AlertView if the user tries to import a sound but no sound has been imported using iTunes.")
#define kLocalizedNoOrTooShortInputDescription NSLocalizedString(@"No input or the input is too short. Please enter at least %lu character(s).", nil)
#define kLocalizedSpaceInputDescription NSLocalizedString(@"Only space is not allowed. Please enter at least %lu other character(s).", nil)
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


//************************************************************************************************************
//*******************************       BRICK TITLE TRANSLATIONS      ****************************************
//************************************************************************************************************

//#if DEBUG == 0 // DEBUG <= TODO: remove this line later
//------------------------------------------------------------------------------------------------------------
// TODO: in our first release we do not use translated strings in the script-editor because the translated
//       strings can vary in their length compared to the english version. This would lead to graphical issues
//       since the BrickCells are not able to handle the word wrapping of their titles correctly at this
//       stage.

// control bricks
#define kLocalizedWhenProgramStarted @"When program started"
#define kLocalizedWhenTapped @"When tapped"
#define kLocalizedWaitNSeconds @"Wait %@ second(s)"
#define kLocalizedVibrateNSeconds @"Vibrate %@ second(s)"
#define kLocalizedWhenIReceive @"When I receive\n%@"
#define kLocalizedBroadcast @"Broadcast\n%@"
#define kLocalizedBroadcastAndWait @"Broadcast and wait\n%@"
#define kLocalizedNote @"Note %@"
#define kLocalizedForever @"Forever"
#define kLocalizedIfIsTrueThen @"If %@ is true then"
#define kLocalizedElse @"Else"
#define kLocalizedEndIf @"End If"
#define kLocalizedRepeatNTimes @"Repeat %@ times"
#define kLocalizedEndOfLoop @"End of Loop"

// motion bricks
#define kLocalizedPlaceAt @"Place at\nX: %@ Y: %@"
#define kLocalizedSetX @"Set X to %@"
#define kLocalizedSetY @"Set Y to %@"
#define kLocalizedChangeX @"Change X by %@"
#define kLocalizedChangeY @"Change Y by %@"
#define kLocalizedIfIsTrueThenOnEdgeBounce @"If on edge, bounce"
#define kLocalizedMoveNSteps @"Move %@ step(s)"
#define kLocalizedTurnLeft @"Turn left %@°"
#define kLocalizedTurnRight @"Turn right %@°"
#define kLocalizedPointInDirection @"Point in direction %@°"
#define kLocalizedPointTowards @"Point towards\n%@"
#define kLocalizedGlideTo @"Glide %@ second(s)\nto X: %@ Y: %@"
#define kLocalizedGoNStepsBack @"Go back %@ layer(s)"
#define kLocalizedComeToFront @"Go to front"

// look bricks
#define kLocalizedSetLook @"Switch to look\n%@"
#define kLocalizedSetBackground @"Set background\n%@"
#define kLocalizedNextLook @"Next look"
#define kLocalizedNextBackground @"Next background"
#define kLocalizedSetSizeTo @"Set size to %@\%"
#define kLocalizedChangeSizeByN @"Change size by %@\%"
#define kLocalizedHide @"Hide"
#define kLocalizedShow @"Show"
#define kLocalizedLedOn @"Flashlight on"
#define kLocalizedLedOff @"Flashlight off"
#define kLocalizedSetGhostEffect @"Set transparency\nto %@\%"
#define kLocalizedChangeGhostEffectByN @"Change transparency\nby %@\%"
#define kLocalizedSetBrightness @"Set brightness to %@\%"
#define kLocalizedChangeBrightnessByN @"Change brightness\nby %@\%"
#define kLocalizedClearGraphicEffect @"Clear graphic effects"

// sound bricks
#define kLocalizedPlaySound @"Start sound\n%@"
#define kLocalizedStopAllSounds @"Stop all sounds"
#define kLocalizedSetVolumeTo @"Set volume to %@\%"
#define kLocalizedChangeVolumeByN @"Change volume by %@"
#define kLocalizedSpeak @"Speak %@"

// variable bricks
#define kLocalizedSetVariable @"Set variable\n%@\nto %@"
#define kLocalizedChangeVariable @"Change variable\n%@\nby %@"

//#else // DEBUG == 0
//
//// control bricks
//#define kLocalizedWhenProgramStarted NSLocalizedString(@"When program started", nil)
//#define kLocalizedWhenTapped NSLocalizedString(@"When tapped", nil)
//#define kLocalizedWaitNSeconds NSLocalizedString(@"Wait %@ second(s)", nil)
//#define kLocalizedVibrateNSeconds NSLocalizedString(@"Vibrate %@ second(s)", nil)
//#define kLocalizedWhenIReceive NSLocalizedString(@"When I receive\n%@", nil)
//#define kLocalizedBroadcast NSLocalizedString(@"Broadcast\n%@", nil)
//#define kLocalizedBroadcastAndWait NSLocalizedString(@"Broadcast and wait\n%@", nil)
//#define kLocalizedNote NSLocalizedString(@"Note %@", nil)
//#define kLocalizedForever NSLocalizedString(@"Forever", nil)
//#define kLocalizedIfIsTrueThen NSLocalizedString(@"If %@ is true then", nil)
//#define kLocalizedElse NSLocalizedString(@"Else", nil)
//#define kLocalizedEndIf NSLocalizedString(@"End If", nil)
//#define kLocalizedRepeatNTimes NSLocalizedString(@"Repeat %@ times", nil)
//#define kLocalizedEndOfLoop NSLocalizedString(@"End of Loop", nil)
//
//// motion bricks
//#define kLocalizedPlaceAt NSLocalizedString(@"Place at\nX: %@ Y: %@", nil)
//#define kLocalizedSetX NSLocalizedString(@"Set X to %@", nil)
//#define kLocalizedSetY NSLocalizedString(@"Set Y to %@", nil)
//#define kLocalizedChangeX NSLocalizedString(@"Change X by %@", nil)
//#define kLocalizedChangeY NSLocalizedString(@"Change Y by %@", nil)
//#define kLocalizedIfIsTrueThenOnEdgeBounce NSLocalizedString(@"If on edge, bounce", nil)
//#define kLocalizedMoveNSteps NSLocalizedString(@"Move %@ step(s)", nil)
//#define kLocalizedTurnLeft NSLocalizedString(@"Turn left %@°", nil)
//#define kLocalizedTurnRight NSLocalizedString(@"Turn right %@°", nil)
//#define kLocalizedPointInDirection NSLocalizedString(@"Point in direction %@°", nil)
//#define kLocalizedPointTowards NSLocalizedString(@"Point towards\n%@", nil)
//#define kLocalizedGlideTo NSLocalizedString(@"Glide %@ second(s)\nto X: %@ Y: %@", nil)
//#define kLocalizedGoNStepsBack NSLocalizedString(@"Go back %@ layer(s)", nil)
//#define kLocalizedComeToFront NSLocalizedString(@"Go to front", nil)
//
//// look bricks
//#define kLocalizedSetLook NSLocalizedString(@"Switch to look\n%@", nil)
//#define kLocalizedSetBackground NSLocalizedString(@"Set background\n%@", nil)
//#define kLocalizedNextLook NSLocalizedString(@"Next look", nil)
//#define kLocalizedNextBackground NSLocalizedString(@"Next background", nil)
//#define kLocalizedSetSizeTo NSLocalizedString(@"Set size to %@\%", nil)
//#define kLocalizedChangeSizeByN NSLocalizedString(@"Change size by %@\%", nil)
//#define kLocalizedHide NSLocalizedString(@"Hide", nil)
//#define kLocalizedShow NSLocalizedString(@"Show", nil)
//#define kLocalizedLedOn NSLocalizedString(@"Flashlight on", nil)
//#define kLocalizedLedOff NSLocalizedString(@"Flashlight off", nil)
//#define kLocalizedSetGhostEffect NSLocalizedString(@"Set transparency\nto %@\%", nil)
//#define kLocalizedChangeGhostEffectByN NSLocalizedString(@"Change transparency\nby %@\%", nil)
//#define kLocalizedSetBrightness NSLocalizedString(@"Set brightness to %@\%", nil)
//#define kLocalizedChangeBrightnessByN NSLocalizedString(@"Change brightness\nby %@\%", nil)
//#define kLocalizedClearGraphicEffect NSLocalizedString(@"Clear graphic effects", nil)
//
//// sound bricks
//#define kLocalizedPlaySound NSLocalizedString(@"Start sound\n%@", nil)
//#define kLocalizedStopAllSounds NSLocalizedString(@"Stop all sounds", nil)
//#define kLocalizedSetVolumeTo NSLocalizedString(@"Set volume to %@\%", nil)
//#define kLocalizedChangeVolumeByN NSLocalizedString(@"Change volume by %@", nil)
//#define kLocalizedSpeak NSLocalizedString(@"Speak %@", nil)
//
//// variable bricks
//#define kLocalizedSetVariable NSLocalizedString(@"Set variable\n%@\nto %@", nil)
//#define kLocalizedChangeVariable NSLocalizedString(@"Change variable\n%@\nby %@", nil)
//
//#endif // DEBUG == 0

#define kLocalizedAddCommentHere NSLocalizedString(@"add comment here...", nil)
#define kLocalizedMessage1 NSLocalizedString(@"message 1", nil)
#define kLocalizedHello NSLocalizedString(@"Hello !", nil)

//************************************************************************************************************
//**********************************       Login/Upload            *******************************************
//************************************************************************************************************

#define kLocalizedLogin NSLocalizedString(@"Login", nil)
#define kLocalizedUsername NSLocalizedString(@"Username", nil)
#define kLocalizedPassword NSLocalizedString(@"Password", nil)
#define kLocalizedEmail NSLocalizedString(@"Email", nil)
#define kLocalizedRegister NSLocalizedString(@"Register", nil)
#define kLocalizedLoginOrRegister NSLocalizedString(@"Login/Register", nil)
#define kLocalizedUploadProgram NSLocalizedString(@"Upload Program", nil)
#define kLocalizedLoginUsernameNecessary NSLocalizedString(@"Username is necessary!", nil)
#define kLocalizedLoginEmailNotValid NSLocalizedString(@"Email is not valid!", nil)
#define kLocalizedLoginPasswordNotValid NSLocalizedString(@"Password is not vaild! \n It has to contain at least 6 characters/symbols", nil)
#define kLocalizedUploadProgramNecessary NSLocalizedString(@"Program Name is necessary!", nil)
#define kLocalizedForgotPassword NSLocalizedString(@"Forgot password", nil)
#define kLocalizedTermsAgreementPart NSLocalizedString(@"By registering you agree to our", nil)
#define kLocalizedUploadSuccessfull NSLocalizedString(@"Upload successfull", nil)
#define kLocalizedRegistrationSuccessfull NSLocalizedString(@"Registration successfull", nil)
#define kUploadSelectedProgram NSLocalizedString(@"Upload Selected Program", nil)
#define kLocalizedUploadProblem NSLocalizedString (@"Problems occured while Uploading your program", nil)
#define kLocalizedUploadSelectProgram NSLocalizedString (@"Please select a program to upload", nil)

//************************************************************************************************************
//************************************       PAINT                ********************************************
//************************************************************************************************************

#define kLocalizedPaintWidth NSLocalizedString(@"Width", @"paint")
#define kLocalizedPaintRed NSLocalizedString(@"Red", @"paint")
#define kLocalizedPaintGreen NSLocalizedString(@"Green", @"paint")
#define kLocalizedPaintBlue NSLocalizedString(@"Blue", @"paint")
#define kLocalizedPaintAlpha NSLocalizedString(@"Alpha", @"paint")
#define kLocalizedPaintBrush NSLocalizedString(@"brush", @"paint")
#define kLocalizedPaintEraser NSLocalizedString(@"eraser", @"paint")
#define kLocalizedPaintCrop NSLocalizedString(@"crop", @"paint")
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
#define kLocalizedPaintSaveChanges NSLocalizedString(@"Do you want to save the changes", @"paint")
#define kLocalizedPaintMenuButtonTitle NSLocalizedString(@"Menu", @"paint")
#define kLocalizedPaintSelect NSLocalizedString(@"Select option:", @"paint")
#define kLocalizedPaintSave NSLocalizedString(@"Save to CameraRoll", @"paint")
#define kLocalizedPaintSaveClose NSLocalizedString(@"Save & Close Paint", @"paint")
#define kLocalizedPaintDiscardClose NSLocalizedString(@"Discard & Close", @"paint")
#define kLocalizedPaintNewCanvas NSLocalizedString(@"New Canvas", @"paint")
#define kLocalizedPaintPickItem NSLocalizedString(@"Please pick an item", @"paint")
#define kLocalizedPaintSaveChanges NSLocalizedString(@"Do you want to save the changes", @"paint")
#define kLocalizedPaintNoCrop NSLocalizedString(@"Nothing to crop!", @"paint")
#define kLocalizedPaintAskNewCanvas NSLocalizedString(@"Do you really want to delete the current drawing?", @"paint")
#define kLocalizedPaintRound NSLocalizedString(@"round", @"paint")
#define kLocalizedPaintSquare NSLocalizedString(@"square", @"paint")
#define kLocalizedPaintPocketPaint NSLocalizedString(@"Pocket Paint", @"paint")
#define kLocalizedPaintStamped NSLocalizedString(@"Stamped", @"paint")
#define kLocalizedPaintInserted NSLocalizedString(@"Inserted", @"paint")

//************************************************************************************************************
//************************************       FormulaEditor        ********************************************
//************************************************************************************************************

#define kUIActionSheetTitleSelectLogicalOperator NSLocalizedString(@"Select logical operator", nil)
#define kUIActionSheetTitleSelectMathematicalFunction NSLocalizedString(@"Select mathematical function", nil)
#define kUIFENumbers NSLocalizedString(@"Numbers", nil)
#define kUIFELogic NSLocalizedString(@"Logic", nil)
#define kUIFEVar NSLocalizedString(@"New", nil)
#define kUIFETake NSLocalizedString(@"Take", nil)
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



//************************************************************************************************************
//************************************       BrickCategoryTitles        ********************************************
//************************************************************************************************************
#define kUIFENewText NSLocalizedString(@"New Text", nil)
#define kUIFETextMessage NSLocalizedString(@"Text message:", nil)
#define kUIScriptTitle NSLocalizedStringFromTable(@"Script", @"BrickCategoryViewController", nil);
#define kUIControlTitle NSLocalizedStringFromTable(@"Control", @"BrickCategoryViewController", nil);
#define kUIMotionTitle  NSLocalizedStringFromTable(@"Motion", @"BrickCategoryViewController", nil);
#define kUISoundTitle  NSLocalizedStringFromTable(@"Sound", @"BrickCategoryViewController", nil);
#define kUILookTitle  NSLocalizedStringFromTable(@"Look", @"BrickCategoryViewController", nil);
#define kUIVariableTitle  NSLocalizedStringFromTable(@"Variable", @"BrickCategoryViewController", nil);


#if DEBUG == 1
//************************************************************************************************************
//****************************************       Debug        ************************************************
//************************************************************************************************************
#define kLocalizedDebugModeTitle NSLocalizedString(@"Debug mode", nil)
#define kLocalizedStartedInDebugMode NSLocalizedString(@"Pocket Code has been started in debug mode.", nil)
#endif
