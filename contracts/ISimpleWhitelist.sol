pragma solidity >=0.4.21 <0.6.0;

interface ISimpleWhitelist {

    event RequestedMembership(address indexed account);
    event RemovedMembershipRequest(address indexed account, address indexed whitelistAdmin);

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin;

    function renounceWhitelistAdmin() public;

    function addWhitelisted(address account) public onlyWhitelistAdmin;

    function removeWhitelisted(address account) public onlyWhitelistAdmin;

    function renounceWhitelisted() public;

    function requestMembership() public;

    function revokeMembershipRequest(address account) public onlyWhitelistAdmin;

    function pendingWhitelistRequests() public view returns(address[] memory addresses);
    
    function members() public view returns(address[] memory addresses);
    
    function adminMembers() public view returns(address[] memory addresses);
    
}