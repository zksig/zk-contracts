import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ZKAgreement } from "../typechain-types";

describe("ZKAgreement", () => {
  let owner: SignerWithAddress;
  let contract: ZKAgreement;

  before(async () => {
    [owner] = await ethers.getSigners();
    const validAgreementIdFactory = await ethers.getContractFactory(
      "ValidAgreementId"
    );
    const validAgreementId = await validAgreementIdFactory.deploy();
    await validAgreementId.deployed();

    const validAgreementSignatureInsertFactory =
      await ethers.getContractFactory("ValidAgreementSignatureInsert");
    const validAgreementSignatureInsert =
      await validAgreementSignatureInsertFactory.deploy();
    await validAgreementSignatureInsert.deployed();

    const zkAgreementFactory = await ethers.getContractFactory("ZKAgreement", {
      libraries: {
        ValidAgreementId: validAgreementId.address,
        ValidAgreementSignatureInsert: validAgreementSignatureInsert.address,
      },
    });
    contract = await zkAgreementFactory.deploy(ethers.constants.AddressZero);
  });

  it("creates an agreement with valid id", async () => {
    return expect(
      contract.createAgreement({
        agreementId:
          "15672289171331961726174349807060979975311854093145864462589715964709036733829",
        proof: Buffer.from(
          "2c500fd67c0e7c0fc7f98d77130fd5471492b50930bf5f49ce994e46eefb42900670f6de58d613759cd5158e33f5bf8e3de9c39f529bb567a76a246863c4fb08060106a1168619cf1cccaf10bfda58855abeff68c6b3aad4523eaaa2df8901820e201853ed0b949b94fb16d4826cfe2acbc2621bd7a73178e13f40935905bbb72542c7737fa6150e9514f002d62a5a730fa9b071a98141e8e78de4cef5aad2e62ddae781b8413e9d0e5de6ca9bd0f4c2d810b5e26f9a5da9b5c64266c754a57e1426ee7fa58576ee1d6d09e35efe7daa5aa7636be8240b63064e56440388953f1c7e905300f68a62d4f5af835867e9592a18c0f091f6effa6c533a88a2a68e602d8097db2162a131b9f888f8361d3a664f50f7d6fb04bc8595c3b968de9be6d23048fd9f2d4c5913781e848e6f47ce93e787cacb4620298022f3690d6d7c8e9125de20d2611e5c466a0424e682d7b4d6ad490a8769645db1d06eb8121acd094007c877b4fb3a10c2792769bc7bf64c0f91e27b542bedba05d868fd3af8ac66fb0064f1316129f2e7be3659941e6ae8b01c7f6b03803a79564a00d62018a2a9131144f62bfb979d04fd17b9a759aa58178575407fe35934de036fe1e34dcdaeda132623b0f76434e69bde01b8c393de84c6d1898c21d3bbe2efbe24d5511f6084156c1942fb5bb6bbbe5660ad48c1dd9afcfd8b66e633be3e7b9a9e1ca82239380aa492dc966e39db1e470b522bb12cc86eb902252ec9c03761b05657614ad1361a1ccea9fe23226caaec1f3bf2015bed53e92ebaa038d3e41099bab4135d025809dc72c55f1f3db6537616a4f9c233e39e8e385525c859c5d9acc40781795a942757022f4bebfc2161e4a0d55a0650791cdb0567f9ba73956eae6926f35448972b46c07d0d753c51213dd87508cc31978934dad63d9feb953628157d8be1439b190a0843dcbe673e1efe98ed500061712958d6c92d1f22d336ed60b5b92a9bea00ad0272aa9d22cc56b29403697aa28fbd6fa00e0a7dd6ec208db67bd3907efd1164a42dc6c587fda21f9c98b40f290f7be2a97e2b5b0622e1ec2acf37b17c4a0421420974e32f4655948d74c0e250e4a1c8c588c15f25f0907ae8ae7773b00a",
          "hex"
        ),
      })
    )
      .to.emit(contract, "CreateAgreement")
      .withArgs(
        owner.address,
        "15672289171331961726174349807060979975311854093145864462589715964709036733829",
        Buffer.from(
          "2c500fd67c0e7c0fc7f98d77130fd5471492b50930bf5f49ce994e46eefb42900670f6de58d613759cd5158e33f5bf8e3de9c39f529bb567a76a246863c4fb08060106a1168619cf1cccaf10bfda58855abeff68c6b3aad4523eaaa2df8901820e201853ed0b949b94fb16d4826cfe2acbc2621bd7a73178e13f40935905bbb72542c7737fa6150e9514f002d62a5a730fa9b071a98141e8e78de4cef5aad2e62ddae781b8413e9d0e5de6ca9bd0f4c2d810b5e26f9a5da9b5c64266c754a57e1426ee7fa58576ee1d6d09e35efe7daa5aa7636be8240b63064e56440388953f1c7e905300f68a62d4f5af835867e9592a18c0f091f6effa6c533a88a2a68e602d8097db2162a131b9f888f8361d3a664f50f7d6fb04bc8595c3b968de9be6d23048fd9f2d4c5913781e848e6f47ce93e787cacb4620298022f3690d6d7c8e9125de20d2611e5c466a0424e682d7b4d6ad490a8769645db1d06eb8121acd094007c877b4fb3a10c2792769bc7bf64c0f91e27b542bedba05d868fd3af8ac66fb0064f1316129f2e7be3659941e6ae8b01c7f6b03803a79564a00d62018a2a9131144f62bfb979d04fd17b9a759aa58178575407fe35934de036fe1e34dcdaeda132623b0f76434e69bde01b8c393de84c6d1898c21d3bbe2efbe24d5511f6084156c1942fb5bb6bbbe5660ad48c1dd9afcfd8b66e633be3e7b9a9e1ca82239380aa492dc966e39db1e470b522bb12cc86eb902252ec9c03761b05657614ad1361a1ccea9fe23226caaec1f3bf2015bed53e92ebaa038d3e41099bab4135d025809dc72c55f1f3db6537616a4f9c233e39e8e385525c859c5d9acc40781795a942757022f4bebfc2161e4a0d55a0650791cdb0567f9ba73956eae6926f35448972b46c07d0d753c51213dd87508cc31978934dad63d9feb953628157d8be1439b190a0843dcbe673e1efe98ed500061712958d6c92d1f22d336ed60b5b92a9bea00ad0272aa9d22cc56b29403697aa28fbd6fa00e0a7dd6ec208db67bd3907efd1164a42dc6c587fda21f9c98b40f290f7be2a97e2b5b0622e1ec2acf37b17c4a0421420974e32f4655948d74c0e250e4a1c8c588c15f25f0907ae8ae7773b00a",
          "hex"
        )
      );
  });

  it("fails to create an agreement with invalid id", async () => {
    return expect(
      contract.createAgreement({
        agreementId:
          "25672289171331961726174349807060979975311854093145864462589715964709036733828",
        proof: Buffer.from(
          "2c500fd67c0e7c0fc7f98d77130fd5471492b50930bf5f49ce994e46eefb42900670f6de58d613759cd5158e33f5bf8e3de9c39f529bb567a76a246863c4fb08060106a1168619cf1cccaf10bfda58855abeff68c6b3aad4523eaaa2df8901820e201853ed0b949b94fb16d4826cfe2acbc2621bd7a73178e13f40935905bbb72542c7737fa6150e9514f002d62a5a730fa9b071a98141e8e78de4cef5aad2e62ddae781b8413e9d0e5de6ca9bd0f4c2d810b5e26f9a5da9b5c64266c754a57e1426ee7fa58576ee1d6d09e35efe7daa5aa7636be8240b63064e56440388953f1c7e905300f68a62d4f5af835867e9592a18c0f091f6effa6c533a88a2a68e602d8097db2162a131b9f888f8361d3a664f50f7d6fb04bc8595c3b968de9be6d23048fd9f2d4c5913781e848e6f47ce93e787cacb4620298022f3690d6d7c8e9125de20d2611e5c466a0424e682d7b4d6ad490a8769645db1d06eb8121acd094007c877b4fb3a10c2792769bc7bf64c0f91e27b542bedba05d868fd3af8ac66fb0064f1316129f2e7be3659941e6ae8b01c7f6b03803a79564a00d62018a2a9131144f62bfb979d04fd17b9a759aa58178575407fe35934de036fe1e34dcdaeda132623b0f76434e69bde01b8c393de84c6d1898c21d3bbe2efbe24d5511f6084156c1942fb5bb6bbbe5660ad48c1dd9afcfd8b66e633be3e7b9a9e1ca82239380aa492dc966e39db1e470b522bb12cc86eb902252ec9c03761b05657614ad1361a1ccea9fe23226caaec1f3bf2015bed53e92ebaa038d3e41099bab4135d025809dc72c55f1f3db6537616a4f9c233e39e8e385525c859c5d9acc40781795a942757022f4bebfc2161e4a0d55a0650791cdb0567f9ba73956eae6926f35448972b46c07d0d753c51213dd87508cc31978934dad63d9feb953628157d8be1439b190a0843dcbe673e1efe98ed500061712958d6c92d1f22d336ed60b5b92a9bea00ad0272aa9d22cc56b29403697aa28fbd6fa00e0a7dd6ec208db67bd3907efd1164a42dc6c587fda21f9c98b40f290f7be2a97e2b5b0622e1ec2acf37b17c4a0421420974e32f4655948d74c0e250e4a1c8c588c15f25f0907ae8ae7773b00a",
          "hex"
        ),
      })
    ).to.rejectedWith("Invalid agreement id");
  });

  it("signs an agreement with valid signature", async () => {
    return expect(
      contract.signAgreement({
        agreementId:
          "15672289171331961726174349807060979975311854093145864462589715964709036733829",
        root: "11138567854912611493926693428430420645437166165045302007425203386365416754882",
        proof: Buffer.from(
          "1c14b5b1f72c91a45a15b40812472bf6cb2749bc27028e2d2ea2948b21a2d670117473b37957ae0e578e8388e9aa7cc05d5797663cac66b32e1bf026e2106d2212c51e15ce5a149b1fd77467a59b25563a0298122530f307283de9f68b8a507f303fa55a633787b62afdca428d5082d734533a537ef6abb1f7518eb7a342696f03cca379df211681624a6b5ff4ea0c5b7acfac6a2a0baf3402953f6459a9374906bba8e50c6cd60078180f141df2e62811c9ab62aad514c7ec316bf2b25e1bdf0ad25f7115b1b0245995e386a4ee6994c79e42a737e0228b1d7c392220f3dc5806722a91a5f3ebc2e48cf73573037bd545b4d7b6000e68c92dfc8eb91984dec11fe4f67af287f396371d14dff398e6cbbcef0a2dacd75062cdb7029447986fa41c1a104f148ff0b5a35f22a88c17e86a2fa0267a1e8786e29a4eb06e8af8e3f4222a9175531f0a8cc5374bac7c57043017b4a152d46c71f86f2219dc12cee3ea1eab84c6925cc9135290f025b7433b657dc87ae866ba7f1dbcb308039fb04442140f74c09af24409a65a6556551a50c378753f23c34414c1e832bb22b18332da2487a5b8ad7643d7cb5c7c02df974b0afb8381da596c6aa75433f109bdf8eb6c027debd9de822b4ae8f76cd1fd47fd0f7ffcea198734b7b52a8af5b7027272ed00641dd9774cb2c53b044cd80879e43b0d5c78d6afb6e40908a7e87dda5055562777f5f1f15e21349f2e0966ed850d93fb9a7f21a9e53425abc4f8a5bf68a1f200ecd5bf8157c6ba6b246d3e1bd438c9e5f6b4b36829533ee45fb2bb3ba01ddd06f926dc9fedf997b389df461022971c281f464f6483452b4a90327b42a8c36e1002534f987d47e84d42ab2f0c4142fa7a5346370ee1cab2dcb6b79cc1fe4bcc22487bf3379d8ee3527c925c90e9c79e4dafa16653e5e8dff40f25af86704cfb248a7743ca7b39c0f5d293d71361d4d55624d3c86bdb9109fb69369afdb4355001e45f07fc094a758bd19e8915d7fa804874493550865b7db5259e28585afdab051152116589f815a166e600e9dbee17add25b54795bcd0abb9d9b7045f5607514641e3895bb765e5acc3c301ce86dd9df425ec9998bd2a5153a29e97a04bc24",
          "hex"
        ),
      })
    )
      .to.emit(contract, "SignAgreement")
      .withArgs(
        "15672289171331961726174349807060979975311854093145864462589715964709036733829",
        "0",
        "11138567854912611493926693428430420645437166165045302007425203386365416754882",
        Buffer.from(
          "1c14b5b1f72c91a45a15b40812472bf6cb2749bc27028e2d2ea2948b21a2d670117473b37957ae0e578e8388e9aa7cc05d5797663cac66b32e1bf026e2106d2212c51e15ce5a149b1fd77467a59b25563a0298122530f307283de9f68b8a507f303fa55a633787b62afdca428d5082d734533a537ef6abb1f7518eb7a342696f03cca379df211681624a6b5ff4ea0c5b7acfac6a2a0baf3402953f6459a9374906bba8e50c6cd60078180f141df2e62811c9ab62aad514c7ec316bf2b25e1bdf0ad25f7115b1b0245995e386a4ee6994c79e42a737e0228b1d7c392220f3dc5806722a91a5f3ebc2e48cf73573037bd545b4d7b6000e68c92dfc8eb91984dec11fe4f67af287f396371d14dff398e6cbbcef0a2dacd75062cdb7029447986fa41c1a104f148ff0b5a35f22a88c17e86a2fa0267a1e8786e29a4eb06e8af8e3f4222a9175531f0a8cc5374bac7c57043017b4a152d46c71f86f2219dc12cee3ea1eab84c6925cc9135290f025b7433b657dc87ae866ba7f1dbcb308039fb04442140f74c09af24409a65a6556551a50c378753f23c34414c1e832bb22b18332da2487a5b8ad7643d7cb5c7c02df974b0afb8381da596c6aa75433f109bdf8eb6c027debd9de822b4ae8f76cd1fd47fd0f7ffcea198734b7b52a8af5b7027272ed00641dd9774cb2c53b044cd80879e43b0d5c78d6afb6e40908a7e87dda5055562777f5f1f15e21349f2e0966ed850d93fb9a7f21a9e53425abc4f8a5bf68a1f200ecd5bf8157c6ba6b246d3e1bd438c9e5f6b4b36829533ee45fb2bb3ba01ddd06f926dc9fedf997b389df461022971c281f464f6483452b4a90327b42a8c36e1002534f987d47e84d42ab2f0c4142fa7a5346370ee1cab2dcb6b79cc1fe4bcc22487bf3379d8ee3527c925c90e9c79e4dafa16653e5e8dff40f25af86704cfb248a7743ca7b39c0f5d293d71361d4d55624d3c86bdb9109fb69369afdb4355001e45f07fc094a758bd19e8915d7fa804874493550865b7db5259e28585afdab051152116589f815a166e600e9dbee17add25b54795bcd0abb9d9b7045f5607514641e3895bb765e5acc3c301ce86dd9df425ec9998bd2a5153a29e97a04bc24",
          "hex"
        )
      );
  });

  it("fails to sign an agreement with invalid signature insert", async () => {
    return expect(
      contract.signAgreement({
        agreementId:
          "15672289171331961726174349807060979975311854093145864462589715964709036733829",
        root: "21138567854912611493926693428430420645437166165045302007425203386365416754882",
        proof: Buffer.from(
          "1c14b5b1f72c91a45a15b40812472bf6cb2749bc27028e2d2ea2948b21a2d670117473b37957ae0e578e8388e9aa7cc05d5797663cac66b32e1bf026e2106d2212c51e15ce5a149b1fd77467a59b25563a0298122530f307283de9f68b8a507f303fa55a633787b62afdca428d5082d734533a537ef6abb1f7518eb7a342696f03cca379df211681624a6b5ff4ea0c5b7acfac6a2a0baf3402953f6459a9374906bba8e50c6cd60078180f141df2e62811c9ab62aad514c7ec316bf2b25e1bdf0ad25f7115b1b0245995e386a4ee6994c79e42a737e0228b1d7c392220f3dc5806722a91a5f3ebc2e48cf73573037bd545b4d7b6000e68c92dfc8eb91984dec11fe4f67af287f396371d14dff398e6cbbcef0a2dacd75062cdb7029447986fa41c1a104f148ff0b5a35f22a88c17e86a2fa0267a1e8786e29a4eb06e8af8e3f4222a9175531f0a8cc5374bac7c57043017b4a152d46c71f86f2219dc12cee3ea1eab84c6925cc9135290f025b7433b657dc87ae866ba7f1dbcb308039fb04442140f74c09af24409a65a6556551a50c378753f23c34414c1e832bb22b18332da2487a5b8ad7643d7cb5c7c02df974b0afb8381da596c6aa75433f109bdf8eb6c027debd9de822b4ae8f76cd1fd47fd0f7ffcea198734b7b52a8af5b7027272ed00641dd9774cb2c53b044cd80879e43b0d5c78d6afb6e40908a7e87dda5055562777f5f1f15e21349f2e0966ed850d93fb9a7f21a9e53425abc4f8a5bf68a1f200ecd5bf8157c6ba6b246d3e1bd438c9e5f6b4b36829533ee45fb2bb3ba01ddd06f926dc9fedf997b389df461022971c281f464f6483452b4a90327b42a8c36e1002534f987d47e84d42ab2f0c4142fa7a5346370ee1cab2dcb6b79cc1fe4bcc22487bf3379d8ee3527c925c90e9c79e4dafa16653e5e8dff40f25af86704cfb248a7743ca7b39c0f5d293d71361d4d55624d3c86bdb9109fb69369afdb4355001e45f07fc094a758bd19e8915d7fa804874493550865b7db5259e28585afdab051152116589f815a166e600e9dbee17add25b54795bcd0abb9d9b7045f5607514641e3895bb765e5acc3c301ce86dd9df425ec9998bd2a5153a29e97a04bc24",
          "hex"
        ),
      })
    ).to.rejectedWith("Invalid signature insert");
  });
});
