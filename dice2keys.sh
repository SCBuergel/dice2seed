# Based on https://github.com/swansontec/dice2key
#
# Converts a sequence of dice rolls to a master private keys
# and stores them in a CSV file keys.txt.
#
# Simply roll a standard 6-sided die 100 times, and pass the resulting
# numbers along with a passphrase into the script.
#
# Requires a build of libbitcoin-explorer with ICU build enabled.
#
# Example usage:
# $ . dice2keys.sh 1234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234 'P@SSWORD 1$ n0t s3cret.'
# your entropy is: 39BD194E3B989D612E6ED5BF485BAE130D53F5F532F29585E98ECD298282A5C3
# your mnemonic is: defy trip fatal jaguar mean rack rifle survey satisfy drift twist champion steel wife state furnace night consider glove olympic oblige donor novel left
# your seed is: ac09fdce665aa86195fd3dba3f3731bb23c7735e31de64569c3b54ad348668bfb4ceefc4758311784510cc4cf3b3c460749a1cd0e61d608689b55b0c4ef72cca
# your master private key is: xprv9s21ZrQH143K3L2duGWeQ6e3PA6fJLDrkRkbsaxZyAb8ung1sUb2UJmgDPKxgFQeZcxosJvGL2m1hjmqZqQKCAxJsa9g1k5rxE8h7aXxaEs
# M/44H: xprv9uqh6TbyfqnX8LHHnzRcuLfNDyzMkjcLPmy3C6vuo11HsH2ScWnz7TX4CrYdsPrk4WcQdXpXJs6v9iFmrDKV81N66WJbe5MC43oXaqNyLoS
# took 0 s to generate 10 keys

# a normal 6-sided dice does not start at 0 but at 1
# therefor we have to reformat the parameter
# from string containing numbers 1-6 to string containing 0-5
# so that we can do a proper conversion later
dice=$(echo "$1" | tr 1-6 0-5)
password=$2

# file into which the output keys are written
outputFile="pubKeys.txt"

# output file contains keys for all coin types and address indices
# up to the maximal values defined here
# (m/44'/0'/0'/0/0 to m/44'/maxCoinTyp'/0'/0/maxAddressIndex)
maxCoinTyp=100
maxAddressIndex=10

# we should have at least 100 dice rolls to reach an entropy of 256 bits
# (6^100 > 2^256)
if [ ${#dice} -lt 100 ]; then
    echo "warning: The input has less than 100 dice rolls"
fi

# convert from base 6 to base 16
eval "hex=$(echo 'obase=16;ibase=6; '$dice | bc)"

# print the last 64 hex digits of the output
entropy=$(echo $hex | sed -e 's/.*\(.\{64\}\)$/\1/')
echo "your entropy is: $entropy"

# generate mnemonic, seed, master private key
mnemonic=$(bx mnemonic-new $entropy)
echo "your mnemonic is: $mnemonic"

seed=$(bx mnemonic-to-seed --language en $mnemonic)
echo "your seed is: $seed"

M=$(bx hd-new $seed)
echo "your master private key is: $M"

M44H=$(bx hd-private -d -i 44 $M)
echo "M/44H: $M44H"

# generate addresses and store in CSV file
# c, M/44'/c'/0'/0/a
start=`date +%s`
echo "CSV file of uncompressed elliptic curve public keys generated from a BIP39 secrect mnemonic and optional password for a range BIP32 HD wallets with BIP43 purpose and BIP44 paths and coin types (m/44'/COINTYPE'/0'/0/ADDRESSINDEX)" >> $outputFile
echo "COINTYPE, ADDRESS_INDEX, EC_UNCOMPRESSED_PUBKEY" >> $outputFile
for (( c = 0; c <= $maxCoinTyp; c++ ))
do
    echo "Generating keys for coin type $c out of $maxCoinTyp..."
    parentPrivKey=$(echo $M44H | bx hd-private -d -i $c | bx hd-private -d -i 0 | bx hd-private -i 0 | bx hd-private -i 0)
    for (( a = 0; a <= $maxAddressIndex; a++ ))
    do
        childPrivKey=$(bx hd-private -i $a $parentPrivKey)
        childEcPubKey=$(echo $childPrivKey | bx hd-to-ec | bx ec-to-public -u)
        echo "$c, $a, $childEcPubKey" >> $outputFile
    done
done
end=`date +%s`
runtime=$((end-start))
echo "took $runtime s to generate $maxCoinTyp keys"