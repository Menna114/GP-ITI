resource "aws_secretsmanager_secret" "redis_secret" {
  name = "redis-credentials5"
}

resource "aws_secretsmanager_secret_version" "redis_secret_version" {
  secret_id     = aws_secretsmanager_secret.redis_secret.id
  secret_string = jsonencode({
    hostname = "redis-service"
    port     = "6379"
  })
}
