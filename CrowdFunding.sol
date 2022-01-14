pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding{

    address public manager;
    mapping(address => uint) public contributorList;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline;
    uint public goal;
    uint public raisedAmount;
    
    struct Request{
        string description;
        address payable recipient;
        uint amount;
        bool completed;
        uint noOfVoters;
        mapping (address => bool) voters; // struct contains mapping cannot declare an array;
    }
    
    mapping (uint => Request) public RequestList;
    uint public noOfRequest;

    constructor(uint _minimumContribution, uint _deadline, uint _goal){
        minimumContribution = _minimumContribution;
        deadline = block.timestamp + _deadline;
        goal = _goal;
        manager = msg.sender;
    }

    modifier onlyManager(){
        require (msg.sender == manager,"Only manager can send spending request!");
        _;
    }

    modifier checkBalance(){
        require (msg.value >= minimumContribution);
        _;
    }

    modifier isActive(){
        require (block.timestamp <= deadline, "The campaign has ended!");
        _;
    }

    function Contribution() public payable checkBalance isActive{
        if (contributorList[msg.sender] == 0){
            noOfContributors ++;
        }
        contributorList[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    receive() external payable{
        Contribution();
    }
    fallback() external payable{}

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getRefund() public payable{
        require(block.timestamp > deadline && raisedAmount < goal);
        require(contributorList[msg.sender] > 0);

        payable (msg.sender).transfer(contributorList[msg.sender]);
        noOfContributors --;
        raisedAmount -= contributorList[msg.sender];
        contributorList[msg.sender] = 0;
    }

    function createRequest(string memory _des, address payable _recipient, uint _amount) public onlyManager {
        Request storage spendingRequest = RequestList[noOfRequest];
        noOfRequest ++;

        spendingRequest.description = _des;
        spendingRequest.recipient = _recipient;
        spendingRequest.amount = _amount;
        spendingRequest.completed = false;
        spendingRequest.noOfVoters = 0;
    }

    function voteRequest(uint _index) public {
        require (contributorList[msg.sender] > 0, "Only the contributor can vote on the request!");
        Request storage curr = RequestList[_index];
        require (curr.voters[msg.sender] == false);
        RequestList[_index].noOfVoters ++;
        curr.voters[msg.sender] == true;
        
    }

    function payRequest(uint _index) public payable onlyManager {
        require (raisedAmount >= goal, "The campaign has not ended!");
        require (RequestList[_index].completed == false, "The request has been completed!");
        require (RequestList[_index].noOfVoters > noOfContributors / 2, "Not enough votes on the request!");

        RequestList[_index].recipient.transfer(RequestList[_index].amount);
        RequestList[_index].completed = true;


    }
    
}