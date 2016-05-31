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

#define kAppStoreIdentifier @"1117935892"
#define kAppStoreURL @"itms-apps://itunes.apple.com/app/" kAppStoreIdentifier

#define kConnectionTimeout 15
#define kBaseUrl @"https://share.catrob.at/pocketcode/"
#define kTestUrl @"https://catroid-test.catrob.at/pocketcode/"
#define kConnectionHost kBaseUrl @"api/projects"
#define kLoginOrRegisterUrlExtension @"api/loginOrRegister"
#define kLoginUrlExtension @"api/login"
#define kRegisterUrlExtension @"api/register"
#define kReportProgramExtension @"api/reportProgram/reportProgram.json"
#define kUploadUrlExtension @"api/upload"
#define kLoginOrRegisterUrl kBaseUrl kLoginOrRegisterUrlExtension
#define kTestLoginOrRegisterUrl kTestUrl kLoginOrRegisterUrlExtension
#define kLoginUrl kBaseUrl kLoginUrlExtension
#define kTestLoginUrl kTestUrl kLoginUrlExtension
#define kRegisterUrl kBaseUrl kRegisterUrlExtension
#define kTestRegisterUrl kTestUrl kRegisterUrlExtension
#define kTestReportProgramUrl kTestUrl kReportProgramExtension
#define kReportProgramUrl kBaseUrl kReportProgramExtension
#define kUploadUrl kBaseUrl kUploadUrlExtension
#define kTestUploadUrl kTestUrl kUploadUrlExtension
#define kForumURL kBaseUrl @"help"
#define kDownloadUrl kBaseUrl @"download"
#define kSourceCodeLicenseURL @"http://developer.catrobat.org/licenses"
#define kAboutCatrobatURL @"http://www.catrobat.org"
#define kTermsOfUseURL kBaseUrl @"termsOfUse"
#define kRecoverPassword kBaseUrl @"resetting/request"
#define kMediaLibraryUrl kBaseUrl @"pocket-library"

#define kConnectionSearch @"search.json"
#define kConnectionRecent @"recentIDs.json"
#define kConnectionRecentFull @"recent.json"
#define kConnectionFeatured @"featured.json"
#define kConnectionMostDownloaded @"mostDownloadedIDs.json"
#define kConnectionMostDownloadedFull @"mostDownloaded.json"
#define kConnectionMostViewed @"mostViewedIDs.json"
#define kConnectionMostViewedFull @"mostViewed.json"
#define kConnectionIDQuery @"getInfoById.json"
#define kConnectionLoginOrRegister @"loginOrRegister.json"
#define kConnectionLogin @"Login.json"
#define kConnectionRegister @"Register.json"
#define kConnectionUpload @ "upload.json"

#define kProgramsOffset @"offset="
#define kProgramsLimit @"limit="
