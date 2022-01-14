pragma solidity >=0.7.0 <0.9.0;

contract Lottery{

    address public manager; // the one who controls this lottery.
    address payable[] public players; 
    //uint public redeemIndex;
    //uint public constant serviceFee = 0.1 ether;
    constructor() public {
        manager = msg.sender;
    }
    
    modifier onlyBy(){
        require(msg.sender == manager, "Not Manager!");
        _;
    }
    receive() external payable{
        require (msg.value == 0.01 ether, "Not enough Ether!");
        require (msg.sender != manager, "Manager cannot participate the Lottery!");
        players.push(payable(msg.sender));
    }
    fallback() external payable{}

    /*function generateWinner()public returns(uint){
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        redeemIndex = rand % players.length;
        return redeemIndex;
    }
    */
    
    function getBalance() public onlyBy() view returns(uint){
        return address(this).balance;
    }

    function redeem() payable public {
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        uint redeemIndex = rand % players.length;
        uint serviceFee = 0.1 ether;
        players[redeemIndex].transfer(address(this).balance);
        players = new address payable[](0);
    }

    

    


}