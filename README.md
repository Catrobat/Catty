Catty
=====

Catty, also known as **Pocket Code for iOS**, is an on-device visual programming system for iPhones.

Catrobat is a visual programming language and set of creativity tools for smartphones, tablets, and mobile browsers. Catrobat programs can be written by using the Catroid programming system on Android phones and tablets, using Catroid, or Catty for iPhones.

For more information oriented towards developers please visit our [developers page](http://developer.catrobat.org/).
# Issues #

For reporting issues use our [JIRA Bugtracking System](https://jira.catrob.at/secure/RapidBoard.jspa?rapidView=75). Before, please browse our currently open issues [here](https://jira.catrob.at/secure/IssueNavigator.jspa?reset=true&jqlQuery=project+%3D+IOS+AND+resolution+%3D+Unresolved+ORDER+BY+priority+DESC%2C+key+DESC&mode=hide).

# Questions?
Please ask on our Google Plus community: http://goo.gl/fOjQi



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


# First steps for extern Contributors
## Learn iOS development?
We recommend [iPad and iPhone App Development](https://itunes.apple.com/us/course/ipad-iphone-app-development/id495052415) from the Stanford University.

## Setting Up Your First Project - Step by Step
For a step-by-step guide how to deploy your first project, see: http://goo.gl/R0tmG

## ... Short Version

* If you want to contribute we suggest that you start with [forking](https://help.github.com/articles/fork-a-repo/) our repository and browse the code. Then you can look at our [Issue-Tracker](https://jira.catrob.at/secure/RapidBoard.jspa?rapidView=75) and start with fixing one ticket. We strictly use [Test-Driven Development](http://c2.com/cgi/wiki?TestDrivenDevelopment) and [Clean Code](http://www.planetgeek.ch/wp-content/uploads/2013/06/Clean-Code-V2.2.pdf), so first read everything you can about these development methods. Code developed in a different style will not be accepted. 
After you've created a pull request we will review your code and do a full testrun on your branch.

* If you want to implement a new feature, please ask about the details in JIRA or our IRC channel (#catrobat or #catrobatdev) first.

* Download XCode (at least version 6) from the Mac App Store

* Clone this project by using git clone

* If you have any further questions please use our IRC Channel(#catrobat or #catrobatdev) or Google Plus community: http://goo.gl/fOjQi




# License

The Following License Header should be used for all header and source files.

## License Header (for source and header files)
<pre lang="objective-c"><code>
/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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
