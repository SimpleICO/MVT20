pragma solidity >=0.4.21 <0.6.0;

import "../node_modules/openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol";

contract SimpleWhitelist is WhitelistedRole {

    mapping(address => uint256) private whitelistAdminsIndex;
    address[] public whitelistAdmins;
    mapping(address => uint256) private whitelistedsIndex;
    address[] public whitelisteds;

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        whitelistAdmins.push(account);
        whitelistAdminsIndex[account] = whitelistAdmins.length + 1;
        super.addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        require(whitelistAdminsIndex[msg.sender] != 0);
        uint256 index = whitelistAdminsIndex[msg.sender];
        delete whitelistAdmins[index];
        super._removeWhitelistAdmin(msg.sender);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        whitelisteds.push(account);
        whitelistedsIndex[account] = whitelisteds.length + 1;
        super.addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        require(whitelistedsIndex[account] != 0);
        uint256 index = whitelistedsIndex[account];
        delete whitelisteds[index];
        super.removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        require(whitelistedsIndex[msg.sender] != 0);
        uint256 index = whitelistedsIndex[msg.sender];
        delete whitelisteds[index];
        super._removeWhitelisted(msg.sender);
    }
}