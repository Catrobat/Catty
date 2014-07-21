/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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
 * -----------------------------------------------------------------------------------------------------------
 * General defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kGeneralNewDefaultProgramName NSLocalizedString(@"New Program", @"Default name for new programs")
#define kGeneralBackgroundObjectName NSLocalizedString(@"Background", @"Title for background object")
#define kGeneralDefaultObjectName NSLocalizedString(@"My Object", @"Title for first (default) object")
#define kDefaultImportedImageName NSLocalizedString(@"My Image", @"Default title of imported photo from camera (taken by camera)")

/*
 * -----------------------------------------------------------------------------------------------------------
 * NSDate title defines
 * -----------------------------------------------------------------------------------------------------------
 */

// today, yesterday names
#define kNSDateTitleNameToday NSLocalizedString(@"Today", nil)
#define kNSDateTitleNameYesterday NSLocalizedString(@"Yesterday", nil)

// weekday names
#define kNSDateTitleWeekdayNameSunday NSLocalizedString(@"Sunday", nil)
#define kNSDateTitleWeekdayNameMonday NSLocalizedString(@"Monday", nil)
#define kNSDateTitleWeekdayNameTuesday NSLocalizedString(@"Tuesday", nil)
#define kNSDateTitleWeekdayNameWednesday NSLocalizedString(@"Wednesday", nil)
#define kNSDateTitleWeekdayNameThursday NSLocalizedString(@"Thursday", nil)
#define kNSDateTitleWeekdayNameFriday NSLocalizedString(@"Friday", nil)
#define kNSDateTitleWeekdayNameSaturday NSLocalizedString(@"Saturday", nil)

// weekday names short
#define kNSDateTitleWeekdayShortNameSunday NSLocalizedString(@"Su", nil)
#define kNSDateTitleWeekdayShortNameMonday NSLocalizedString(@"Mo", nil)
#define kNSDateTitleWeekdayShortNameTuesday NSLocalizedString(@"Tu", nil)
#define kNSDateTitleWeekdayShortNameWednesday NSLocalizedString(@"We", nil)
#define kNSDateTitleWeekdayShortNameThursday NSLocalizedString(@"Th", nil)
#define kNSDateTitleWeekdayShortNameFriday NSLocalizedString(@"Fr", nil)
#define kNSDateTitleWeekdayShortNameSaturday NSLocalizedString(@"Sa", nil)

// month names
#define kNSDateTitleMonthNameJanuary NSLocalizedString(@"January", nil)
#define kNSDateTitleMonthNameFebruary NSLocalizedString(@"February", nil)
#define kNSDateTitleMonthNameMarch NSLocalizedString(@"March", nil)
#define kNSDateTitleMonthNameApril NSLocalizedString(@"April", nil)
#define kNSDateTitleMonthNameMay NSLocalizedString(@"May", nil)
#define kNSDateTitleMonthNameJune NSLocalizedString(@"June", nil)
#define kNSDateTitleMonthNameJuly NSLocalizedString(@"July", nil)
#define kNSDateTitleMonthNameAugust NSLocalizedString(@"August", nil)
#define kNSDateTitleMonthNameSeptember NSLocalizedString(@"September", nil)
#define kNSDateTitleMonthNameOctober NSLocalizedString(@"October", nil)
#define kNSDateTitleMonthNameNovember NSLocalizedString(@"November", nil)
#define kNSDateTitleMonthNameDecember NSLocalizedString(@"December", nil)

