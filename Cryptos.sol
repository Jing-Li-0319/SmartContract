//SPDX-License-Identifier: MIT;
pragma solidity >=0.7.0 <0.9.0;

interface ERC20{

    function name() external  returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining); 

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

library SafeMath{
    
    function add(uint a, uint b) public pure returns(uint){
        uint c = a + b;
        require (c >= a && c >= b);
        return c;
    }
    function sub(uint a, uint b) public pure returns(uint){
        require (a >= b);
        uint c = a - b;
        return c;
    } 
    function div(uint256 a, uint256 b) public pure returns (uint256) {
        require(b > 0); 
        uint256 c = a / b;
    
        return c;
    }
}

    
contract Cryptos is ERC20{

    using SafeMath for uint;
    string public override constant name = "Cryptos";
    string public override constant symbol = "UHCT";
    uint8 public override constant decimals = 0;
    uint256 public override totalSupply;
    address public owner;
    uint public start;
    uint public end;
    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint)) public allowed;

    constructor(){
        owner = msg.sender;
        totalSupply = 1000000;
        balances[owner] = totalSupply;
    }
    
    
    function balanceOf(address _owner) public override view returns (uint){
        return balances[_owner];
    }
    function transfer(address _to, uint256 _value) public virtual override returns (bool){
        require (_value <= balances[msg.sender], "Not enough money!");
        balances[msg.sender].sub(_value);
        balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public override returns (bool){
        require (_value > 0 && _value <= balances[msg.sender], "Not valid amount!");
        require (_spender != address(0),"Not valid spender address!");

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public override view returns (uint256){
        return allowed[_owner][_spender];
    }
    function transferFrom(address _from, address _to, uint256 _value) public virtual override view returns (bool){
        require (_value > 0 && _value <= allowed[_from][_to]);
        require (_value <= balances[_from]);

        balances[_from].sub(_value);
        allowed[_from][_to].sub(_value);
        balances[_to].add(_value);
        return true;

    }

    
}