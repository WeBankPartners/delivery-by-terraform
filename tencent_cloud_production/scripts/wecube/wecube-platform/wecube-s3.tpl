version: "2"
services:
  wecube-s3:
    image: ccr.ccs.tencentyun.com/webankpartners/minio
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
      - MINIO_ACCESS_KEY=access_key
      - MINIO_SECRET_KEY=secret_key