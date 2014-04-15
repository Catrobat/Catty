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

#define kGeneralNewDefaultProgramName NSLocalizedString(@"New Program",@"Default name for new programs")
#define kGeneralBackgroundObjectName NSLocalizedString(@"Background", @"Title for background object")
#define kGeneralDefaultObjectName NSLocalizedString(@"My Object", @"Title for first (default) object")

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

#define kUIViewControllerTitleCategories NSLocalizedString(@"Categories", nil)
#define kUIViewControllerTitleExplore NSLocalizedString(@"Explore", nil)
#define kUIViewControllerTitleHelp NSLocalizedString(@"Help", nil)
#define kUIViewControllerTitleInfo NSLocalizedString(@"Info", nil)
#define kUIViewControllerTitleLooks NSLocalizedString(@"Looks", nil)
#define kUIViewControllerTitleSounds NSLocalizedString(@"Sounds", nil)
#define kUIViewControllerTitleChooseSound NSLocalizedString(@"Choose sound", nil)
#define kUIViewControllerTitlePrograms NSLocalizedString(@"Programs", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIViewController placeholder defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUIViewControllerPlaceholderTitleScripts NSLocalizedString(@"Scripts", nil)
#define kUIViewControllerPlaceholderTitleBackgrounds NSLocalizedString(@"Backgrounds", nil)
#define kUIViewControllerPlaceholderTitleLooks kUIViewControllerTitleLooks
#define kUIViewControllerPlaceholderTitleSounds kUIViewControllerTitleSounds

#define kUIViewControllerPlaceholderDescriptionStandard NSLocalizedString(@"Click \"+\" to add %@", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIViewController placeholder defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUITableViewControllerMenuTitleScripts kUIViewControllerPlaceholderTitleScripts
#define kUITableViewControllerMenuTitleBackgrounds kUIViewControllerPlaceholderTitleBackgrounds
#define kUITableViewControllerMenuTitleLooks kUIViewControllerPlaceholderTitleLooks
#define kUITableViewControllerMenuTitleSounds kUIViewControllerPlaceholderTitleSounds

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIBarButtonItem title defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUIBarButtonItemTitleEdit NSLocalizedString(@"Edit", nil)
#define kUIBarButtonItemTitleCancel NSLocalizedString(@"Cancel", nil)
#define kUIBarButtonItemTitleSelectAllItems NSLocalizedString(@"Select all", nil)
#define kUIBarButtonItemTitleUnselectAllItems NSLocalizedString(@"Unselect all", nil)
#define kUIBarButtonItemTitleDelete NSLocalizedString(@"Delete", nil)

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

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIActionSheetButton title defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUIActionSheetButtonTitleClose NSLocalizedString(@"Close", nil)
#define kUIActionSheetButtonTitleDeleteBrick NSLocalizedString(@"Delete Brick", nil)
#define kUIActionSheetButtonTitleHighlightScript NSLocalizedString(@"Highlight Script", nil)
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
#define kUIActionSheetButtonTitleDeleteObjects NSLocalizedString(@"Delete Objects", nil)
#define kUIActionSheetButtonTitleDeletePrograms NSLocalizedString(@"Delete Programs", nil)
#define kUIActionSheetButtonTitlePocketCodeRecorder NSLocalizedString(@"Pocket Code Recorder", nil)
#define kUIActionSheetButtonTitleChooseSound NSLocalizedString(@"Choose sound", nil)

#define kUIActionSheetButtonTitleCameraRoll NSLocalizedString(@"Camera Roll", nil)
#define kUIActionSheetButtonTitleProject NSLocalizedString(@"Project", nil)
#define kUIActionSheetButtonTitleCancel NSLocalizedString(@"Cancel", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIButton title defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUIButtonTitlePlay NSLocalizedString(@"Play", nil)
#define kUIButtonTitleDownload NSLocalizedString(@"Download", nil)
#define kUIButtonTitleCancel kUIBarButtonItemTitleCancel

/*
 * -----------------------------------------------------------------------------------------------------------
 * UIAlertView title, placeholder, text, button defines
 * -----------------------------------------------------------------------------------------------------------
 */

// title defines
#define kUIAlertViewTitleStandard NSLocalizedString(@"Pocket Code", nil)
#define kUIAlertViewTitleAddObject NSLocalizedString(@"Add Object", nil)
#define kUIAlertViewTitleRenameProgram NSLocalizedString(@"Rename program", nil)
#define kUIAlertViewTitleCantRestartProgram NSLocalizedString(@"Can't restart program!", nil)
#define kUIAlertViewTitleScreenshotSavedToCameraRoll NSLocalizedString(@"Screenshot saved to Camera Roll", nil)
#define kUIAlertViewTitleScreenshotSavedToProject NSLocalizedString(@"Screenshot saved to project", nil)

// placeholder defines
#define kUIAlertViewPlaceholderEnterProgramName NSLocalizedString(@"Enter your program name here...", @"Placeholder for program-name input field")
#define kUIAlertViewPlaceholderEnterObjectName NSLocalizedString(@"Enter your object name here...", @"Placeholder for add object-name input field")

// text defines
#define kUIAlertViewMessageInfoForPocketCode NSLocalizedString(@"Pocket Code for iOS", nil)
#define kUIAlertViewMessageFeatureComingSoon NSLocalizedString(@"This feature is coming soon!", nil)
#define kUIAlertViewMessageProgramName NSLocalizedString(@"Program name", nil)
#define kUIAlertViewMessageObjectName NSLocalizedString(@"Object name", nil)
#define kUIAlertViewMessageNoImportedSoundsFound NSLocalizedString(@"No imported sounds found. Please connect your iPhone to your PC/Mac and use iTunes FileSharing to import sound files into the PocketCode app.", nil)

#define kUIAlertViewButtonTitleOK NSLocalizedString(@"OK", nil)

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
#define kUILabelTextBack NSLocalizedString(@"Back", nil)
#define kUILabelTextBack NSLocalizedString(@"Back", nil)
#define kUILabelTextContinue NSLocalizedString(@"Continue", nil)
#define kUILabelTextScreenshot NSLocalizedString(@"Screenshot", nil)
#define kUILabelTextGrid NSLocalizedString(@"Grid", nil)

/*
 * -----------------------------------------------------------------------------------------------------------
 * UISegmentedControl title defines
 * -----------------------------------------------------------------------------------------------------------
 */

#define kUISegmentedControlTitleMostDownloaded NSLocalizedString(@"Most Downloaded", nil)
#define kUISegmentedControlTitleMostViewed NSLocalizedString(@"Most Viewed", nil)
#define kUISegmentedControlTitleNewest NSLocalizedString(@"Newest", nil)
