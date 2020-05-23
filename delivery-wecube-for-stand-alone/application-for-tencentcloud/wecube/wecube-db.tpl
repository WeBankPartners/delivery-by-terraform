version: "2"
services:
  mysql-wecube:
    image: ccr.ccs.tencentyun.com/webankpartners/mysql:5.6
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
      - {{WECUBE_HOME}}/installer/wecube/database/platform-core:/docker-entrypoint-initdb.d
      - {{WECUBE_HOME}}/mysql-wecube/data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD={{MYSQL_USER_PASSWORD}}
      - MYSQL_DATABASE=wecube
    ports:
      - 3307:3306

  mysql-auth-server:
    image: ccr.ccs.tencentyun.com/webankpartners/mysql:5.6
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
      - {{WECUBE_HOME}}/installer/wecube/database/auth-server:/docker-entrypoint-initdb.d
      - {{WECUBE_HOME}}/mysql-auth-server/data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD={{MYSQL_USER_PASSWORD}}
      - MYSQL_DATABASE=auth_server
    ports:
      - 3308:3306
