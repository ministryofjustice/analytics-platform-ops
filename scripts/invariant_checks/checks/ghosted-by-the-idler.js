/* eslint-disable prefer-destructuring */
function isIdled(deployment) {
  return deployment.metadata.labels && deployment.metadata.labels['mojanalytics.xyz/idled'] === 'true';
}

function hasReplicas(deployment) {
  return deployment.spec.replicas > 0;
}

function formatInfo(host) {
  return `${host} not in Unidler`;
}

async function getIngressForDeployment(client, deployment) {
  const selector = deployment.spec.selector.matchLabels;
  return client
    .apis
    .extensions
    .v1beta1
    .namespaces(deployment.metadata.namespace)
    .ingresses.get(
      { qs: { labelSelector: `app=${selector.app}` } },
    );
}

async function hostInUnidlerIngress(deployment, unidlerHosts, client) {
  const deploymentIngress = await getIngressForDeployment(client, deployment);
  if (Object.hasOwnProperty.call(deploymentIngress.body, 'items') && deploymentIngress.body.items.length > 0) {
    const host = deploymentIngress.body.items[0].spec.rules[0].host;
    const hostInUnidler = unidlerHosts.has(host);
    if (!hostInUnidler) {
      console.log(formatInfo(host));
    }
    return hostInUnidler;
  }
  return false;
}

module.exports.check = async function check(client) {
  let passed = true;
  const deployments = await client.apis.apps.v1.namespaces('').deployments.get();
  const unidlerIngress = await client.apis.extensions.v1beta1.namespaces('default').ingress('unidler').get();
  const unidlerHosts = new Set(unidlerIngress.body.spec.rules.map(x => x.host));
  // loop through all deployments with 0 replicas & check if they are in the unidler ingress
  for (const deployment of deployments.body.items) {
    if (
      (isIdled(deployment)
        && !hasReplicas(deployment))
      // eslint-disable-next-line no-await-in-loop
      && !await hostInUnidlerIngress(deployment, unidlerHosts, client)
    ) {
      passed = false;
    }
  }
  return passed;
};

module.exports.fix = async function check(client) {
  const deployments = await client.apis.apps.v1.namespaces('').deployments.get();
  const unidlerIngress = await client.apis.extensions.v1beta1.namespaces('default').ingress('unidler').get();
  const unidlerHosts = new Set(unidlerIngress.body.spec.rules.map(x => x.host));
  // loop through all deployments with 0 replicas & check if they are in the unidler ingress
  for (const deployment of deployments.body.items) {
    const deploymentIngress = await getIngressForDeployment(client, deployment);
    if (
      (isIdled(deployment)
        && !hasReplicas(deployment))
      // eslint-disable-next-line no-await-in-loop
      && !await hostInUnidlerIngress(deployment, unidlerHosts, client)
    ) {
      const host = deploymentIngress.body.items[0].spec.rules[0].host;
      console.log(`Adding ${host} to unidler ingress`);
      const patch = {
        headers: { 'Content-Type': 'application/json-patch+json' },
        body: [
          {
            op: 'add',
            path: '/spec/rules/1',
            value: {
              host,
              http: {
                paths: [
                  {
                    backend: {
                      serviceName: 'unidler',
                      servicePort: 80,
                    },
                  },
                ],
              },
            },
          },
        ],
      };
      // eslint-disable-next-line no-await-in-loop
      await client.apis.extensions.v1beta1.namespaces('default').ingress('unidler').patch(patch);
    }
  }
};
