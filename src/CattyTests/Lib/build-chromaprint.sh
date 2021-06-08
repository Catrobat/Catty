#!/bin/sh

set -e

CHROMAPRINT_VERSION="1.5.0"
IOS_DEPLOYMENT_TARGET="12.0"

git clone https://github.com/acoustid/chromaprint.git chromaprint
cd chromaprint
git checkout v$CHROMAPRINT_VERSION

cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TOOLS=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_FRAMEWORK=ON -DFFT_LIB=vdsp -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$IOS_DEPLOYMENT_TARGET -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" -DCMAKE_OSX_SYSROOT=$(xcrun --show-sdk-path --sdk iphonesimulator) .
make

mkdir -p build/simulator
cp -r src/chromaprint.framework build/simulator/Chromaprint.framework

make clean
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TOOLS=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_FRAMEWORK=ON -DFFT_LIB=vdsp -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$IOS_DEPLOYMENT_TARGET -DCMAKE_OSX_ARCHITECTURES="arm64" -DCMAKE_OSX_SYSROOT=$(xcrun --show-sdk-path --sdk iphoneos) .
make

mkdir -p build/device
cp -r src/chromaprint.framework build/device/Chromaprint.framework

mkdir build/simulator/Chromaprint.framework/Modules
echo 'framework module Chromaprint {
    header "chromaprint.h"
    link "c++"
    link framework "Accelerate"
}' > build/simulator/Chromaprint.framework/Modules/module.modulemap

cp -r build/simulator/Chromaprint.framework/Modules build/device/Chromaprint.framework/Modules/

/usr/libexec/PlistBuddy -c "add :CFBundleName string Chromaprint" build/simulator/Chromaprint.framework/Info.plist
/usr/libexec/PlistBuddy -c "add :MinimumOSVersion string ${IOS_DEPLOYMENT_TARGET}" build/simulator/Chromaprint.framework/Info.plist
/usr/libexec/PlistBuddy -c "set :CFBundleIdentifier org.acoustid.chromaprint" build/simulator/Chromaprint.framework/Info.plist
/usr/libexec/PlistBuddy -c "set :CFBundleDevelopmentRegion en" build/simulator/Chromaprint.framework/Info.plist
/usr/libexec/PlistBuddy -c "set :CFBundleVersion ${CHROMAPRINT_VERSION}" build/simulator/Chromaprint.framework/Info.plist
/usr/libexec/PlistBuddy -c "set :CFBundleShortVersionString ${CHROMAPRINT_VERSION}" build/simulator/Chromaprint.framework/Info.plist
/usr/libexec/PlistBuddy -c "delete :CFBundleIconFile" build/simulator/Chromaprint.framework/Info.plist
/usr/libexec/PlistBuddy -c "delete :CSResourcesFileMapped" build/simulator/Chromaprint.framework/Info.plist

cp build/simulator/Chromaprint.framework/Info.plist build/device/Chromaprint.framework/Info.plist

xcodebuild -create-xcframework -framework build/device/Chromaprint.framework -framework build/simulator/Chromaprint.framework -output ../Chromaprint.xcframework

cd ..
rm -rf chromaprint
