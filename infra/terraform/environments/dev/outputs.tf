output "env" {
    value = "${var.env}"
}

output "github_webhooks_secret" {
    value = "${var.gh_hook_secret}"
    sensitive = true
}

output "webhooks_api_url" {
    value = "${module.webhooks_api.url}"
}
