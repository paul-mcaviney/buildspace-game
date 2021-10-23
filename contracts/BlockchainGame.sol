// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract BlockchainGame {

    // hold the character attributes in a struct
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    // An array to hold the default data for the characters
    CharacterAttributes[] defaultCharacters;

    // Data passed in ti the contract when first initialized - creating the characters
    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDamage
    ) 
    {
        // Loop through all characters, save their values in the contract to be used later when minting NFTs
        for (uint i = 0; i < characterNames.length; i++) {
            defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHp[i],
                maxHp: characterHp[i],
                attackDamage: characterAttackDamage[i]
            }));

            CharacterAttributes memory c = defaultCharacters[i];
            console.log("Finished initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
        }
    }
}