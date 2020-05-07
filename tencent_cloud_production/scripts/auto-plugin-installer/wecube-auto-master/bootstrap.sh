sh init_wecube.sh target.postman_environment.json
echo "Registing plugins..."
sh register_plugins.sh  target.postman_environment.json plugin_packages.csv

sh sync_data_model.sh target.postman_environment.json
sh init_plugin.sh target.postman_environment.json
sh import_workflow.sh target.postman_environment.json data/workflows.csv
sh init_service_mgmt.sh target.postman_environment.json data/service_mgnt_init.csv
sh raise_service_mgmt_request.sh target.postman_environment.json data/service_mgnt_request.csv