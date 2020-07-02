from qcloud_cos import CosConfig
from qcloud_cos import CosS3Client
import sys
import logging
import pathlib

logging.basicConfig(level=logging.INFO, stream=sys.stdout)

_, secret_id, secret_key, region_name, bucket_name, object_keys, download_dir = sys.argv

token = None
scheme = 'http'

config = CosConfig(Region=region_name, SecretId=secret_id, SecretKey=secret_key, Token=token, Scheme=scheme)
client = CosS3Client(config)

for object_key in object_keys.split():
	object_response = client.get_object(
	    Bucket=bucket_name,
	    Key=object_key
	)

	local_file = '%s/%s'%(download_dir, object_key)
	logging.info('Saving file %s ...'%(local_file))
	pathlib.Path(local_file).parent.mkdir(parents=True, exist_ok=True)
	object_response['Body'].get_stream_to_file(local_file)
