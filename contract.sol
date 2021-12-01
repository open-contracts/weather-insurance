pragma solidity ^0.8.0;
import "https://github.com/open-contracts/protocol/blob/main/solidity_contracts/OpenContractRopsten.sol";

contract WeatherInsurance is OpenContract {

    struct deal {
        uint256 payout;
        uint256 price;
        address insurer;
        bool insured;
    }

    mapping(bytes32 => mapping(address => deal)) insurance;

    constructor() {
        setOracle(this.settle.selector, "any");  // for debugging purposes, allow any oracleID
    }

    function policyID(int8 latitude, int8 longitude, uint8 year, uint8 month, uint8 threshold) public pure returns(bytes32) {
        return keccak256(abi.encode(latitude, longitude, year, month, threshold));
    }

    function request(bytes32 policyID) public payable {
        require(!insurance[policyID][msg.sender].insured, "Your policy is already active.");
        insurance[policyID][msg.sender].price += msg.value;
    }

    function retract(bytes32 policyID) public {
        require(!insurance[policyID][msg.sender].insured, "Your policy is already active.");
        uint256 payment = insurance[policyID][msg.sender].price;
        insurance[policyID][msg.sender].price = 0;
        payable(msg.sender).transfer(payment);
    }

    function provide(address beneficiary, bytes32 policyID) public payable {
        require(!insurance[policyID][beneficiary].insured, "The policy is already active.");
        require(msg.value >= insurance[policyID][beneficiary].payout, "You did send enough ETH to provide the insurance.");
        insurance[policyID][beneficiary].insured = true;
        insurance[policyID][beneficiary].insurer = msg.sender;
        uint256 payment = insurance[policyID][beneficiary].price;
        insurance[policyID][beneficiary].price = 0;
        payable(msg.sender).transfer(payment);
    }

    function settle(bytes32 oracleID, address beneficiary, bytes32 policyID, bool damageOccured)
    public checkOracle(oracleID, this.settle.selector) {
        require(!insurance[policyID][beneficiary].insured, "The insurance policy was not active.");
        uint256 payout = insurance[policyID][beneficiary].payout;
        if (damageOccured) {
            payable(beneficiary).transfer(payout);
        } else {
            payable(insurance[policyID][beneficiary].insurer).transfer(payout);
        }
    }
}
