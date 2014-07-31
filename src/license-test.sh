#!/bin/bash

SEARCH_STRING=" \\*  Copyright \\(C\\) 2010-2014 The Catrobat Team| \\*  \\(http:\\/\\/developer.catrobat.org\\/credits\\)| \\*  This program is free software: you can redistribute it and\\/or modify| \\*  it under the terms of the GNU Affero General Public License as| \\*  published by the Free Software Foundation, either version 3 of the| \\*  License, or \\(at your option\\) any later version.| \\*  An additional term exception under section 7 of the GNU Affero| \\*  General Public License, version 3, is available at| \\*  \\(http:\\/\\/developer.catrobat.org\\/license_additional_term\\)| \\*  This program is distributed in the hope that it will be useful,| \\*  but WITHOUT ANY WARRANTY; without even the implied warranty of| \\*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the| \\*  GNU Affero General Public License for more details.| \\*  You should have received a copy of the GNU Affero General Public License| \\*  along with this program.  If not, see http:\\/\\/www.gnu.org\\/licenses\\/."

EXCLUDED_DIRS=( "TTTAttributedLabel" "minizip" "SSZipArchive" "GDataXMLNode" "FBShimmering" "LXReorderableCollectionViewFlowLayout" "AHKActionSheetViewController" "AHKAdditions" "IBActionSheet" "SWCellScrollView" "SWLongPressGestureRecognizer" "SWTableViewCell" "FXBlurView" "BDKNotifyHUD" "EVCircularProgressView" )

EXCLUDED_FILES=( "AHKActionSheet.[mh]" "AHKActionSheetViewController.[mh]" "LXReorderableCollectionViewFlowLayout.[mh]" "IBActionSheet.[mh]" "Reachability.[mh]" "SharkfoodMuteSwitchDetector.[mh]" "SWCellScrollView.[mh]" "SWUtilityButtonView.[mh]" "UIImage+AHKAdditions.[mh]" "UIWindow+AHKAdditions.[mh]" "SWLongPressGestureRecognizer.[mh]" "SWTableViewCell.[mh]" "SWUtilityButtonTapGestureRecognizer.[mh]" )



EXCLUDED_DIRS_STR=""
for ((i=0;i<${#EXCLUDED_DIRS[@]};++i)); do
    if [ "$i" -gt 0 ]
    then
        EXCLUDED_DIRS_STR="$EXCLUDED_DIRS_STR -o"
    fi
    EXCLUDED_DIRS_STR="$EXCLUDED_DIRS_STR -name \"${EXCLUDED_DIRS[i]}\""
done

EXCLUDED_FILES_STR=""
for ((i=0;i<${#EXCLUDED_FILES[@]};++i)); do
    if [ "$i" -gt 0 ]
    then
        EXCLUDED_FILES_STR="$EXCLUDED_FILES_STR -o"
    fi
    EXCLUDED_FILES_STR="$EXCLUDED_FILES_STR -name \"${EXCLUDED_FILES[i]}\""
done

ERROR_COUNT=0
while read file
do
    matches=$(egrep -wx "$SEARCH_STRING" $file | wc -l)
    if [ $matches -ne 15 ]; then
        echo -e $file:1: error : No valid License Header found! 1>&2 
        ERROR_COUNT=1
    fi
done < <(eval "find . -type d \( $EXCLUDED_DIRS_STR \) -prune -o -type f \( $EXCLUDED_FILES_STR \) -prune -o -type f \( -name \"*.m\" -o -name \"*.h\" -o -name \"*.pch\" \) -print")

exit $ERROR_COUNT
