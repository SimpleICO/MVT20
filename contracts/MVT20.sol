pragma solidity >=0.4.21 <0.6.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "./SimpleWhitelist.sol";

/**
 * @title Security Token ERC20 token
 *
 * @dev Implementation of a Security Token
 *
 * The ST20 comes with a whitelisting functionality.
 * Tokens may only be transferred if the holder is whitelisted by a WhitelistAdmin
 */

contract MVT20 is ERC20, ERC20Detailed, SimpleWhitelist {

    constructor (
        uint256 supply,
        string memory name, 
        string memory symbol, 
        uint8 decimals) 
        public 
        ERC20Detailed (
            name,
            symbol, 
            decimals
        ) 
    {
        _mint(msg.sender, supply);
    }

    /**
    * @dev Transfer token for a specified address if the sender is whitelisted
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        require(isWhitelisted(to));
        super.transfer(to, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another if the sender is whitelisted
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(isWhitelisted(to));
        super.transferFrom(from, to, value);
        return true;
    }
}