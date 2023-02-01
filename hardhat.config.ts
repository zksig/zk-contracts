import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
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
    validAgreementId: {
      mumbai: "0x809AC0b9E5A424f80F7224348beAc3719320679D",
    },
    validAgreementSignatureInsert: {
      mumbai: "0x1732cf384eF96bEc9a61bd6B854F84e5eF9351cf",
    },
  },
};

export default config;
