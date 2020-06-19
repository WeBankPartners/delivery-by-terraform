from qcloud_cos import CosConfig
from qcloud_cos import CosS3Client
import sys
import logging

logging.basicConfig(level=logging.INFO, stream=sys.stdout)

secret_id = '${COS_SECRETID}'      # 替换为用户的 secretId
secret_key = '${COS_SECRETKEY}'      # 替换为用户的 secretKey
region = '${COS_REGION}'     # 替换为用户的 Region
token = None                # 使用临时密钥需要传入 Token，默认为空，可不填
scheme = 'http'            # 指定使用 http/https 协议来访问 COS，默认为 https，可不填
bucket = '${COS_BUCKET}'
download_dir = '${DOWNLOAD_DIR}'

config = CosConfig(Region=region, SecretId=secret_id, SecretKey=secret_key, Token=token, Scheme=scheme)
client = CosS3Client(config)

list_bucket_response = client.list_objects(
    Bucket=bucket
)

for object in list_bucket_response['Contents']:
    file_name = object['Key']
    local_file = '%s/%s'%(download_dir,file_name)

    object_response = client.get_object(
        Bucket=bucket,
        Key=file_name
    )

    logging.info('Saving file %s ...'%(local_file))
    object_response['Body'].get_stream_to_file(local_file)
