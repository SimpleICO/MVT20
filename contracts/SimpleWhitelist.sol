pragma solidity >=0.4.21 <0.6.0;

import "../node_modules/openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol";

contract SimpleWhitelist is WhitelistedRole {

    event RequestedMembership(address indexed account);
    event RemovedMembershipRequest(address indexed account, address indexed whitelistAdmin);

    mapping(address => uint256) private _whitelistAdminsIndex;
    address[] private _adminMembers;
    
    mapping(address => uint256) private _whitelistedsIndex;
    address[] private _members;
    
    mapping(address => uint256) private _pendingRequestsIndex;
    address[] private _pendingWhitelistRequests;

    constructor () public {
        _adminMembers.push(msg.sender);
        _members.push(msg.sender);
        _whitelistAdminsIndex[msg.sender] = _adminMembers.length;
        _whitelistedsIndex[msg.sender] = _members.length;
        super._addWhitelisted(msg.sender);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _adminMembers.push(account);
        _whitelistAdminsIndex[account] = _adminMembers.length;
        super._addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        uint256 index = _whitelistAdminsIndex[msg.sender];
        require(index > 0);
        delete _adminMembers[index-1];
        super._removeWhitelistAdmin(msg.sender);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _members.push(account);
        _whitelistedsIndex[account] = _members.length;
        super._addWhitelisted(account);
        if (_pendingRequestsIndex[account] > 0) {
            revokeMembershipRequest(account);
        }
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        uint256 index = _whitelistedsIndex[account];
        require(index > 0);
        delete _members[index-1];
        super._removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        uint256 index = _whitelistedsIndex[msg.sender];
        require(index > 0);
        delete _members[index-1];
        super._removeWhitelisted(msg.sender);
    }

    function requestMembership() public {
        require(_pendingRequestsIndex[msg.sender] == 0);
        require(!isWhitelisted(msg.sender));
        _pendingWhitelistRequests.push(msg.sender);
        _pendingRequestsIndex[msg.sender] = _pendingWhitelistRequests.length;
        emit RequestedMembership(msg.sender);
    }

    function revokeMembershipRequest(address account) public onlyWhitelistAdmin {
        uint256 index = _pendingRequestsIndex[account];
        require(index > 0);
        delete _pendingWhitelistRequests[index-1];
        emit RemovedMembershipRequest(account, msg.sender);
    }

    function pendingWhitelistRequests() public view returns(address[] memory addresses) {
        return _pendingWhitelistRequests;
    }
    
    function members() public view returns(address[] memory addresses) {
        return _members;
    }
    
    function adminMembers() public view returns(address[] memory addresses) {
        return _adminMembers;
    }
}