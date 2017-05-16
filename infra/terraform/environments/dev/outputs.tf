output "env" {
    value = "${var.env}"
}

output "github_webhooks_secret" {
    value = "${var.gh_hook_secret}"
    sensitive = true
}

output "api_url" {
    value = "${module.data_access.api_url}"
}
