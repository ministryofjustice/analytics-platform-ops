output "ec2_instance_names" {
  value = aws_instance.softnas.*.tags.Name
}

output "ec2_instance_ids" {
  value = aws_instance.softnas.*.id
}