// month short names
#define kNSDateTitleMonthShortNameJanuary NSLocalizedString(@"Jan", nil)
#define kNSDateTitleMonthShortNameFebruary NSLocalizedString(@"Feb", nil)
#define kNSDateTitleMonthShortNameMarch NSLocalizedString(@"Mar", nil)
#define kNSDateTitleMonthShortNameApril NSLocalizedString(@"Apr", nil)
#define kNSDateTitleMonthShortNameMay NSLocalizedString(@"May", nil)
#define kNSDateTitleMonthShortNameJune NSLocalizedString(@"Jun", nil)
#define kNSDateTitleMonthShortNameJuly NSLocalizedString(@"Jul", nil)
#define kNSDateTitleMonthShortNameAugust NSLocalizedString(@"Aug", nil)
#define kNSDateTitleMonthShortNameSeptember NSLocalizedString(@"Sep", nil)
#define kNSDateTitleMonthShortNameOctober NSLocalizedString(@"Oct", nil)
#define kNSDateTitleMonthShortNameNovember NSLocalizedString(@"Nov", nil)
#define kNSDateTitleMonthShortNameDecember NSLocalizedString(@"Dec", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIViewController title defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUIViewControllerTitlePocketCode NSLocalizedString(@"Pocket Code", nil)
#define kUIViewControllerTitleCategories NSLocalizedString(@"Categories", nil)
#define kUIViewControllerTitleExplore NSLocalizedString(@"Explore", nil)
#define kUIViewControllerTitleHelp NSLocalizedString(@"Help", nil)
#define kUIViewControllerTitleInfo NSLocalizedString(@"Info", nil)
#define kUIViewControllerTitleLooks NSLocalizedString(@"Looks", nil)
#define kUIViewControllerTitleSounds NSLocalizedString(@"Sounds", nil)
#define kUIViewControllerTitleChooseSound NSLocalizedString(@"Choose sound", nil)
#define kUIViewControllerTitlePrograms NSLocalizedString(@"Programs", nil)
#define kUIViewControllerTitleFeaturedPrograms NSLocalizedString(@"Featured Programs", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIViewController placeholder defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUIViewControllerPlaceholderTitleScripts NSLocalizedString(@"Scripts", nil)
#define kUIViewControllerPlaceholderTitleBackgrounds NSLocalizedString(@"Backgrounds", nil)
#define kUIViewControllerPlaceholderTitleLooks kUIViewControllerTitleLooks
#define kUIViewControllerPlaceholderTitleSounds kUIViewControllerTitleSounds

#define kUIViewControllerPlaceholderDescriptionStandard NSLocalizedString(@"Tap \"+\" to add %@", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIViewController menu title and NavigationBar defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUITableViewControllerMenuTitleContinue NSLocalizedString(@"Continue", nil)
#define kUITableViewControllerMenuTitleNew NSLocalizedString(@"New", nil)
#define kUITableViewControllerMenuTitlePrograms NSLocalizedString(@"Programs", nil)
#define kUITableViewControllerMenuTitleHelp NSLocalizedString(@"Help", nil)
#define kUITableViewControllerMenuTitleExplore NSLocalizedString(@"Explore", nil)
#define kUITableViewControllerMenuTitleUpload NSLocalizedString(@"Upload", nil)

#define kUITableViewControllerMenuTitleScripts kUIViewControllerPlaceholderTitleScripts
#define kUITableViewControllerMenuTitleBackgrounds kUIViewControllerPlaceholderTitleBackgrounds
#define kUITableViewControllerMenuTitleLooks kUIViewControllerPlaceholderTitleLooks
#define kUITableViewControllerMenuTitleSounds kUIViewControllerPlaceholderTitleSounds

#define kUINavigationItemTitleEditMenu NSLocalizedString(@"Edit Mode", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIBarButtonItem title defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUIBarButtonItemTitleEdit NSLocalizedString(@"Edit", nil)
#define kUIBarButtonItemTitleCancel NSLocalizedString(@"Cancel", nil)
#define kUIBarButtonItemTitleSelectAllItems NSLocalizedString(@"Select All", nil)
#define kUIBarButtonItemTitleUnselectAllItems NSLocalizedString(@"Unselect All", nil)
#define kUIBarButtonItemTitleDelete NSLocalizedString(@"Delete", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIActivity title defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUIActivityTitleSaveToProject NSLocalizedString(@"Save to PocketCode", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIActionSheet title defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUIActionSheetTitleEditSounds NSLocalizedString(@"Edit Sounds",@"Action sheet menu title")
#define kUIActionSheetTitleEditLooks NSLocalizedString(@"Edit Looks", @"Action sheet menu title")
#define kUIActionSheetTitleAddLook NSLocalizedString(@"Add look", @"Action sheet menu title")
#define kUIActionSheetTitleEditProgramSingular NSLocalizedString(@"Edit Program", nil)
#define kUIActionSheetTitleEditProgramPlural NSLocalizedString(@"Edit Programs", nil)
#define kUIActionSheetTitleAddSound NSLocalizedString(@"Add sound", @"Action sheet menu title")
#define kUIActionSheetTitleSaveScreenshot NSLocalizedString(@"Save Screenshot to", @"Action sheet menu title")
#define kUIActionSheetTitleSelectBrickCategory NSLocalizedString(@"Select Brick Category", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIActionSheetButton title defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUIActionSheetButtonTitleClose NSLocalizedString(@"Close", nil)
#define kUIActionSheetButtonTitleDeleteBrick NSLocalizedString(@"Delete Brick", nil)
#define kUIActionSheetButtonTitleDeleteScript NSLocalizedString(@"Delete Script", nil)
#define kUIActionSheetButtonTitleAnimateBricks NSLocalizedString(@"Animate Brick", nil)
#define kUIActionSheetButtonTitleCopyBrick NSLocalizedString(@"Copy Brick", nil)
#define kUIActionSheetButtonTitleEditFormula NSLocalizedString(@"Edit Formula", nil)

