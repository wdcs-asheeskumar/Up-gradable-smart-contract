// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNewToken is ERC20, ERC20Burnable, Ownable {
    address public taxCollector;
    uint256 public currentTaxDeducted;
    uint256 public grossTaxCollected;

    mapping(address => mapping(address => uint256))public _taxRecord;
    constructor(address initialOwner, uint amount, address _taxCollector)
        ERC20("MyNewToken", "MNTK")
        Ownable(initialOwner)
    {
        taxCollector = _taxCollector;
        _mint(initialOwner,amount * (10 **(decimals())));
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(to == msg.sender, "Minting allowed only to owner");
        _mint(to,amount * (10 **(decimals())));
    }

    function decimals()public view virtual override returns(uint8){
        return 9;
    }

    function transfer(address to, uint value) public virtual override returns(bool) {
        currentTaxDeducted = (5 * value)/100;
        uint transferAmount = value - currentTaxDeducted;
        grossTaxCollected = grossTaxCollected + currentTaxDeducted;
        address _taxCollector = taxCollector;
        _transfer(msg.sender, taxCollector, currentTaxDeducted);
        _transfer(msg.sender, to, transferAmount);
        _taxRecord[_taxCollector][to] += currentTaxDeducted;
        return true;

    }
}