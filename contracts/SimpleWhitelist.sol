pragma solidity >=0.4.21 <0.6.0;

import "../node_modules/openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol";

contract SimpleWhitelist is WhitelistedRole {

    event RequestedMembership(address indexed account);
    event RevokedMembership(address indexed account);

    mapping(address => uint256) private whitelistAdminsIndex;
    address[] public whitelistAdmins;
    
    mapping(address => uint256) private whitelistedsIndex;
    address[] public whitelisteds;
    
    mapping(address => uint256) private pendingRequestsIndex;
    address[] public pendingWhitelistRequests;

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

    function requestMembership() public {
        require(pendingRequestsIndex[msg.sender] == 0);
        pendingWhitelistRequests.push(msg.sender);
        emit RequestedMembership(msg.sender);
    }

    function revokeMembershipRequest(address account) public onlyWhitelistAdmin {
        require(pendingRequestsIndex[account] != 0);
        uint256 index = pendingRequestsIndex[account];
        delete pendingWhitelistRequests[index];
        emit RevokedMembership(msg.sender);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        whitelisteds.push(account);
        whitelistedsIndex[account] = whitelisteds.length + 1;
        super.addWhitelisted(account);
        if (pendingRequestsIndex[account] != 0) {
            revokeMembershipRequest(account);
        }
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