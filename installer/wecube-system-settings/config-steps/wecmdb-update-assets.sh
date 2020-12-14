if [ -n "$REGION" ]; then
	echo "No region is given, skipped updating assets."
else
	echo "Updating region data in CMDB..."
	read -d '' SQL_STMT <<-EOF || true
		UPDATE ``data_center``
		   SET ``location`` = 'Region=${REGION}'
		 WHERE ``key_name`` = '${REGION_ASSET_NAME}';
	EOF
	../execute-sql-statements.sh $PLUGIN_DB_HOST $PLUGIN_DB_PORT \
		$PLUGIN_CMDB_DB_NAME $PLUGIN_DB_USERNAME $PLUGIN_DB_PASSWORD \
		"$SQL_STMT"

	echo "Updating availability zone data in CMDB..."
	AZ_ASSET_NAME=(${AZ_ASSET_NAME//,/ })
	AZ=(${AZ//,/ })
	for INDEX in ${!AZ_ASSET_NAME[@]}; do
		read -d '' SQL_STMT <<-EOF || true
			UPDATE ``data_center``
			 SET ``location`` = 'Region=${REGION}'
			WHERE ``key_name`` = '${REGION_ASSET_NAME}';
		EOF
		../execute-sql-statements.sh $PLUGIN_DB_HOST $PLUGIN_DB_PORT \
			$PLUGIN_CMDB_DB_NAME $PLUGIN_DB_USERNAME $PLUGIN_DB_PASSWORD \
			"$SQL_STMT"
	done

	echo "Updating vpc asset data in CMDB..."
	read -d '' SQL_STMT <<-EOF || true
		UPDATE ``network_segment``
		   SET ``vpc_asset_id``            = '${WECUBE_VPC_ASSET_ID}',
			   ``route_table_asset_id``    = '${WECUBE_ROUTE_TABLE_ASSET_ID}',
			   ``security_group_asset_id`` = '${WECUBE_SECURITY_GROUP_ASSET_ID}'
		 WHERE ``name``                    = '${WECUBE_VPC_ASSET_NAME}';
	EOF
	../execute-sql-statements.sh $PLUGIN_DB_HOST $PLUGIN_DB_PORT \
		$PLUGIN_CMDB_DB_NAME $PLUGIN_DB_USERNAME $PLUGIN_DB_PASSWORD \
		"$SQL_STMT"

	echo "Updating subnet asset data in CMDB..."
	WECUBE_SUBNET_ASSET_NAME=(${WECUBE_SUBNET_ASSET_NAME//,/ })
	WECUBE_SUBNET_ASSET_ID=(${WECUBE_SUBNET_ASSET_ID//,/ })
	for INDEX in ${!WECUBE_SUBNET_ASSET_NAME[@]}; do
		read -d '' SQL_STMT <<-EOF || true
			UPDATE ``network_segment``
			   SET ``subnet_asset_id`` = '${WECUBE_SUBNET_ASSET_ID[$INDEX]}'
			 WHERE ``name``            = '${WECUBE_SUBNET_ASSET_NAME[$INDEX]}';
		EOF
		../execute-sql-statements.sh $PLUGIN_DB_HOST $PLUGIN_DB_PORT \
			$PLUGIN_CMDB_DB_NAME $PLUGIN_DB_USERNAME $PLUGIN_DB_PASSWORD \
			"$SQL_STMT"
	done

	echo "Updating host asset data in CMDB..."
	WECUBE_HOST_ASSET_NAME=(${WECUBE_HOST_ASSET_NAME//,/ })
	WECUBE_HOST_ASSET_ID=(${WECUBE_HOST_ASSET_ID//,/ })
	WECUBE_HOST_PRIVATE_IP=(${WECUBE_HOST_PRIVATE_IP//,/ })
	for INDEX in ${!WECUBE_HOST_ASSET_NAME[@]}; do
		read -d '' SQL_STMT <<-EOF || true
			UPDATE ``host_resource_instance``
			   SET ``asset_id``   = '${WECUBE_HOST_ASSET_ID[$INDEX]}',
				   ``ip_address`` = '${WECUBE_HOST_PRIVATE_IP[$INDEX]}'
			 WHERE ``name``       = '${WECUBE_HOST_ASSET_NAME[$INDEX]}';
		EOF
		../execute-sql-statements.sh $PLUGIN_DB_HOST $PLUGIN_DB_PORT \
			$PLUGIN_CMDB_DB_NAME $PLUGIN_DB_USERNAME $PLUGIN_DB_PASSWORD \
			"$SQL_STMT"
	done

	echo "Updating db asset data in CMDB..."
	WECUBE_DB_ASSET_NAME=(${WECUBE_DB_ASSET_NAME//,/ })
	WECUBE_DB_ASSET_ID=(${WECUBE_DB_ASSET_ID//,/ })
	WECUBE_DB_PRIVATE_IP=(${WECUBE_DB_PRIVATE_IP//,/ })
	for INDEX in ${!WECUBE_DB_ASSET_NAME[@]}; do
		read -d '' SQL_STMT <<-EOF || true
			UPDATE ``rdb_resource_instance``
			   SET ``asset_id``   = '${WECUBE_DB_ASSET_ID[$INDEX]}',
				   ``ip_address`` = '${WECUBE_DB_PRIVATE_IP[$INDEX]}'
			 WHERE ``key_name``   = '${WECUBE_DB_ASSET_NAME[$INDEX]}';
		EOF
		../execute-sql-statements.sh $PLUGIN_DB_HOST $PLUGIN_DB_PORT \
			$PLUGIN_CMDB_DB_NAME $PLUGIN_DB_USERNAME $PLUGIN_DB_PASSWORD \
			"$SQL_STMT"
	done

	echo "Updating lb asset data in CMDB..."
	WECUBE_LB_ASSET_NAME=(${WECUBE_LB_ASSET_NAME//,/ })
	WECUBE_LB_ASSET_ID=(${WECUBE_LB_ASSET_ID//,/ })
	WECUBE_LB_PRIVATE_IP=(${WECUBE_LB_PRIVATE_IP//,/ })
	for INDEX in ${!WECUBE_LB_ASSET_NAME[@]}; do
		read -d '' SQL_STMT <<-EOF || true
			UPDATE ``lb_resource_instance``
			   SET ``asset_id``   = '${WECUBE_LB_ASSET_ID[$INDEX]}',
				   ``ip_address`` = '${WECUBE_LB_PRIVATE_IP[$INDEX]}'
			 WHERE ``key_name``   = '${WECUBE_LB_ASSET_NAME[$INDEX]}';
		EOF
		../execute-sql-statements.sh $PLUGIN_DB_HOST $PLUGIN_DB_PORT \
			$PLUGIN_CMDB_DB_NAME $PLUGIN_DB_USERNAME $PLUGIN_DB_PASSWORD \
			"$SQL_STMT"
	done
fi

