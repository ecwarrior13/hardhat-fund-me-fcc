//SPDX-License-Identifier: MIT
//pragma first
pragma solidity 0.8.8;
//imports
import "./PriceConverter.sol";
import "hardhat/console.sol";

// constant, immutable
error FundMe__NotOwner();

/** @title A contract for crowd funding
 * @author Michael A
 * @notice demo a sample funding contract
 * @dev implements rpice feeds as our library
 */
contract FundMe {
    // Type declarations
    using PriceConverter for uint256;
    // State Variables
    uint256 public constant MINIMUM_USD = 50 * 10**18;
    //1,014,199 - constant
    //1,038,398 - non constant
    //
    //

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_owner;

    //immutalbe cost 21,508
    //non-immutable cost 23,644
    AggregatorV3Interface private s_priceFeed;

    constructor(address s_priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(s_priceFeedAddress);
    }

    /***@notice this funciton funds this contracts
     * @dev This implement price feeds as our library
     */

    function fund() public payable {
        //set a min fund amount in USD
        //1. how do we sent eth to this contract?

        require(
            msg.value.getConversionRate(s_priceFeed) > 1e18,
            "Didn't send enough"
        ); //1e18 == 1 * 10 ** 18 = 10000000000
        //who sent money
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        // for loop  [1,2,3,4]
        //for (/*start index, end index, step amount*/)
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex = funderIndex++
        ) {
            //code
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //reset the array
        s_funders = new address[](0);
        //withdraw the funds
        //three ways to send, transfer, send, call (simplest = transfer)
        //call is the recommended way
        //console.log("starting payable msg.sender");
        //payable(msg.sender).transfer(address(this).balance);
        //send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send Failed");
        //call
        (bool callSucess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSucess, "Call Failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        //read the array to memory, then review the memory

        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    /* what happens if someone send this contract eth without calling funds
    removed so not to test
    
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
    */

    //receive()
    //fallback()
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
