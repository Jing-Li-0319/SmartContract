//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;


contract CryptoTokenCreator{ //scalability
    address public creator;
    CryptoToken[] public CryptoList;
    constructor() {
        creator = msg.sender;
    }

    function createNewCryptoToken(string memory _name, string memory _symbol, uint _totalSupply, uint _decimal) public {
        CryptoToken crypto = new CryptoToken(msg.sender, _name, _symbol, _totalSupply, _decimal);
        CryptoList.push(crypto);
    } 

}

contract CryptoToken{
    
    address public minter;
    string public name;
    string public symbol;
    uint public immutable totalSupply;
    uint public immutable decimal;
    enum State{Started, Running, Suspended, Ended}
    mapping(address => uint) public balances;
    mapping(address => mapping (address => uint)) public allowed;
    State public CoinState;
    event TransferCoin(address _from, address _to, uint _amount);

    constructor(address eoa, string memory _name, string memory _symbol, uint _totalSupply, uint _decimal){
        minter = eoa;
        name = _name;
        symbol = _symbol;
        CoinState = State.Running;
        totalSupply = _totalSupply;
        decimal = _decimal;
        balances[eoa] = _totalSupply;
    }
    
    modifier onlyMinter() {
        require (msg.sender == minter, "Not authorized!");
        _;
    }

    modifier isRunning() {
        require (CoinState == State.Running,"The minting is not running!");
        _;
    }

    modifier checkBalance(address _to, uint _amount){
        require (_to != address(0) && _amount <= balances[msg.sender], "Not enough balance!");
        _;
    }

    function startMinting() public onlyMinter{
        CoinState = State.Running;
    }

    function Minting(address receiver, uint amount) public onlyMinter isRunning{
        balances[receiver] += amount;
    }
    function Transfer(address to, uint amount) public checkBalance(to,amount){
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit TransferCoin (msg.sender, to, amount);
    }
    function SuspendMint() public onlyMinter{
        CoinState = State.Suspended;
    }
    function getBalance(address _addr) public view returns(uint){
        return balances[_addr];
    }
    
    // credit system
    function remainingAllowance(address _sender, address _receiver) public view returns(uint){
        return allowed[_sender][_receiver];
    }
    function approveAllowance(address _receiver, uint _amount) public{
        require (_amount > 0 && _amount <= balances[msg.sender], "Not enough money!");
        require (_receiver != address(0),"Not valid address!");
        allowed[msg.sender][_receiver] = _amount;
    }
    function getAllowance(address _sender, uint _amount) public{
        require (allowed[_sender][msg.sender] > 0, "No allowance available!");
        require (_amount >0 && _amount <= allowed[_sender][msg.sender], "Not valid amount!");
        require (_amount <= balances[_sender], "The sender do not have enough money!");

        allowed[_sender][msg.sender] -= _amount;
        balances[_sender] -= _amount;
        balances[msg.sender] += _amount;
    }

}

