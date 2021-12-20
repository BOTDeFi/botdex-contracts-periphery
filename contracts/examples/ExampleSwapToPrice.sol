pragma solidity >=0.8.0;
pragma abicoder v1;

import '../interfaces/external/IBotdexPair.sol';
import '../interfaces/IBotdexRouter01.sol';
import '../libraries/BotdexLibrary.sol';
import '../libraries/SafeMath.sol';
import '../libraries/Babylonian.sol';
import '../libraries/TransferHelper.sol';

contract ExampleSwapToPrice {
    using SafeMath for uint256;

    IBotdexRouter01 public immutable router;
    address public immutable factory;

    constructor(address factory_, IBotdexRouter01 router_) {
        factory = factory_;
        router = router_;
    }

    // computes the direction and magnitude of the profit-maximizing trade
    function computeProfitMaximizingTrade(
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 reserveA,
        uint256 reserveB
    ) pure public returns (bool aToB, uint256 amountIn) {
        aToB = (reserveA * truePriceTokenB / reserveB) < truePriceTokenA;

        uint256 invariant = reserveA * reserveB;

        uint256 leftSide = Babylonian.sqrt(
            (invariant * (aToB ? truePriceTokenA : truePriceTokenB) * 1000) /
            (uint256(aToB ? truePriceTokenB : truePriceTokenA) * 998)
        );
        uint256 rightSide = (aToB ? reserveA * 1000 : reserveB * 1000) / 998;

        // compute the amount that must be sent to move the price to the profit-maximizing price
        amountIn = leftSide - rightSide;
    }

    // swaps an amount of either token such that the trade is profit-maximizing, given an external true price
    // true price is expressed in the ratio of token A to token B
    // caller must approve this contract to spend whichever token is intended to be swapped
    function swapToPrice(
        address tokenA,
        address tokenB,
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 maxSpendTokenA,
        uint256 maxSpendTokenB,
        address to,
        uint256 deadline
    ) public {
        // true price is expressed as a ratio, so both values must be non-zero
        require(truePriceTokenA != 0 && truePriceTokenB != 0, "ExampleSwapToPrice: ZERO_PRICE");
        // caller can specify 0 for either if they wish to swap in only one direction, but not both
        require(maxSpendTokenA != 0 || maxSpendTokenB != 0, "ExampleSwapToPrice: ZERO_SPEND");

        bool aToB;
        uint256 amountIn;
        
            (uint256 reserveA, uint256 reserveB) = BotdexLibrary.getReserves(factory, tokenA, tokenB);
            (aToB, amountIn) = computeProfitMaximizingTrade(
                truePriceTokenA, truePriceTokenB,
                reserveA, reserveB
            );
        

        // spend up to the allowance of the token in
        uint256 maxSpend = aToB ? maxSpendTokenA : maxSpendTokenB;
        if (amountIn > maxSpend) {
            amountIn = maxSpend;
        }

        (address tokenIn, address tokenOut) = aToB ? (tokenA, tokenB) : (tokenB, tokenA);

        TransferHelper.safeTransferFrom(tokenIn, msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(tokenIn, address(router), amountIn);

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        router.swapExactTokensForTokens(
            amountIn,
            0, // amountOutMin: we can skip computing this number because the math is tested
            path,
            to,
            deadline
        );
    }
}