#define kUIActionSheetButtonTitleDeleteSounds NSLocalizedString(@"Delete Sounds", nil)
#define kUIActionSheetButtonTitleHideDetails NSLocalizedString(@"Hide Details", nil)
#define kUIActionSheetButtonTitleShowDetails NSLocalizedString(@"Show Details", nil)

#define kUIActionSheetButtonTitleShowDetails NSLocalizedString(@"Show Details", nil)
#define kUIActionSheetButtonTitleDeleteLooks NSLocalizedString(@"Delete Looks",nil)
#define kUIActionSheetButtonTitleFromCamera NSLocalizedString(@"From Camera", nil)
#define kUIActionSheetButtonTitleChooseImage NSLocalizedString(@"Choose image", nil)
#define kUIActionSheetButtonTitleDrawNewImage NSLocalizedString(@"Draw new image", nil)

#define kUIActionSheetButtonTitleRename NSLocalizedString(@"Rename", nil)
#define kUIActionSheetButtonTitleCopy NSLocalizedString(@"Copy", nil)
#define kUIActionSheetButtonTitleDescription NSLocalizedString(@"Description", nil)
#define kUIActionSheetButtonTitleUpload NSLocalizedString(@"Upload", nil)
#define kUIActionSheetButtonTitleDeleteObjects NSLocalizedString(@"Delete Objects", nil)
#define kUIActionSheetButtonTitleDeletePrograms NSLocalizedString(@"Delete Programs", nil)
#define kUIActionSheetButtonTitlePocketCodeRecorder NSLocalizedString(@"Pocket Code Recorder", nil)
#define kUIActionSheetButtonTitleChooseSound NSLocalizedString(@"Choose sound", nil)

#define kUIActionSheetButtonTitleCameraRoll NSLocalizedString(@"Camera Roll", nil)
#define kUIActionSheetButtonTitleProject NSLocalizedString(@"Project", nil)
#define kUIActionSheetButtonTitleCancel NSLocalizedString(@"Cancel", nil)
#define kUIActionSheetButtonTitleDelete NSLocalizedString(@"Delete", nil)

#define kUIActionSheetButtonTitleControl NSLocalizedString(@"Control", nil)
#define kUIActionSheetButtonTitleMotion NSLocalizedString(@"Motion", nil)
#define kUIActionSheetButtonTitleSound NSLocalizedString(@"Sound", nil)
#define kUIActionSheetButtonTitleLooks NSLocalizedString(@"Looks", nil)
#define kUIActionSheetButtonTitleVariables NSLocalizedString(@"Variables", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIButton title defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUIButtonTitlePlay NSLocalizedString(@"Play", nil)
#define kUIButtonTitleDownload NSLocalizedString(@"Download", nil)
#define kUIButtonTitleCancel kUIBarButtonItemTitleCancel
#define kUIButtonTitleMore NSLocalizedString(@"More", nil)
#define kUIButtonTitleDelete NSLocalizedString(@"Delete", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIAlertView title, placeholder, text, button defines
 * -----------------------------------------------------------------------------------------------------------
 */

