#!/bin/bash

SEARCH_STRING="NSLocalizedString"

EXCLUDED_DIRS=( "minizip" "SSZipArchive" )

EXCLUDED_FILES=( "LanguageTranslationDefines.h" "Functions.m" "Operators.m" "BSKeyboardControls.m" )

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
  matches=$(egrep "$SEARCH_STRING" "$file" | wc -l)
  if [ $matches -gt 0 ]; then
    echo -e $file:1: error : NSLocalizedString MUST BE moved to LanguageTranslationDefines.h! 1>&2
    ERROR_COUNT=1
  fi
done < <(eval "find . -type d \( $EXCLUDED_DIRS_STR \) -prune -o -type f \( $EXCLUDED_FILES_STR \) -prune -o -type f \( -name \"*.m\" -o -name \"*.h\" -o -name \"*.pch\" \) -print")

exit $ERROR_COUNT
