resource "aws_elasticache_subnet_group" "vprofile_cache_subnet_group" {
  name = "${var.project_name}-cache-subnet-group"

  subnet_ids = [
    aws_subnet.private_backend_subnet_1.id,
    aws_subnet.private_backend_subnet_2.id
  ]

  tags = {
    Name = "${var.project_name}-cache-subnet-group"
  }
}

resource "aws_elasticache_cluster" "vprofile_cache" {
  cluster_id      = "vprofile-cache"
  engine          = "memcached"
  engine_version  = "1.6.22"
  node_type       = "cache.t3.micro"
  num_cache_nodes = 1
  port            = 11211

  subnet_group_name = aws_elasticache_subnet_group.vprofile_cache_subnet_group.name
  security_group_ids = [
    aws_security_group.cache_sg.id
  ]

  tags = {
    Name = "${var.project_name}-cache"
  }
}
