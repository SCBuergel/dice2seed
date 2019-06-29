# dice2seed
Generate entropy for bitcoin (and most other crypto asset) wallets by using a normal 6-sided dice as a source of entropy.

## Usage
1. Make sure that the dice is not biased to any specific output and nobody is observing or recording your dice rolls.
2. Roll the dice exactly 100 times so that you reach entropy of 256 bit.
3. Enter the dice rolls as one long number concatenated as the parameter to this script, e.g.
```
$ . dice2seed.sh 1234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234
your seed is:
39BD194E3B989D612E6ED5BF485BAE130D53F5F532F29585E98ECD298282A5C3
```
You can now use the resulting entropy to create a mnemonic which you can archive or you can use it to create private keys and / or addresses.

## Command line one-liner
You might be in a setting where you are offline, cannot clone this repo and just need a minimal one-liner that you can type on a command line. In that case feel free to use the following:
```
dice1=123456; dice0=$(echo $dice1 | tr 1-6 0-5); echo "obase=16;ibase=6; $dice0" | bc | sed -e 's/.*\(.\{64\}\)$/\1/'
```

In the one-liner, replace `123456` with the result of 100 times throwing the dice. Beware that this is a minimal one-liner without checks. So make sure to enter exactly 100 digits as otherwise your resulting entropy would have too few hex characters. You could also omit the last `sed` part of the one-liner and manually ensure that the output has 64 characters.

