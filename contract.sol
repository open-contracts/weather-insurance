pragma solidity ^0.8.0;

import "https://github.com/open-contracts/protocol/blob/main/solidity_contracts/OpenContractRopsten.sol";

contract WeatherInsurance is OpenContractAlpha {
    
    mapping(bytes32 => uint256) _payout;
    mapping(bytes32 => uint256) _payment;
    mapping(bytes32 => address) _provider;
    mapping(bytes32 => uint8) _threshold;
    mapping(bytes32 => bool) public insured;

    function policyID(address beneficiary, int8 lon, int8 lat, uint8 year, uint8 month) public pure returns(bytes32){
        return keccak256(abi.encodePacked(beneficiary, lon, lat, year, month));
    }

    function request(int8 lon, int8 lat, uint8 year, uint8 month, uint8 threshold, uint256 payout) public payable {
        bytes32 policyID = keccak256(abi.encodePacked(msg.sender, lon, lat, year, month));
        _payment[policyID] = msg.value;
        _threshold[policyID] = threshold;
        _payout[policyID] = payout;
    }
    
    function retract(int8 lon, int8 lat, uint8 year, uint8 month) public {
        bytes32 policyID = keccak256(abi.encodePacked(msg.sender, lon, lat, year, month));
        uint256 payment = _payment[policyID];
        _payment[policyID] = 0;
        payable(msg.sender).transfer(payment);
    }
    
    function provide(address beneficiary, int8 lon, int8 lat, uint8 year, uint8 month) public payable {
        bytes32 policyID = keccak256(abi.encodePacked(beneficiary, lon, lat, year, month));
        require(msg.value >= _payout[policyID], "You did not provide enough funds to provide the insurance.");
        insured[policyID] = true;
        uint256 payment = _payment[policyID];
        _payment[policyID] = 0;
        payable(msg.sender).transfer(payment);
        _provider[policyID] = msg.sender;
    }
    
    function claim(bytes32 oracleHash, address msgSender, address beneficiary, uint8 rainfall, int8 lon, int8 lat, uint8 year, uint8 month)
    public _oracle(oracleHash, msgSender, this.claim.selector) {
        bytes32 policyID = keccak256(abi.encodePacked(beneficiary, lon, lat, year, month));
        require(insured[policyID], "This insurance was not provided.");
        uint256 payout = _payout[policyID];
        _payout[policyID] = 0;
        if (rainfall < _threshold[policyID]) {
            payable(beneficiary).transfer(payout);
        } else {
            payable(_provider[policyID]).transfer(payout);
        }
    }
}
