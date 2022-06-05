# ostokenswap

Open Source Simple and Easy Token Swap FOR WEB ONLY

THIS IS A OPEN SOURCE TOKEN SWAP MADE BY ME (Rodrigo), YOU CAN USE THIS FOR FREE WITHOUT RESTRICTIONS. IT IS NOT MANDATORY TO GIVE CREDITS, BUT I WOULD LIKE YOU TO DO IT BY REDIRECTING TO THIS GITHUB

## Getting Started

This is a Token Swap from Real Crypto to Virtual Points and vice versa and it was made especially for new solidity programmers

## How to make it work?

(Optional) Only need to connect firebase firestore (If you don't do this, you should store the points in another database or in a cache in addition to having to adapt it)
There is a dart file named "Changeable_Variables" here you must add your own Contract Address, Json Abi and Token Address to work.

## What Contains?

Deposit crypto, save points on firebase, withdraw crypto, delete points on firebase and save account metamask address in firebase with a small interface

## Contract Steps

1) There is a .sol file you must compile and deploy in Remix, Vyper or your desired IDE, 
2) Copy the ABI JSON and paste in Changeable_Variables.jsonAbi
3) Copy the contract address and paste in Changeable_Variables.contractAddress
4) Copy you desired token (crypto) address (by example: USDC) and paste in Changeable_Variables.tokenAddress. Remember that it has to match the operating chain

## Notes

By default the connection to metamask is allowed in the 97 network, if you want to change it you must go to metamask.dart and change operatingchain to desired. You must change this if you have a contract or token in another chain

--

I do not provide any type of support when referring to open source but in case of errors in my free time I can solve them
