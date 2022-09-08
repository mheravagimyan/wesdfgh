// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PoolToken.sol";
import "./interfaces/IRouter.sol";
contract Pool is Ownable{

    uint256 contractTokenBalance;
    IERC20 public stable;
    PoolToken public pToken;
    uint256 profitFromArbitrage; // to know how much income after arbitrage 
    // address owner;

    constructor(address _stable, address _pToken) {
        stable = IERC20(_stable);
        pToken = PoolToken(_pToken);
        // owner = msg.sender;
    }

    function deposit(uint256 _amount, address _tokenAddress) external {
        require(
            _amount >= 100 && _amount <= 1000 ether,
            "Amount not in range"
        );
        require(
            _tokenAddress == address(stable),
            "Only stable"
        );
        require(
            stable.balanceOf(msg.sender) >= _amount,
            "Not enough balance"
        );
        require(
            stable.allowance(msg.sender, address(this)) >= _amount,
            "Not enough allowance"
        );

        uint256 mintAmount = stable.balanceOf(address(this)) == 0 ? _amount / 10 : contractTokenBalance * _amount / stable.balanceOf(address(this));
        
        stable.transferFrom(msg.sender, address(this), _amount);
        contractTokenBalance += mintAmount;
        pToken.mint(msg.sender, mintAmount);
        
    }

    function withdraw(uint256 _amount) external {
        uint256 pTokenFromAmount = _amount * contractTokenBalance / stable.balanceOf(address(this));

        require(
            pToken.balanceOf(msg.sender) >= pTokenFromAmount,
            "Pool: Dont have enough pTokens!"
        );
        
        pToken.burn(msg.sender, pTokenFromAmount);
        contractTokenBalance -= pTokenFromAmount;
        stable.transfer(msg.sender, _amount);
    }

    function arbitrage(
        address router1,
        address router2,
        address token1,
        address token2,
        uint256 amount
    ) external onlyOwner{
        // uniswap router address - 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        address[] memory tokens = new address[](2);
        tokens[0] = token1;
        tokens[1] = token2;
        uint256 token1AmountBefore = IERC20(token1).balanceOf(address(this));
        uint256 token2AmountBefore = IERC20(token2).balanceOf(address(this));

        IRouter(router1).swapExactTokensForTokens(
            amount,
            1,
            tokens,
            address(this),
            block.timestamp + 300
        );

        uint256 token2ProfitAfter = IERC20(token2).balanceOf(address(this)) - token2AmountBefore;
        tokens[0] = token2;
        tokens[1] = token1;

        IRouter(router2).swapExactTokensForTokens(
            token2ProfitAfter,
            1,
            tokens,
            address(this),
            block.timestamp + 300
        );

        uint256 token1AmountAfter = IERC20(token1).balanceOf(address(this));

        require(token1AmountAfter > token1AmountBefore, "Arbitrage: Unprofitable trade!");
        profitFromArbitrage = token1AmountAfter - token1AmountBefore;
    }

    // function arbitrage(
    //     address router1,
    //     address router2,
    //     address token1,
    //     address token2,
    //     uint256 amount
    // ) external onlyOwner{
    //     // uniswap router address - 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    //     address[] memory tokens = new address[](2);
    //     tokens[0] = token1;
    //     tokens[1] = token2;
    //     uint256 token1AmountBefore = IERC20(token1).balanceOf(address(this));
    //     uint256 token2AmountBefore = IERC20(token2).balanceOf(msg.sender);

    //     IRouter(router1).swapExactTokensForTokens(
    //         amount,
    //         1,
    //         tokens,
    //         msg.sender,
    //         block.timestamp + 300
    //     );

    //     uint256 token1AmountAfter = IERC20(token2).balanceOf(msg.sender) - token1AmountBefore;
    //     uint256 token2AmountAfter = IERC20(token2).balanceOf(msg.sender) - token2AmountBefore;
    //     tokens[0] = token2;
    //     tokens[1] = token1;

    //     IRouter(router2).swapExactTokensForTokens(
    //         token2AmountAfter,
    //         1,
    //         tokens,
    //         msg.sender,
    //         block.timestamp + 300
    //     );

    //     require(token1AmountAfter > token1AmountBefore, "Arbitrage: Unprofitable trade!");
    //     profitFromArbitrage = token1AmountAfter - token1AmountBefore;
    // }

    // percnet - for know how many percent owner wantto receive
    function profitDistribution(uint256 percent) external onlyOwner { 
        require(profitFromArbitrage > 0, "Distribution: Not enough profit!");
        stable.transfer(owner(), profitFromArbitrage * percent / 100);
        profitFromArbitrage = 0;
    }


}
