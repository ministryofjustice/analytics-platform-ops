#!/usr/bin/env node

const Client = require('kubernetes-client').Client;
const config = require('kubernetes-client').config;
const program = require('commander');
const chalk = require('chalk');

const client = new Client({ config: config.fromKubeconfig() });

const package = require('./package.json')
const checks = require('./checks')


program
  .version(package.version)
  .option('--all', 'Run all checks [default]')
  .parse(process.argv);

async function main() {
  try {
    await client.loadSpec();
    Object.entries(checks).forEach(async ([key, val]) => {
      process.stdout.write(`starting check: ${key}`);
      let passed = await val.check(client);
      console.log(`${key}: ${passed ? chalk.green('PASS') : chalk.red('FAIL')}`)
    });


  } catch (ex) {
    console.log(ex)
  }
}

main()
