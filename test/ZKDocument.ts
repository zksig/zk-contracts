import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { LocalTableland } from "@tableland/local";
import { ZKDocument } from "../typechain-types";

const lt = new LocalTableland({ silent: true });

describe("ZKDocument", () => {
  let owner: SignerWithAddress;
  let contract: ZKDocument;

  before(async () => {
    lt.start();
    await lt.isReady();

    [owner] = await ethers.getSigners();
    const validDocumentIdFactory = await ethers.getContractFactory(
      "ValidDocumentId"
    );
    const validDocumentId = await validDocumentIdFactory.deploy();
    await validDocumentId.deployed();

    const validDocumentParticipantInsertFactory =
      await ethers.getContractFactory("ValidDocumentParticipantInsert");
    const validDocumentParticipantInsert =
      await validDocumentParticipantInsertFactory.deploy();
    await validDocumentParticipantInsert.deployed();

    const zkDocumentFactory = await ethers.getContractFactory("ZKDocument", {
      libraries: {
        ValidDocumentId: validDocumentId.address,
        ValidDocumentParticipantInsert: validDocumentParticipantInsert.address,
      },
    });
    contract = await zkDocumentFactory.deploy(ethers.constants.AddressZero);
    await contract.initialize(ethers.constants.AddressZero, owner.address);
    await contract.setupTables();
  });

  after(async () => {
    await lt.shutdown();
  });

  it("creates a document with valid id", async () => {
    return expect(
      contract.createDocument({
        documentId:
          "3582412050679495162987849962896474819009991887378400823408172248678867010753",
        expectedParticipantCount: 1,
        encryptedDetailsCID: "12345",
        proof: {
          a: [
            "7657335195695277880903644436605548852115690219531150836956192758004149320063",
            "11460376350772623699245243607274833362141924026516931647590153162448840229265",
          ],
          b: [
            [
              "19017262352788335040987125288314528510993823733944752963261325156298941489889",
              "6562227636326813265589659387391131438593201664360707420580530558625149948308",
            ],
            [
              "11649279319085912723084576169225518646884451818682000567865129794759111244602",
              "8951051385827836200753209363942682803248972216431675225925097227267914092942",
            ],
          ],
          c: [
            "2523585361793855629232548248552385338498389305557038422792884898511735773884",
            "711165583117806686134582445115443813702795355504145857626928110347665932103",
          ],
        },
      })
    ).to.emit(contract, "CreateDocument");
  });

  it("fails to create a document if it already exists", async () => {
    return expect(
      contract.createDocument({
        documentId:
          "3582412050679495162987849962896474819009991887378400823408172248678867010753",
        expectedParticipantCount: 1,
        encryptedDetailsCID: "12345",
        proof: {
          a: [
            "7657335195695277880903644436605548852115690219531150836956192758004149320063",
            "11460376350772623699245243607274833362141924026516931647590153162448840229265",
          ],
          b: [
            [
              "19017262352788335040987125288314528510993823733944752963261325156298941489889",
              "6562227636326813265589659387391131438593201664360707420580530558625149948308",
            ],
            [
              "11649279319085912723084576169225518646884451818682000567865129794759111244602",
              "8951051385827836200753209363942682803248972216431675225925097227267914092942",
            ],
          ],
          c: [
            "2523585361793855629232548248552385338498389305557038422792884898511735773884",
            "711165583117806686134582445115443813702795355504145857626928110347665932103",
          ],
        },
      })
    ).to.rejectedWith("Document exists");
  });

  it("fails to create a document with invalid id", async () => {
    return expect(
      contract.createDocument({
        documentId:
          "1582412050679495162987849962896474819009991887378400823408172248678867010753",
        expectedParticipantCount: 1,
        encryptedDetailsCID: "12345",
        proof: {
          a: [
            "7657335195695277880903644436605548852115690219531150836956192758004149320063",
            "11460376350772623699245243607274833362141924026516931647590153162448840229265",
          ],
          b: [
            [
              "19017262352788335040987125288314528510993823733944752963261325156298941489889",
              "6562227636326813265589659387391131438593201664360707420580530558625149948308",
            ],
            [
              "11649279319085912723084576169225518646884451818682000567865129794759111244602",
              "8951051385827836200753209363942682803248972216431675225925097227267914092942",
            ],
          ],
          c: [
            "2523585361793855629232548248552385338498389305557038422792884898511735773884",
            "711165583117806686134582445115443813702795355504145857626928110347665932103",
          ],
        },
      })
    ).to.rejectedWith("Invalid document id");
  });

  it("verifies a document with valid verified participant", async () => {
    return expect(
      contract.addDocumentParticipant({
        documentId:
          "3582412050679495162987849962896474819009991887378400823408172248678867010753",
        verifiedParticipant:
          "25740335134468492854161423831973294313154674688193368093551170597985757595801",
        encryptedParticipantCID: "5678",
        nonce: "0",
        root: "15740335134468492854161423831973294313154674688193368093551170597985757595801",
        proof: {
          a: [
            "12478338684628348582701523510829150873321558676622252331908819555169489980498",
            "8899570539837704905122089633843940242177330695893768326732492990876671908474",
          ],
          b: [
            [
              "7283059804183926855299048465912075263413613808971398181579607688562367419714",
              "14495063997023333403898855043237946805703737899402467426207455075003619767105",
            ],
            [
              "12434772517165159385548736081572221833736113001861872661574219419692106444358",
              "9118435869643345087711878427200059911291797635769013919029660677261838788581",
            ],
          ],
          c: [
            "4763330114883313991846644000992727437969864208147019390834925533426784469642",
            "16665935850804907404177959490951113632617832050403172998072793521125931112172",
          ],
        },
      })
    ).to.emit(contract, "NewDocumentParticipant");
  });

  it("fails to verify an document with invalid verified participant insert", async () => {
    return expect(
      contract.addDocumentParticipant({
        documentId:
          "3582412050679495162987849962896474819009991887378400823408172248678867010753",
        verifiedParticipant:
          "25740335134468492854161423831973294313154674688193368093551170597985757595801",
        encryptedParticipantCID: "5678",
        nonce: "0",
        root: "20020478736176704528763471674210344244189298963256884275413681314235999212975",
        proof: {
          a: [
            "12478338684628348582701523510829150873321558676622252331908819555169489980498",
            "8899570539837704905122089633843940242177330695893768326732492990876671908474",
          ],
          b: [
            [
              "7283059804183926855299048465912075263413613808971398181579607688562367419714",
              "14495063997023333403898855043237946805703737899402467426207455075003619767105",
            ],
            [
              "12434772517165159385548736081572221833736113001861872661574219419692106444358",
              "9118435869643345087711878427200059911291797635769013919029660677261838788581",
            ],
          ],
          c: [
            "4763330114883313991846644000992727437969864208147019390834925533426784469642",
            "16665935850804907404177959490951113632617832050403172998072793521125931112172",
          ],
        },
      })
    ).to.rejectedWith("Invalid participant insert");
  });
});
