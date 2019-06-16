# dice2seed
Generate seed for bitcoin (and most other crypto asset) wallets by using a normal 6-sided dice as a source of entropy.

## Usage
1. Make sure that the dice is not biased to any specific output and nobody is observing or recording your dice rolls.
2. Roll the dice exactly 100 times so that you reach entropy of 256 bit.
3. Enter the dice rolls as one long number concatenated as the parameter to this script, e.g.
```
$ . mydice.sh 1234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234
your seed is:
1E978F00617621AA87960EE62CE47AADDFCE967B2A1D06D4D814D9D65A5F4F89
```
You can now use the resulting seed to create a mnemonic which you can archive or you can use it to create private keys and / or addresses.

## BIP39 mnemonic archiving
The hexadecimal seed with 256 bit entropy can now be used as the input for a BIP39 mnemonic. We can e.g. use libbitcoin's [BX](https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-mnemonic-new):
```
$ bx mnemonic-new 1E978F00617621AA87960EE62CE47AADDFCE967B2A1D06D4D814D9D65A5F4F89
burden round scale seed ginger stem bundle scrub tower grunt burger forum woman enroll uncover dry almost plug ahead recipe grant cook dilemma crumble
```
For production you might want to archive your mnemonic in a secure fashion by using e.g. the [blockplate](https://www.blockplate.com/) and store it in a secure location.
