Catty
=====

iOS implementation of the Catrobat language

# Questions?
Please ask on our Google Plus community: http://goo.gl/fOjQi

<!--
# Setup guide
1. Download XCode (at least version 5) from the Mac App Store
1. Make sure you have installed [Brew][1], a package manage for OSX, which the `bootstrap` script uses to pull dependencies
1. Now install xctool and cmake by executing following lines at the command-line prompt:
   `sudo brew install xctool`
   `sudo brew install cmake`
1. Checkout our repository
   `git clone ...`
1. Update submodules
   `git submodule update --init --recursive`
1. Call bootstrap script of ObjectiveGit library
   `Catty/objective-git/script/bootstrap`
1. `sudo brew install homebrew/versions/perl516`
-->

# First Steps
## Learn iOS development?
We recommend [iPad and iPhone App Development](https://itunes.apple.com/us/course/ipad-iphone-app-development/id495052415) from the Stanford University.

## Setting Up Your First Project - Step by Step
For a step-by-step guide how to deploy your first project, see: http://goo.gl/R0tmG

## ... Short Version
* First of all you need an Apple ID if you haven't got it by now create it. [Create Apple ID](https://appleid.apple.com/cgi-bin/WebObjects/MyAppleId.woa/135/wa/createAppleId?wosid=4buecjiwQGa14dIxx55bYM&localang=de_DE)
* Now write a mail to your administrator of your Apple Developer Program. The Mail should look like this:

> Subject: [Catroid iOS Developer Team] Apple Development Certificates
> 
> Hi,
> 
> I am from the Catroid iOS-Team and would like to develop/test on my iDevice.
> Would you be so kind and send me an invitation.
> 
> Cheers,
>  Your Name

* Now you have to wait a bit until your administrator sends you an invitation through Apple.
* When you get the mail there is a link in it. Just click it and login with your Apple ID.
* Now continue with the following [guide](http://itunes.tugraz.at/media/items/ios_application_development_2011_pdf/1298971525-12_-_App_Deployment.pdf) from Josef Kolbitsch.
* Then write a mail to your administrator:

> I have uploaded my certificate and here is some additional data
> 
> Device ID: <PASTE IN YOUR DEVICE Identifiere>
> App ID: at.tugraz.DEVist.catroid-demo-app-1
> App Name: Catroid Player

* Finished

# License

The Following License Header should be used for all header and source files.

## License Header (for source and header files)
<pre lang="objective-c"><code>
/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
</code></pre>

[1]: http://brew.sh