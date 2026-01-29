$APP_NAME=""
$RELEASE_NAME=""
$OWNER_NAME=""
$FULL_APP_RELEASE_NAME=$APP_NAME + ":" + $RELEASE_NAME

fcli fod release create $FULL_APP_RELEASE_NAME --auto-required-attrs --app-type Web --status Development --app-criticality High --app-owner $OWNER_NAME --store release
