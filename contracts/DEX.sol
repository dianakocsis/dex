// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title DEX - A simple DEX with liquidity pools
/// @notice You can use this contract for swapping tokens and adding/withdrawing liquidity
contract DEX {

    IERC20 token;
    uint256 public totalLiquidity;
    mapping(address=>uint256) public liquidity;

    event EthToTokenSwap(
        address swapper,
        uint256 tokenOutput,
        uint256 ethInput
    );

    event TokenToEthSwap(
        address swapper,
        uint256 tokensInput,
        uint256 ethOutput
    );

    event LiquidityProvided(
        address liquidityProvider,
        uint256 liquidityMinted,
        uint256 ethInput,
        uint256 tokensInput
    );

    event LiquidityRemoved(
        address liquidityRemover,
        uint256 liquidityWithdrawn,
        uint256 tokensOutput,
        uint256 ethOutput
    );

    error AlreadyHasLiquidity();
    error FailedToTransferTokens();
    error FailedToTransferEth();
    error NotEnoughLiquidity();
    error MustDepositValue();

    /// @notice Initializes the contract with the token to be used
    ///// @param token_addr The address of the token to be used
    constructor(address token_addr) {
        token = IERC20(token_addr);
    }

    /// @notice Initializes amount of tokens and eth that will be transferred to the DEX itself
    /// @param tokens amount to be transferred to DEX
    /// @return totalLiquidity the number of LPTs minting as a result of deposits made to DEX contract
    /// @dev since ratio is 1:1, this is fine to initialize the totalLiquidity (wrt to balloons) as equal to eth
    ///      balance of contract.
    function init(uint256 tokens) public payable returns (uint256) {
        if (totalLiquidity != 0) {
            revert AlreadyHasLiquidity();
        }
        totalLiquidity = address(this).balance;
        liquidity[msg.sender] = totalLiquidity;
        bool success = token.transferFrom(msg.sender, address(this), tokens);
        if (!success) {
            revert FailedToTransferTokens();
        }

        return totalLiquidity;
    }

    /// @notice returns yOutput, or yDelta for xInput (or xDelta)
    /// @param xInput the amount of eth or tokens being swapped
    /// @param xReserves the amount of eth or tokens in the reserves
    /// @param yReserves the amount of eth or tokens in the reserves
    /// @return yOutput the amount of eth or tokens being swapped
    function price(
        uint256 xInput,
        uint256 xReserves,
        uint256 yReserves
    ) public pure returns (uint256 yOutput) {
        uint256 xInputWithFee = xInput * 997;
        uint256 numerator = xInputWithFee * yReserves;
        uint256 denominator = (xReserves * 1000) + xInputWithFee;
        return (numerator / denominator);
    }

    /// @notice returns liquidity for a user
    /// @param lp the address of the liquidity provider
    function getLiquidity(address lp) public view returns (uint256) {
        return liquidity[lp];
    }


    /// @notice sends Ether to DEX in exchange for $BAL tokens
    /// @return tokenOutput the amount of $BAL tokens being swapped
    function ethToToken() public payable returns (uint256 tokenOutput) {
        if (msg.value == 0) {
            revert MustDepositValue();
        }
        uint256 ethInput = msg.value;
        uint256 ethReserves = address(this).balance - msg.value;
        uint256 tokenReserves = token.balanceOf(address(this));
        tokenOutput = price(ethInput, ethReserves, tokenReserves);
        emit EthToTokenSwap(msg.sender, tokenOutput, ethInput);
        (bool success) = token.transfer(msg.sender, tokenOutput);
        if (!success) {
            revert FailedToTransferTokens();
        }
    }

    /// @notice sends $BAL tokens to DEX in exchange for Ether
    /// @param tokenInput the amount of $BAL tokens being swapped
    /// @return ethOutput the amount of Ether being swapped
    function tokenToEth(
        uint256 tokenInput
    ) public returns (uint256 ethOutput) {
        if (tokenInput == 0) {
            revert MustDepositValue();
        }
        uint256 tokenReserves = token.balanceOf(address(this)) - tokenInput;
        uint256 ethReserves = address(this).balance;
        ethOutput = price(tokenInput, tokenReserves, ethReserves);
        emit TokenToEthSwap(msg.sender, ethOutput, tokenInput);
        bool success = token.transferFrom(msg.sender, address(this), tokenInput);
        if (!success) {
            revert FailedToTransferTokens();
        }
        (bool sent,) = msg.sender.call{value: ethOutput}("");
        if (!sent) {
            revert FailedToTransferEth();
        }
    }

    /// @notice allows deposits of $BAL and $ETH to liquidity pool
    /// @dev The msg.value is used to determine the amount of $BAL needed and taken from the depositor and the
    ///      user has to make sure to give the DEX approval to spend their tokens on their behalf by calling the
    ///      approve function prior to this function call. Equal parts of both assets will be removed from the user's
    ///      wallet with respect to the price outlined by the AMM.
    function deposit() public payable returns (uint256 tokensDeposited) {
        if (msg.value == 0) {
            revert MustDepositValue();
        }
        uint256 ethDesired = msg.value;
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance - msg.value;
        tokensDeposited = (ethDesired * tokenReserve) / ethReserve;
        uint256 addedLiquidity = ethDesired * totalLiquidity / ethReserve;
        totalLiquidity += addedLiquidity;
        liquidity[msg.sender] += addedLiquidity;
        emit LiquidityProvided(msg.sender, addedLiquidity, ethDesired, tokensDeposited);
        bool success = token.transferFrom(msg.sender, address(this), tokensDeposited);
        if (!success) {
            revert FailedToTransferTokens();
        }
    }

    /// @notice allows withdrawal of $BAL and $ETH from liquidity pool
    /// @param amount the amount of liquidity being redeemed for underlying assets
    /// @return eth_amount the amount of Ether being withdrawn
    /// @return token_amount the amount of $BAL tokens being withdrawn
    function withdraw(
        uint256 amount
    ) public returns (uint256 eth_amount, uint256 token_amount) {
        if (liquidity[msg.sender] < amount) {
            revert NotEnoughLiquidity();
        }
        uint256 ethReserve = address(this).balance;
        uint256 tokenReserve = token.balanceOf(address(this));
        eth_amount = amount * ethReserve / totalLiquidity;
        token_amount = amount * tokenReserve / totalLiquidity;

        totalLiquidity -= amount;
        liquidity[msg.sender] -= amount;
        emit LiquidityRemoved(msg.sender, amount, token_amount, eth_amount);
        bool success = token.transfer(msg.sender, token_amount);
        if (!success) {
            revert FailedToTransferTokens();
        }
        (bool sent,) = msg.sender.call{value: eth_amount}("");
        if (!sent) {
            revert FailedToTransferEth();
        }
    }
}
