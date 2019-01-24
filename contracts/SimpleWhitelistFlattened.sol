pragma solidity >=0.4.21 <0.6.0;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
// input  /Users/GustavoIbarra/Projects/Solidity/SimpleWhitelist/contracts/SimpleWhitelist.sol
// flattened :  Thursday, 24-Jan-19 18:50:31 UTC
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

contract WhitelistedRole is WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

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
