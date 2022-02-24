//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
* @title ReserveBondingCurve
* @author Carson Case (carsonpcase@gmail.com)
* @dev library contract to allow for easy reserve ratios enabled by bonding curves. Does the math for ERC20s
 */
library ReserveBondingCurve {

    uint constant ONE_HUDNRED_PERCENT = 100;

    /**
    * @dev returns the amount of debt tokens to be given for the amount of payment tokens input
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
    * @dev returns the amount of payment tokens to be given for the amount of payment tokens input
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
        reserve ratio is for payment tokens.
        so a reserver ratio of 20% means that 20% of the debt token supply must be stored in this contract for exchange 1:1
     */
    function _getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint _reserveRatio, bool purchaseIn) private pure returns(uint){
        uint amountInWithFee = amountIn;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = ((reserveIn) + ((ONE_HUDNRED_PERCENT - _reserveRatio) * amountInWithFee));
        return purchaseIn ? 
        (numerator * _reserveRatio) / ((denominator) * ONE_HUDNRED_PERCENT) : 
        (numerator * ONE_HUDNRED_PERCENT) / ((denominator) * _reserveRatio); 
    }

}
