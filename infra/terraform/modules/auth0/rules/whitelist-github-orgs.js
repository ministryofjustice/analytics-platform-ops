/*
 * This rule is managed by Terraform, DO NOT EDIT!
 */
function (user, context, callback) {
  const githubIdentity = _.find(user.identities, { connection: "github" });
  const authorizedOrgs = splitByComma(configuration.GITHUB_ORGS);

  if (githubIdentity) {
    fetchOrgs(githubIdentity.access_token)
      .then(orgs => {
        if (orgs.some(org => authorizedOrgs.includes(org.login))) {
          return callback(null, user, context);
        }
        return callback(new UnauthorizedError("Access denied."));
      })
      .catch(err => {
        return callback(new Error(`Error retrieving orgs from Github: ${err}`));
      });

  } else {
    return callback(null, user, context);
  }

  function fetchOrgs(accessToken) {
    const request = require('request-promise');
    return request({
      uri: "https://api.github.com/user/orgs",
      headers: {
        "Authorization": `token ${accessToken}`,
        "User-Agent": "request",
      },
      json: true
    });
  }

  function splitByComma(s) {
    return s.split(/,\s*/).map(c => c.trim());
  }
}
