pragma solidity >=0.7.0 <0.9.0;

contract ContractLender {
    address private owner;
    uint256 balance;
    
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
    
    uint rate = 1;
    uint id = 1;
    
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
        Loan memory myLoan; //TODO: Change
        myLoan.id = id;
        myLoan.borrower = msg.sender;
        myLoan.amountBorrowed = amount * 100;
        myLoan.amountLeft = amount * (100 * rate);
        myLoan.loanRate = rate;
        myLoan.state;
        
        idToLoan[id] = myLoan;
        clientToLoansId[msg.sender].push(myLoan.id);
        requestIds.push(id);
        
        id++;
        return myLoan.id;
    }
}