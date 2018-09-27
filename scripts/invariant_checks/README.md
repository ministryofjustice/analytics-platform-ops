# Invariant Checker

This is a simple framework for checking if things are fishy with the cluster.

Initially there is only one check. If there are any deployments marked as
"idled" that have > 0 replicas.

Examples of things we can add in future:

* user's url is in unidler but not in the tls block
* user is running old version of rstudio / jupyter
* resources left in cluster for users that have left
* pod iam annotations match iam ns annotations

## Usage

`cd` to this directory and run the following:

```bash
$ npm install
$ node ./index.js
```

## Adding new checks

1. Create a `.js` file in `invariant_checks/checks/`
2. Export a function called check, this will take a `kubernetes client` as a
   parameter and return true or false to indicate the check passed.
3. Add it to the `checks/index.js` exports so that the runner can find it.


## TODOS
* Make it possible to run a single check
* Allow checks to expose a `fix` function that is called automatically if the
  check fails. (if `--fix` paramater is pased to the runner)
* Make it possible to run in the cluster (currently the client expects a
  `.kubeconfig` file)