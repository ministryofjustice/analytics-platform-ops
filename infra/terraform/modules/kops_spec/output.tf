output "kops_spec" {
  value = "${data.template_file.kops.rendered}"
}
