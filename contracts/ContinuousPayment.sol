pragma solidity ^0.4.15;

contract ContinuousPayment {

    address public contractor; // Contractor hired for the job
    address public employer; // Employer that hires the contractor for work
    uint public weiPerSecond; // Payment rate in Wei per second
    uint public startTime; // Timestap of when the contract begins

    event Withdrew(uint amount, address indexed withdrawer); // Shows how much was withdrawn from the contract


    //Constructor that assigns the contractor and wei per second
    function ContinuousPayment(uint _weiPerSecond) { 
        weiPerSecond = _weiPerSecond;
        contractor = msg.sender;
    }

    //Transfers payment 
    function() payable {
        depositPayment();
    }

    //Payment deposits from employer; contract begins when deposits have been made
    function depositPayment() payable {
        employer = msg.sender;
        startTime = getTime();
    }

    //Withdraws from deposits from either the contractor or employer
    function withdrawPayment() {
        uint owed = balanceOwed();
        startTime = getTime();
        if (contractor == msg.sender) {
            require(owed > 0);
            contractor.transfer(owed);
            Withdrew(owed, msg.sender);
        }
        if (employer == msg.sender) {
            uint employerOwed = address(this).balance - owed;
            require(employerOwed > 0);
            employer.transfer(employerOwed);
            Withdrew(employerOwed, msg.sender);
        }
    }

    //Calculates the balance owed to each party as time passes 
    function balanceOwed() constant returns (uint) {
        uint owed = weiPerSecond * (getTime() - startTime);
        uint balance = address(this).balance;
        if (owed > balance) {
            owed = balance;
        }
        return owed;
    }

    function getTime() constant returns (uint) {
        return now;
    }
}