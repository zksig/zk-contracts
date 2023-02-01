import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deployer: DeployFunction = async ({
  deployments,
  getNamedAccounts,
}: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;

  const {
    deployer,
    forwarder,
    validAgreementId,
    validAgreementSignatureInsert,
  } = await getNamedAccounts();

  const { address } = await deploy("ZKAgreement", {
    from: deployer,
    args: [forwarder],
    libraries: {
      ValidAgreementId: validAgreementId,
      ValidAgreementSignatureInsert: validAgreementSignatureInsert,
    },
    log: true,
    proxy: true,
  });

  console.log(`Deployed to ${address}`);
};

deployer.dependencies = ["libraries"];
export default deployer;
