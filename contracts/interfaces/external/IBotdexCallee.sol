pragma solidity >=0.5.0;

interface IBotdexCallee {
    function botdexCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
