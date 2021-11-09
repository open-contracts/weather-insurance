pragma solidity ^0.8.0;

import "https://github.com/open-contracts/protocol/blob/main/solidity_contracts/OpenContractRopsten.sol";

contract WeatherInsurance is OpenContractAlpha {
    
    mapping(bytes32 => uint256) _payout;
    mapping(bytes32 => uint256) _payment;
    mapping(bytes32 => address) _provider;
    mapping(bytes32 => uint8) _threshold;
    mapping(bytes32 => bool) public insured;

    function policyNo(address beneficiary, int8 lon, int8 lat, uint8 year, uint8 month) public pure returns(bytes32){
        return keccak256(abi.encodePacked(beneficiary, lon, lat, year, month));
    }

    function request(int8 lon, int8 lat, uint8 year, uint8 month, uint8 threshold, uint256 payout) public payable {
        bytes32 policyNo = keccak256(abi.encodePacked(msg.sender, lon, lat, year, month));
        _payment[policyNo] = msg.value;
        _threshold[policyNo] = threshold;
        _payout[policyNo] = payout;
    }
    
    function retract(int8 lon, int8 lat, uint8 year, uint8 month) public {
        bytes32 policyNo = keccak256(abi.encodePacked(msg.sender, lon, lat, year, month));
        uint256 payment = _payment[policyNo];
        _payment[policyNo] = 0;
        payable(msg.sender).transfer(payment);
    }
    
    function provide(address beneficiary, int8 lon, int8 lat, uint8 year, uint8 month) public payable {
        bytes32 policyNo = keccak256(abi.encodePacked(beneficiary, lon, lat, year, month));
        require(msg.value >= _payout[policyNo], "You did not provide enough funds to provide the insurance.");
        insured[policyNo] = true;
        uint256 payment = _payment[policyNo];
        _payment[policyNo] = 0;
        _provider[policyNo] = msg.sender;
        payable(msg.sender).transfer(payment);
    }
    
    function claim(bytes32 oracleHash, address msgSender, address beneficiary, uint8 rainfall, int8 lon, int8 lat, uint8 year, uint8 month)
    public _oracle(oracleHash, msgSender, this.claim.selector) {
        bytes32 policyNo = keccak256(abi.encodePacked(beneficiary, lon, lat, year, month));
        require(insured[policyNo], "This insurance was not provided.");
        uint256 payout = _payout[policyNo];
        _payout[policyNo] = 0;
        if (rainfall < _threshold[policyNo]) {
            payable(beneficiary).transfer(payout);
        } else {
            payable(_provider[policyNo]).transfer(payout);
        }
    }
}
