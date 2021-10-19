pragma solidity ^0.8.3;
import "@openzeppelin/contracts/OpenContractAlpha.sol"

contract ExampleContract is OpenContractAlpha("13e9e6f91c2570d12c84b904740ed3fee4f8473cf98543d13a0c689580c022de") {
    
    string stringStorage;
    
    function saveFromEnclaveOnly (bytes32 oracleHash, string memory someString) public {
        requireOracle(oracleHash);
        stringStorage = someString;
    }
}
