pragma solidity >0.7.0 <0.9.0;

contract Creator{
    Voting[] public VotingList;
    function createVoting(address _addr, uint _start, uint _end) public {
        Voting _voting = new Voting(_addr, _start, _end);
        VotingList.push(_voting);
    }
}
contract Voting{

    address public contract_designer;
    uint public assignVotingWeight;
    uint public startVote;
    uint public endVote;
    uint AssignedWeights;
    bool public WinnerSelected;

    enum State{Started, Running, Suspended, Ended}
    struct proposal{
        string description;
        uint votesCount;
    }
    struct voter{
        uint weight;
        bool voted;
        uint votedIndex;
        address addr;
    }

    proposal[] public proposalList;
    voter[] public voterList;
    mapping(address => uint) public voters;
    State public votingState;

    constructor(address EOA, uint _startVote, uint _endVote){
        contract_designer = EOA;
        assignVotingWeight = block.timestamp;
        startVote = assignVotingWeight + _startVote;
        endVote = startVote + _endVote;
        proposalList.push(proposal("", 0));
        voterList.push(voter(0,false,0,address(0)));
    }
    
    modifier onlyDesigner{
        require (msg.sender == contract_designer, "Not authorized!");
        _;
    }
    
    modifier AssignmentStage{
        require (block.timestamp < startVote && block.timestamp > assignVotingWeight, "The voting weight assignment has ended!");
        _;
    }

    modifier VotingStarted{
        require (block.timestamp >= startVote && block.timestamp < endVote, "Not the voting time!");
        _;
    }

    modifier VotingEnded{
        require (block.timestamp > endVote, "The voting has not ended!");
        _;
    }
    
    // check voting State
    function viewVotingState() public returns(string memory){
        if (block.timestamp < startVote && block.timestamp > assignVotingWeight){
            return "The owner is initializing the proposals and assigning the voting weight!";
        }
        else if (block.timestamp >= startVote && block.timestamp < endVote){
            if (votingState == State.Suspended){
                return "The voting is suspened!";
            }
            else {
                votingState == State.Running;
            }
                return "The voting is running";
        }
        else{
            votingState = State.Ended;
            return "The voting has ended!";
        } 
            
    }

    // assign voting weight to the validators
    
    function assignWeight(uint[] memory _weight, address[] memory _addr) public onlyDesigner AssignmentStage {
        require (_weight.length == _addr.length, "The weight information is not complete!");
        uint len = voterList.length;
        for (uint i = 0; i < _weight.length; i++){
            voters[_addr[i]] = len;
            len ++;
            AssignedWeights += _weight[i];
            voter memory _voter = voter(_weight[i], false, 0, _addr[i]);
            voterList.push(_voter);
        }
    }

    // view the personal weight

    function viewPersonalWeight() public view returns(uint){
        require (msg.sender == contract_designer || voters[msg.sender]!=0, "Not authorized!");
        return voterList[voters[msg.sender]].weight;
    }

    // view the total voting weight

    function viewTotalWeights() public onlyDesigner view returns(uint) {
        return AssignedWeights;
    }
    
    // cancel someone's voting right

    function cancelVoteRright(address _addr) public {
        require (votingState == State.Suspended || (block.timestamp > assignVotingWeight && block.timestamp < startVote), "The voting need to be suspended!");

        uint voterIndex = voters[_addr];
        AssignedWeights -= voterList[voterIndex].weight;
        require (voterList[voterIndex].voted == true);
        uint proposalIndex = voterList[voterIndex].votedIndex;
        proposalList[proposalIndex].votesCount -= voterList[voterIndex].weight;

        //delete the validator

        uint lastVoter = voterList.length-1;
        address lastAddr = voterList[lastVoter].addr;
        voters[lastAddr] = voterIndex;
        voterList[voterIndex].weight = voterList[lastVoter].weight;
        voterList[voterIndex].voted = voterList[lastVoter].voted;
        voterList[voterIndex].votedIndex = voterList[lastVoter].votedIndex;
        voterList[voterIndex].addr = lastAddr;
        voters[_addr] = 0;

        voterList.pop();

    }
    
    // suspend the voting

    function suspendVoting() public onlyDesigner VotingStarted{
        require (votingState == State.Started, "The voting state cannot be changed!");
        votingState = State.Suspended;
    }

    // resume the voting

    function resumeVoting() public onlyDesigner VotingStarted{
        require (votingState == State. Suspended, "The voting is running now!");
        votingState = State.Running;
    }

    //create proposal

    function createProposal(string memory _des) public AssignmentStage{
        proposal memory _pro = proposal(_des, 0);
        proposalList.push(_pro);
    }
    function checkProposal() public view returns(string[] memory){
        string[] memory str = new string[](proposalList.length-1);
   
        for (uint i = 1; i< proposalList.length; i++){
            str[i-1] = proposalList[i].description;
        }
        return str;
    }
    
    //Voting starts

    function Vote(uint index) public VotingStarted {
        require (votingState != State.Suspended, "Voting has been suspended!");
        require (index != 0, "Invalid proposal index!");
        require (voters[msg.sender]!=0, "Not authorized!");
        require (voterList[voters[msg.sender]].voted == false, "You have voted!");

        uint voterIndex = voters[msg.sender];
        voterList[voterIndex].voted = true;
        voterList[voterIndex].votedIndex = index;

        proposalList[index].votesCount += voterList[voterIndex].weight;

    }

    //Select the winner

    function Winner() public onlyDesigner VotingEnded returns(string memory, uint){
        uint threshold = AssignedWeights/2;
        WinnerSelected = true;
        string memory _description = "No proposal got approved!";
        uint _votesCount = 0;
        while(proposalList.length != 1){
            if (proposalList[1].votesCount >= threshold){
                _description = proposalList[1].description;
                _votesCount = proposalList[1].votesCount;
            }
            proposalList[1].description = proposalList[proposalList.length-1].description;
            proposalList[1].votesCount = proposalList[proposalList.length-1].votesCount;

            proposalList.pop();
        }
        
        return (_description, _votesCount);

    }

    // Reset the validators

    function Reset() public onlyDesigner VotingEnded{
        require(WinnerSelected == true, "The winner has not been selected!");

        for (uint i = 1; i < voterList.length; i++){
            voterList[i].voted = false;
            voterList[i].votedIndex = 0;
        }

    }


}