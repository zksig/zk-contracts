import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  defaultNetwork: "localhost",
  mocha: {
    timeout: 100000000,
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
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
      mumbai: "0xb1c5129aAd91bDcBeA38Af4C5D341cFb75FDA35A",
    },
    validDocumentParticipantInsert: {
      mumbai: "0x12f98c19986D2014353e30Ca7aa6B76A15b35441",
    },
  },
};

export default config;
