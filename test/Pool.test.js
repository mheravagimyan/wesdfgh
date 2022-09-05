const {
  time,
  loadFixture,
  mine
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Lock", function () {
  async function deployPoolFixture() {

      const [owner, caller, otherAccount] = await ethers.getSigners();
      const Pool = await ethers.getContractFactory("Pool");
      const PoolToken = await ethers.getContractFactory("PoolToken");
      const Stable = await ethers.getContractFactory("Stable");
      const pToken = await PoolToken.deploy();
      const stable = await Stable.deploy();
      const stableAddress = stable.address;
      const tokenAddress = pToken.address;
      const pool = await Pool.deploy(stable.address, tokenAddress);
      const token = await ethers.getContractAt("PoolToken", tokenAddress);

      return { pool, token, tokenAddress, stableAddress, owner, caller, otherAccount };
  }

  describe("Initialization: ", function () {
    it("Should init with correct args: ", async function () {
        const { pool, token, tokenAddress, stableAddress, owner, caller, otherAccount } = await loadFixture(deployPoolFixture);
        // await pool(stableAddress, tokenAddress);
        expect(await pool.stable()).is.equal(stableAddress);
        expect(await pool.pToken()).is.equal(tokenAddress);
    });
  });

  describe("Deposit requires: ", function () {
    it("Should reverted with 'Amount not in range' ", async function () {
        const { pool, token, tokenAddress, stableAddress, owner, caller, otherAccount } = await loadFixture(deployPoolFixture);
        await expect(pool.deposit(10, stableAddress))
                .to
                .be
                .revertedWith("Amount not in range");        
    });
  });

  describe("Deposit: ", function () {
    it("Should deposit with correc args: ", async function () {
        const { pool, token, tokenAddress, stableAddress, owner, caller, otherAccount } = await loadFixture(deployPoolFixture);
        await caller
  });



  
  
});