// title defines
#define kUIAlertViewTitleStandard NSLocalizedString(@"Pocket Code", nil)
#define kUIAlertViewTitleAddObject NSLocalizedString(@"Add object", nil)
#define kUIAlertViewTitleAddImage NSLocalizedString(@"Add image", nil)
#define kUIAlertViewTitleRenameProgram NSLocalizedString(@"Rename program", nil)
#define kUIAlertViewTitleCantRestartProgram NSLocalizedString(@"Can't restart program!", nil)
#define kUIAlertViewTitleScreenshotSavedToCameraRoll NSLocalizedString(@"Screenshot saved to Camera Roll", nil)
#define kUIAlertViewTitleScreenshotSavedToProject NSLocalizedString(@"Screenshot saved to project", nil)
#define kUIAlertViewTitleNewProgram NSLocalizedString(@"New program", nil)
#define kUIAlertViewTitleDeleteProgram NSLocalizedString(@"Delete this program", nil)
#define kUIAlertViewTitleDeleteMultipleObjects NSLocalizedString(@"Delete these objects", nil)
#define kUIAlertViewTitleDeleteSingleObject NSLocalizedString(@"Delete this object", nil)
#define kUIAlertViewTitleDeleteMultiplePrograms NSLocalizedString(@"Delete these programs", nil)
#define kUIAlertViewTitleDeleteSingleProgram NSLocalizedString(@"Delete this program", nil)
#define kUIAlertViewTitleDeleteMultipleLooks NSLocalizedString(@"Delete these looks", nil)
#define kUIAlertViewTitleDeleteSingleLook NSLocalizedString(@"Delete this look", nil)
#define kUIAlertViewTitleDeleteMultipleSounds NSLocalizedString(@"Delete these sounds", nil)
#define kUIAlertViewTitleDeleteSingleSound NSLocalizedString(@"Delete this sound", nil)
#define kUIAlertViewTitleNotEnoughFreeMemory NSLocalizedString(@"Not enough free memory to download this program. Please delete some of your programs", nil)
#define kUIAlertViewTitleCopyProgram NSLocalizedString(@"Copy program", nil)

// placeholder defines
#define kUIAlertViewPlaceholderEnterProgramName NSLocalizedString(@"Enter your program name here...", @"Placeholder for program-name input field")
#define kUIAlertViewPlaceholderEnterObjectName NSLocalizedString(@"Enter your object name here...", @"Placeholder for add object-name input field")
#define kUIAlertViewPlaceholderEnterImageName NSLocalizedString(@"Enter your image name here...", @"Placeholder for add image-name input field")

// text defines
#define kUIAlertViewMessageInfoForPocketCode NSLocalizedString(@"Pocket Code for iOS", nil)
#define kUIAlertViewMessageFeatureComingSoon NSLocalizedString(@"This feature is coming soon!", nil)
#define kUIAlertViewMessageProgramName NSLocalizedString(@"Program name", nil)
#define kUIAlertViewMessageObjectName NSLocalizedString(@"Object name", nil)
#define kUIAlertViewMessageImageName NSLocalizedString(@"Image name", nil)
#define kUIAlertViewMessageNoImportedSoundsFound NSLocalizedString(@"No imported sounds found. Please connect your iPhone to your PC/Mac and use iTunes FileSharing to import sound files into the PocketCode app.", nil)
#define kUIAlertViewMessageInvalidProgramName NSLocalizedString(@"No or invalid program name entered, try again.", nil)
#define kUIAlertViewMessageProgramNameAlreadyExists NSLocalizedString(@"A program with the same name already exists, try again.", nil)
#define kUIAlertViewMessageInvalidObjectName NSLocalizedString(@"No or invalid object name entered, try again.", nil)
#define kUIAlertViewMessageUnableToLoadProgram NSLocalizedString(@"Unable to load program!", nil)
#define kUIAlertViewMessageIrreversibleAction NSLocalizedString(@"This action can not be undone!", nil)
#define kUIAlertViewMessageUnableToPlaySound NSLocalizedString(@"Unable to play that sound!\nMaybe this is no valid sound or the file is corrupt.", nil)
#define kUIAlertViewMessageDeviceIsInMutedStateIPhone NSLocalizedString(@"Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the left side of your iPhone and tap on play again.", nil)
#define kUIAlertViewMessageDeviceIsInMutedStateIPad NSLocalizedString(@"Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the right side of your iPad and tap on play again.", nil)
#define kUIAlertViewMessageNoInternetConnection NSLocalizedString(@"No internet connection available.", nil)

