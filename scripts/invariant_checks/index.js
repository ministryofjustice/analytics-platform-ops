#!/usr/bin/env node

const { Client, config } = require('kubernetes-client');
const program = require('commander');
const chalk = require('chalk');

const client = new Client({ config: config.fromKubeconfig() });

const packageSpec = require('./package.json');
const checks = require('./checks');


program
  .version(packageSpec.version)
  .option('--all', 'Run all checks [default]')
  .option('-f, --fix', 'autofix any failed checks')
  .parse(process.argv);

async function main() {
  try {
    await client.loadSpec();
    Object.entries(checks).forEach(async ([key, val]) => {
      console.log(`🔎 starting check: ${key}`);
      const passed = await val.check(client);
      console.log(`▶ ${key}: \t${passed ? chalk.green('✅ PASS') : chalk.red('❎ FAIL')}`);
      if (program.fix && !passed && val.fix) {
        console.log(`🛠 FIXING: ${key}`);
        val.fix(client);
      }
    });
  } catch (ex) {
    console.log(ex);
  }
}

main();
