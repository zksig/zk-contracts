import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  mocha: {
    timeout: 100000000,
  },
  networks: {
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      chainId: 80001,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
  namedAccounts: {
    deployer: {
      mumbai: "0xa96bb1719fa7f78b8B2d3c24BBc79e52Ae9a3988",
    },
    forwarder: {
      mumbai: "0x9c66b91cff4855ddf693889335acbb0564ea19b8",
    },
    validDocumentId: {
      mumbai: "0xc76B836b2489E65BF7F7593E725D333b086E6341",
    },
    validDocumentParticipantInsert: {
      mumbai: "0xa295b447f30b3c947CAD05eB09aBDf7D3AdA905F",
    },
  },
};

export default config;
