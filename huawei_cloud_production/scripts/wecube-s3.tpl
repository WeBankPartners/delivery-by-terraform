version: "2"
services:
  wecube-s3:
    image: swr.ap-southeast-3.myhuaweicloud.com/webankpartners/minio
    restart: always
    command: [
        'server',
        'data'
    ]
    ports:
      - {{S3_PORT}}:9000
    volumes:
      - /data/minio-storage/data:/data    
      - /data/minio-storage/config:/root
      - /etc/localtime:/etc/localtime
    environment:
      - MINIO_ACCESS_KEY={{S3_ACCESS_KEY}}
      - MINIO_SECRET_KEY={{S3_SECRET_KEY}}
