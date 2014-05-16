#!/bin/bash

searchString=" \\*  Copyright \\(C\\) 2010-2013 The Catrobat Team| \\*  \\(http:\\/\\/developer.catrobat.org\\/credits\\)| \\*  This program is free software: you can redistribute it and\\/or modify| \\*  it under the terms of the GNU Affero General Public License as| \\*  published by the Free Software Foundation, either version 3 of the| \\*  License, or \\(at your option\\) any later version.| \\*  An additional term exception under section 7 of the GNU Affero| \\*  General Public License, version 3, is available at| \\*  \\(http:\\/\\/developer.catrobat.org\\/license_additional_term\\)| \\*  This program is distributed in the hope that it will be useful,| \\*  but WITHOUT ANY WARRANTY; without even the implied warranty of| \\*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the| \\*  GNU Affero General Public License for more details.| \\*  You should have received a copy of the GNU Affero General Public License| \\*  along with this program.  If not, see http:\\/\\/www.gnu.org\\/licenses\\/."
ERROR_COUNT=0
while read file
do
    matches=$(egrep -wx "$searchString" $file | wc -l)
    if [ $matches -ne 15 ]; then
        echo -e $file:1: error : No valid License Header found! 1>&2 
        ERROR_COUNT=1
    fi
done < <(find . -type d \( -name "TTTAttributedLabel" -o -name "minizip" -o -name "SSZipArchive" -o -name "GDataXMLNode" -o name "FBShimmeringView" -o name "FBShimmeringLayer" -o name "FBShimmering" -o name "LXReorderableCollectionViewFlowLayout"  -o name "AHKActionSheet" - name "AHKActionSheetViewController" -o name "AHKAdditions" \) -prune -o -type f \( -name "*.m" -o -name "*.h" -o -name "*.pch" \) -print)

exit $ERROR_COUNT
