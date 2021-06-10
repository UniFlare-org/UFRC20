pragma solidity ^0.8.4; // SPDX-License-Identifier: MIT
    /**
     * 
     * 
     * UFRC20 - A secure and optimized token standard made with Flare Network in  mind.
     * 
     * 
     * 
     */
import './libraries/SafeMath.sol';
import './libraries/auth.sol';
import './libraries/address.sol';
import './libraries/ReentrancyGuard.sol';
import './interfaces/IUFRC20.sol';
contract DeflatingUFRC20 is auth, ReentrancyGuard, IUFRC20 {
    using SafeMath for uint;

    string public _name;
    string public _symbol;
    uint8 public constant _decimals = 18;
    uint  public _totalSupply;
    mapping(address => uint) internal _balanceOf;
    mapping(address => mapping(address => uint)) internal _allowance;
    uint taxRate = 1;
    bytes32 public DOMAIN_SEPARATOR;
    //	//	//	//	//	// keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) public nonces;

    constructor(uint startSupply_, string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(_name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
        _mint(_msgSender(), startSupply_*10**18);
    }
    
    fallback() external {  // fallback protection
        Stop();
        }
    
    function Stop() public pure returns (bool){
        return false;
        }     

    receive() external payable {
        Stop(); 
        } // end fallback protection
    
    function setTax(uint _taxRate) public onlyOwner{
       taxRate = _taxRate; 
        
    }
    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balanceOf[account];
    }
    function getOwner() external view override returns (address) {
        return _owner;
    }

        function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowance[owner][spender];
    }
    
    function _mint(address to, uint value) internal {
        _totalSupply = _totalSupply.add(value);
        _balanceOf[to] = _balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }
    
    function mint(address to, uint value) public govern {
       _mint(to, value); 
    }
    
    function _burn(address from, uint value) internal {
        _balanceOf[from] = _balanceOf[from].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function burn(address from, uint value) public govern {
        _burn(from, value);
    }

    function _approve(address owner, address spender, uint value) private {
        _allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) internal nonReentrant returns (bool) {
        uint burnAmount = value / 100;
        _burn(from, burnAmount);
        uint transferAmount = value.sub(burnAmount);
        _balanceOf[from] = _balanceOf[from].sub(transferAmount);
        _balanceOf[to] = _balanceOf[to].add(transferAmount);
        emit Transfer(from, to, transferAmount);
        return true;
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) public override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public override returns (bool) {
        if (_allowance[from][msg.sender] >= value) {
            _allowance[from][msg.sender] = _allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, 'EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}
