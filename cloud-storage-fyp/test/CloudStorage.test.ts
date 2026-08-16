import { expect } from "chai";
import hre from "hardhat";

// Hardhat 3 requires us to explicitly create a network connection to use ethers
const { ethers } = await hre.network.create();

describe("CloudStorage System", function () {
  
  // A helper fixture to deploy the contract before each test
  async function deployStorageFixture() {
    const [owner, user1, user2] = await ethers.getSigners();
    
    // The new v3 way to deploy contracts
    const cloudStorage = await ethers.deployContract("CloudStorage");
    
    return { cloudStorage, owner, user1, user2 };
  }

  it("Should upload a file and assign ownership", async function () {
    const { cloudStorage, owner } = await deployStorageFixture();
    
    const cid = "QmDummyHash12345";
    const fileName = "my_fyp_proposal.pdf";
    const fileSize = 1024;
    const fileType = "application/pdf";

    // Upload the file
    await cloudStorage.uploadFile(cid, fileName, fileSize, fileType);
    
    // Fetch the files for the caller (owner)
    const myFiles = await cloudStorage.getMyFiles();
    
    expect(myFiles.length).to.equal(1);
    expect(myFiles[0].cid).to.equal(cid);
    expect(myFiles[0].fileName).to.equal(fileName);
    expect(myFiles[0].fileSize).to.equal(fileSize);
    expect(myFiles[0].fileType).to.equal(fileType);
    expect(myFiles[0].owner).to.equal(owner.address);
    
    // Verify the owner has access to their own file
    expect(await cloudStorage.hasAccess(cid, owner.address)).to.be.true;
  });

  it("Should allow the owner to share a file with another user", async function () {
    const { cloudStorage, owner, user1 } = await deployStorageFixture();
    const cid = "QmDummyHash67890";

    await cloudStorage.uploadFile(cid, "shared_image.png", 2048, "image/png");
    
    // Initially, user1 should NOT have access
    expect(await cloudStorage.hasAccess(cid, user1.address)).to.be.false;

    // Owner shares the file with user1
    await cloudStorage.shareFile(cid, user1.address);

    // Now, user1 SHOULD have access
    expect(await cloudStorage.hasAccess(cid, user1.address)).to.be.true;

    // User1 should see the file in their SharedWithMe array
    const sharedFiles = await (cloudStorage as any).connect(user1).getSharedWithMe();
    expect(sharedFiles.length).to.equal(1);
    expect(sharedFiles[0].cid).to.equal(cid);
  });

  it("Should prevent unauthorized users from sharing files", async function () {
    const { cloudStorage, user1, user2 } = await deployStorageFixture();
    const cid = "QmDummyHashTopSecret";
    
    // Owner uploads a file
    await cloudStorage.uploadFile(cid, "secret_keys.txt", 100, "text/plain");

    // user1 tries to share the owner's file with user2
    // We cast to 'any' to avoid strict TypeScript errors when switching signers
    await expect(
      (cloudStorage as any).connect(user1).shareFile(cid, user2.address)
    ).to.be.revertedWith("You do not have permission");
  });
});