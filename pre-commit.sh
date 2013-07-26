# Builds distribution
# Add this to your git hooks by running
# `ln -s ../../pre-commit.sh .git/hooks/pre-commit`
grunt
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]];then
  echo "Aborted commit"
  exit 1
else
  echo ""
fi
git add dist
