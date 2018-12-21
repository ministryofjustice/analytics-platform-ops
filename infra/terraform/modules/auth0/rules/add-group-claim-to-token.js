/*
 * This rule is managed by Terraform, DO NOT EDIT!
 */
function (user, context, callback) {
  const githubIdentity = _.find(user.identities, {connection: 'github'});
  const targeted_clients = [
    configuration.KUBECTL_OIDC_CLIENT_ID,
  ];

  if (!githubIdentity || !targeted_clients.includes(context.clientID)) {
    return callback(null, user, context);
  }

  fetchTeams(githubIdentity.access_token)
    .then(teams => {
      context.idToken[claim('groups')] = teams.map(t => t.slug);
    })
    .catch(err => {
      return callback(new Error(`Error retrieving teams from Github: ${error}`));
    });

  function fetchTeams(accessToken) {
    const request = require('request-promise');
    return request({
      uri: "https://api.github.com/user/teams",
      headers: {
        "Authorization": `token ${accessToken}`,
        "User-Agent": "request",
      },
      json: true,
    });
  }

  // For custom claims, you must define a namespace for oidc compliance.
  // See https://auth0.com/docs/api-auth/tutorials/adoption/scope-custom-claims
  function claim(s) {
    return `${configuration.OIDC_CLAIMS_NAMESPACE}${s}`;
  }

  return callback(null, user, context);
}
