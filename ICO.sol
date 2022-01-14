
pragma solidity >=0.7.0 <0.9.0;

import "./Cryptos.sol";



contract CryptoICO is Cryptos{
    address public admin;
    address payable public deposit;
    uint public hardCap;
    uint public tokenPrice;
    uint public raisedAmount;
    uint public ICOstart;
    uint public ICOend;
    uint public maxInvestment;
    uint public minInvestment;
    uint public lockingPeriod;
 

    enum State {Initializing, Running, Halted, Ended}
    State public ICOstate;
    
    event Invest(address _investor, uint _value, uint _tokenCount);

    constructor(address payable _deposit){
        admin = msg.sender;
        deposit = _deposit;
        hardCap = 100 ether;
        tokenPrice = 0.1 ether;
        ICOstart = block.timestamp;
        ICOend = ICOstart + 604800;
        maxInvestment = 1 ether;
        minInvestment = 0.1 ether;
        ICOstate = State.Running;
        lockingPeriod = ICOend + 604800;
    }

    modifier onlyAdmin(){
        require (msg.sender == admin, "Not the admin!");
        _;
    }
    
    function halt() public onlyAdmin{
        ICOstate = State.Halted;
    }
    
    function resume() public onlyAdmin{
        ICOstate = State.Running;
    }
    
    function getICOstate() public returns(State){
        if (block.timestamp >= ICOend){
            ICOstate = State.Ended;
        }
        
        return ICOstate;
    }

    function changeDepositAddress(address payable newEOA) public onlyAdmin{
        deposit = newEOA;
    }

    function invest() payable public returns(bool){
        require (msg.value >= minInvestment && msg.value <= maxInvestment, "Invalid amount!");
        State currentState = getICOstate();
        require (currentState == State.Running, "ICO is not running!");

        raisedAmount = SafeMath.add(raisedAmount, msg.value);
        require (raisedAmount <= hardCap);

        deposit.transfer(msg.value);//ether
        uint tokenCount = SafeMath.div(msg.value, tokenPrice);
        balances[owner] = SafeMath.sub(balances[owner], tokenCount);//token
        balances[msg.sender] = SafeMath.add(balances[msg.sender], tokenCount);
        
        emit Invest(msg.sender, msg.value, tokenCount);
        return true;
    }

    receive() external payable{
        invest();
    }

    function transfer(address _to, uint256 _value) public override returns (bool){
        require (block.timestamp > lockingPeriod);
        super.transfer(_to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public override view returns (bool){
        require (block.timestamp > lockingPeriod);
        super.transferFrom(_from, _to, _value);
        return true;

    }
    //burning the tokens: if the raised amount is less than hardCap, we can burn the remaining tokens to increase the price;
    function burnTokens()public returns(bool){
        require (getICOstate() == State.Ended);
        balances[admin] == 0;
        return true;
    }



}
