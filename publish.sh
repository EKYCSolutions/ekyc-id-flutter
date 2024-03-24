# set environment variables
export VERSION="$1" &&\
export CWD="$(pwd)" &&\
export PUBSPEC="pubspec.yaml"

# update version in .podspec file
sed "s#\(.*version.*\):.*#\1: ${VERSION}#" $PUBSPEC > $PUBSPEC.bak &&\
mv $PUBSPEC.bak $PUBSPEC &&\

# sync git changes
git add . &&\
git commit -m "released version ${VERSION}" | true &&\
git tag "${VERSION}" | true &&\
git push --tags | true &&\
git push origin main | true &&\

# publish
flutter packages pub publish