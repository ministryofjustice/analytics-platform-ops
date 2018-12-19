/*
 * This rule is managed by Terraform, DO NOT EDIT!
 */
function (user, context, callback) {
  var request = require('request');

  var whitelist = ['moj-analytical-services']; // authorized github orgs

  // Apply to 'github' connections only
  var github_identity = _.find(user.identities, { connection: 'github' });
  if (github_identity) {
    var access_token = github_identity.access_token;

    request({
      url: 'https://api.github.com/user/orgs',
      headers: {
          'Authorization': 'token ' + access_token,
          'User-Agent': 'request'
      }
    }, function (err, resp, body) {

      if (resp.statusCode !== 200) {
        return callback(new Error('Error retrieving orgs from github: ' + body || err));
      }

      var user_orgs = JSON.parse(body).map(function(org){
        return org.login;
      });

      var authorized = whitelist.some(function(org){
        return user_orgs.indexOf(org) !== -1;
      });

      if (authorized) {
        return callback(null, user, context);
      } else {
        return callback(new UnauthorizedError('Access denied.'));
      }

    });

  } else {
    callback(null, user, context);
  }
}
