// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;
// Implement Uniswap swap interface
// Implement library to help with token transfers
import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract SimpleTokenSwap {
    // Define the Uniswap Router address and the WETH address variable
    ISwapRouter public immutable swapRouter;
    address public immutable WETH;
    uint24 public constant poolFee = 3000;

    // Define the constructor
    constructor(ISwapRouter _swapRouter, address _WETH) {
        // Initialize the addresses
        swapRouter = _swapRouter;
        WETH = _WETH;
    }

    // Create a swap function that takes input and output token addresses,
    // the input amount, the minimum output amount, and the recipient's address
    function swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMinimum, address recipient)
        external returns (uint256 amountOut)
    {
        require(recipient == msg.sender, "Recipient must be the caller");
        
        // Transfer the input tokens from the sender to the contract
        TransferHelper.safeTransferFrom(tokenIn, msg.sender, address(this), amountIn);

        // Approve the Uniswap router to spend the input tokens
        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

        // Define the exact input swapping path to swap maximum amount of receiving token
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: poolFee,
            recipient: recipient,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: 0
        });

        // Call the Uniswap router's exactInputSingle function to execute the swap
        amountOut = swapRouter.exactInputSingle(params);
    }
}
