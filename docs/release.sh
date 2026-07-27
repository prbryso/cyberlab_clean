#!/bin/zsh

echo "Cleaning project..."
flutter clean
flutter pub get

echo "Building release..."
flutter build web --release

echo "Deploying to gh-pages..."
git checkout gh-pages
rm -rf !( .git )
cp -r ../build/web/* .
git add .
git commit -m "Automated release build"
git push

echo "Done! New release deployed."
