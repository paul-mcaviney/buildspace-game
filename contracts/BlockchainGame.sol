// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// NFT contract to inherit from
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// OpenZeppelin helper functions
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract BlockchainGame is ERC721 {

    // hold the character attributes in a struct
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    // tokenId = NFTs unique identifier
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // An array to hold the default data for the characters
    CharacterAttributes[] defaultCharacters;

    // map an NFTs attributes to the tokenID
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // map NFT tokenId to an address - keeps track of who owns what
    mapping(address => uint256) public nftHolders;

    // Data passed in ti the contract when first initialized - creating the characters
    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDamage
    ) 
        ERC721("Heroes", "Hero")
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

        // Incremetn tokenIds so first NFT has an ID of 1
        _tokenIds.increment();
    }

    // mint an NFT based on the character selected
    function mintCharacterNFT(uint _characterIndex) external {
        // Get current tokenID
        uint newItemId = _tokenIds.current();
        // Assign tokenId to the caller's wallet adress
        _safeMint(msg.sender, newItemId);

        // map character attributes to tokenId
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].hp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

        // See who owns what NFT
        nftHolders[msg.sender] = newItemId;

        // Increment tokenId for next minting
        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAttributes memory characterAttributes = nftHolderAttributes[_tokenId];

        string memory strHp = Strings.toString(characterAttributes.hp);
        string memory strMaxHp = Strings.toString(characterAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(characterAttributes.attackDamage);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        characterAttributes.name,
                        ' -- NFT #: ',
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in a blockchain based game project", "image": "',
                        characterAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ', strHp, ', "max_value":' , strMaxHp, '}, { "trait_type": "AttackDamage", "value": ',
                        strAttackDamage, '}]}'
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}