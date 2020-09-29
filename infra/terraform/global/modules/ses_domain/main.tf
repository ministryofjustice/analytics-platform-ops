resource "aws_ses_domain_identity" "domain" {
  domain = var.domain
}

# SES Verification: TXT Record
resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = var.aws_route53_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.domain.id}"
  type    = "TXT"
  ttl     = "1800"
  records = [aws_ses_domain_identity.domain.verification_token]
}

resource "aws_ses_domain_identity_verification" "amazonses_verification" {
  domain     = aws_ses_domain_identity.domain.id
  depends_on = [aws_route53_record.amazonses_verification_record]
}

# SES Verification: DKIM
resource "aws_ses_domain_dkim" "domain_verification" {
  domain = aws_ses_domain_identity.domain.domain
}

resource "aws_route53_record" "domain_amazonses_dkim_verification_record" {
  count   = length(aws_ses_domain_dkim.domain_verification.dkim_tokens)
  zone_id = var.aws_route53_zone_id
  name = "${element(
    aws_ses_domain_dkim.domain_verification.dkim_tokens,
    count.index,
  )}._domainkey.${aws_ses_domain_identity.domain.domain}"
  type = "CNAME"
  ttl  = "1800"
  records = ["${element(
    aws_ses_domain_dkim.domain_verification.dkim_tokens,
    count.index,
  )}.dkim.amazonses.com"]
}
