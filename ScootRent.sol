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
        renters[walletAddress].active = true;
        renters[walletAddress].start = block.timestamp; //the timestamp is a uint with all date info inside
        renters[walletAddress].canRent = false; //this person can not rent a scooter bc he already has one


    }

    //Check in a scooter
    function checkIn(address walletAddress) public {
        // not in a bike anymore
        renters[walletAddress].active = false; 
        renters[walletAddress].end = block.timestamp; //timestamp for the checkin
        //set the amount of due when they check in the scoot
        setDue(walletAddress);
    }


    //Get total duration of scooter use
    // view reads other variables of the contract but does not alter them
    function getTotalDuration(address walletAddress) public view returns(uint) {
        // this returns time in seconds, so then I convert it to minutes
        uint timespan = renterTimespan(renters[walletAddress].start, renters[walletAddress].end);
        uint timespanInMinutes = timespan / 60;
        return timespanInMinutes;
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
        return renters[walletAddress].canRent;
    }



}




// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, "Eleftheria", "Ntoulia", true, false, 0,0,0,0
