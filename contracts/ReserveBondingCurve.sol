//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
* @title ReserveBondingCurve
* @author Carson Case (carsonpcase@gmail.com)
* @dev library contract to allow for easy reserve ratios enabled by bonding curves. Does the math for ERC20s
* NOTE
* This contract refrences two types of ERC20s defined as follows:
* - Payment Token
*   - Token deposited and held in reserve. Think colloquially of gold for USD.
* - Debt Token
*   - Token returned to represent ownership of payment tokens. Think colloquially of USD to be exchanged for gold
 */
library ReserveBondingCurve {

    uint constant ONE_HUDNRED_PERCENT = 10000;

    /**
    * @dev returns the amount of debt tokens to be given for the amount of payment tokens input.
    * @param _amount the amount of payment tokens to be deposited
    * @param _paymentTokenReserve the amount of payment tokens currently in reserve, meaning they are available for exchange with debt tokens
    * @param _debtTokenTotalSupply the total supply of debt tokens
    * @param _reserveRate the rate of reserve. If 20%, then 20% of payment token reserve is essentially treated as if it was 100% in the y=xk Bonding Curve. 
    *   example:
    *   1:1 token price exists at a PaymentToken Reserve of 20 and a debtTokenTotalSupply of 100
    *   even though there are 5x as many debt tokens as payment tokens to pay them back, the exchange rate is still treated 1:1, only the curve is 5x steeper to accommodate bank runs
     */
    function getDepositAmount(uint _amount, uint _paymentTokenReserve, uint _debtTokenTotalSupply, uint _reserveRate) external pure returns(uint out){
        out = _getAmountOut(
            _amount,
            _paymentTokenReserve,                        // payment token is reserve in
            _debtTokenTotalSupply,                       // debt token is reserve out
            _reserveRate,
            true
        );
    }

    /**
    * @dev the same function as above but for withdrawals: exchanges of debt token back to payment token.
     */
    function getWithdrawalAmount(uint _amount, uint _paymentTokenReserve, uint _debtTokenTotalSupply, uint _reserveRate) external pure returns(uint out){
        out = _getAmountOut(
            _amount, 
            _debtTokenTotalSupply,                      // debt token supply is reserve in, 
            _paymentTokenReserve,                       // payment token is reserve out
            _reserveRate,
            false
        );
    }

    /**
    * @dev function with the uniswap bonding curve logic but with the reserve ratio logic thrown in
     */
    function _getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint _reserveRatio, bool purchaseIn) internal pure returns(uint){
        uint amountInWithFee = amountIn;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = ((reserveIn) + ((ONE_HUDNRED_PERCENT - _reserveRatio) * amountInWithFee)/ ONE_HUDNRED_PERCENT);
        return purchaseIn ? 
        (numerator * _reserveRatio) / ((denominator) * ONE_HUDNRED_PERCENT) : 
        (numerator * ONE_HUDNRED_PERCENT) / ((denominator) * _reserveRatio); 
    }

}
