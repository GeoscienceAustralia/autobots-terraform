output "wwwurl" {
   value = "http://${aws_instance.www.public_dns}"
}