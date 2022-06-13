
Catty
=====
[![](https://jenkins.catrob.at/buildStatus/icon?job=Catty%2Fdevelop)](https://jenkins.catrob.at/job/Catty/job/develop/) ![](https://img.shields.io/github/release/catrobat/catty.svg) ![](https://img.shields.io/github/languages/top/catrobat/catty.svg)

Catty, also known as **Pocket Code for iOS**, is an on-device visual programming system for iPhones.

Catrobat is a visual programming language and set of creativity tools for smartphones, tablets, and mobile browsers. Catrobat programs can be written by using the Catroid programming system on Android phones and tablets, using Catroid, or Catty for iPhones.

For more information oriented towards developers please visit our [developers page](http://developer.catrobat.org/).

[![Download on the App Store](https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg)](https://catrob.at/PCios)

# Issues #

For reporting issues use our [Jira issue tracker](https://jira.catrob.at/secure/CreateIssue.jspa?pid=11901&issuetype=1). Before creating a new bug, please browse our currently open issues [here](https://jira.catrob.at/secure/IssueNavigator.jspa?reset=true&jqlQuery=project+%3D+CATTY+AND+resolution+%3D+Unresolved+ORDER+BY+priority+DESC%2C+key+DESC&mode=hide).

# Contributing #

We welcome all offers for help! If you want to contribute we suggest that you start with [forking](https://help.github.com/articles/fork-a-repo/) our repository and browse the code. You can then look at our [Jira issue tracker](https://jira.catrob.at/issues/?jql=project%20%3D%20Catty%20AND%20status%20%3D%20%22Ready%20For%20Development%22%20AND%20%22Experience%20Level%22%20in%20(BEGINNER%2CTRAINING)) and start working on a ticket. It is recommended to start your contribution on a ticket labelled as *TRAINING* or *BEGINNER* ticket. We strictly use [Test-Driven Development](http://c2.com/cgi/wiki?TestDrivenDevelopment) and [Clean Code](http://www.planetgeek.ch/wp-content/uploads/2013/06/Clean-Code-V2.2.pdf), code developed in a different style will not be accepted. After you have implemented a certain ticket, hand in a pull request on GitHub and have a look at our pull request template.

If you want to implement a new feature, please ask about further details on [Google Groups](https://groups.google.com/forum/#!forum/catty-ios).

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

* Install [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) 13.0 or newer and [SwiftLint](https://github.com/realm/SwiftLint)

* Clone this repository and open [Catty.xcodeproj](src/Catty.xcodeproj)

* If you have any further questions please use our [Google Group](https://groups.google.com/forum/#!forum/catty-ios)

# License

The Following License Header should be used for all header and source files.

## License Header (for source and header files)
<pre lang="objective-c"><code>
/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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
