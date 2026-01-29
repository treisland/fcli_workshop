$RETURN_PATH=$PWD
$SOURCE_CODE_PATH=""

#navigate to the source code path
cd $SOURCE_CODE_PATH

#remove previous package file if it exists
rm *.zip

#package the source code
scancentral package

cd $RETURN_PATH