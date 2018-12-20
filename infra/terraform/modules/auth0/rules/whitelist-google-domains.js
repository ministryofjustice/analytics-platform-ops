/*
 * This rule is managed by Terraform, DO NOT EDIT!
 */
function (user, context, callback) {
  const allowedDomains = splitByComma(configuration.GOOGLE_DOMAINS);
  const emailParts = user.email.split('@');
  const domain = emailParts[emailParts.length - 1].toLowerCase();

  if (user.identities[0].connection === 'google-oauth2' &&
      !allowedDomains.includes(domain)) {
    return callback(new UnauthorizedError("Access denied."));
  }

  function splitByComma(s) {
    return s.split(/,\s*/).map(c => c.trim());
  }

  return callback(null, user, context);
}
