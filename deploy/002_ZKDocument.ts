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
    validDocumentId,
    validDocumentParticipantInsert,
  } = await getNamedAccounts();

  const { address } = await deploy("ZKDocument", {
    from: deployer,
    args: [forwarder],
    libraries: {
      ValidDocumentId: validDocumentId,
      ValidDocumentParticipantInsert: validDocumentParticipantInsert,
    },
    log: true,
    proxy: {
      execute: {
        init: {
          methodName: "initialize",
          args: [forwarder, deployer],
        },
      },
    },
  });

  console.log(`Deployed to ${address}`);
};

deployer.dependencies = ["libraries"];
export default deployer;
