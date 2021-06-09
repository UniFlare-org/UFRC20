pragma solidity ^0.8.4;  // SPDX-License-Identifier: MIT
import "./Context.sol";
contract auth is Context {
    address public _owner;
    mapping (address => bool) internal _gov;
    mapping (address => bool) internal _authList;
    mapping (address => bool) internal _adminList;
    mapping (address => bool) internal _blackList;
    constructor() { 
        _owner = msg.sender; 
    }
 
    function isOwner(address account) public view returns (bool) {
    if (account == _owner) {return true;} else {return false;}
    }
    
    function isGovern(address account) public view returns (bool) {
        return _gov[account];
    }
        
    function isAdmin(address account) public view returns (bool) {
        return _adminList[account];
    }
    
    function isAuth(address account) public view returns (bool) {
        return _authList[account];
    }

    function isBanned(address account) public view returns (bool) {
        return _blackList[account];
    }
    
    modifier onlyOwner() { require(isOwner( _msgSender())); _;}
    
    modifier govern() {    require(isGovern( _msgSender()) ); _;}
        
    modifier admin() {    require(isAdmin( _msgSender()) ); _;}

    modifier _auth() {    require(isAuth( _msgSender()) ); _;}
    
    modifier _banCheck() {  require(!isBanned( _msgSender()) ); _;}
    
        
    function makeGov(address adr) public onlyOwner {
        _gov[adr] = true;
    }
    function takeAGov(address adr) public onlyOwner {
        _gov[adr] = false;
    }
        
    function makeAdmin(address adr) public onlyOwner {
        _adminList[adr] = true;
    }
    function takeAdmin(address adr) public onlyOwner {
        _adminList[adr] = false;
    }
        
    function makeAuth(address adr) public admin {
        _authList[adr] = true;
    }
    function takeAuth(address adr) public admin {
        _authList[adr] = false;
    }
    
   function banAddress(address adr) public admin {
        _blackList[adr] = true;
    }
    function unbanAddress(address adr) public admin {
        _blackList[adr] = false;
    }
    
    function transferOwnership(address payable adr) public onlyOwner {
        _owner = adr;
    }
}
