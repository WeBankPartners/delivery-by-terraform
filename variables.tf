variable "cloud_provider" {
  description = "Specify the public cloud provider used to create resources"
  default     = "TencentCloud"
}

variable "secret_id" {
  description = "Secret id used when connecting to the public cloud provider"
}

variable "secret_key" {
  description = "Secret key used when connecting to the public cloud provider"
}

variable "region" {
  description = "The region of the public cloud where resources are to be created"
  default     = "ap-shanghai"
}

variable "availability_zones" {
  description = "The availability zones in the region where resources are to be created (STANDALONE mode will be used if SINGLE AZ is specified and CLUSTER mode will be used for 2 AZs)"
  type        = list(string)
  default     = [
    "ap-shanghai-2"
  ]
}

variable "wecube_release_version" {
  description = "The WeCube release version on GitHub that we use to determine target versions of specific components to be installed.\nValid options:\n- \"latest\" (latest release version)\n- \"v2.7.1\" (specific release version)\n- \"customized\" (using a customized version spec file)"
#  default     = "latest"
}

variable "wecube_settings" {
  description = "Set of features provided by plugins and best practices desired during installation.\nValid options:\n- \"standard\" (complete plugin installation and configurations)\n- \"bootcamp\" (used for bootcamp tutorial)\n- \"empty\" (no plugin will be installed)\n- \"init\" (base plugin will be installed without configurations)"
}

variable "wecube_home" {
  description = "The installation root directory of WeCube on the host"
  default     = "/data/wecube"
}

variable "wecube_user" {
  description = "The user to run WeCube"
  default     = "root"
}

variable "initial_password" {
  description = "The initial password of root user on hosts and MySQL instances"
  default     = "Wecube@123456"
}

variable "public_key_file" {
  description = "Public key file for ssh login"
  default     = ""#"~/.ssh/id_rsa.pub"
}

variable "default_mysql_port" {
  description = "The listening port of MySQL instances"
  default     = "3307"
}

variable "use_mirror_in_mainland_china" {
  description = "Whether we should mirror sites in Mainland China during WeCube installation"
  type        = bool
  default     = true
}
