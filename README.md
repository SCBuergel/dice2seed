# dice2seed
Generate entropy for bitcoin (and most other crypto asset) wallets by using a normal 6-sided dice as a source of entropy.

## 1. Usage
1. Make sure that the dice is not biased to any specific output and nobody is observing or recording your dice rolls.
2. Roll the dice exactly 100 times so that you reach entropy of 256 bit.
3. Enter the dice rolls as one long number concatenated as the parameter to this script, e.g.
```
$ . dice2seed.sh 1234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234
your seed is:
39BD194E3B989D612E6ED5BF485BAE130D53F5F532F29585E98ECD298282A5C3
```
You can now use the resulting entropy to create a mnemonic which you can archive or you can use it to create private keys and / or addresses.

## 2. Command line one-liner
You might be in a setting where you are offline, cannot clone this repo and just need a minimal one-liner that you can type on a command line. In that case feel free to use the following:
```
dice1=123456; dice0=$(echo $dice1 | tr 1-6 0-5); echo "obase=16;ibase=6; $dice0" | bc | sed -e 's/.*\(.\{64\}\)$/\1/'
```

In the one-liner, replace `123456` with the result of 100 times throwing the dice. Beware that this is a minimal one-liner without checks. So make sure to enter exactly 100 digits as otherwise your resulting entropy would have too few hex characters. You could also omit the last `sed` part of the one-liner and manually ensure that the output has 64 characters.

