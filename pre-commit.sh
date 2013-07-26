# Builds distribution
# Add this to your git hooks by running
# `ln -s ../../pre-commit.sh .git/hooks/pre-commit`
grunt
git add dist
