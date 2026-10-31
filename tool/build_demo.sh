#!/bin/sh
# Builds the alpha demo APK for friends: the hidden ending closed, the
# author's settings hidden, double tempo (lib/story/demo.dart).
# Signed with android/key.properties when it exists (see story/YAPILACAKLAR.md).
set -e
cd "$(dirname "$0")/.."
flutter build apk --release --dart-define=DEMO=true "$@"
version=$(sed -n 's/^version: \([^+]*\).*/\1/p' pubspec.yaml)
cp build/app/outputs/flutter-apk/app-release.apk "build/ledective-$version.apk"
echo "build/ledective-$version.apk"
