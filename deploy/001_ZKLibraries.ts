import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deployer: DeployFunction = async ({
  deployments,
  getNamedAccounts,
}: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  const validDocumentId = await deploy("ValidDocumentId", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log(`ValidDocumentId library deployed to ${validDocumentId.address}`);

  const validDocumentParticipantInsert = await deploy(
    "ValidDocumentParticipantInsert",
    {
      from: deployer,
      args: [],
      log: true,
    }
  );

  console.log(
    `ValidDocumentParticipantInsert library deployed to ${validDocumentParticipantInsert.address}`
  );

  const validVerifiedParticipantData = await deploy(
    "ValidVerifiedParticipantData",
    {
      from: deployer,
      args: [],
      log: true,
    }
  );

  console.log(
    `ValidVerifiedParticipantData library deployed to ${validVerifiedParticipantData.address}`
  );

  const validDocumentIdPart = await deploy("ValidDocumentIdPart", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log(
    `ValidDocumentIdPart library deployed to ${validDocumentIdPart.address}`
  );

  const validDocumentPage = await deploy("ValidDocumentPage", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log(
    `ValidDocumentPage library deployed to ${validDocumentPage.address}`
  );

  const proofOfSignature = await deploy("ProofOfSignature", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log(
    `ProofOfSignature library deployed to ${proofOfSignature.address}`
  );
};

deployer.tags = ["libraries"];
export default deployer;
