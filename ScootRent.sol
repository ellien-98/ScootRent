// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScootRent{
    address owner;

    constructor(){
        owner = msg.sender;
    }

    struct Rider{
        address payable walletAddress;
        string fName;
        string lName;
        bool canRent;
        bool active;    
        uint balance;   
        uint due;   
        uint start;
        uint end;
    }

    mapping (address => Rider) public riders;

    function addRider(address payable walletAddress,string memory fName,string memory lName,bool canRent,bool active,uint balance,uint due,uint start,uint end) public {
        riders[walletAddress] = Rider(walletAddress,fName,lName,canRent,active,balance,due,start,end);        
    }

    function takeScoot(address walletAddress) public{
        require(riders[walletAddress].due==0, "You can not rent a scooter if you don't pay your pending balance");
        require(riders[walletAddress].canRent==true, "You already have rent a scooter, you cannot rent at this time.");
        riders[walletAddress].active = true;
        riders[walletAddress].start = block.timestamp; 
        riders[walletAddress].canRent = false; 
    }

    function leaveScoot(address walletAddress) public {
        require(riders[walletAddress].active==true, "You must rent a scooter first and then check in with that!");
        riders[walletAddress].active = false; 
        riders[walletAddress].end = block.timestamp; 
        setDue(walletAddress);
    }

    function calcTotalDuration(address walletAddress) public view returns(uint) {
        require(riders[walletAddress].active == false, "Scooter is currently checked out.");
        // uint timespan = renterTimespan(riders[walletAddress].start, riders[walletAddress].end);
        // uint timespanInMinutes = timespan / 60;
        // return timespanInMinutes;
        // here we return 6 minutes (hard coded) so we don't have to wait each time 5 minutes
        return 6;
    }

    function calcTimespan(uint start, uint end) internal pure returns(uint) {
        return end - start;
    }

    function getBalance() view public returns(uint){
        return address(this).balance;
    }

    function balanceOfRider(address walletAddress) public view returns(uint) {
        return riders[walletAddress].balance;
    }

    function setDue(address walletAddress) internal {
        uint timespanMinutes = calcTotalDuration(walletAddress); 
        uint fiveMinuteIncrements = timespanMinutes / 5;
        riders[walletAddress].due = fiveMinuteIncrements * 5000000000000000;
    }

    function canRentScoot(address walletAddress) public view returns(bool) {
        return riders[walletAddress].canRent;
    }

    function deposit(address walletAddress) payable public {
        riders[walletAddress].balance += msg.value;
    }

    function makePayment(address walletAddress) payable public {
        require(riders[walletAddress].balance > msg.value, "You do not have enough funds to cover payment. Please make a deposit.");
        require(riders[walletAddress].due > 0, "Hooray, you have to pay nothing right now");
        riders[walletAddress].balance -= msg.value;
        riders[walletAddress].canRent = true;
        riders[walletAddress].due = 0;
        riders[walletAddress].start = 0;
        riders[walletAddress].end = 0;
    }
}


























