const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    // sepolia: {
    //   provider: function() {
    //     return new HDWalletProvider({
    //       mnemonic: "drink slow deal juice jungle please assume night snack degree fringe blur", // Add your mnemonic for the wallet
    //       providerOrUrl: "https://sepolia.infura.io/v3/ed2834f2c03f4d3fae928c007085343d",
    //       numberOfAddresses: 1,
    //     });
    //   },
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
      gas: 5000000
    }
  },
  compilers: {
    solc: {
      version: "0.8.0",
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 200      // Default: 200
        },
      }
    }
  }
};
