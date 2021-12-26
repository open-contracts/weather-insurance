pragma solidity ^0.8.0;
import "https://github.com/open-contracts/protocol/blob/main/solidity_contracts/OpenContractRopsten.sol";

contract WeatherInsurance is OpenContract {

    struct parameters {
        uint256 payout;
        uint256 price;
        address insurer;
        bool active;
    }

    mapping(bytes32 => mapping(address => parameters)) public policy;

    constructor() {
        setOracle(this.settle.selector, "any");  // for debugging purposes, allow any oracleID
    }

    function policyID(int8 latitude, int8 longitude, uint8 year, uint8 month, uint8 threshold) public pure returns(bytes32) {
        return keccak256(abi.encode(latitude, longitude, year, month, threshold));
    }

    function request(bytes32 policyID, uint256 payout) public payable {
        require(!policy[policyID][msg.sender].active, "Your policy is already active.");
        policy[policyID][msg.sender].price += msg.value;
        policy[policyID][msg.sender].payout = payout;
    }

    function retract(bytes32 policyID) public {
        require(!policy[policyID][msg.sender].active, "Your policy is already active.");
        uint256 payment = policy[policyID][msg.sender].price;
        policy[policyID][msg.sender].price = 0;
        payable(msg.sender).transfer(payment);
    }

    function provide(address beneficiary, bytes32 policyID) public payable {
        require(!policy[policyID][beneficiary].active, "The policy is already active.");
        require(msg.value >= policy[policyID][beneficiary].payout, "You did not send enough ETH to provide the insurance.");
        policy[policyID][beneficiary].active = true;
        policy[policyID][beneficiary].insurer = msg.sender;
        uint256 payment = policy[policyID][beneficiary].price;
        policy[policyID][beneficiary].price = 0;
        payable(msg.sender).transfer(payment);
    }

    function settle(bytes32 oracleID, address beneficiary, bytes32 policyID, bool damageOccured)
    public checkOracle(oracleID, this.settle.selector) {
        require(policy[policyID][beneficiary].active, "The insurance is not active.");
        uint256 payout = policy[policyID][beneficiary].payout;
        if (damageOccured) {
            payable(beneficiary).transfer(payout);
        } else {
            payable(policy[policyID][beneficiary].insurer).transfer(payout);
        }
    }
}
