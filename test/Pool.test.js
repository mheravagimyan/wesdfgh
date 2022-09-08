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
      const stableToken = await Stable.deploy();
      const stableAddress = stableToken.address;
      const tokenAddress = pToken.address;
      const pool = await Pool.deploy(stableToken.address, tokenAddress);
      const token = await ethers.getContractAt("PoolToken", tokenAddress);
      const stable = await ethers.getContractAt("Stable", stableAddress);

      return { pool, token, stable, tokenAddress, stableAddress, owner, caller, otherAccount };
  }

  describe("Initialization: ", function () {
    it("Should init with correct args: ", async function () {
      const { pool, token, tokenAddress, stableAddress, owner, caller, otherAccount } = await loadFixture(deployPoolFixture);
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

    it("Should reverted with 'Only stable' ", async function () {
      const { pool, token, stable, tokenAddress, stableAddress, owner, caller, otherAccount } = await loadFixture(deployPoolFixture);
      await expect(pool.deposit(200, tokenAddress))
              .to
              .be
              .revertedWith("Only stable");        
    });

    it("Should reverted with 'Not enough balance' ", async function () {
      const { pool, token, stable, tokenAddress, stableAddress, owner, caller, otherAccount } = await loadFixture(deployPoolFixture);
      await expect(pool.deposit(200, stableAddress))
              .to
              .be
              .revertedWith("Not enough balance");        
    });

    it("Should reverted with 'Not enough allowance' ", async function () {
      const { pool, token, stable, tokenAddress, stableAddress, owner, caller, otherAccount } = await loadFixture(deployPoolFixture);
      await stable.mint(caller.address, 1000);
      await stable.approve(pool.address, 200);
      await expect(pool.deposit(200, stableAddress))
              .to
              .be
              .revertedWith("Not enough allowance");        
    });

  });

  // describe("Deposit: ", function () {
  //   it("Should deposit with correc args: ", async function () {
  //       const { pool, token, tokenAddress, stableAddress, owner, caller, otherAccount } = await loadFixture(deployPoolFixture);
  //       await caller
  //   });
  // });



  
  
});