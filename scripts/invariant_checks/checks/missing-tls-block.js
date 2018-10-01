function isMissingTlsBlock(ingress) {
  return !Object.prototype.hasOwnProperty.call(ingress.spec, 'tls');
}

function formatInfo(ingress) {
  return `${ingress.metadata.namespace} / ${ingress.metadata.name} - Missing TLS Block`;
}

module.exports.check = async function check(client) {
  let passed = true;
  const ingresses = await client.apis.extensions.v1beta1.namespaces('').ingresses.get();
  for (const ingress of ingresses.body.items) {
    if (isMissingTlsBlock(ingress)) {
      passed = false;
      console.log(formatInfo(ingress));
    }
  }
  return passed;
};

module.exports.fix = async function fix(client) {
  const ingresses = await client.apis.extensions.v1beta1.namespaces('').ingresses.get();
  const toFix = ingresses.body.items.filter(isMissingTlsBlock);
  for (const ingress of toFix) {
    const { spec, metadata: { namespace, name } } = ingress;
    const patch = {
      body: {
        spec: {
          tls: [{
            hosts: [spec.rules[0].host],
          }],
        },
      },
    };

    try {
      // eslint-disable-next-line no-await-in-loop
      await client.apis.extensions.v1beta1.namespace(
        namespace,
      ).ingress(name).patch(
        patch,
      );
    } catch (ex) {
      console.dir(ex, { depth: null, color: true });
      break;
    }
  }
};
