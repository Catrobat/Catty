#!/bin/bash

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

LANGUAGE_TRANSLATION_DEFINES_FILE="./Catty/Defines/LanguageTranslationDefines.h"
LOCALIZED_STRINGS_DIR="./iOS_Lang/en.lproj/"
LOCALIZED_STRINGS_FILENAME="Localizable.strings"
LOCALIZED_STRINGS_FILE=$LOCALIZED_STRINGS_DIR$LOCALIZED_STRINGS_FILENAME

if [ ! -f $LANGUAGE_TRANSLATION_DEFINES_FILE ]
then
  echo -e "No such file found: $LANGUAGE_TRANSLATION_DEFINES_FILE\nPlease update LANGUAGE_TRANSLATION_DEFINES_FILE variable in ${BASH_SOURCE[0]}"
  exit 1
fi

if [ ! -d $LOCALIZED_STRINGS_DIR ]
then
  echo -e "No such file found: $LOCALIZED_STRINGS_DIR\nPlease update LOCALIZED_STRINGS_DIR variable in ${BASH_SOURCE[0]}"
  exit 1
fi

echo -e "$LANGUAGE_TRANSLATION_DEFINES_FILE" | xargs genstrings -o $LOCALIZED_STRINGS_DIR

# now check if generated file exists at given path
if [ ! -f $LOCALIZED_STRINGS_FILE ]
then
  echo -e "No such file found: $LOCALIZED_STRINGS_FILE\nPlease update LOCALIZED_STRINGS_FILE variable in ${BASH_SOURCE[0]}"
  exit 1
fi

# convert encoding from utf16le (le stands for little endian) to utf8
# this is needed because sed has problems in dealing with utf16 encoded files
textutil -convert txt -encoding UTF-8 $LOCALIZED_STRINGS_FILE -output $LOCALIZED_STRINGS_FILE
# file --mime $LOCALIZED_STRINGS_FILE

# remove invalid special characters that were added by xargs
sed -i '' 's/[0-9]\$//g' $LOCALIZED_STRINGS_FILE

exit 0
