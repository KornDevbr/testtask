# Color variables
RED='\033[0;31m'
NO_COLOR='\033[0m'

### Prepare list of the files in this commit.
FILES=$(git diff --name-only -r origin/$BITBUCKET_PR_DESTINATION_BRANCH..$BITBUCKET_BRANCH)

if [[ "$FILES" == "" ]]; then
  exit 0;
fi

###
### File modes section.
###
STATUS=0
for FILE in $FILES; do

  # Ensure the file still exists (i.e. is not being deleted).
  if [ -a $FILE ]; then

    # Ignore .sh files from the check.
    if [ ${FILE: -3} != ".sh" ]; then

      # Ensure the file has the correct mode.
      EXPECTED_MODE="644"
      STAT="$(stat -f "%A" $FILE 2>/dev/null)"
      if [ $? -ne 0 ]; then
        STAT="$(stat -c "%a" $FILE 2>/dev/null)"
      fi
      if [ "$STAT" -ne "$EXPECTED_MODE" ]; then

        # Exported YAML config files have 664 file mode.
        if [ ${FILE: -4} == ".yml" ]; then
          EXPECTED_MODE="664"
        fi

        if [ "$STAT" -ne "$EXPECTED_MODE" ]; then
          printf "${RED}File modes check failed (should be $EXPECTED_MODE not $STAT):${NO_COLOR} file $FILE \n"
          STATUS=1
        fi
      fi
    fi
  fi
done
exit $STATUS