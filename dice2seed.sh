# Based on https://github.com/swansontec/dice2key
#
# Converts a sequence of dice rolls to a Bitcoin private key.
#
# Simply roll a standard 6-sided die 100 times, and pass the resulting
# numbers into the script.
#
# Example usage:
# $ . dice2seed.sh 1234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234561234
# your seed is:
# 1E978F00617621AA87960EE62CE47AADDFCE967B2A1D06D4D814D9D65A5F4F89

# a normal 6-sided dice does not start at 0 but at 1
# therefor we have to reformat the parameter
# from string containing numbers 1-6 to string containing 0-5
# so that we can do a proper conversion later

dice=$(echo "$1" | tr 1-6 0-5)

# we should have at least 100 dice rolls to reach an entropy of 256 bits
# (6^100 > 2^256)
if [ ${#dice} -lt 100 ]; then
    echo "warning: The input has less than 100 dice rolls"
fi

# Convert from base 6 to base 16.
eval "hex=$(echo 'obase=16;ibase=6; '$dice | bc)"

# Print the last 64 hex digits of the output:
echo "your seed is: "
echo $hex | sed -e 's/.*\(.\{64\}\)$/\1/'
