newman run 021_wecube_init_plugin.postman_collection.json -e $1 --delay-request 2000 --verbose  --disable-unicode --reporters cli,htmlextra --reporter-htmlextra-export "newman/plugin_init.html"
