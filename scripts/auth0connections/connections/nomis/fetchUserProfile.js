function(accessToken, ctx, cb) {
  var base_url = "{{gateway_url}}";
  var user_endpoint = "{{user_endpoint}}";
  var user_profile_url = base_url + user_endpoint;

  // call oauth2 API with the accesstoken and create the profile
  request.get(
    user_profile_url,
    {
      headers: {
        Authorization: "Bearer " + accessToken
      }
    },
    function(err, resp, body) {
      if (err) {
        cb(err);
        return;
      }
      if (!/^2/.test("" + resp.statusCode)) {
        cb(body);
        return;
      }
      var parsedBody = JSON.parse(body);
      var profile = {
        user_id: parsedBody.staffId,
        nickname: parsedBody.name,
        name: parsedBody.name,
        email: parsedBody.username + "+" + parsedBody.activeCaseLoadId + "@nomis",
        username: parsedBody.username,
        blocked: !parsedBody.active,
        activeCaseLoadId: parsedBody.activeCaseLoadId,
        _nomisAccessToken: accessToken
      };
      cb(null, profile);
    }
  );
}
