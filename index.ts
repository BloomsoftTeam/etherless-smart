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
    .command('run <funcName> [params..]', 'run a function', () => {}, async (argv) => {
      try {
          await ethers.loadWalletFromFS();
          //const contractRun = ethers.createContract("0x6C9a34F5343B15314869b839b1b2e2dC1F8cE016").connect(ethers.userWallet);//vecchio contratto funzionante
          // contractRun.connect(ethers.userWallet);
          // ethers.createContract("0x38bB51CaAD409943d4dF3A177674B03262C10F98").connect(ethers.userWallet); //per testare
  
          let walletUser = ethers.userWallet; 
          /* ----- yargs ------ */
          let stringParameters = "";
          console.log(stringParameters);
          let paramArray = argv.params;
          let paramJSON ="{";
          for(var i = 0; i<(paramArray.length); i++){
              let j = i + 1;
              paramJSON = paramJSON.concat("'param").concat(j.toString()).concat("': ").concat(paramArray[i]).concat(",");
          }
          paramJSON = paramJSON.substring(0, paramJSON.length-1);
          paramJSON = paramJSON.concat("}");
          console.log(paramJSON);
          console.log(JSON.stringify(paramJSON));
          //let myJSON = JSON.parse(paramJSON);
          //console.log(myJSON);
          for(var i = 0; i<(paramArray.length -1); i++){
              stringParameters = stringParameters.concat(paramArray[i] + ",");
          }
          //perchè dopo l'ultimo parametro non voglio la virgola, parametri in formato (param1,param2,param3) senza parentesi
          stringParameters = stringParameters.concat(paramArray[i]);
          /* ------------------- */
  
          await ethers.loadSmartContract("0x38bB51CaAD409943d4dF3A177674B03262C10F98")
          .then( (contractRun) => {
              contractRun = contractRun.connect(ethers.userWallet);
  
              contractRun.sendRunEvent(argv.funcName , stringParameters).then(console.log).catch(console.log);
  
              //Capire come usare il wallet dell'user nel ritorno
              contractRun.on("runResult", (walletUser, fResult) => {
                  console.log("Ricevuto risultato: ");
                  console.log(fResult);
                  contractRun.removeAllListeners("runResult");
              } );
          }).catch(console.log);
          
      } catch(e) {
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
  .help(false)
  .parse();