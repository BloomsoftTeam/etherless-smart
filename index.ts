#!/usr/bin/env bash
import * as path from 'path';
import * as yargs from 'yargs';
import * as readline from 'readline';

import chalk from 'chalk';
import boxen from 'boxen';

import { EthersManager } from './ethersManager';
import { KeyManager } from './keyManager';

const keyManager = new KeyManager('hdtedx');
const ethers = new EthersManager(keyManager);

const msgInit = chalk.white.bold('Welcome in Etherless! Lets you associate an ETH wallet to Etherless!');

yargs
  .command('init', msgInit, () => { }, (argv) => {
    const boxenOptions = {
      padding: 1,
      margin: 1,
      borderColor: 'green',
      backgroundColor: '#555555',
    };
    const msgBoxInit = boxen(msgInit, boxenOptions);
    console.log(msgBoxInit);
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    rl.question('Do you want to link an existing ETH wallet or create a new one? [link/create] ', (answer1) => {
      switch (answer1.toLowerCase()) {
        case 'l':
        case 'link':
          rl.question('Insert your eth wallet private key: \n', (answer2) => {
            if (ethers.linkEthWallet(answer2)) {
              console.log('wallet ETH associato correttamente');
            } else {
              console.log('Errore nell\'associazione della chiave privata al wallet ETH (magari la chiave inserita non è corretta?)');
            }
            rl.close();
          });
          break;
        case 'c':
        case 'create':
          if (ethers.checkEthWalletExistance()) {
            rl.question('An ETH Wallet is already associated. Do you want to delete it and create a new one? [Yes/no] ', (answer2) => {
              switch (answer2.toLowerCase()) {
                case 'y':
                case 'yes':
                  const myNewWallet = ethers.createNewEthWallet();
                  console.log('A new ethereum wallet is now ready for you!');
                  console.log('Take notes of your newly generated mnemonic so that you can recover your credentials in the future');
                  console.log(`Mnemonic: ${myNewWallet.mnemonic}`);
                  console.log(`Wallet address: ${myNewWallet.address}`);
                  break;
                case 'n':
                case 'no':
                  console.log('operazione annullata con successo');
                  break;
                default:
                  console.log('Invalid answer!');
              }
              rl.close();
            });
          } else {
            rl.close();
            const myNewWallet = ethers.createNewEthWallet();
            console.log('A new ethereum wallet is now ready for you!');
            console.log('Take notes of your newly generated mnemonic so that you can recover your credentials in the future');
            console.log(`Mnemonic: ${myNewWallet.mnemonic}`);
            console.log(`Wallet address: ${myNewWallet.address}`);
          }
          break;
        default:
          console.log('Invalid answer!');
          rl.close();
      }
    });
  })
  .command('logout', 'lets you remove your ETH wallet from etherless', () => { }, (argv) => {
    if (ethers.removeWalletFromFS()) {
      console.log('wallet rimosso con successo');
    } else {
      console.log('non è stato trovato nessun wallet');
    }
  })
  .command('help', 'show a brief description for each command',
    function (yargs) {
      return yargs
        .option('FAQ', {
          alias: 'faq',
          describe: 'display Frequently Asked Questions about Etherless',
          nargs: 0,
        })
        .option('c', {
          alias: 'command',
          describe: 'display help about a specific Etherless command',
          type: 'string',
          nargs: 1,
        })
        .option('a', {
          alias: 'about',
          describe: 'display administrators email for requesting information/help',
          nargs: 0,
        });
    }, (argv) => {
      console.log('comando help eseguito');
      console.log(argv);
    })
  .command('list', 'list all available functions on etherless',
    function (yargs) {
      return yargs
        .option('r', {
          alias: 'recent',
          describe: 'list all recent functions run on etherless',
          nargs: 0,
        })
        .option('o', {
          alias: 'own',
          describe: 'list all functions uploaded by the user',
          nargs: 0,
        })
        .option('h', {
          alias: 'hidden',
          describe: 'list all functions currently unavailable',
          nargs: 0,
        });
    }, (argv) => {
      console.log('comando list eseguito');
      console.log(argv);
    })
  .command('deploy <filePath> <funcName>', 'upload a javascript function to etherless',
    function (yargs) {
      return yargs
        .option('p', {
          alias: 'parameters',
          describe: 'specify every parameter required by the func',
          type: 'array',
        });
    }, (argv) => {
      console.log('comando deploy eseguito');
      console.log(argv);
    })
  .command('run <funcName> [params..]', 'run a javascript function to etherless', () => { }, async (argv) => {
    try {
      // await ethers.loadWalletFromFS();
      // const contractRun = ethers.createContract("").connect(ethers.userWallet);
      const stringParameters = argv.params.join(',');
      console.log(stringParameters);/*
        let sourceCode = "stringa col codice da eseguire";
        contractRun.sendRunEvent(sourceCode, stringParameters);
        contractRun.on("runResult", () => {
            console.log("Ricevuto risultato: ");
            // console.log(runResult.risultato);
        } );
        contractRun.removeAllListeners("runResult");*/
    } catch (e) {
      console.log(e);
    }
  })
  .command('deployContract <contractPath>', 'deploya uno smart contract sulla blockchain', () => { }, async (argv) => {
    try {
      await ethers.loadWalletFromFS();
      ethers.deploySmartContract(path.resolve(__dirname, 'contracts', argv.contractPath));
    } catch (e) {
      console.log(e);
    }
  })
  .command('deployFunc <funcName>', 'deploya una funzione su etherless che verrà beccata dal webhook', () => { }, async (argv) => {
    try {
      await ethers.loadWalletFromFS();
      await ethers.deployFunc(argv.funcName);
    } catch (e) {
      console.log(e);
    }
  })
  /*
.command('run HelloWorld', 'run HelloWorld function', () => {}, async (argv) => {
    try {
        await ethers.loadWalletFromFS();
        const contractAlfred = ethers.createContract("0x7526aaCdf025991e68c6c1196fF581066c491b06")
          .connect(ethers.userWallet);

        // contractAlfred.getGreeting().then(console.log);
        contractAlfred.setGreeting("Alfred saluta ").then(console.log);

        contractAlfred.once("serverSendGreeting", () => {
            console.log("Rosalina ha salutato");
            contractAlfred.removeAllListeners("serverSendGreeting");
        });

    } catch(e) {
        console.log(e);
    }
}) */
  .command('runPoc <funcName> [params..]', 'run a function', () => { }, async (argv) => {
    try {
      await ethers.loadWalletFromFS();

      ethers.loadWalletFromFS()
        .then((success) => {
          if (success) {
            const contractRun = ethers.loadSmartContract('0x6C9a34F5343B15314869b839b1b2e2dC1F8cE016')
              .then((contractRun) => {
                const contractRunSigned = contractRun.connect(ethers.userWallet);

                /* ----- yargs ------ */
                const stringParameters = argv.params.join(',');
                console.log(typeof stringParameters);
                /* ------------------- */

                contractRunSigned.sendRunEvent(argv.funcName, stringParameters).then(console.log);

                contractRunSigned.on('runResult', (fResult) => {
                  console.log('Ricevuto risultato: ');
                  console.log(fResult);
                });
              })
              .catch(console.log);
          }
        })
        .catch(console.log);

      // contractRun.removeAllListeners("runResult");
    } catch (e) {
      console.log(e);
    }
  })
  .help(false)
  .parse();

// ethers.showPrivateKey();

// ethers.loadWalletFromFS()
// .then((success) => {
//     if (success) {
//         const myContract = ethers.loadSmartContract('0x618B96E44f2Cb4c060341FB8A81F4DA36Eb930f6')
//         .then((myContract) => {
//             let signedContract = myContract.connect(ethers.userWallet);
//             console.log(ethers.userWallet.privateKey);
//             signedContract.getGreeting().then(console.log);
//             signedContract.setGreeting("Mestolo").then(console.log);
//         })
//     .catch(console.log);
//     }
// })
// .catch(console.log);
