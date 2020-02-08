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

let kLocalizedSkip = NSLocalizedString("Skip", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedWelcomeToPocketCode = NSLocalizedString("Welcome to Pocket Code", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedExploreApps = NSLocalizedString("Explore apps", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCreateAndEdit = NSLocalizedString("Create & Remix", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNewProject = NSLocalizedString("New project", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNewMessage = NSLocalizedString("New message", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedBackground = NSLocalizedString("Background", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMyObject = NSLocalizedString("My object", bundle: Bundle(for: LanguageTranslation.self), comment: "Title for first (default) object")
let kLocalizedMyImage = NSLocalizedString("My image", bundle: Bundle(for: LanguageTranslation.self), comment: "Default title of imported photo from camera (taken by camera)")
let kLocalizedMyFirstProject = NSLocalizedString("My first project", bundle: Bundle(for: LanguageTranslation.self), comment: "Name of the default catrobat project (used as filename!!)")
let kLocalizedMole = NSLocalizedString("Mole", bundle: Bundle(for: LanguageTranslation.self), comment: "Prefix of default catrobat project object names (except background object)")
let kLocalizedToday = NSLocalizedString("Today", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedYesterday = NSLocalizedString("Yesterday", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSunday = NSLocalizedString("Sunday", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMonday = NSLocalizedString("Monday", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTuesday = NSLocalizedString("Tuesday", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedWednesday = NSLocalizedString("Wednesday", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedThursday = NSLocalizedString("Thursday", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedFriday = NSLocalizedString("Friday", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSaturday = NSLocalizedString("Saturday", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSu = NSLocalizedString("Su", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMo = NSLocalizedString("Mo", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTu = NSLocalizedString("Tu", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedWe = NSLocalizedString("We", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTh = NSLocalizedString("Th", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedFr = NSLocalizedString("Fr", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSa = NSLocalizedString("Sa", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedJanuary = NSLocalizedString("January", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedFebruary = NSLocalizedString("February", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMarch = NSLocalizedString("March", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedApril = NSLocalizedString("April", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedJune = NSLocalizedString("June", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedJuly = NSLocalizedString("July", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAugust = NSLocalizedString("August", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSeptember = NSLocalizedString("September", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedOctober = NSLocalizedString("October", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNovember = NSLocalizedString("November", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDecember = NSLocalizedString("December", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedJan = NSLocalizedString("Jan", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedFeb = NSLocalizedString("Feb", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMar = NSLocalizedString("Mar", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedApr = NSLocalizedString("Apr", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMay = NSLocalizedString("May", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedJun = NSLocalizedString("Jun", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedJul = NSLocalizedString("Jul", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAug = NSLocalizedString("Aug", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSep = NSLocalizedString("Sep", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedOct = NSLocalizedString("Oct", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNov = NSLocalizedString("Nov", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDec = NSLocalizedString("Dec", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPocketCode = NSLocalizedString("Pocket Code", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCategories = NSLocalizedString("Categories", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDetails = NSLocalizedString("Details", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLooks = NSLocalizedString("Looks", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedFeaturedProjects = NSLocalizedString("Featured projects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedScripts = NSLocalizedString("Scripts", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedBackgrounds = NSLocalizedString("Backgrounds", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTapPlusToAddBackground = NSLocalizedString("Tap \"+\" to add backgrounds", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTapPlusToAddScript = NSLocalizedString("Tap \"+\" to add scripts", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTapPlusToAddSprite = NSLocalizedString("Tap \"+\" to add actors or objects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTapPlusToAddLook = NSLocalizedString("Tap \"+\" to add looks", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTapPlusToAddSound = NSLocalizedString("Tap \"+\" to add sounds", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedContinue = NSLocalizedString("Continue", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedContinueProject = NSLocalizedString("Continue project", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNew = NSLocalizedString("New", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNewElement = NSLocalizedString("New...", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedProjects = NSLocalizedString("Projects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedProjectsOnDevice = NSLocalizedString("Projects on device", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedProject = NSLocalizedString("Project", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedHelp = NSLocalizedString("Help", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCatrobatCommunity = NSLocalizedString("Catrobat community", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeletionMenu = NSLocalizedString("Deletion mode", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAboutPocketCode = NSLocalizedString("About Pocket Code", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTermsOfUse = NSLocalizedString("Terms of Use and Service", bundle: Bundle(for: LanguageTranslation.self), comment: "Button title at the settings screen to get to the terms of use and service.")
let kLocalizedForgotPassword = NSLocalizedString("Forgot password", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRateUs = NSLocalizedString("Rate Us", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPrivacySettings = NSLocalizedString("Privacy Settings", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedVersionLabel = NSLocalizedString("iOS.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedBack = NSLocalizedString("Back", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSourceCodeLicenseButtonLabel = NSLocalizedString("Pocket Code Source Code License", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAboutCatrobatButtonLabel = NSLocalizedString("About Catrobat", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedEdit = NSLocalizedString("Edit", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCancel = NSLocalizedString("Cancel", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDone = NSLocalizedString("Done", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUndo = NSLocalizedString("Undo", bundle: Bundle(for: LanguageTranslation.self), comment: "Button title of alert view to invoke undo if user shakes device")
let kLocalizedUndoDrawingDescription = NSLocalizedString("Undo Drawing?", bundle: Bundle(for: LanguageTranslation.self), comment: "Description text in alert view if user shakes the device")
let kLocalizedUndoTypingDescription = NSLocalizedString("Undo Typing?", bundle: Bundle(for: LanguageTranslation.self), comment: "Description text in alert view if user shakes the device")
let kLocalizedSelectAllItems = NSLocalizedString("Select all", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUnselectAllItems = NSLocalizedString("Unselect all", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSaveToPocketCode = NSLocalizedString("Save to PocketCode", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedEditSounds = NSLocalizedString("Edit sounds", bundle: Bundle(for: LanguageTranslation.self), comment: "Action sheet menu title")
let kLocalizedEditSound = NSLocalizedString("Edit sound", bundle: Bundle(for: LanguageTranslation.self), comment: "Action sheet menu title")
let kLocalizedEditLooks = NSLocalizedString("Edit looks", bundle: Bundle(for: LanguageTranslation.self), comment: "Action sheet menu title")
let kLocalizedEditLook = NSLocalizedString("Edit look", bundle: Bundle(for: LanguageTranslation.self), comment: "Action sheet menu title")
let kLocalizedEditBackground = NSLocalizedString("Edit background", bundle: Bundle(for: LanguageTranslation.self), comment: "Action sheet menu title")
let kLocalizedEditBackgrounds = NSLocalizedString("Edit backgrounds", bundle: Bundle(for: LanguageTranslation.self), comment: "Action sheet menu title")
let kLocalizedEditScript = NSLocalizedString("Edit script", bundle: Bundle(for: LanguageTranslation.self), comment: "Action sheet menu title")
let kLocalizedEditBrick = NSLocalizedString("Edit brick", bundle: Bundle(for: LanguageTranslation.self), comment: "Action sheet menu title")
let kLocalizedAddLook = NSLocalizedString("Add look", bundle: Bundle(for: LanguageTranslation.self), comment: "Action sheet menu title")
let kLocalizedLookFilename = NSLocalizedString("look", bundle: Bundle(for: LanguageTranslation.self), comment: "LOOK")
let kLocalizedEditProject = NSLocalizedString("Edit project", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedEditProjects = NSLocalizedString("Edit projects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedEditObject = NSLocalizedString("Edit actor or object", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAddSound = NSLocalizedString("Add sound", bundle: Bundle(for: LanguageTranslation.self), comment: "Action sheet menu title")
let kLocalizedSelectBrickCategory = NSLocalizedString("Select brick category", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedClose = NSLocalizedString("Close", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteBrick = NSLocalizedString("Delete brick", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteThisBrick = NSLocalizedString("Delete this brick?", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteTheseBricks = NSLocalizedString("Delete these bricks?", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteCondition = NSLocalizedString("Delete condition", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteThisCondition = NSLocalizedString("Delete this condition?", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteTheseConditions = NSLocalizedString("Delete these conditions?", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteLoop = NSLocalizedString("Delete loop", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteThisLoop = NSLocalizedString("Delete this loop?", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteTheseLoops = NSLocalizedString("Delete these loops?", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteScript = NSLocalizedString("Delete script", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteThisScript = NSLocalizedString("Delete this script?", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteTheseScripts = NSLocalizedString("Delete these scripts?", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAnimateBrick = NSLocalizedString("Animate brick-parts", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCopyBrick = NSLocalizedString("Copy brick", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedEditFormula = NSLocalizedString("Edit formula", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMoveBrick = NSLocalizedString("Move brick", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteSounds = NSLocalizedString("Delete sounds", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMoveSounds = NSLocalizedString("Move sounds", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedHideDetails = NSLocalizedString("Hide details", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedShowDetails = NSLocalizedString("Show details", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteLooks = NSLocalizedString("Delete looks", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteBackgrounds = NSLocalizedString("Delete backgrounds", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMoveLooks = NSLocalizedString("Move looks", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCopyLooks = NSLocalizedString("Copy looks", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedFromCamera = NSLocalizedString("From camera", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedChooseImage = NSLocalizedString("Choose image", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDrawNewImage = NSLocalizedString("Draw new image", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRename = NSLocalizedString("Rename", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCopy = NSLocalizedString("Copy", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteObjects = NSLocalizedString("Delete actors or objects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMoveObjects = NSLocalizedString("Move actors or objects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteProjects = NSLocalizedString("Delete projects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPocketCodeRecorder = NSLocalizedString("Pocket Code Recorder", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCameraRoll = NSLocalizedString("Camera roll", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedOpen = NSLocalizedString("Open", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDownload = NSLocalizedString("Download", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMore = NSLocalizedString("More", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDelete = NSLocalizedString("Delete", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAddObject = NSLocalizedString("Add actor or object", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAddImage = NSLocalizedString("Add image", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRenameObject = NSLocalizedString("Rename actor or object", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRenameImage = NSLocalizedString("Rename image", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRenameSound = NSLocalizedString("Rename sound", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteThisObject = NSLocalizedString("Delete this actor or object", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteThisProject = NSLocalizedString("Delete this project", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteThisLook = NSLocalizedString("Delete this look", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteThisBackground = NSLocalizedString("Delete this background", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteThisSound = NSLocalizedString("Delete this sound", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCopyProject = NSLocalizedString("Copy project", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRenameProject = NSLocalizedString("Rename project", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSetDescription = NSLocalizedString("Set description", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPocketCodeForIOS = NSLocalizedString("Pocket Code for iOS", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedProjectName = NSLocalizedString("Project name", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMessage = NSLocalizedString("Message", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDescription = NSLocalizedString("Description", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedObjectName = NSLocalizedString("Object or actor name", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedImageName = NSLocalizedString("Image name", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSoundName = NSLocalizedString("Sound name", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedOK = NSLocalizedString("OK", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedYes = NSLocalizedString("Yes", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNo = NSLocalizedString("No", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeleteProject = NSLocalizedString("Delete project", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLoading = NSLocalizedString("Loading", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSaved = NSLocalizedString("Saved", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSaveError = NSLocalizedString("Error saving file", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAuthor = NSLocalizedString("Author", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDownloads = NSLocalizedString("Downloads", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUploaded = NSLocalizedString("Uploaded", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedVersion = NSLocalizedString("Version", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedViews = NSLocalizedString("Views", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedInformation = NSLocalizedString("Information", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMeasure = NSLocalizedString("Measure", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSize = NSLocalizedString("Size", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedObject = NSLocalizedString("Object", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedObjects = NSLocalizedString("Actors and objects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedBricks = NSLocalizedString("Bricks", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSounds = NSLocalizedString("Sounds", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLastAccess = NSLocalizedString("Last access", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLength = NSLocalizedString("Length", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRestart = NSLocalizedString("Restart", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPreview = NSLocalizedString("Preview", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAxes = NSLocalizedString("Axes", bundle: Bundle(for: LanguageTranslation.self), comment: "Title of icon shown in the side bar to enable or disable an overlayed view to show the origin of the coordinate system and implicitly the display size.")
let kLocalizedMostDownloaded = NSLocalizedString("Most downloaded", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMostViewed = NSLocalizedString("Most viewed", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNewest = NSLocalizedString("Newest", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedVariables = NSLocalizedString("Variables", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLists = NSLocalizedString("Lists", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroBricks = NSLocalizedString("Use Phiro bricks", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedArduinoBricks = NSLocalizedString("Arduino extension", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedFrontCamera = NSLocalizedString("Front camera", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDisconnectAllDevices = NSLocalizedString("Disconnect all devices", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRemoveKnownDevices = NSLocalizedString("Remove known devices", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRecording = NSLocalizedString("Recording", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedError = NSLocalizedString("Error", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMemoryWarning = NSLocalizedString("Not enough Memory", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedReportProject = NSLocalizedString("Report as inappropriate", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedEnterReason = NSLocalizedString("Enter a reason", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLoginToReport = NSLocalizedString("Please log in to report this project as inappropriate", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedName = NSLocalizedString("Name", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDownloaded = NSLocalizedString("Download successful", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSettings = NSLocalizedString("Settings", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedOff = NSLocalizedString("off", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedOn = NSLocalizedString("on", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCameraBack = NSLocalizedString("back", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCameraFront = NSLocalizedString("front", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMoreInformation = NSLocalizedString("More information", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//************************************************************************************************************
//**********************************       SHORT DESCRIPTIONS      *******************************************
//************************************************************************************************************

let kLocalizedCantRestartProject = NSLocalizedString("Can't restart project!", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedThisFeatureIsComingSoon = NSLocalizedString("This feature is coming soon!", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNoDescriptionAvailable = NSLocalizedString("No description available", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNoSearchResults = NSLocalizedString("No search results", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUnableToLoadProject = NSLocalizedString("Unable to load project!", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedThisActionCannotBeUndone = NSLocalizedString("This action can not be undone!", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedErrorInternetConnection = NSLocalizedString("An unknown error occurred. Check your Internet connection.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedErrorUnknown = NSLocalizedString("An unknown error occurred. Please try again later.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedInvalidURLGiven = NSLocalizedString("Invalid URL given!", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNoCamera = NSLocalizedString("No camera available", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedImagePickerSourceNotAvailable = NSLocalizedString("Image source not available", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedBluetoothPoweredOff = NSLocalizedString("Bluetooth is turned off. Please turn it on to connect to a Bluetooth device.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedBluetoothNotAvailable = NSLocalizedString("Bluetooth is not available. Either your device does not support Bluetooth 4.0 or your Bluetooth chip is damaged. Please check it by connection to another Bluetooth device in the Settings.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDisconnectBluetoothDevices = NSLocalizedString("All Bluetooth devices successfully disconnected", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRemovedKnownBluetoothDevices = NSLocalizedString("All known Bluetooth devices successfully removed", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedArduinoBricksDescription = NSLocalizedString("Allow the app to control Arduino boards", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//************************************************************************************************************
//**********************************       LONG DESCRIPTIONS      ********************************************
//************************************************************************************************************

let kLocalizedWelcomeDescription = NSLocalizedString("Pocket Code let's you play great games and run other fantastic apps like for instance presentations, quizzes and so on.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedExploreDescription = NSLocalizedString("By switching to the section \"Explore\" you can discover more interesting projects from people all over the world.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCreateAndEditDescription = NSLocalizedString("You are also able to build your own apps, remix existing ones and share them with your friends and other exciting people around the world.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAboutPocketCodeDescription = NSLocalizedString("Pocket Code is a programming environment for iOS for the visual programming language Catrobat. The code of Pocket Code is mostly under GNU AGPL v3 licence. For further information to the licence please visit following links:", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTermsOfUseDescription = NSLocalizedString("In order to be allowed to use Pocket Code and other executables offered by the Catrobat project, you must agree to our Terms of Use and strictly follow them when you use Pocket Code and our other executables. Please see the link below for their precise formulation.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNotEnoughFreeMemoryDescription = NSLocalizedString("Not enough free memory to download this project. Please delete some of your projects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedProjectNotFound = NSLocalizedString("The requested project can not be found. Please choose a different one.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedInvalidZip = NSLocalizedString("The requested project can not be loaded. Please try again later.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedEnterYourProjectNameHere = NSLocalizedString("Enter your project name here...", bundle: Bundle(for: LanguageTranslation.self), comment: "Placeholder for project-name input field")
let kLocalizedEnterNameForImportedProjectTitle = NSLocalizedString("Import File", bundle: Bundle(for: LanguageTranslation.self), comment: "Title of prompt shown when a *.catrobat file is imported from a third-party app.")
let kLocalizedEnterYourProjectDescriptionHere = NSLocalizedString("Enter your project description here...", bundle: Bundle(for: LanguageTranslation.self), comment: "Placeholder for project-description input field")
let kLocalizedEnterYourMessageHere = NSLocalizedString("Enter your message here...", bundle: Bundle(for: LanguageTranslation.self), comment: "Placeholder for message input field")
let kLocalizedEnterYourVariableNameHere = NSLocalizedString("Enter your variable name here...", bundle: Bundle(for: LanguageTranslation.self), comment: "Placeholder for variable input field")
let kLocalizedEnterYourListNameHere = NSLocalizedString("Enter your list name here...", bundle: Bundle(for: LanguageTranslation.self), comment: "Placeholder for list input field")
let kLocalizedEnterYourObjectNameHere = NSLocalizedString("Enter your object name here...", bundle: Bundle(for: LanguageTranslation.self), comment: "Placeholder for add object-name input field")
let kLocalizedEnterYourImageNameHere = NSLocalizedString("Enter your image name here...", bundle: Bundle(for: LanguageTranslation.self), comment: "Placeholder for add image-name input field")
let kLocalizedEnterYourSoundNameHere = NSLocalizedString("Enter your sound name here...", bundle: Bundle(for: LanguageTranslation.self), comment: "Placeholder for add sound-name input field")
let kLocalizedNoOrTooShortInputDescription = NSLocalizedString("Please enter at least %lu character(s).", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTooLongInputDescription = NSLocalizedString("The input is too long. Please enter maximal %lu character(s).", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSpaceInputDescription = NSLocalizedString("Only space is not allowed. Please enter at least %lu other character(s).", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSpecialCharInputDescription = NSLocalizedString("Only special characters are not allowed. Please enter at least %lu other character(s).", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedBlockedCharInputDescription = NSLocalizedString("The name contains blocked characters. Please try again!", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedInvalidInputDescription = NSLocalizedString("Invalid input entered, try again.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedProjectNameAlreadyExistsDescription = NSLocalizedString("A project with the same name already exists, try again.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedInvalidDescriptionDescription = NSLocalizedString("The description contains invalid characters, try again.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedObjectNameAlreadyExistsDescription = NSLocalizedString("An object with the same name already exists, try again.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMessageAlreadyExistsDescription = NSLocalizedString("A message with the same name already exists, try again.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedInvalidImageNameDescription = NSLocalizedString("No or invalid image name entered, try again.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedInvalidSoundNameDescription = NSLocalizedString("No or invalid sound name entered, try again.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedImageNameAlreadyExistsDescription = NSLocalizedString("An image with the same name already exists, try again.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUnableToPlaySoundDescription = NSLocalizedString("Unable to play that sound!\nMaybe this is no valid sound or the file is corrupt.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeviceIsInMutedStateIPhoneDescription = NSLocalizedString("Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the left side of your iPhone and tap on play again.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDeviceIsInMutedStateIPadDescription = NSLocalizedString("Unable to play the selected sound. Your device is in silent mode. Please turn off silent mode by toggling the switch on the right side of your iPad and tap on play again.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedProjectAlreadyDownloadedDescription = NSLocalizedString("You have already downloaded this project!", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNoAccesToImagesCheckSettingsDescription = NSLocalizedString("Pocket Code has no access to your images. To permit access, tap settings and activate images. Your drawing will automatically be saved to PocketCode for you.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNoAccesToCameraCheckSettingsDescription = NSLocalizedString("Pocket Code has no access to your camera. To permit access, tap settings and activate camera. Your drawing will automatically be saved to PocketCode for you.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNoAccesToMicrophoneCheckSettingsDescription = NSLocalizedString("Pocket Code has no access to your microphone. To permit access, tap settings and activate microphone.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUnsupportedElementsDescription = NSLocalizedString("Following features used in this project are not compatible with this version of Pocket Code:", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//************************************************************************************************************
//*******************************       BRICK TITLE TRANSLATIONS      ****************************************
//************************************************************************************************************

// control bricks
let kLocalizedScript = NSLocalizedString("Script", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedWhenProjectStarted = NSLocalizedString("When project started", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedWhenTapped = NSLocalizedString("When tapped", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTouchDown = NSLocalizedString("When stage is tapped", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedWait = NSLocalizedString("Wait", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSecond = NSLocalizedString("second ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSeconds = NSLocalizedString("seconds ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedVibrateFor = NSLocalizedString("Vibrate for", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedWhenYouReceive = NSLocalizedString("When you receive", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedBroadcast = NSLocalizedString("Broadcast", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedBroadcastAndWait = NSLocalizedString("Broadcast and wait", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNote = NSLocalizedString("Note", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedForever = NSLocalizedString("Forever", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedIfBegin = NSLocalizedString("If", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedIfBeginSecondPart = NSLocalizedString("is true then", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedElse = NSLocalizedString("Else", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedEndIf = NSLocalizedString("End if", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedWaitUntil = NSLocalizedString("Wait until", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRepeat = NSLocalizedString("Repeat", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRepeatUntil = NSLocalizedString("Repeat until", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUntilIsTrue = NSLocalizedString("is true", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTime = NSLocalizedString("time", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTimes = NSLocalizedString("times", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedEndOfLoop = NSLocalizedString("End of Loop", bundle: Bundle(for: LanguageTranslation.self), comment: "")

// motion bricks
let kLocalizedPlaceAt = NSLocalizedString("Place at ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedXLabel = NSLocalizedString("x: ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedYLabel = NSLocalizedString("y: ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSetX = NSLocalizedString("Set x to ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSetY = NSLocalizedString("Set y to ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedChangeXBy = NSLocalizedString("Change x by ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedChangeYBy = NSLocalizedString("Change y by ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedIfIsTrueThenOnEdgeBounce = NSLocalizedString("If on edge, bounce", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMove = NSLocalizedString("Move", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedStep = NSLocalizedString("step", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSteps = NSLocalizedString("steps", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTurnLeft = NSLocalizedString("Turn left", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTurnRight = NSLocalizedString("Turn right", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedDegrees = NSLocalizedString("degrees", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPointInDirection = NSLocalizedString("Point in direction", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPointTowards = NSLocalizedString("Point towards", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedGlide = NSLocalizedString("Glide", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedToX = NSLocalizedString("to x:", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedGoBack = NSLocalizedString("Go back", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLayer = NSLocalizedString("layer", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLayers = NSLocalizedString("layers", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedComeToFront = NSLocalizedString("Go to front", bundle: Bundle(for: LanguageTranslation.self), comment: "")

// look bricks
let kLocalizedLook = NSLocalizedString("Look", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSetLook = NSLocalizedString("Switch to look", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSetBackground = NSLocalizedString("Set background", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNextLook = NSLocalizedString("Next look", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNextBackground = NSLocalizedString("Next background", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPreviousLook = NSLocalizedString("Previous look", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPreviousBackground = NSLocalizedString("Previous background", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSetSizeTo = NSLocalizedString("Set size to", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedChangeSizeByN = NSLocalizedString("Change size by", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedHide = NSLocalizedString("Hide", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedShow = NSLocalizedString("Show", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLedOn = NSLocalizedString("Flashlight on", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLedOff = NSLocalizedString("Flashlight off", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSetTransparency = NSLocalizedString("Set transparency ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedChangeTransparency = NSLocalizedString("Change transparency ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSetBrightness = NSLocalizedString("Set brightness ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedChangeBrightness = NSLocalizedString("Change brightness ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTo = NSLocalizedString("to", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedBy = NSLocalizedString("by", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedClearGraphicEffect = NSLocalizedString("Clear graphic effects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSetColor = NSLocalizedString("Set color ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedChangeColor = NSLocalizedString("Change color ", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedFlash = NSLocalizedString("Turn flashlight", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCamera = NSLocalizedString("Turn camera", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedChooseCamera = NSLocalizedString("Use camera", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedFor = NSLocalizedString("for", bundle: Bundle(for: LanguageTranslation.self), comment: "")

// sound bricks
let kLocalizedSound = NSLocalizedString("Sound", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPlaySound = NSLocalizedString("Start sound", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPlaySoundAndWait = NSLocalizedString("Start sound and wait", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedStopAllSounds = NSLocalizedString("Stop all sounds", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSetVolumeTo = NSLocalizedString("Set volume to", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedChangeVolumeBy = NSLocalizedString("Change volume by", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSay = NSLocalizedString("Say", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedThink = NSLocalizedString("Think", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSpeak = NSLocalizedString("Speak", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAndWait = NSLocalizedString("and wait", bundle: Bundle(for: LanguageTranslation.self), comment: "")

// variable
let kLocalizedSetVariable = NSLocalizedString("Set variable", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedChangeVariable = NSLocalizedString("Change variable", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedShowVariable = NSLocalizedString("Show variable", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedHideVariable = NSLocalizedString("Hide variable", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAt = NSLocalizedString("at ", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//userlist
let kLocalizedUserListAdd = NSLocalizedString("Add", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUserListTo = NSLocalizedString("to list", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUserListDeleteItemFrom = NSLocalizedString("Delete item from list", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUserListAtPosition = NSLocalizedString("at position", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUserListInsert = NSLocalizedString("Insert", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUserListInto = NSLocalizedString("into list", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUserListReplaceItemInList = NSLocalizedString("Replace item in list", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUserListWith = NSLocalizedString("with", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//Note
let kLocalizedNoteAddCommentHere = NSLocalizedString("add comment here...", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//Bubble
let kLocalizedHello = NSLocalizedString("Hello!", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedHmmmm = NSLocalizedString("Hmmmm!", bundle: Bundle(for: LanguageTranslation.self), comment: "")

// Broadcast
let kLocalizedBroadcastMessage1 = NSLocalizedString("message 1", bundle: Bundle(for: LanguageTranslation.self), comment: "")

// phiro bricks
let kLocalizedStopPhiroMotor = NSLocalizedString("Stop Phiro motor", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroSpeed = NSLocalizedString("Speed", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroMoveForward = NSLocalizedString("Move Phiro motor forward", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroMoveBackward = NSLocalizedString("Move Phiro motor backward", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroRGBLight = NSLocalizedString("Set Phiro light", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroRGBLightRed = NSLocalizedString("red", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroRGBLightGreen = NSLocalizedString("green", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroRGBLightBlue = NSLocalizedString("blue", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroPlayTone = NSLocalizedString("Play Phiro music\n", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroPlayDuration = NSLocalizedString("Duration", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroSecondsToPlay = NSLocalizedString("seconds", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroIfLogic = NSLocalizedString("If", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroThenLogic = NSLocalizedString("is true then", bundle: Bundle(for: LanguageTranslation.self), comment: "")

// Arduino bricks
let kLocalizedArduinoSetDigitalValue = NSLocalizedString("Set Arduino digital pin", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedArduinoSetPinValueTo = NSLocalizedString("to", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedArduinoSendPWMValue = NSLocalizedString("Set Arduino PWM~ pin", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//Unsupported elements
let kLocalizedUnsupportedElements = NSLocalizedString("Unsupported Elements", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUnsupportedBrick = NSLocalizedString("Unsupported Brick:", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUnsupportedScript = NSLocalizedString("Unsupported Script:", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//************************************************************************************************************
//**********************************       Login/Upload            *******************************************
//************************************************************************************************************

let kLocalizedLogin = NSLocalizedString("Login", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLogout = NSLocalizedString("Logout", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUsername = NSLocalizedString("Username", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPassword = NSLocalizedString("Password", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedConfirmPassword = NSLocalizedString("Confirm password", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedEmail = NSLocalizedString("Email", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRegister = NSLocalizedString("Create account", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUploadProject = NSLocalizedString("Upload project", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLoginUsernameNecessary = NSLocalizedString("Username must not be blank", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLoginEmailNotValid = NSLocalizedString("Your email seems to be invalid", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLoginPasswordNotValid = NSLocalizedString("Password is not vaild! \n It has to contain at least 6 characters/symbols", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRegisterPasswordConfirmationNoMatch = NSLocalizedString("Passwords do not match", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUploadProjectNecessary = NSLocalizedString("Project Name is necessary!", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedTermsAgreementPart = NSLocalizedString("By registering you agree to our", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUploadSuccessful = NSLocalizedString("Upload successful", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedRegistrationSuccessful = NSLocalizedString("Registration successful", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedLoginSuccessful = NSLocalizedString("Login successful", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUploadSelectedProject = NSLocalizedString("Upload selected project", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUploadProblem = NSLocalizedString("Problems occured while uploading your project", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUploadSelectProject = NSLocalizedString("Please select a project to upload", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNoWhitespaceAllowed = NSLocalizedString("No whitespace character allowed", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedAuthenticationFailed = NSLocalizedString("Authentication failed", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kLocalizedInfoLogin = NSLocalizedString("Login", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedInfoRegister = NSLocalizedString("Register", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//************************************************************************************************************
//************************************       PAINT                ********************************************
//************************************************************************************************************

let kLocalizedPaintWidth = NSLocalizedString("Width selection", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintRed = NSLocalizedString("Red", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintGreen = NSLocalizedString("Green", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintBlue = NSLocalizedString("Blue", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintAlpha = NSLocalizedString("Alpha", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintBrush = NSLocalizedString("Brush", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintEraser = NSLocalizedString("Eraser", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintResize = NSLocalizedString("Resize", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintPipette = NSLocalizedString("Pipette", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintMirror = NSLocalizedString("Mirror", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintImage = NSLocalizedString("Image", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintLine = NSLocalizedString("Line", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintRect = NSLocalizedString("Rectangle / Square", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintCircle = NSLocalizedString("Ellipse / Circle", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintStamp = NSLocalizedString("Stamp", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintRotate = NSLocalizedString("Rotate", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintFill = NSLocalizedString("Fill", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintZoom = NSLocalizedString("Zoom", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintPointer = NSLocalizedString("Pointer", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintTextTool = NSLocalizedString("Text", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintSaveChanges = NSLocalizedString("Do you want to save the changes", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintMenuButtonTitle = NSLocalizedString("Menu", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintSelect = NSLocalizedString("Select option:", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintSave = NSLocalizedString("Save to cameraRoll", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintClose = NSLocalizedString("Close Paint", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintNewCanvas = NSLocalizedString("New canvas", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintPickTool = NSLocalizedString("Please pick a tool", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintNoCrop = NSLocalizedString("Nothing to crop!", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintAskNewCanvas = NSLocalizedString("Do you really want to delete the current drawing?", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintRound = NSLocalizedString("round", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintSquare = NSLocalizedString("square", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintPocketPaint = NSLocalizedString("Pocket Paint", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintStamped = NSLocalizedString("Stamped", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintInserted = NSLocalizedString("Inserted", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintText = NSLocalizedString("Text:", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintAttributes = NSLocalizedString("Attributes:", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintBold = NSLocalizedString("bold", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintItalic = NSLocalizedString("italic", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintUnderline = NSLocalizedString("underline", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")
let kLocalizedPaintTextAlert = NSLocalizedString("Please enter a text.", bundle: Bundle(for: LanguageTranslation.self), comment: "paint")

//************************************************************************************************************
//************************************       FormulaEditor        ********************************************
//************************************************************************************************************

let kUIActionSheetTitleSelectLogicalOperator = NSLocalizedString("Select logical operator", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIActionSheetTitleSelectMathematicalFunction = NSLocalizedString("Select mathematical function", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFENumbers = NSLocalizedString("Numbers", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFELogic = NSLocalizedString("Logic", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEVar = NSLocalizedString("New", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFETake = NSLocalizedString("Choose", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEDelete = NSLocalizedString("Delete", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEMath = NSLocalizedString("Math", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObject = NSLocalizedString("Object", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensor = NSLocalizedString("Sensors", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEVariable = NSLocalizedString("Variables", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEVariableList = NSLocalizedString("Var/List", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFECompute = NSLocalizedString("Compute", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEDone = NSLocalizedString("Done", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEError = NSLocalizedString("Error", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEtooLongFormula = NSLocalizedString("Formula too long!", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEResult = NSLocalizedString("Result", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEComputed = NSLocalizedString("Computed result is %.2f", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEComputedTrue = NSLocalizedString("Computed result is TRUE", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEComputedFalse = NSLocalizedString("Computed result is FALSE", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFENewVar = NSLocalizedString("New variable", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFENewList = NSLocalizedString("New list", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFENewVarExists = NSLocalizedString("Name already exists.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEonly15Char = NSLocalizedString("only 15 characters allowed", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEVarName = NSLocalizedString("Variable name:", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEListName = NSLocalizedString("List name:", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEOtherName = NSLocalizedString("Please choose another name:", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEAddNewText = NSLocalizedString("Abc", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFEProjectVars = NSLocalizedString("Project variables:", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectVars = NSLocalizedString("Object variables:", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEProjectLists = NSLocalizedString("Project lists:", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectLists = NSLocalizedString("Object lists:", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEDeleteVarBeingUsed = NSLocalizedString("This variable can not be deleted because it is still in use.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEActionVar = NSLocalizedString("Variable type", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEActionList = NSLocalizedString("List type", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEActionVarObj = NSLocalizedString("for this actor or object", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEActionVarPro = NSLocalizedString("for all actors or objects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEChangesSaved = NSLocalizedString("Changes saved.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEChangesDiscarded = NSLocalizedString("Changes discarded.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESyntaxError = NSLocalizedString("Syntax Error!", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEEmptyInput = NSLocalizedString("Empty input!", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFEVarOrList = NSLocalizedString("Variable or list", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFEFunctionSqrt = NSLocalizedString("sqrt", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionTrue = NSLocalizedString("true", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionFalse = NSLocalizedString("false", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionLetter = NSLocalizedString("letter", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionJoin = NSLocalizedString("join", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionLength = NSLocalizedString("length", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionFloor = NSLocalizedString("floor", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionCeil = NSLocalizedString("ceil", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionNumberOfItems = NSLocalizedString("number of items", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionElement = NSLocalizedString("element", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionContains = NSLocalizedString("contains", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFEFunctionScreenIsTouched = NSLocalizedString("stage is touched", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionScreenTouchX = NSLocalizedString("stage touch x", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEFunctionScreenTouchY = NSLocalizedString("stage touch y", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFEOperatorAnd = NSLocalizedString("and", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEOperatorNot = NSLocalizedString("not", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEOperatorOr = NSLocalizedString("or", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFEObjectTransparency = NSLocalizedString("transparency", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectBrightness = NSLocalizedString("brightness", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectColor = NSLocalizedString("color", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectLookNumber = NSLocalizedString("look number", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectLookName = NSLocalizedString("look name", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectBackgroundNumber = NSLocalizedString("background number", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectBackgroundName = NSLocalizedString("background name", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectSize = NSLocalizedString("size", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectDirection = NSLocalizedString("direction", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectLayer = NSLocalizedString("layer", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectPositionX = NSLocalizedString("position x", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFEObjectPositionY = NSLocalizedString("position y", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFESensorDateYear = NSLocalizedString("year", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorDateMonth = NSLocalizedString("month", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorDateDay = NSLocalizedString("day", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorDateWeekday = NSLocalizedString("weekday", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorTimeHour = NSLocalizedString("hour", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorTimeMinute = NSLocalizedString("minute", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorTimeSecond = NSLocalizedString("second", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFESensorCompass = NSLocalizedString("compass", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorLoudness = NSLocalizedString("loudness", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorAccelerationX = NSLocalizedString("acceleration x", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorAccelerationY = NSLocalizedString("acceleration y", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorAccelerationZ = NSLocalizedString("acceleration z", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorInclinationX = NSLocalizedString("inclination x", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorInclinationY = NSLocalizedString("inclination y", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorLatitude = NSLocalizedString("latitude", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorLongitude = NSLocalizedString("longitude", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorLocationAccuracy = NSLocalizedString("location accuracy", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorAltitude = NSLocalizedString("altitude", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorFingerTouched = NSLocalizedString("stage is touched", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorFingerX = NSLocalizedString("stage touch x", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorFingerY = NSLocalizedString("stage touch y", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorLastFingerIndex = NSLocalizedString("last stage touch index", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorPhiroFrontLeft = NSLocalizedString("phiro front left", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorPhiroFrontRight = NSLocalizedString("phiro front right", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorPhiroSideLeft = NSLocalizedString("phiro side left", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorPhiroSideRight = NSLocalizedString("phiro side right", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorPhiroBottomLeft = NSLocalizedString("phiro bottom left", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorPhiroBottomRight = NSLocalizedString("phiro bottom right", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFESensorArduinoAnalog = NSLocalizedString("arduino analog", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFESensorArduinoDigital = NSLocalizedString("arduino digital", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kLocalizedSensorCompass = NSLocalizedString("compass", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSensorLocation = NSLocalizedString("location", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSensorDeviceMotion = NSLocalizedString("device motion-sensor", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSensorAcceleration = NSLocalizedString("acceleration-sensor", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSensorRotation = NSLocalizedString("gyro-sensor", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSensorMagnetic = NSLocalizedString("magnetic-sensor", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedVibration = NSLocalizedString("vibration", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSensorLoudness = NSLocalizedString("loudness", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedSensorLED = NSLocalizedString("LED", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedNotAvailable = NSLocalizedString("not available. Continue anyway?", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFESensorFaceDetected = NSLocalizedString("face detected", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorFaceSize = NSLocalizedString("facesize", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorFaceX = NSLocalizedString("faceposition x", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFESensorFaceY = NSLocalizedString("faceposition y", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFEUnknownElementType = NSLocalizedString("Unknown Element", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kUIFENewText = NSLocalizedString("New text", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kUIFETextMessage = NSLocalizedString("Text message:", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//************************************************************************************************************
//************************************       BrickCategoryTitles        **************************************
//************************************************************************************************************

let kLocalizedCategoryFrequentlyUsed = NSLocalizedString("Frequently used", bundle: Bundle(for: LanguageTranslation.self), comment: "Title of View where the user can see the frequently used bricks.")
let kLocalizedCategoryControl = NSLocalizedString("Control", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCategoryMotion = NSLocalizedString("Motion", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCategoryLook = NSLocalizedString("Look", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCategorySound = NSLocalizedString("Sound", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCategoryVariable = NSLocalizedString("Variable", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCategoryArduino = NSLocalizedString("Arduino", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedCategoryPhiro = NSLocalizedString("Phiro", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//************************************************************************************************************
//************************************       PhiroDefines         ********************************************
//************************************************************************************************************

let kLocalizedPhiroBoth = NSLocalizedString("Both", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroLeft = NSLocalizedString("Left", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroRight = NSLocalizedString("Right", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let kLocalizedPhiroDO = NSLocalizedString("DO", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroRE = NSLocalizedString("RE", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroMI = NSLocalizedString("MI", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroFA = NSLocalizedString("FA", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroSO = NSLocalizedString("SO", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroLA = NSLocalizedString("LA", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedPhiroTI = NSLocalizedString("TI", bundle: Bundle(for: LanguageTranslation.self), comment: "")

let klocalizedBluetoothSearch = NSLocalizedString("Search", bundle: Bundle(for: LanguageTranslation.self), comment: "bluetooth")
let klocalizedBluetoothKnown = NSLocalizedString("Known devices", bundle: Bundle(for: LanguageTranslation.self), comment: "bluetooth")
let klocalizedBluetoothSelectPhiro = NSLocalizedString("Select Phiro", bundle: Bundle(for: LanguageTranslation.self), comment: "bluetooth")
let klocalizedBluetoothSelectArduino = NSLocalizedString("Select Arduino", bundle: Bundle(for: LanguageTranslation.self), comment: "bluetooth")
let klocalizedBluetoothConnectionNotPossible = NSLocalizedString("Connection not possible", bundle: Bundle(for: LanguageTranslation.self), comment: "bluetooth")
let klocalizedBluetoothConnectionTryResetting = NSLocalizedString("Please try resetting the device and try again.", bundle: Bundle(for: LanguageTranslation.self), comment: "bluetooth")
let klocalizedBluetoothConnectionFailed = NSLocalizedString("Connection failed", bundle: Bundle(for: LanguageTranslation.self), comment: "bluetooth")
let klocalizedBluetoothCannotConnect = NSLocalizedString("Cannot connect to device, please try resetting the device and try again.", bundle: Bundle(for: LanguageTranslation.self), comment: "bluetooth")
let klocalizedBluetoothNotResponding = NSLocalizedString("Cannot connect to device. The device is not responding.", bundle: Bundle(for: LanguageTranslation.self), comment: "bluetooth")
let klocalizedBluetoothConnectionLost = NSLocalizedString("Connection lost", bundle: Bundle(for: LanguageTranslation.self), comment: "bluetooth")
let klocalizedBluetoothDisconnected = NSLocalizedString("Device disconnected.", bundle: Bundle(for: LanguageTranslation.self), comment: "bluetooth")

//************************************************************************************************************
//************************************       MediaLibrary        *********************************************
//************************************************************************************************************

let kLocalizedMediaLibrary = NSLocalizedString("Media library", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMediaLibraryConnectionIssueTitle = NSLocalizedString("Connection failed", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMediaLibraryConnectionIssueMessage = NSLocalizedString("Cannot connect to the media library. Please check your internet connection.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMediaLibraryImportFailedTitle = NSLocalizedString("Failed to import item", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMediaLibraryImportFailedMessage = NSLocalizedString("The following item could not be imported from the media library:", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMediaLibrarySoundLoadFailureTitle = NSLocalizedString("Failed to load sound", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMediaLibrarySoundLoadFailureMessage = NSLocalizedString("The sound item cannot be loaded", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMediaLibrarySoundPlayFailureTitle = NSLocalizedString("Failed to play sound", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedMediaLibrarySoundPlayFailureMessage = NSLocalizedString("The sound item cannot be played", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//************************************************************************************************************
//**********************************       FeaturedProjects        *******************************************
//************************************************************************************************************

let kLocalizedFeaturedProjectsLoadFailureTitle = NSLocalizedString("Failed to load featured projects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedFeaturedProjectsLoadFailureMessage = NSLocalizedString("The featured projects cannot be loaded", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//************************************************************************************************************
//***********************************       ChartProjects        *********************************************
//************************************************************************************************************

let kLocalizedChartProjectsLoadFailureTitle = NSLocalizedString("Failed to load recent projects", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizeChartProjectsLoadFailureMessage = NSLocalizedString("The recent projects cannot be loaded", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//************************************************************************************************************
//**************************************       Networking        *********************************************
//************************************************************************************************************

let kLocalizedServerTimeoutIssueTitle = NSLocalizedString("Connection failed", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedServerTimeoutIssueMessage = NSLocalizedString("Server is taking to long to respond, please try again later.", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUnexpectedErrorTitle = NSLocalizedString("Unexpected Error", bundle: Bundle(for: LanguageTranslation.self), comment: "")
let kLocalizedUnexpectedErrorMessage = NSLocalizedString("Unexpected Error, please try again later.", bundle: Bundle(for: LanguageTranslation.self), comment: "")

//************************************************************************************************************
//****************************************       Debug        ************************************************
//************************************************************************************************************
let kLocalizedDebugMode = NSLocalizedString("debug", bundle: Bundle(for: LanguageTranslation.self), comment: "")

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

import UIKit

class LanguageTranslation {}
