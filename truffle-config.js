module.exports = {
  networks: {
    development: {
      host: "127.0.0.1", 
      port: 7545,        // Ganache GUI default
      network_id: "*",   // Match any network id
    },
  },
  compilers: {
    solc: {
      version: "0.8.20"
    }
  },
  compilers: {
    solc: {
      version: "0.8.20", // Make sure it matches your pragma
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        },
        viaIR: true
      }
    }
  }
};