// button defines
#define kUIAlertViewButtonTitleOK NSLocalizedString(@"OK", nil)
#define kUIAlertViewButtonTitleCancel NSLocalizedString(@"Cancel", nil)
#define kUIAlertViewButtonTitleYes NSLocalizedString(@"Yes", nil)
#define kUIAlertViewButtonTitleNo NSLocalizedString(@"No", nil)
#define kUIAlertViewButtonTitleDelete NSLocalizedString(@"Delete", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UILabel text defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUILabelTextLoading NSLocalizedString(@"Loading", nil)
#define kUILabelTextDescription NSLocalizedString(@"Description", nil)
#define kUILabelTextNoDescriptionAvailable NSLocalizedString(@"No Description available", nil)
#define kUILabelTextAuthor NSLocalizedString(@"Author", nil)
#define kUILabelTextDownloads NSLocalizedString(@"Downloads", nil)
#define kUILabelTextUploaded NSLocalizedString(@"Uploaded", nil)
#define kUILabelTextVersion NSLocalizedString(@"Version", nil)
#define kUILabelTextViews NSLocalizedString(@"Views", nil)
#define kUILabelTextInformation NSLocalizedString(@"Information", nil)
#define kUILabelTextMeasure NSLocalizedString(@"Measure", nil)
#define kUILabelTextSize NSLocalizedString(@"Size", nil)
#define kUILabelTextBackground NSLocalizedString(@"Background", @"Title for Background-Section-Header in program view")
#define kUILabelTextObjectSingular NSLocalizedString(@"Object",@"Title for Object-Section-Header in program view (singular)")
#define kUILabelTextObjectPlural NSLocalizedString(@"Objects",@"Title for Object-Section-Header in program view (plural)")
#define kUILabelTextScripts NSLocalizedString(@"Scripts", nil)
#define kUILabelTextBricks NSLocalizedString(@"Bricks", nil)
#define kUILabelTextLooks NSLocalizedString(@"Looks", nil)
#define kUILabelTextSounds NSLocalizedString(@"Sounds", nil)
#define kUILabelTextLastAccess NSLocalizedString(@"Last access", nil)
#define kUILabelTextSize NSLocalizedString(@"Size", nil)
#define kUILabelTextLength NSLocalizedString(@"Length", nil)

#define kUILabelTextBack NSLocalizedString(@"Back", nil)
#define kUILabelTextRestart NSLocalizedString(@"Restart", nil)
#define kUILabelTextContinue NSLocalizedString(@"Continue", nil)
#define kUILabelTextScreenshot NSLocalizedString(@"Screenshot", nil)
#define kUILabelTextGrid NSLocalizedString(@"Grid", nil)

#define kUILabelNoSearchResults NSLocalizedString(@"No search results", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UISegmentedControl title defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUISegmentedControlTitleMostDownloaded NSLocalizedString(@"Most Downloaded", nil)
#define kUISegmentedControlTitleMostViewed NSLocalizedString(@"Most Viewed", nil)
#define kUISegmentedControlTitleNewest NSLocalizedString(@"Newest", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * BrickCell title defines
 * -----------------------------------------------------------------------------------------------------------
 */

// categories
#define kBrickCellControlCategoryTitle NSLocalizedString(@"Control", nil)
#define kBrickCellMotionCategoryTitle NSLocalizedString(@"Motion", nil)
#define kBrickCellSoundCategoryTitle NSLocalizedString(@"Sound", nil)
#define kBrickCellLooksCategoryTitle NSLocalizedString(@"Looks", nil)
#define kBrickCellVariablesCategoryTitle NSLocalizedString(@"Variables", nil)

// control bricks
#define kBrickCellControlTitleWhenProgramStarted NSLocalizedString(@"When program started", nil)
#define kBrickCellControlTitleWhenTapped NSLocalizedString(@"When tapped", nil)
#define kBrickCellControlTitleWait NSLocalizedString(@"Wait %@ second(s)", nil)
#define kBrickCellControlTitleWhenIReceive NSLocalizedString(@"When I receive\n%@", nil)
#define kBrickCellControlTitleBroadcast NSLocalizedString(@"Broadcast\n%@", nil)
#define kBrickCellControlTitleBroadcastAndWait NSLocalizedString(@"Broadcast and wait\n%@", nil)
#define kBrickCellControlTitleNote NSLocalizedString(@"Note %@", nil)
#define kBrickCellControlTitleForever NSLocalizedString(@"Forever", nil)
#define kBrickCellControlTitleIf NSLocalizedString(@"If %@ is true then", nil)
#define kBrickCellControlTitleElse NSLocalizedString(@"Else", nil)
#define kBrickCellControlTitleEndIf NSLocalizedString(@"If End", nil)
#define kBrickCellControlTitleRepeat NSLocalizedString(@"Repeat %@ times", nil)
#define kBrickCellControlTitleEndOfLoop NSLocalizedString(@"End of Loop", nil)

