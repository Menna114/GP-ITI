resource "aws_secretsmanager_secret" "mysql_secret" {
  name = "mysql-credentials4"
}

resource "aws_secretsmanager_secret_version" "mysql_secret_version" {
  secret_id     = aws_secretsmanager_secret.mysql_secret.id
  secret_string = jsonencode({
    MYSQL_ROOT_PASSWORD = "yousra"
    hostname = "mysql-service"
    username = "root"
    password = "yousra"
    port     = "3306"
  })
}
