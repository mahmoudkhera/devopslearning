output "bastion_id" {
  description = "ID of the VPC"
  value       = aws_vpc.bastion_vpc.id
}

output "bastion_route_table" {
    description = "bastion vpc route table id"

    value = aws_route_table.rt_bastion.id
}