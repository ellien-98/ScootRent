// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ScootRent{

    address owner;

    // the constructor is implemented when the contract is deployed. the owner who wrote this sends the message, so he is atsm owner of the contract
    constructor(){
        owner = msg.sender;

    }

    //Add yourself as a renter
    struct Renter{
        address payable walletAddress;
        string firstNem;
        string lastName;
        bool canRent;
        bool active;    //currently on the bike
        uint balance;   //to send money to their balance to pay their fees
        uint due;   // the amount they have to pay || they owe to pay
        uint start;
        uint end;
    }

    // mapping is like dictionary, address is the key, value is the renter
    mapping (address => Renter) public renters;

    //strings have to be declared with memory keyword
    function addRenter(address payable walletAddress,string memory firstName,string memory lastName,bool canRent,bool active,uint balance,uint due,uint start,uint end) public {
        // Add the new renter to a mapping, it's like pushing the renter to the mapping
        renters[walletAddress] = Renter(walletAddress,firstName,lastName,canRent,active,balance,due,start,end);

        
    }

    // Checkout scooter
    function checkOut(address walletAddress) public{
        //the require statements they will revert the transaction BEFORE GAS IS SPENT(so you don't blow it for nothing)
        require(renters[walletAddress].due==0, "You can not rent a scooter if you don't pay your pending balance");
        require(renters[walletAddress].canRent == true, "You already rent a scooter, you cannot rent at this time.");
        renters[walletAddress].active = true;
        renters[walletAddress].start = block.timestamp; //the timestamp is a uint with all date info inside
        renters[walletAddress].canRent = false; //this person can not rent a scooter bc he already has one
        // if they have a due they should not be able to checkout again (before they make the owed payment)

    }

    //Check in a scooter
    function checkIn(address walletAddress) public {
        require(renters[walletAddress].active==true, "You must checkout the previousi scooter to rent a new one!");
        // not in a bike anymore
        renters[walletAddress].active = false; 
        renters[walletAddress].end = block.timestamp; //timestamp for the checkin
        //set the amount of due when they check in the scoot
        setDue(walletAddress);
    }


    //Get total duration of scooter use
    // view reads other variables of the contract but does not alter them
    function getTotalDuration(address walletAddress) public view returns(uint) {
        //one can not request to check his/her total duration unledd he is active rn
        require(renters[walletAddress].active == false, "Scooter is currently checked out.");
        // this returns time in seconds, so then I convert it to minutes
        // uint timespan = renterTimespan(renters[walletAddress].start, renters[walletAddress].end);
        // uint timespanInMinutes = timespan / 60;
        // return timespanInMinutes;
        // here we return 6 minutes (hard coded) so we don't have to wait each time 5 minutes
        return 6;
    }

    // we keep it internal, pure does not even read any variables outside of this function
    function renterTimespan(uint start, uint end) internal pure returns(uint) {
        return end - start;
    }

    //Get Contract balance
    function balanceOf() view public returns(uint){
        return address(this).balance;
    }

    // Get renter's balance
    function balanceOfRenter(address walletAddress) public view returns(uint) {
        return renters[walletAddress].balance;
    }

    //Set Due amount // the binance smart chain uses the same amount of decimals as ethereum (18 decimals)
    function setDue(address walletAddress) internal {
        uint timespanMinutes = getTotalDuration(walletAddress); //add walletAddress to know whose duration is this
        // the time is divided into 5 minutes intervals, bc the charge is 0.005 bnb every 5 minutes 
        uint fiveMinuteIncrements = timespanMinutes / 5;
        renters[walletAddress].due = fiveMinuteIncrements * 5000000000000000;
    }

    function canRentScoot(address walletAddress) public view returns(bool) {
        // if a renter is checked out canRentScoot must be set and returned to false, they can not rent a 2nd one atsm
        return renters[walletAddress].canRent;
    }

    //Make payment, the renter is going to deposit money in their balance(like prepaying)
    // money come to the contract and then depending on the payment bill money is going to be deducted from each one

    //we want to add the money to the renter's balance
    //we are depositing money to the whole contract and also gonna credit to this person
    // One can not pay directly, they have first to deposit money and then transfer this money as payments.
    function deposit(address walletAddress) payable public {
        renters[walletAddress].balance += msg.value;
    }


    // Make Payment
    // this is a payable function, people are sending money
    function makePayment(address walletAddress) payable public {
        require(renters[walletAddress].due > 0, "Hoorayk, you have to pay nothing right now");
        require(renters[walletAddress].balance > msg.value, "You do not have enough funds to cover payment. Please make a deposit.");
        //if you are the only renter you put in 10 dollars in your balance, and so there are 10 dollars in the contract too
        //so when you make the payment you are pulling that amount out of your balance and these 5 dollars for example
        // they now belong to the contract's owner, (that's how she makes money),
        // so actually we are removing money from our balance
        renters[walletAddress].balance -= msg.value;
        // if their balance is ready they are free to rent again
        renters[walletAddress].canRent = true;
        // they already paid the amount due, everything is set fresh again
        renters[walletAddress].due = 0;
        renters[walletAddress].start = 0;
        renters[walletAddress].end = 0;
    }

}




// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, "Eleftheria", "Ntoulia", true, false, 0,0,0,0
