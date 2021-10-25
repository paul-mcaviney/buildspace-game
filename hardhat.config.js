require("@nomiclabs/hardhat-waffle");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.0",
  networks: {
      rinkeby: {
          url: process.env.ALCHEMY_URL,
          accounts: [process.env.PRIVATE_KEY],
      },
  },
};
