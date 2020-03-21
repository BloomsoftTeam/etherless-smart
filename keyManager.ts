import * as path from 'path';
import * as fs from 'fs';

import _sodium = require('libsodium-wrappers');

export class KeyManager {
  readonly credentialsPath = path.resolve(__dirname, '.credentials');
  readonly privatePath;
  readonly magicNumber = 'etlkey';
  private readonly password;

  constructor(password: string) {
    this.privatePath = path.resolve(this.credentialsPath, 'private.key');
    this.password = password;
  }

  encryptKey(data: string, password: string) {
    return new Promise((resolve, reject) => {
      _sodium.ready.then(() => {
        const sodium = _sodium;

        let salt_for_key = sodium.randombytes_buf(sodium.crypto_pwhash_SALTBYTES);
        let salt_for_nonce = sodium.randombytes_buf(sodium.crypto_pwhash_SALTBYTES);

        let key = sodium.crypto_pwhash(sodium.crypto_secretbox_KEYBYTES
          , password
          , salt_for_key
          , sodium.crypto_pwhash_OPSLIMIT_MIN
          , sodium.crypto_pwhash_MEMLIMIT_MIN
          , sodium.crypto_pwhash_ALG_DEFAULT);

        let nonce = sodium.crypto_pwhash(sodium.crypto_secretbox_NONCEBYTES
          , password
          , salt_for_nonce
          , sodium.crypto_pwhash_OPSLIMIT_MIN
          , sodium.crypto_pwhash_MEMLIMIT_MIN
          , sodium.crypto_pwhash_ALG_DEFAULT);

        let cmtext = sodium.crypto_secretbox_easy(data, nonce, key);

        let toSave = this.magicNumber
          + sodium.to_base64(salt_for_key)
          + sodium.to_base64(salt_for_nonce)
          + sodium.to_base64(cmtext);

        resolve(toSave);
      }).catch(reject);
    });
  }

  saveCredentials(privateKey: string) {
    this.encryptKey(privateKey, this.password).then((cipher) => {
      fs.writeFileSync(this.privatePath, cipher);
    }).catch(console.error);
  }

  removeCredentials(): boolean {
    try {
      fs.unlinkSync(this.privatePath);
      return true;
    } catch (err) {
      return false;
    }
  }

  decryptKey() {
    return new Promise((resolve, reject) => {
      _sodium.ready.then(() => {
        const sodium = _sodium;
        const password = this.password;

        let buffer = fs.readFileSync(this.privatePath, 'utf8');
        if (this.magicNumber != buffer.substring(0, this.magicNumber.length)) {
          reject("magicNumber mismatch");
          return;
        }

        // TODO: check length for salt and other things...
        // TODO: offset as const

        try {
          let salt_for_key = sodium.from_base64(buffer.substring(this.magicNumber.length, this.magicNumber.length + 22));
          let salt_for_nonce = sodium.from_base64(buffer.substring(this.magicNumber.length + 22, this.magicNumber.length + 44));
          let cmtext = sodium.from_base64(buffer.substring(this.magicNumber.length + 44, buffer.length));

          let key = sodium.crypto_pwhash(sodium.crypto_secretbox_KEYBYTES
            , password
            , salt_for_key
            , sodium.crypto_pwhash_OPSLIMIT_MIN
            , sodium.crypto_pwhash_MEMLIMIT_MIN
            , sodium.crypto_pwhash_ALG_DEFAULT);

          let nonce = sodium.crypto_pwhash(sodium.crypto_secretbox_NONCEBYTES
            , password
            , salt_for_nonce
            , sodium.crypto_pwhash_OPSLIMIT_MIN
            , sodium.crypto_pwhash_MEMLIMIT_MIN
            , sodium.crypto_pwhash_ALG_DEFAULT);

          let data = sodium.crypto_secretbox_open_easy(cmtext, nonce, key);
          resolve(sodium.to_string(data));
        } catch (e) {
          // handle error
          reject(e);
        }
      }).catch(reject);
    });
  }

}

