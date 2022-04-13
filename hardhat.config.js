require('@nomiclabs/hardhat-waffle');
require('dotenv').config();

module.exports = {
  solidity: {
    version: '0.8.1',
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000,
      },
    },
  },
  networks: {
    matic: {
      url: `${process.env.ALCHEMY_MATIC_URL}`,
      accounts: [`0x${process.env.MATIC_PRIVATE_KEY}`],
    },
  },
};
