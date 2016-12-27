Jenkins Install
---------------

Install Jenkins using helm with `config.yml`, *and the release name `analytics`:

`$ helm install -f config.yml kubernetes-charts/jenkins --name analytics`

Create ingress rules to point the domain at the `analytics-jenkins` service created by Helm:
`$ kubectl create -f ingress.yml`
