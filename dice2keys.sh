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
# your seed is: f320457d50602d0b1aa4adcfaf445647b8ac1410ecf42a6fb5c2955055f12fbbd267d9c6b1c059b70f088c2e9cc44b875c05660e80ca07c02ab607265c919396
# your master private key is: xprv9s21ZrQH143K3MUXsSGZNHGAKWYF7Ke45cq6uYXz9K5j9hnUnoUMo1jJ2huiXf8bwwh678w599zMqqgNkZeTGcG7fkdu6TJZPJsXdHKR1qr
# M/44H: xprv9v2YKHf2AK88aZtFyuH3wLv4mt7CtjUmSXzJgCuDwg3BW6xxukj5z55y7rAB9f4JJo2E6mLZ2p1tVcfamCvmz5YB2CAZB3SEmEdnVqo8arK
# took 0 s to generate 10 keys

# a normal 6-sided dice does not start at 0 but at 1
# therefor we have to reformat the parameter
# from string containing numbers 1-6 to string containing 0-5
# so that we can do a proper conversion later

dice=$(echo "$1" | tr 1-6 0-5)
password=$2

# file into which the output keys are written
outputFile="keys.txt"

# output file contains keys for this coin type
# (m/44'/0'/0'/0/0 to m/44'/maxCoinTyp'/0'/0/0)
maxCoinTyp=10

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

seed=$(bx mnemonic-to-seed --language en --passphrase "$password" $mnemonic)
echo "your seed is: $seed"

M=$(bx hd-new $seed)
echo "your master private key is: $M"

M44H=$(bx hd-private -d -i 44 $M)
echo "M/44H: $M44H"

# generate addresses and store in CSV file
# c, m/44'/c'/0'/0/0
echo "c, m/44'/c'/0'/0/0" > $outputFile
start=`date +%s`
for (( c = 0; c <= $maxCoinTyp; c++ )) 
do
    childPrivKey=$(echo $M44H | bx hd-private -d -i $c | bx hd-private -d -i 0 | bx hd-private -i 0 | bx hd-private -i 0)
    echo "$c, $childPrivKey" >> $outputFile
done
end=`date +%s`
runtime=$((end-start))
echo "took $runtime s to generate $maxCoinTyp keys"