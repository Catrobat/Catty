#!/bin/bash

LANGUAGE_TRANSLATION_DEFINES_FILE="./Catty/Defines/LanguageTranslationDefines.h"
LOCALIZED_STRINGS_DIR="./iOS_Lang/en.lproj/"

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
exit 0

