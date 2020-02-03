version: "2"
services:
  mysql-wecube:
    image: mysql:5.6
    restart: always
    command:
      [
        "--character-set-server=utf8mb4",
        "--collation-server=utf8mb4_unicode_ci",
        "--default-time-zone=+8:00",
        "--max_allowed_packet=4M",
        "--lower_case_table_names=1",
      ]
    volumes:
      - /etc/localtime:/etc/localtime
      - "/root/application/wecube/database/platform-core/:/docker-entrypoint-initdb.d/"
    environment:
      - MYSQL_ROOT_PASSWORD={{MYSQL_USER_PASSWORD}}
      - MYSQL_DATABASE=wecube
    ports:
      - 3307:3306

  mysql-auth-server:
    image: mysql:5.6
    restart: always
    command:
      [
        "--character-set-server=utf8mb4",
        "--collation-server=utf8mb4_unicode_ci",
        "--default-time-zone=+8:00",
        "--max_allowed_packet=4M",
        "--lower_case_table_names=1",
      ]
    volumes:
      - /etc/localtime:/etc/localtime
      - "/root/application/wecube/database/auth-server/:/docker-entrypoint-initdb.d/"
    environment:
      - MYSQL_ROOT_PASSWORD={{MYSQL_USER_PASSWORD}}
      - MYSQL_DATABASE=auth_server
    ports:
      - 3308:3306
