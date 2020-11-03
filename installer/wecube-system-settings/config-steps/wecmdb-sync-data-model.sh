echo -e "\nSynchronizing plugin data model from WeCMDB..."
docker run --rm -t \
	-v "$COLLECTION_DIR:$COLLECTION_DIR" \
	postman/newman \
	run "$COLLECTION_DIR/022_wecube_sync_model.postman_collection.json" \
	--env-var "domain=$PUBLIC_DOMAIN" \
	--env-var "username=$DEFAULT_ADMIN_USERNAME" \
	--env-var "password=$DEFAULT_ADMIN_PASSWORD" \
	--env-var "wecube_host=$CORE_HOST" \
	--env-var "plugin_host=$PLUGIN_HOST" \
	--delay-request 2000 --disable-unicode \
	--reporters cli \
	--reporter-cli-no-banner --reporter-cli-no-console
