// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChainConnectToken is ERC20, ERC20Burnable,ERC20Pausable, Ownable  {
    constructor(uint256 initialSupply) ERC20("ChainConnectToken", "CCT") Ownable(msg.sender) {
        uint256 _totalSupply = initialSupply * 10 ** 6;
        _mint(msg.sender, _totalSupply);
    }
    function burn(uint256 value) public override  virtual {
        _burn(_msgSender(), value);
    }

       function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }


    

}