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

    // struct for the boss of the game
    struct BigBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    BigBoss public bigBoss;

    // map NFT tokenId to an address - keeps track of who owns what
    mapping(address => uint256) public nftHolders;

    // Events
    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);

    // Data passed in ti the contract when first initialized - creating the characters
    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDamage,
        string memory bossName,
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage
    ) 
        ERC721("Heroes", "Hero")

    {
        // Initialize the boss and save to bigBoss state variable
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log("Done initializing boss %s, HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);
   
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

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
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


    // Function for attacking the boss
    function attackBoss() public {
        // Get the state of the player's NFT
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

        console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
        console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

        // Make sure the player has more than 0 HP
        require (
            player.hp > 0,
            "Error: character must have HP to attack the boss"
        );

        // Make sure the boss has more than 0 HP
        require (
            bigBoss.hp > 0,
            "Error: boss must have HP in order to attack the boss"
        );
        
        // Allow player to attack the boss
        if ( bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp -= player.attackDamage;
        }

        // Allow the boss to attack the player
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp -= bigBoss.attackDamage;
        }

        // Log results
        console.log("Boss attacked player. New player HP: %s\n", player.hp);

        emit AttackComplete(bigBoss.hp, player.hp);
    }


    // Check if user has an NFT and if so get it's attributes
    function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
        // Get the tokenId of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];

        // If the user has a token Id in the map, return their character, else return empty character
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        } else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }


    // get Default Characters for character selection
    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
        return defaultCharacters;
    }


    // Get The Boss and it's attributes
    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }
}