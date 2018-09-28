function isMissingTlsBlock(ingress) {
  return !ingress.spec.hasOwnProperty('tls')
}

function formatInfo(ingress) {
  return `${ingress.metadata.namespace} / ${ingress.metadata.name} - Missing TLS Block`
}

module.exports.check = async function check(client) {
  let passed = true;
  let ingresses = await client.apis.extensions.v1beta1.namespaces('').ingresses.get()
  for (let ingress of ingresses.body.items) {

    if (isMissingTlsBlock(ingress)) {
      passed = false;
      console.log(formatInfo(ingress));
    }
  }
  return passed;
}

module.exports.fix = async function fix(client) {
  let ingresses = await client.apis.extensions.v1beta1.namespaces('').ingresses.get()
  let toFix = ingresses.body.items.filter(isMissingTlsBlock)
  for (let ingress of toFix) {
    let spec = ingress.spec;
    let name = ingress.metadata.name;
    let namespace = ingress.metadata.namespace;
    let patch = {
      body: {
        spec: {
          tls: [{
            hosts: [spec.rules[0].host]
          }]
        }
      }
    }

    try {
      let updated = await client.apis.extensions.v1beta1.namespace(
        namespace
      ).ingress(name).patch(
        patch
      )
    } catch (ex) {
      console.dir(ex, { depth: null, color: true });
      break;
    }

  }

}
