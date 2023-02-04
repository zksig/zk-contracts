import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deployer: DeployFunction = async ({
  deployments,
  getNamedAccounts,
}: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;

  const { deployer, forwarder, validDocumentId, validDocumentVerifierInsert } =
    await getNamedAccounts();

  const { address } = await deploy("ZKDocument", {
    from: deployer,
    args: [forwarder],
    libraries: {
      ValidDocumentId: validDocumentId,
      ValidDocumentVerifierInsert: validDocumentVerifierInsert,
    },
    log: true,
    proxy: true,
  });

  console.log(`Deployed to ${address}`);
};

deployer.dependencies = ["libraries"];
export default deployer;
