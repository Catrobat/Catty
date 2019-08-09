
Catty
=====
[![](https://jenkins.catrob.at/buildStatus/icon?job=Catty%2Fdevelop)](https://jenkins.catrob.at/job/Catty/job/develop/) ![](https://img.shields.io/github/release/catrobat/catty.svg) ![](https://img.shields.io/github/languages/top/catrobat/catty.svg)

Catty, also known as **Pocket Code for iOS**, is an on-device visual programming system for iPhones.

Catrobat is a visual programming language and set of creativity tools for smartphones, tablets, and mobile browsers. Catrobat programs can be written by using the Catroid programming system on Android phones and tablets, using Catroid, or Catty for iPhones.

For more information oriented towards developers please visit our [developers page](http://developer.catrobat.org/).

[![Download on the App Store](https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg)](https://catrob.at/PCios)

# Issues #

For reporting issues use our [JIRA Bugtracking System](https://jira.catrob.at/secure/RapidBoard.jspa?rapidView=75). Before, please browse our currently open issues [here](https://jira.catrob.at/secure/IssueNavigator.jspa?reset=true&jqlQuery=project+%3D+IOS+AND+resolution+%3D+Unresolved+ORDER+BY+priority+DESC%2C+key+DESC&mode=hide).

# Contributing #

If you want to contribute we suggest that you start with [forking](https://help.github.com/articles/fork-a-repo/) our repository and browse the code. Then you can look at our [Issue-Tracker](https://jira.catrob.at/secure/RapidBoard.jspa?rapidView=60) and start with fixing one ticket. We strictly use [Test-Driven Development](http://c2.com/cgi/wiki?TestDrivenDevelopment) and [Clean Code](http://www.planetgeek.ch/wp-content/uploads/2013/06/Clean-Code-V2.2.pdf), so first read everything you can about these development methods. Code developed in a different style will not be accepted.
After you've created a pull request we will review your code and do a full testrun on your branch.

If you want to implement a new feature, please ask about the details on http://catrob.at/mailinglist or our [Google Group](https://groups.google.com/forum/#!forum/catty-ios)

<!--
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

## Learn iOS development

We recommend [Developing iOS 11 Apps with Swift](https://itunes.apple.com/us/course/developing-ios-11-apps-with-swift/id1309275316) from the Stanford University.

## Start setting up the working environment:

* Install [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) and [Carthage](https://github.com/Carthage/Carthage).

* Clone this repository, set up the required third-party libraries by executing `make init` within the 'Catty' directory and open [Catty.xcodeproj](src/Catty.xcodeproj)

* If you have any further questions please use our [Google Group](https://groups.google.com/forum/#!forum/catty-ios)

# License

The Following License Header should be used for all header and source files.

## License Header (for source and header files)
<pre lang="objective-c"><code>
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
</code></pre>

[1]: http://brew.sh
