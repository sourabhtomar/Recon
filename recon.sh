#!/bin/bash

mkdir ~/bugbounty_targets/$1

echo "Gathering subdomains from assetfinder"

assetfinder --subs-only $1 | tee ~/bugbounty_targets/$1/assetfinder_subdomains

echo "Gathering subdomains from subfinder"

subfinder -d $1 | tee ~/bugbounty_targets/$1/subfinder_subdomains

echo "Gathering subdomains from findomain"

findomain -t $1 -u ~/bugbounty_targets/$1/findomain_subdomains

echo "Gathering subdomains from sublist3r"

sublist3r -d $1 | tee ~/bugbounty_targets/$1/sublist3r_subdomains

echo "Gathering subdomains from amass"

amass enum --passive -d $1 | tee ~/bugbounty_targets/$1/amass_subdomains

echo "Gathering subdomains from crt.sh"

curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee ~/bugbounty_targets/$1/crt.txt

cd ~/bugbounty_targets/$1

echo "Filtering subdomains to unique"

cat amass_subdomains sublist3r_subdomains findomain_subdomains subfinder_subdomains assetfinder_subdomains crt.txt | sort -u | tee unique_subdomains.txt

rm amass_subdomains sublist3r_subdomains findomain_subdomains subfinder_subdomains assetfinder_subdomains crt.txt

echo "Finding live subdomains"

cat unique_subdomains.txt | httpx | tee alive_subdomains

echo "Taking screenshot"
cat alive_subdomains | aquatone -out aquatone
