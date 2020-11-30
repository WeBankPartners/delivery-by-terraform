echo -e "\nSimplifying system menu for bootcamp..."

read -d '' SQL_STMT <<-EOF || true
	DELETE FROM ``plugin_package_menus``
	      WHERE ``code`` IN (
	            'MENU_IDC_PLANNING_DESIGN',
	            'MENU_IDC_RESOURCE_PLANNING',
	            'MENU_APPLICATION_ARCHITECTURE_DESIGN',
	            'MENU_APPLICATION_ARCHITECTURE_QUERY',
	            'MENU_APPLICATION_DEPLOYMENT_DESIGN'
	        );
EOF
../execute-sql-statements.sh $CORE_DB_HOST $CORE_DB_PORT \
	$CORE_DB_NAME $CORE_DB_USERNAME $CORE_DB_PASSWORD \
	"$SQL_STMT"
