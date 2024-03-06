// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLoan {
    address public borrower;
    uint256 public loanAmount;
    uint256 public interestRate;
    uint256 public loanDuration;
    uint256 public totalRepayment;

    constructor(uint256 _loanAmount, uint256 _interestRate, uint256 _loanDuration) {
        borrower = msg.sender;
        loanAmount = _loanAmount;
        interestRate = _interestRate;
        loanDuration = _loanDuration;
        totalRepayment = calculateTotalRepayment();
    }

    function calculateTotalRepayment() internal view returns (uint256) {
        return loanAmount + (loanAmount * interestRate * loanDuration / 100);
    }
}
