//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "https://github.com/Uniswap/v3-periphery/blob/main/contracts/interfaces/ISwapRouter.sol";
import "https://github.com/Uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract SwapExamples{

    ISwapRouter public immutable swapRouter;

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    uint24 public constant poolfee = 3000;

    constructor(ISwapRouter _swapRouter){
        swapRouter = _swapRouter;
    }

    function swapExactInputSingle(uint256 amountIn) external returns(uint amountOut){
        
        TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountIn);

        TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = 
            ISwapRouter.ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH9,
                fee: poolfee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
        });

        amountOut = swapRouter.exactInputSingle(params);
    }

    function swapExactOutputSingle(uint amountOut, uint amountInMaximum) external returns (uint amountIn){
        
        TransferHelper.safeTransferFrom(DAI, msg.sender, address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH9,
                fee: poolfee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });
            
            amountIn = swapRouter.exactOutputSingle(params);
           
            if(amountIn < amountInMaximum) {
            TransferHelper.safeApprove(DAI, address(swapRouter), 0);
            TransferHelper.safeTransfer(DAI, msg.sender, amountInMaximum - amountIn);
        }
    }

}