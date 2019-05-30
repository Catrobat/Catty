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

//*************************************************************************************
//***********************       MediaLibrary        ***********************************
//*************************************************************************************

let kMediaLibraryBackgroundsIndex = kBaseUrl.appending("/api/media/package/Backgrounds/json")
let kMediaLibraryLooksIndex = kBaseUrl.appending("/api/media/package/Looks/json")
let kMediaLibrarySoundsIndex = kBaseUrl.appending("/api/media/package/Sounds/json")
let kMediaLibraryDownloadBaseURL = kBaseUrl.replacingOccurrences(of: "/pocketcode/", with: "")

//*************************************************************************************
//*******************      FeaturedProjectStoreViewController       *******************
//*************************************************************************************

let kConnectionHost = kBaseUrl.appending("api/projects")
let kFeaturedImageBaseUrl = kBaseUrl.replacingOccurrences(of: "/pocketcode/", with: "/")
let kChartProjectsMaxResults = 10
let kRecentProjectsMaxResults = 20
let kSearchStoreMaxResults = 50
let kAspectRatioHeight: CGFloat = 25
let kAspectRatioWidth: CGFloat = 64

//*************************************************************************************
//********************        UploadViewController       ******************************
//*************************************************************************************

let kUploadUrl = kBaseUrl.appending("api/upload")

//*************************************************************************************
//*********************      HelpWebViewController       ******************************
//*************************************************************************************

let kDownloadUrl = kBaseUrl.appending("download")
let kForumURL = kBaseUrl.appending("help")
