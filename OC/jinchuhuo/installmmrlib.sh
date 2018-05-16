#!/bin/sh
echo "usage: cmd /Users/zengy/temp/mmrendev"
echo "check MMR_DEV_ROOT env"
env | grep MMR_DEV_ROOT
if [ ! $MMR_DEV_ROOT ]; then
     if [ $1 ] ; then
		if [ -d $1 ]; then
			export MMR_DEV_ROOT=$1
			env | grep MMR_DEV_ROOT
		else
			echo 'alert: MMR_DEV_ROOT not exist, exit'
			exit 1
		fi
     else
         pwd
         echo ' alert: MMR_DEV_ROOT not set,exit '
         exit 1
     fi  
fi  

# 发布到sdk目录
echo ""
echo "发布到sdk目录"
#cd $MMR_DEV_ROOT/sdk
pwd
#rm -R lib/android/*
INSTALLPath="$MMR_DEV_ROOT/sdk"
PROJECTPath="$MMR_DEV_ROOT/ios/jinchuhuo/jinchuhuo"

echo "清理当前库和头文件目录"
rm -r $PROJECTPath/jinchuhuo/Library/include/*
rm -r $PROJECTPath/jinchuhuo/Library/lib/*

echo "发布到ios jinchuhuo目录"
cp -R $MMR_DEV_ROOT/sdk/include/ios/DataTypes/*.h $PROJECTPath/jinchuhuo/Library/include/
cp -R $MMR_DEV_ROOT/sdk/include/ios/Interface/*.h $PROJECTPath/jinchuhuo/Library/include/
cp -R $MMR_DEV_ROOT/sdk/lib/ $PROJECTPath/jinchuhuo/Library/lib/
cp $PROJECTPath/jinchuhuo/Library/lib/Debug-iphoneos/libiOSInterface.a $PROJECTPath/jinchuhuo/Library/lib/