## 3. BIP39 mnemonic archiving
The hexadecimal 256 bit entropy can now be used as the input for a BIP39 mnemonic. We can e.g. use libbitcoin's [BX](https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-mnemonic-new):
```
$ bx mnemonic-new 39BD194E3B989D612E6ED5BF485BAE130D53F5F532F29585E98ECD298282A5C3
defy trip fatal jaguar mean rack rifle survey satisfy drift twist champion steel wife state furnace night consider glove olympic oblige donor novel left
```
For production you might want to archive your mnemonic in a secure fashion by using e.g. the [blockplate](https://www.blockplate.com/) and store it in a secure location.

## 4. Using mnemonic
Use the mnemonic and optionally a password to create a seed:
```
$ bx mnemonic-to-seed --language en defy trip fatal jaguar mean rack rifle survey satisfy drift twist champion steel wife state furnace night consider glove olympic oblige donor novel left
ac09fdce665aa86195fd3dba3f3731bb23c7735e31de64569c3b54ad348668bfb4ceefc4758311784510cc4cf3b3c460749a1cd0e61d608689b55b0c4ef72cca
```
If you have a BX version with ICU build enabled then you could also strengthen your seed with a password:
```
$ bx mnemonic-to-seed --language en --passphrase "PASSWORD is not s3cret" defy trip fatal jaguar mean rack rifle survey satisfy drift twist champion steel wife state furnace night consider glove olympic oblige donor novel left
5f048ddf9a3860ff29665980bd27d9f31db4a1678c1fb174cf5107cd3cb415afcf6234c910307fa6a7082af48f1c7802559fdf351d6a3d36a9071ee6a0692823
```
Note that the binaries which are distributed via GitHub do not support ICU and thus you cannot use the password feature. Instead you have to follow the fairly straightforward [build instructions](https://github.com/libbitcoin/libbitcoin-explorer#installation) and then e.g. build via:

```
$ ./install.sh --prefix=/home/me/myprefix --with-icu --build-icu --without-tests --build-boost --build-zmq --disable-shared
```
Adjust `/home/me/myprefix` to a folder in your home directory into which you want to build bx, e.g. `/User/Sebastian/libbitcoin`.
You can then copy the resulting binary `bx` into some location that is on your PATH, e.g.:
```
$ cp libbitcoin/bin/bx /usr/local/bin/
```

### 4.1 HD master privat and public key from seed
Use the seed to create a master private key `m`:
```
$ bx hd-new ac09fdce665aa86195fd3dba3f3731bb23c7735e31de64569c3b54ad348668bfb4ceefc4758311784510cc4cf3b3c460749a1cd0e61d608689b55b0c4ef72cca
xprv9s21ZrQH143K3L2duGWeQ6e3PA6fJLDrkRkbsaxZyAb8ung1sUb2UJmgDPKxgFQeZcxosJvGL2m1hjmqZqQKCAxJsa9g1k5rxE8h7aXxaEs
```

A corresponding master public key `M` can be derived from this this master private key:
```
$ bx hd-to-public xprv9s21ZrQH143K3L2duGWeQ6e3PA6fJLDrkRkbsaxZyAb8ung1sUb2UJmgDPKxgFQeZcxosJvGL2m1hjmqZqQKCAxJsa9g1k5rxE8h7aXxaEs
xpub661MyMwAqRbcFp771J3emEamwBw9hnwi7egCfyNBXW87nb1AR1uH276A4diYRTiduo7y67kd8U8X2KQKsjNVCC9Z2U5YF6kCKppkTL4oQAq
```

#### 4.1.1 Derive child keys from HD private keys
The master private key `m` can be used to derive a hardened (omit the `-d` for not-harneded key) child private key `m/0H`:
```
$ bx hd-private -d -i 0 xprv9s21ZrQH143K3L2duGWeQ6e3PA6fJLDrkRkbsaxZyAb8ung1sUb2UJmgDPKxgFQeZcxosJvGL2m1hjmqZqQKCAxJsa9g1k5rxE8h7aXxaEs
xprv9uqh6TbyfqnVC2uhh5BRFK9iZBCutjL16Py968XMyfNjteHkDqggpFaFV3Kc8j2rLqBCi94Por8fie86Y4LYThbL9eax4wqm6vEuk1EGUE8
```

The corresponding public key `M/0H` can be generated from the derived private key :
```
$ bx hd-to-public xprv9uqh6TbyfqnVC2uhh5BRFK9iZBCutjL16Py968XMyfNjteHkDqggpFaFV3Kc8j2rLqBCi94Por8fie86Y4LYThbL9eax4wqm6vEuk1EGUE8
xpub68q3Vy8sWDLnQWzAo6iRcT6T7D3QJC3rTctjtWvyXzuimSctmNzwN3tjLKFc96cYUt8aHPD9Sgb1dfNfLAfJSTev1PTQ8fXmkH8H1DLkdRH
```

Alternatively, the public key can be obtained directly from the master private key:
```
$ bx hd-public -d -i 0 xprv9s21ZrQH143K3L2duGWeQ6e3PA6fJLDrkRkbsaxZyAb8ung1sUb2UJmgDPKxgFQeZcxosJvGL2m1hjmqZqQKCAxJsa9g1k5rxE8h7aXxaEs
xpub68q3Vy8sWDLnQWzAo6iRcT6T7D3QJC3rTctjtWvyXzuimSctmNzwN3tjLKFc96cYUt8aHPD9Sgb1dfNfLAfJSTev1PTQ8fXmkH8H1DLkdRH
```

The non-hardneded child public `M/0` key can also be directly obtained from the master public key `M`:
```
$ bx hd-public -i 0 xpub661MyMwAqRbcFp771J3emEamwBw9hnwi7egCfyNBXW87nb1AR1uH276A4diYRTiduo7y67kd8U8X2KQKsjNVCC9Z2U5YF6kCKppkTL4oQAq
xpub68q3Vy8jAYopGGGdjk8ysAjUYg5wWmHB32SgMXWEvQvmD3s7aiUQvkN1XxwqVaDdUSNmHJVzUPx3vtWkSs6VAsr6cR2c391xcBhsAiEsESr
```
Note that the child public key derivation from parent public keys only works for non-hardened child public keys.

The above key `M/0` is identically to first deriving an intermediate private key `m/0` and then from there deriving the corresponding public key `M/0`:
```
$ bx hd-private -i 0 xprv9s21ZrQH143K3L2duGWeQ6e3PA6fJLDrkRkbsaxZyAb8ung1sUb2UJmgDPKxgFQeZcxosJvGL2m1hjmqZqQKCAxJsa9g1k5rxE8h7aXxaEs | bx hd-to-public
xpub68q3Vy8jAYopGGGdjk8ysAjUYg5wWmHB32SgMXWEvQvmD3s7aiUQvkN1XxwqVaDdUSNmHJVzUPx3vtWkSs6VAsr6cR2c391xcBhsAiEsESr
```

Further child private keys can now be created from a parent private key. The corresponding public keys can be generated in the same fashion as above for the master public key. E.g. the master private key `m/OH` can be used to generate the following child private keys.

##### 4.1.1.1 m/OH -> m/OH/0H
```
$ bx hd-private -d -i 0 xprv9s21ZrQH143K3L2duGWeQ6e3PA6fJLDrkRkbsaxZyAb8ung1sUb2UJmgDPKxgFQeZcxosJvGL2m1hjmqZqQKCAxJsa9g1k5rxE8h7aXxaEs
xprv9uqh6TbyfqnVC2uhh5BRFK9iZBCutjL16Py968XMyfNjteHkDqggpFaFV3Kc8j2rLqBCi94Por8fie86Y4LYThbL9eax4wqm6vEuk1EGUE8
```

##### 4.1.1.2 m/OH -> m/OH/1H
```
$ bx hd-private -d -i 1 xprv9s21ZrQH143K3L2duGWeQ6e3PA6fJLDrkRkbsaxZyAb8ung1sUb2UJmgDPKxgFQeZcxosJvGL2m1hjmqZqQKCAxJsa9g1k5rxE8h7aXxaEs
xprv9uqh6TbyfqnVEuRZrztE6JYdpDd4uPuwZuVbyg8bVxCxeaNkueX3eTq4ncRejJb6QDxTyAJGH9C7GreDDdih64DUTN3w428G12fWRZR6x5T
```

##### 4.1.1.3 m/OH -> m/OH/1
```
$ bx hd-private -i 1 xprv9s21ZrQH143K3L2duGWeQ6e3PA6fJLDrkRkbsaxZyAb8ung1sUb2UJmgDPKxgFQeZcxosJvGL2m1hjmqZqQKCAxJsa9g1k5rxE8h7aXxaEs
xprv9uqh6TbqLBFX52NsmdVNcqixjS6tzKzzHeZ6jDgj5TWS8reJ85PnL9BYVMjFeh8vmMmsaeB5M4pS4cHxfUeBJzFCWzg44kZk6mPC4Wfbo7i
```

##### 4.1.1.3 m/OH/1 -> m/OH/1/12345
```
$ bx hd-private -i 12345 xprv9uqh6TbqLBFX52NsmdVNcqixjS6tzKzzHeZ6jDgj5TWS8reJ85PnL9BYVMjFeh8vmMmsaeB5M4pS4cHxfUeBJzFCWzg44kZk6mPC4Wfbo7i
xprv9xJ8KhM7YZhR8qdz769c2bUG29WbgSQeSn2dTRhGtbHMKNRzBMRkCzwzUVUqQn2WEn7yR8SNe45EvNfRgHbXwqDeeSeQztJSHKTcC8wBqav
```

#### 4.1.2 Derive child public keys from HD public keys
Further child public keys can now be created from a parent public key. Note that the hardened public keys can only be derived from a parent private key. E.g. the master public key `m/OH` can be used to generate the following child public keys.

##### 4.1.2.1 m/OH -> m/OH/1
```
$ bx hd-public -i 1 xprv9s21ZrQH143K3L2duGWeQ6e3PA6fJLDrkRkbsaxZyAb8ung1sUb2UJmgDPKxgFQeZcxosJvGL2m1hjmqZqQKCAxJsa9g1k5rxE8h7aXxaEs
xpub68q3Vy8jAYopHWTLsf2NyyfhHTwPPniqesUhXc6Ldo3R1eySfci2swW2LcipbUVoM6H2PsWWMN4YTAuxLz6H4ofomdk3NwqNCteGPkpSQo3
```
Note that this key is the same that can also be obtained from the corresponding private key:
```
$ bx hd-to-public xprv9uqh6TbqLBFX52NsmdVNcqixjS6tzKzzHeZ6jDgj5TWS8reJ85PnL9BYVMjFeh8vmMmsaeB5M4pS4cHxfUeBJzFCWzg44kZk6mPC4Wfbo7i
xpub68q3Vy8jAYopHWTLsf2NyyfhHTwPPniqesUhXc6Ldo3R1eySfci2swW2LcipbUVoM6H2PsWWMN4YTAuxLz6H4ofomdk3NwqNCteGPkpSQo3
```

##### 4.1.2.2 m/OH/1 -> m/OH/1/12345
```
$ bx hd-public -i 12345 xpub68q3Vy8jAYopHWTLsf2NyyfhHTwPPniqesUhXc6Ldo3R1eySfci2swW2LcipbUVoM6H2PsWWMN4YTAuxLz6H4ofomdk3NwqNCteGPkpSQo3
xpub6BHUjCt1NwFiMKiTD7gcPjQzaBM65u8VozxEFp6tSvpLCAm8itjzkoGUKkTumk1dth1TfD2XFkqjCnEfFU7t4abAK6Lz1wF4ttPe1Q9Xpnx
```
Note that this key is the same that can also be obtained from the corresponding private key:
```
$ bx hd-to-public xprv9xJ8KhM7YZhR8qdz769c2bUG29WbgSQeSn2dTRhGtbHMKNRzBMRkCzwzUVUqQn2WEn7yR8SNe45EvNfRgHbXwqDeeSeQztJSHKTcC8wBqav
xpub6BHUjCt1NwFiMKiTD7gcPjQzaBM65u8VozxEFp6tSvpLCAm8itjzkoGUKkTumk1dth1TfD2XFkqjCnEfFU7t4abAK6Lz1wF4ttPe1Q9Xpnx
```

### 4.2 EC keys from HD keys
The derived child private key can be turned into an EC (elliptic curve) private key (here we are using `m/0H`) via
```
$ bx hd-to-ec xprv9uqh6TbyfqnVC2uhh5BRFK9iZBCutjL16Py968XMyfNjteHkDqggpFaFV3Kc8j2rLqBCi94Por8fie86Y4LYThbL9eax4wqm6vEuk1EGUE8
05492bb25dc620ba3bae9d5f7d18344152f6ea3e2e5f1315bc98b60ac7e2e1cd
```

Generate an EC compressed public key from the EC private key (add -u to generate an uncompressed public key from which later also a (different!) uncompressed address can be generated in the same way):
```
$ bx ec-to-public 05492bb25dc620ba3bae9d5f7d18344152f6ea3e2e5f1315bc98b60ac7e2e1cd
027be3a3581a5cd52c584871344c8fe57cf4cb356f3b635004ae29bcc8e7d805bd
```

Alternatively, the EC compressed public key can also be obtained from the `m/0H` extended public key:
```
$ bx hd-to-ec xpub68q3Vy8sWDLnQWzAo6iRcT6T7D3QJC3rTctjtWvyXzuimSctmNzwN3tjLKFc96cYUt8aHPD9Sgb1dfNfLAfJSTev1PTQ8fXmkH8H1DLkdRH
027be3a3581a5cd52c584871344c8fe57cf4cb356f3b635004ae29bcc8e7d805bd
```

#### 4.2.1 The short way from EC public key to address

Turn the EC compressed public key directly into the address:
```
$ bx ec-to-address 027be3a3581a5cd52c584871344c8fe57cf4cb356f3b635004ae29bcc8e7d805bd
1DbtUySeX4oP8Z1BSej3VC29xF6bX35o96
```

#### 4.2.2 The long way from EC public key to address (but you understand what is going on!)
(Following the [libbitcoin tutorial](https://github.com/libbitcoin/libbitcoin-explorer/wiki/Payment-Address-Deconstruction))

1. Perform SHA-256 hashing on the public key.
```
$ bx sha256 027be3a3581a5cd52c584871344c8fe57cf4cb356f3b635004ae29bcc8e7d805bd
267021ce9d2c790cac024c80345141df2a76fef8be35523c5fa6dd60039afaef
```
2. Perform RIPEMD-160 hashing on the result of SHA-256.
```
$ bx ripemd160 267021ce9d2c790cac024c80345141df2a76fef8be35523c5fa6dd60039afaef
8a3aa09ad02fafea9324d027820b5e060bec19d1
```
3. Add version byte in front of RIPEMD-160 hash (0x00 for Main Network).
```
$ echo 008a3aa09ad02fafea9324d027820b5e060bec19d1
0024d25ddafa2b707fbcd2981679e1060c0ca3e1f4
```
4. Perform SHA-256 hash on the extended RIPEMD-160 result.
```
$ bx sha256 008a3aa09ad02fafea9324d027820b5e060bec19d1
50d44b28d34a1337e40c21111e870d082dfdbdf49f1d8d1b04dfee9d5e669780
```
5. Perform SHA-256 hash on the result of the previous SHA-256 hash.
```
$ bx sha256 50d44b28d34a1337e40c21111e870d082dfdbdf49f1d8d1b04dfee9d5e669780
1c774ecda2078a7c02dc3ff689ca685237028ce5ee4a905cc341f6ac4aa41353
```
6. Take the first 4 bytes (first 8 hex characters) of the second SHA-256 hash. This is the address checksum. Add the 4 checksum bytes at the end of extended RIPEMD-160 hash from stage 3. This is the 25-byte binary Bitcoin Address.
```
$ echo 008a3aa09ad02fafea9324d027820b5e060bec19d11c774ecd
008a3aa09ad02fafea9324d027820b5e060bec19d11c774ecd
```
7. Convert the result from a byte string into a base58 string using Base58Check encoding. This is the most commonly used Bitcoin Address format.
```
$ bx base58-encode 008a3aa09ad02fafea9324d027820b5e060bec19d11c774ecd
1DbtUySeX4oP8Z1BSej3VC29xF6bX35o96
```
Note that this is exactly the same address that was derived with the higher-level command `bx ec-to-address` in the shorter way above.

# 5. From dice to address in on go
All of the above comments can be concatenated in the following form to obtain the address at the standard derivation path `m/44'/0'/0'/0/0`:
```
$ dice1=1234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234; dice0=$(echo $dice1 | tr 1-6 0-5); echo "obase=16;ibase=6; $dice0" | bc | sed -e 's/.*\(.\{64\}\)$/\1/' | bx mnemonic-new | bx mnemonic-to-seed --language en | bx hd-new | bx hd-private -d -i 44 | bx hd-private -d -i 0 | bx hd-private -d -i 0 | bx hd-private -i 0 | bx hd-private -i 0 | bx hd-to-ec | bx ec-to-public | bx ec-to-address
1FwAening1vyxwjn1SX2eQ2NTu2NapEAfp
```

This address can be confirmed by [online tools](https://iancoleman.io/bip39/) or the BIP39 mnemonic can be imported in wallets like [Electrum](https://electrum.org) to sign transactions from that address and broadcast them.