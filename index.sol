// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.11;

/// this is a basic purchase agreement smart contract that protects both the seller + buyer 

contract PurchaseAgreement {
    uint public value;
    address payable public seller;
    address payable public buyer;

    enum State { Created, Locked, Release, Inactive }

    State public state;

    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
    }

    /// The function cannot be called at the current state. 
    error InvalidState();
    /// Only the buyer can call this function
    error OnlyBuyer();
    /// Only the seller can call this function
    error OnlySeller();

    modifier inState(State state_) {
        if(state!= state_) {
            revert InvalidState();
        }
        _;
    }
/// Only the buyer can call this function
    modifier onlyBuyer() {
        if(msg.sender != buyer) {
            revert OnlyBuyer();
        }
        _;
    }
/// Only the seller can call this function
    modifier onlySeller() {
        if(msg.sender != seller) {
            revert OnlySeller();
        }
        _;
    }

    function confirmPurchase() external inState(State.Created) payable {
        require(msg.value == (2 * value), "Please send in 2x the purchase amount");
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    function confirmReceived() external onlyBuyer inState(State.Locked) {
        state = State.Release;
        buyer.transfer(value);
    }

    function paySeller() external onlySeller inState(State.Release) {
        state = State.Inactive;

        seller.transfer(3 * value);
    }

    function abort() external onlySeller inState(State.Created) {
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }
}