## BIP39 mnemonic archiving
The hexadecimal 256 bit entropy can now be used as the input for a BIP39 mnemonic. We can e.g. use libbitcoin's [BX](https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-mnemonic-new):
```
$ bx mnemonic-new 39BD194E3B989D612E6ED5BF485BAE130D53F5F532F29585E98ECD298282A5C3
defy trip fatal jaguar mean rack rifle survey satisfy drift twist champion steel wife state furnace night consider glove olympic oblige donor novel left
```
For production you might want to archive your mnemonic in a secure fashion by using e.g. the [blockplate](https://www.blockplate.com/) and store it in a secure location.

## Using mnemonic
1. Use the mnemonic and optionally a password to create a seed:
```
$ bx mnemonic-to-seed --language en burden round scale seed ginger stem bundle scrub tower grunt burger forum woman enroll uncover dry almost plug ahead recipe grant cook dilemma crumble
ff7f313152ea95727aff404f3a854794718c9c4392f3670494d83135b527563ca92a4080fb0923d8bc36a9a6177fff2995cf3653ea27ba0e525684b03fdd0f74
```
If you have a BX version with ICU build enabled (the current binaries do not ship with that) then you could also strengthen your seed with a password:
```
$ bx mnemonic-to-seed --language en --passphrase "PASSWORD is not s3cret" burden round scale seed ginger stem bundle scrub tower grunt burger forum woman enroll uncover dry almost plug ahead recipe grant cook dilemma crumble
ff7f313152ea95727aff404f3a854794718c9c4392f3670494d83135b527563ca92a4080fb0923d8bc36a9a6177fff2995cf3653ea27ba0e525684b03fdd0f74
```

### Create HD privat and public key from seed
Use the seed to create a private key:
```
$ bx hd-new ff7f313152ea95727aff404f3a854794718c9c4392f3670494d83135b527563ca92a4080fb0923d8bc36a9a6177fff2995cf3653ea27ba0e525684b03fdd0f74
xprv9s21ZrQH143K2PXvS8LVkpyHLd4aPH4t8wisTstebuBqY8Hvn9YtQpeGEVmtmLtskCLcEvKuMcaBZ7o9k6UEvNyVBPFELPXn2Yvos4ipoMa
```

This (master) private key can be used to derive a hardened (omit the `-d` for not-harneded key) child private key:
```
$ bx hd-private -d -i 0 xprv9s21ZrQH143K2PXvS8LVkpyHLd4aPH4t8wisTstebuBqY8Hvn9YtQpeGEVmtmLtskCLcEvKuMcaBZ7o9k6UEvNyVBPFELPXn2Yvos4ipoMa
xprv9u1BFCaMQ5ZhHZ85UQvCK7GLq9RRenNDZqh5RBmZenUa31JewjGrAg8VN23fMqun1fwmFKtAQYtWopovLbLtPu5BzRQp2mqP3Kghce2pC3D
```

From the derived private key the corresponding public key can be generated:
```
$ bx hd-to-public xprv9u1BFCaMQ5ZhHZ85UQvCK7GLq9RRenNDZqh5RBmZenUa31JewjGrAg8VN23fMqun1fwmFKtAQYtWopovLbLtPu5BzRQp2mqP3Kghce2pC3D
xpub67zXei7FET7zW3CYaSTCgFD5PBFv4F64w4cgDaBBD81YuodoVGb6iUSyDKmo3YMRuQdDx7ffL3WYM6M6xJka5EiXTyM3fKALy698dgbWd9L
```

### Create public key from HD private key
The derived child private key can be turned into an EC (elliptic curve) private key via
```
$ bx hd-to-ec xprv9u1BFCaMQ5ZhHZ85UQvCK7GLq9RRenNDZqh5RBmZenUa31JewjGrAg8VN23fMqun1fwmFKtAQYtWopovLbLtPu5BzRQp2mqP3Kghce2pC3D
007d414579349bf511ac674c0a0348f560d30748d7e1f72794bdc7687bf468ec
```

Generate a compressed public key from the EC private key (add -u to generate an uncompressed public key from which later also a (different!) uncompressed address can be generated in the same way):
```
$ bx ec-to-public 007d414579349bf511ac674c0a0348f560d30748d7e1f72794bdc7687bf468ec
036389b88c9fca94e5f353d0b506af2d71a4884a841442b4f487dfb252ab32a944
```
#### The short way from pub key to address

Turn the public key directly into the address:
```
$ bx ec-to-address 036389b88c9fca94e5f353d0b506af2d71a4884a841442b4f487dfb252ab32a944
14MhLSEbhGDAXZ6iTXvhk1diiapJV1fmgp
```

#### The long way from pub key to address (but you understand what is going on!)
(Following the [libbitcoin tutorial](https://github.com/libbitcoin/libbitcoin-explorer/wiki/Payment-Address-Deconstruction))

1. Perform SHA-256 hashing on the public key.
```
$ bx sha256 036389b88c9fca94e5f353d0b506af2d71a4884a841442b4f487dfb252ab32a944
5d6289537cab715830f71ca69c4031a768945761e7eb8d9bbed07cbda884aef8
```
2. Perform RIPEMD-160 hashing on the result of SHA-256.
```
$ bx ripemd160 5d6289537cab715830f71ca69c4031a768945761e7eb8d9bbed07cbda884aef8
24d25ddafa2b707fbcd2981679e1060c0ca3e1f4
```
3. Add version byte in front of RIPEMD-160 hash (0x00 for Main Network).
```
$ echo 0024d25ddafa2b707fbcd2981679e1060c0ca3e1f4
0024d25ddafa2b707fbcd2981679e1060c0ca3e1f4
```
4. Perform SHA-256 hash on the extended RIPEMD-160 result.
```
$ bx sha256 0024d25ddafa2b707fbcd2981679e1060c0ca3e1f4
0ada374914d6f089345fa9ca4b61b603e0542768266810fadaa894db31131170
```
5. Perform SHA-256 hash on the result of the previous SHA-256 hash.
```
$ bx sha256 0ada374914d6f089345fa9ca4b61b603e0542768266810fadaa894db31131170
cc7cb1652b467eee1175c4166756b21b3f7e19660a5d2d3d06f4f5a099f550f1
```
6. Take the first 4 bytes (first 8 hex characters) of the second SHA-256 hash. This is the address checksum. Add the 4 checksum bytes at the end of extended RIPEMD-160 hash from stage 3. This is the 25-byte binary Bitcoin Address.
```
$ echo 0024d25ddafa2b707fbcd2981679e1060c0ca3e1f4cc7cb165
0024d25ddafa2b707fbcd2981679e1060c0ca3e1f4cc7cb165
```
7. Convert the result from a byte string into a base58 string using Base58Check encoding. This is the most commonly used Bitcoin Address format.
```
$ bx base58-encode 0024d25ddafa2b707fbcd2981679e1060c0ca3e1f4cc7cb165
14MhLSEbhGDAXZ6iTXvhk1diiapJV1fmgp
```
Note that this is exactly the same address that was derived with the higher-level command `bx ec-to-address` in the shorter way above.
