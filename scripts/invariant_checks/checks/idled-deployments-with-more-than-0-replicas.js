function isIdled(deployment) {
  return deployment.metadata.labels && deployment.metadata.labels['mojanalytics.xyz/idled'] === 'true';
}

function hasReplicas(deployment) {
  return deployment.spec.replicas > 0;
}

function formatInfo(deployment) {
  return `${deployment.metadata.namespace} / ${deployment.metadata.name} - Replicas: ${deployment.spec.replicas}`;
}

module.exports.check = async function check(client) {
  let passed = true;
  const deployments = await client.apis.apps.v1.namespaces('').deployments.get();

  for (const deployment of deployments.body.items) {
    if (isIdled(deployment) && hasReplicas(deployment)) {
      passed = false;
      console.log(formatInfo(deployment));
    }
  }
  return passed;
};