// motion bricks
#define kBrickCellMotionTitlePlaceAt NSLocalizedString(@"Place at\nX: %@ Y: %@", nil)
#define kBrickCellMotionTitleSetX NSLocalizedString(@"Set X to %@", nil)
#define kBrickCellMotionTitleSetY NSLocalizedString(@"Set Y to %@", nil)
#define kBrickCellMotionTitleChangeX NSLocalizedString(@"Change X by %@", nil)
#define kBrickCellMotionTitleChangeY NSLocalizedString(@"Change Y by %@", nil)
#define kBrickCellMotionTitleIfOnEdgeBounce NSLocalizedString(@"If on edge, bounce", nil)
#define kBrickCellMotionTitleMoveNSteps NSLocalizedString(@"Move %@ step(s)", nil)
#define kBrickCellMotionTitleTurnLeft NSLocalizedString(@"Turn left %@°", nil)
#define kBrickCellMotionTitleTurnRight NSLocalizedString(@"Turn right %@°", nil)
#define kBrickCellMotionTitlePointInDirection NSLocalizedString(@"Point in direction %@°", nil)
#define kBrickCellMotionTitlePointTowards NSLocalizedString(@"Point towards\n%@", nil)
#define kBrickCellMotionTitleGlideTo NSLocalizedString(@"Glide %@ second(s)\nto X: %@ Y: %@", nil)
#define kBrickCellMotionTitleGoNStepsBack NSLocalizedString(@"Go back %@ layer(s)", nil)
#define kBrickCellMotionTitleComeToFront NSLocalizedString(@"Go to front", nil)

// look bricks
#define kBrickCellLookTitleSetLook NSLocalizedString(@"Switch to look\n%@", nil)
#define kBrickCellLookTitleSetBackground NSLocalizedString(@"Set background\n%@", nil)
#define kBrickCellLookTitleNextLook NSLocalizedString(@"Next look", nil)
#define kBrickCellLookTitleNextBackground NSLocalizedString(@"Next background", nil)
#define kBrickCellLookTitleSetSizeTo NSLocalizedString(@"Set size to %@\%", nil)
#define kBrickCellLookTitleChangeSizeByN NSLocalizedString(@"Change size by %@\%", nil)
#define kBrickCellLookTitleHide NSLocalizedString(@"Hide", nil)
#define kBrickCellLookTitleShow NSLocalizedString(@"Show", nil)
#define kBrickCellLookTitleSetGhostEffect NSLocalizedString(@"Set transparency\nto %@\%", nil)
#define kBrickCellLookTitleChangeGhostEffectByN NSLocalizedString(@"Change transparency\nby %@\%", nil)
#define kBrickCellLookTitleSetBrightness NSLocalizedString(@"Set brightness to %@\%", nil)
#define kBrickCellLookTitleChangeBrightnessByN NSLocalizedString(@"Change brightness\nby %@\%", nil)
#define kBrickCellLookTitleClearGraphicEffect NSLocalizedString(@"Clear graphic effects", nil)

// sound bricks
#define kBrickCellSoundTitlePlaySound NSLocalizedString(@"Start sound\n%@", nil)
#define kBrickCellSoundTitleStopAllSounds NSLocalizedString(@"Stop all sounds", nil)
#define kBrickCellSoundTitleSetVolumeTo NSLocalizedString(@"Set volume to %@\%", nil)
#define kBrickCellSoundTitleChangeVolumeByN NSLocalizedString(@"Change volume by %@", nil)
#define kBrickCellSoundTitleSpeak NSLocalizedString(@"Speak %@", nil)

// variable bricks
#define kBrickCellVariableTitleSetVariable NSLocalizedString(@"Set variable\n%@\nto %@", nil)
#define kBrickCellVariableTitleChangeVariable NSLocalizedString(@"Change variable\n%@\nby %@", nil)
