//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
* @title ReserveBondingCurve
* @author Carson Case (carsonpcase@gmail.com)
* @dev contract to allow for easy reserve ratios enabled by bonding curves. Just does math. Nothing with tokens
 */
contract ReserveBondingCurve {
    uint public ONE_HUDNRED_PERCENT = 100;
    uint public reserveRatio;

    uint private paymentTokenBalance;      // these are for testing only
    uint private debtTokenSupply;          // in production their return functions will be overriden

    /// @param _reserveRate is the percent of payment token out of ONE_HUNDRED_PERCENT that is required to remain in contract
    constructor(uint _reserveRate){
        reserveRatio = _reserveRate;
    }
    
    /**
    * @dev function for testing */
    function setPaymentTokenBalance(uint num) external{
        paymentTokenBalance = num;
    }

    /**
    * @dev function for testing
     */
    function setDebtTokenSupply(uint num) external{
        debtTokenSupply = num;
    }

    /**
    * @dev returns the amount of debt tokens to be given for the amount of payment tokens input
     */
    function getDebtTokensForPayment(uint amount) external returns(uint out){
        out = _getAmountOut(amount, _getPaymentTokenBalance(), _getDebtTokenSupply(), true);
    }

    /**
    * @dev returns the amount of payment tokens to be given for the amount of payment tokens input
     */
    function getPaymentTokensForDebtTokens(uint amount) external virtual returns(uint out){
        out = _getAmountOut(amount, _getDebtTokenSupply(), _getPaymentTokenBalance(), false);
    }

    /**
    * @dev gets the amount of liquid payment tokens in this contract
        override with balance getter
     */
    function _getPaymentTokenBalance() internal virtual returns(uint){
        return paymentTokenBalance;
    }

    /**
    * @dev gets the total supply of debt tokens owed
     */
    function _getDebtTokenSupply() internal virtual returns(uint){
        return debtTokenSupply;
    }

    /**
    * @dev function with the uniswap bonding curve logic but with the reserve ratio logic thrown in
        reserve ratio is for payment tokens.
        so a reserver ratio of 20% means that 20% of the debt token supply must be stored in this contract for exchange 1:1
     */
    function _getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, bool purchaseIn) private view returns(uint){
        uint amountInWithFee = amountIn;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = ((reserveIn) + amountInWithFee);
        return purchaseIn ? 
        (numerator * reserveRatio) / ((denominator) * ONE_HUDNRED_PERCENT) : 
        (numerator * ONE_HUDNRED_PERCENT) / ((denominator) * reserveRatio); 
    }

}
