import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deployer: DeployFunction = async ({
  deployments,
  getNamedAccounts,
}: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  const validAgreementId = await deploy("ValidAgreementId", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log(
    `ValidAgreementId library deployed to ${validAgreementId.address}`
  );

  const validAgreementSignatureInsert = await deploy(
    "ValidAgreementSignatureInsert",
    {
      from: deployer,
      args: [],
      log: true,
    }
  );

  console.log(
    `ValidAgreementSignatureInsert library deployed to ${validAgreementSignatureInsert.address}`
  );
};

deployer.tags = ["libraries"];
export default deployer;
