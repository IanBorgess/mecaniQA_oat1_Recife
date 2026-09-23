# Terraform variables - override defaults here
api_image           = "my-corretto-app:optimized"
mysql_image         = "mysql:8.0"
redis_image         = "redis:7-alpine"
api_port            = 8080
mysql_port          = 3306
redis_port          = 6379
mysql_root_password = "rootpassword"
mysql_database      = "myapp"
mysql_user          = "appuser"
mysql_password      = "apppassword"
