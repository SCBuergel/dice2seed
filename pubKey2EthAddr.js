// converts uncompressed EC pub key to Ethereum address
// expects one parameter which is the uncompressed EC pub key, e.g. 38f04e283c453f6c5c28f5291f12540ae5e27c2fd1a863f2596d8fbd99d24fdeea8b6f7ec7c69686a1617b127fa52bc46887ebf9f8a21524cf9b06c0a7856d7b
// make sure to remove the prefix "04" that is added by the other tool

const keccak256 = require('js-sha3').keccak256;
var StringEcPubKey = process.argv.slice(2)[0];
console.log(StringEcPubKey)
var BufEcPubKey = Buffer.from(StringEcPubKey, 'hex');
const address = keccak256(BufEcPubKey);
console.log("0x" + address.toString().substring(24));
