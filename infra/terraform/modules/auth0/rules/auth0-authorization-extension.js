/*
 *  This rule is managed by Terraform, DO NOT EDIT!
 */
function (user, context, callback) {
  const connection = user.identities[0].connection;

  if (connection !== 'email') {
    return callback(null, user, context);
  }

  getUserPolicy()
    .then((policy) => {
      user.permissions = policy.permissions;

      if (!user.permissions.includes('view:app')) {
        throw new UnauthorizedError('Access denied.');
      }

      callback(null, user, context);
    })
    .catch((err) => {
      console.log(`Error from Authorization Extension: ${err.error}`);
      callback(new UnauthorizedError(`Authorization Extension: ${err.message}`));
    });

  function getUserPolicy() {
    const rp = require('request-promise');
    const endpoint = `users/${user.user_id}/policy/${context.clientID}`;
    return rp({
      method: 'POST',
      uri: `${configuration.AUTH_EXTENSION_URL}/api/${endpoint}`,
      headers: {
        "x-api-key": configuration.AUTH_EXTENSION_API_KEY
      },
      json: true,
      simple: true,
      body: {
        connectionName: 'email',
        groups: user.groups
      },
      timeout: 5000
    });
  }
}
