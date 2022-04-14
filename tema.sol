pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


contract Demo {
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    function swap(address token) public payable {
        address[] memory path = new address[](2);
        IUniswapV2Router02 swap = IUniswapV2Router02(ROUTER);
        path[0] = swap.WETH();
        path[1] = token;
        swap.swapExactETHForTokens{value: msg.value}(0, path, msg.sender, block.timestamp);
    }
}
