output "alb_dns_name" {
  description = "Application Load Balancer DNS"
  value       = aws_lb.vprofile_alb.dns_name
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.vprofile_db.address
}

#output "rabbitmq_endpoint" {
#  description = "Amazon MQ Endpoint"
#  value       = aws_mq_broker.vprofile_mq.instances[0].endpoints[0]
#}

output "memcached_endpoint" {
  description = "ElastiCache Endpoint"
  value       = aws_elasticache_cluster.vprofile_cache.configuration_endpoint
}

output "tomcat_1_private_ip" {
  value = aws_instance.tomcat_1.private_ip
}

output "tomcat_2_private_ip" {
  value = aws_instance.tomcat_2.private_ip
}

output "bastion_public_ip" {
  description = "Public IP of Bastion Host"
  value       = aws_instance.bastion.public_ip
}
