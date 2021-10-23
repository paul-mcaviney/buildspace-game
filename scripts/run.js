const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory("BlockchainGame");
    const gameContract = await gameContractFactory.deploy(
        ["Goku", "Android 18", "Gohan"],    // Names
        ["https://i.imgur.com/E6uySNo.jpg", // Images - Goku
        "https://i.imgur.com/SWciGrF.jpg",  // Images - Android 18
        "https://i.imgur.com/hybQozx.jpg"   // Images - Gohan
        // Images - Cell - https://i.imgur.com/e7eMUwQ.jpg
    ],
    [1000, 600, 750],                       // Hp Values
    [1000, 1400, 1250],                     // Attack Damage
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    // mint an nft character
    let txn = await gameContract.mintCharacterNFT(1);
    await txn.wait();

    // get the value of the NFT's URI
    let returnedTokenUri = await gameContract.tokenURI(1);
    console.log("Token URI:", returnedTokenUri);
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();