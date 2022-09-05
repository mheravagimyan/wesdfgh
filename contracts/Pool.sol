// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./PoolToken.sol";

contract Pool {

    uint256 contractTokenBalance;
    IERC20 public stable;
    PoolToken public pToken;

    constructor(address _stable, address _pToken) {
        stable = IERC20(_stable);
        pToken = PoolToken(_pToken);
    }

    function deposit(uint256 amount, address tokenAddress) external payable {
        require(amount >= 100 && amount <= 1000 ether, "Amount not in range");
        require(tokenAddress == address(stable), "Only stable");
        require(stable.balanceOf(msg.sender) >= amount, "Not enough balance");
        require(
            stable.allowance(msg.sender, address(this)) >= amount,
            "Not enough allowance"
        );

        uint256 mintAmount;

        mintAmount = (stable.balanceOf(address(this)) == 0) ? amount / 10 : contractTokenBalance * amount / stable.balanceOf(address(this));
        
        stable.transferFrom(msg.sender, address(this), amount);
        contractTokenBalance += mintAmount;
        pToken.mint(msg.sender, mintAmount);
        
        
    }

    function foo() external{
        stable.mint(address(this), stable.balanceOf(address(this)) / 10);
    }

    function withdraw() external {
        require(pToken.balanceOf(msg.sender) > 0, "Pool: Dont have pTokens");
        uint256 pTokenBalance = pToken.balanceOf(msg.sender);
        // pTokenAmount -= pTokenBalance / 10;

        pToken.burn(msg.sender, pTokenBalance);

        stable.transfer(msg.sender, stable.balanceOf(address(this)) * pTokenBalance / contractTokenBalance );
    }
}
