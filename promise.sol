pragma solidity ^0.4.19;
contract promise {
    string public promisor;
    string public promisorTwitterAccount;
    string public vow;
    uint public promiseDate;
    uint public endDate;

    bool public active;
    uint[3] public judgeSigning;

    uint256 public deposit;
    address public promisorAccount;
    address public opponentAccount; //or destroy them
    bool public sentMoney = false;

    address[3] public judges;
    uint[3] public voted;
    uint public fouls = 0;

    uint[3] public promiseConditionNotMet;
    uint public wrongConditions = 0;

    function promise(string _promisor, string _promisorTwitterAccount, string _vow, address _promisorAccount, address _opponentAccount, address[3] _judges, uint256 _deposit, uint _endDate) public{
        promisor = _promisor;
        promisorTwitterAccount = _promisorTwitterAccount;
        vow = _vow;
        promisorAccount = _promisorAccount;
        opponentAccount = _opponentAccount;
        judges = _judges;
        deposit = _deposit;
        promiseDate = now;
        endDate = _endDate;
    }

    function signingContractJudges(uint _number){
        require(msg.sender == judges[_number]);
        judgeSigning[_number] = 1;
    }

    function signingPromisor() payable public{
        require(msg.sender == promisorAccount);
        require(judgeSigning[0] == 1);
        require(judgeSigning[1] == 1);
        require(judgeSigning[2] == 1);
        require(!active);
        require(msg.value == deposit);

        active = true;
    }

    function addFoul(uint _number){
        require(active);
        require(msg.sender == judges[_number]);
        require(voted[_number] != 1);

        fouls = fouls + 1;
        voted[_number] = 1;
        if(fouls >= 2){
          opponentAccount.send(deposit);
          sentMoney = true;
        }
    }

    function addWrongCondition(uint _number){
        require(active);
        require(msg.sender == judges[_number]);
        require(promiseConditionNotMet[_number] != 1);

        wrongConditions = wrongConditions + 1;
        promiseConditionNotMet[_number] = 1;
        if(wrongConditions >= 2){
          promisorAccount.send(deposit);
          sentMoney = true;
        }
    }

    function sendMoneyToPromisor(){
        require(active);
        require(now >= endDate);

        promisorAccount.send(deposit);
        sentMoney = true;
    }

    function getBalance() constant returns (uint) {
      return this.balance;
    }

    function selfDestruct(){
        require(sentMoney);
        require(now >= (endDate+432000));

        selfdestruct(msg.sender);
    }
}
