#!/bin/sh

set -xe

VERSION="0.1.3"                                                           #
#SDKVERSION="6.1"
SDKVERSION="7.0"

CURRENTPATH=`pwd`

mkdir -p "${CURRENTPATH}/src"
tar zxf opencore-amr-${VERSION}.tar.gz -C "${CURRENTPATH}/src"
cd "${CURRENTPATH}/src/opencore-amr-${VERSION}"

DEVELOPER=`xcode-select -print-path`
DEST="${CURRENTPATH}/opencore-amr-iphone"
mkdir -p "${DEST}"

ARCHS="i386 armv7 armv7s arm64"  #armv7 armv7s
LIBS="libopencore-amrnb.a libopencore-amrwb.a"

for arch in $ARCHS; do
case $arch in
arm*)

echo "Building opencore-amr for iPhone $arch ****************"
PLATFORM="iPhoneOS"
PATH="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin:$PATH"
SDK="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk"
CC="gcc -arch $arch --sysroot=$SDK" CXX="g++ -arch $arch --sysroot=$SDK" \
LDFLAGS="-Wl,-syslibroot,$SDK" ./configure \
--host=arm-apple-darwin --prefix=$DEST \
--disable-shared #--enable-gcc-armv7
;;
i386)
echo "Building opencore-amr for iPhoneSimulator $arch*****************"
PLATFORM="iPhoneSimulator"
PATH="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin:$PATH"
SDK="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk"
CC="gcc -arch $arch" CXX="g++ -arch $arch" \
./configure \
--prefix=$DEST \
--disable-shared
;;
esac
make -j3 > /dev/null
make install
make clean
for i in $LIBS; do
mv $DEST/lib/$i $DEST/lib/$i.$arch
done
done

for i in $LIBS; do
input=""
for arch in $ARCHS; do
input="$input $DEST/lib/$i.$arch"
done
lipo -create -output $DEST/lib/$i $input
done