newman run 022_wecube_sync_model.postman_collection.json -e $1 --disable-unicode --reporters cli,htmlextra --reporter-htmlextra-export "newman/sync_model.html"
