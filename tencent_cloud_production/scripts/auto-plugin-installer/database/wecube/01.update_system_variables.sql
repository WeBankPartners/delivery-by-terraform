SET NAMES utf8 ;

update `wecube`.`system_variables` set value = 'http://10.40.200.3:20000' where name ='CMDB_URL';

update `wecube`.`system_variables` set value = 'http://10.40.200.3:20002' where name ='SALTSTACK_SERVER_URL';

update `wecube`.`system_variables` set value = 'http://10.40.200.2:9000/wecube-agent/node_exporter_v2.1.tar.gz' where name ='HOST_EXPORTER_S3_PATH';

update `wecube`.`plugin_configs` set status = 'ENABLED' where register_name !='';