// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract LenderContract {
    address private owner;
    uint256 private balance;
    
    enum LoanState{ REQUESTED, GRANTED, DENIED, PAID_BACK }
    
    struct Loan {
        uint id; 
        address borrower;
        uint amountBorrowed;
        uint amountLeft;
        uint loanRate;
        LoanState state;
    }
    
    mapping(uint => Loan) public idToLoan;
    mapping(address => uint[]) public clientToLoansId;
    uint[] public requestIds;
    
    uint rateInBps = 20;
    uint nextId = 1;
    
    LenderContract public secondBank = LenderContract(0x97af3436acA4c78b9d431c43a0Ae5479eCbB796D);
    
    constructor() {
        owner = msg.sender;
    }
    
    function getBalance() public view returns (uint256){
        return balance;
    }
    
    function sendFunds() public payable isOwner {
       balance += msg.value;
    }
    
    function retreiveFunds() public isOwner {
       payable(msg.sender).transfer(balance);
    }
    
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    function request(uint amount) public returns (uint){
        Loan memory loan = Loan({
            id: nextId,
            borrower: msg.sender,
            amountBorrowed: amount,
            amountLeft: amount * (1 + rateInBps/1000),
            loanRate: rateInBps,
            state: LoanState.REQUESTED
        });
        idToLoan[loan.id] = loan;
        clientToLoansId[msg.sender].push(loan.id);
        requestIds.push(loan.id);
        nextId++;
        return loan.id;
    }
    
    function getRequestIds() public view returns (uint[] memory) {
        return requestIds;
    }
    
    function respondToLoan(uint _loanId, bool _accepted) public isOwner {
        require(requestIds[_loanId] != 0, "This loan does not exist or has already been responded to.");
        if(_accepted) {
            require(balance > idToLoan[_loanId].amountBorrowed, "Contract has insufficient funds");
            idToLoan[_loanId].state = LoanState.GRANTED;
            payable(idToLoan[_loanId].borrower).transfer(idToLoan[_loanId].amountBorrowed);
        } else {
            idToLoan[_loanId].state = LoanState.DENIED;
        }
        delete requestIds[_loanId];
    }
    
    function replayLoan(uint _loanId) public payable {
        require(idToLoan[_loanId].id != 0, "This loan does not exist.");
        require(idToLoan[_loanId].amountLeft - msg.value < 0, "Too much money.");
        idToLoan[_loanId].amountLeft -= msg.value;
        if(idToLoan[_loanId].amountLeft == 0) {
            idToLoan[_loanId].state = LoanState.PAID_BACK;
        }
    }
}