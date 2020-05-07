# WeCube Auto

WeCube auto contains scripts to register/setup WeCube plugins

## Usage

- Prepare running env
  - npm install -g newman
  - npm install -g newman-reporter-htmlextra
- Update target.postman_environment.json to setup WeCube environment
  - variable "domain","wecube_host","plugin_host" need to be updated according to the target WeCube platform env,
- Prepare your plugin packages, and update plugin_packages.csv with proper package paths.
- Start auto script with boostrap.sh
  - sh bootstrap.sh
