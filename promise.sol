pragma solidity ^0.4.19;
contract promise{
    string public vow;
    address public promisor;
    address public beneficiary;
    uint256 public deposit;
    uint public endDate;
    address[3] public judges;

    uint[3] public signedByJudge;
    bool public signedByPromisor;

    uint[3] public votedFoul;
    uint public foulVotes = 0;
    uint[3] public votedShy;
    uint public shyVotes = 0;
    uint[3] public votedSuccess;
    uint public successVotes = 0;

    bool public sentMoney = false;

    constructor(address _promisor, string _vow, uint256 _deposit, uint _endDate, address[3] _judges, address _beneficiary) public{
        promisor = _promisor;
        vow = _vow;
        deposit = _deposit;
        endDate = _endDate;
        judges = _judges;
        beneficiary = _beneficiary;
    }

    function getBalance() constant returns(uint){
      return this.balance;
    }

    function judgeSigns(uint _number){
        require(msg.sender == judges[_number]);
        signedByJudge[_number] = 1;
    }

    function promisorSigns() payable public{
        require(msg.sender == promisor);
        require(signedByJudge[0] == 1);
        require(signedByJudge[1] == 1);
        require(signedByJudge[2] == 1);
        require(!signedByPromisor);
        require(msg.value == deposit);

        signedByPromisor = true;
    }

    function voteFoul(uint _number){
        require(signedByPromisor);
        require(msg.sender == judges[_number]);
        require(votedFoul[_number] != 1);
        require(votedShy[_number] != 1);
        require(votedSuccess[_number] != 1);

        foulVotes = foulVotes + 1;
        votedFoul[_number] = 1;
        if(foulVotes >= 2){
          beneficiary.send(deposit);
          sentMoney = true;
        }
    }

    function voteShyOfCondition(uint _number){
        require(signedByPromisor);
        require(msg.sender == judges[_number]);
        require(votedShy[_number] != 1);
        require(votedFoul[_number] != 1);

        shyVotes = shyVotes + 1;
        votedShy[_number] = 1;
        if(shyVotes >= 2){
          promisor.send(deposit);
          sentMoney = true;
        }
    }

    function voteSuccess(uint _number){
        require(signedByPromisor);
        require(msg.sender == judges[_number]);
        require(votedSuccess[_number] != 1);
        require(votedFoul[_number] != 1);

        successVotes = successVotes + 1;
        votedSuccess[_number] = 1;
        if(successVotes >= 2){
          promisor.send(deposit);
          sentMoney = true;
        }
    }

    function selfDestruct(){
      require(sentMoney);
      require(now >= (endDate+432000));

      selfdestruct(msg.sender);
    }
}
