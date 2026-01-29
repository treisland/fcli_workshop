$RETURN_PATH=$PWD
$SOURCE_CODE_PATH="C:\Users\tisland\fortify\test-package\IWA-Java-main"

#navigate to the source code path
cd $SOURCE_CODE_PATH

#remove previous package file if it exists
rm *.zip

#package the source code
scancentral package

cd $RETURN_PATH