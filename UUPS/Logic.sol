//SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

contract Proxy {
    constructor(bytes memory constructData, address contractLogic) {
        assembly {
            sstore(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7,
                contractLogic
            )
        }
        (bool success, ) = contractLogic.delegatecall(constructData);
        require(success, "Delegatecall failed");
    }

    fallback() external payable {
        assembly {
            let contractLogic := sload(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7
            )
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(
                sub(gas(), 10000),
                contractLogic,
                0x0,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
            case 0 {
                revert(0, retSz)
            }
            default {
                return(0, retSz)
            }
        }
    }
}

contract Proxiable {
    function updateCodeAddress(address newAddress) internal {
        require(
            bytes32(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7
            ) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly {
            sstore(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7,
                newAddress
            )
        }
    }

    function proxiableUUID() public pure returns (bytes32) {
        return
            0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

contract Logic is Proxiable {
    address public owner;
    struct VoterDetails {
        address voterAddress;
        uint256 partyNumber;
    }

    struct CandidateDetails {
        string nameOfCandidate;
        bytes32 voterCardNo;
        string partyName;
        uint256 totalVotes;
    }

    mapping(bytes32 => VoterDetails) public voterDetails;
    mapping(uint256 => CandidateDetails) public candidateDetails;
    mapping(bytes32 => bool) public hasVoted;
    mapping(bytes32 => bool) public hasRegistered;

    uint256 public partyCounter;
    uint256 public voterCounter;
    string[] public listOfParties;
    string public winner;
    modifier onlyOwner() {
        require(owner == address(0), "already initialised");
        _;
    }

    function constructor1() public {
        require(owner == address(0), "already initialised");
        owner = msg.sender;
    }

    function addCandidateDetails(
        string memory _nameOfCandidate,
        uint256 _voterCardNo,
        string memory _partyName
    ) public {
        bytes32 voterCard = keccak256(abi.encodePacked(_voterCardNo));
        require(
            hasRegistered[voterCard] == false,
            "Candidate has already been registered"
        );
        uint256 _partyNumber = partyCounter;
        candidateDetails[_partyNumber].nameOfCandidate = _nameOfCandidate;
        candidateDetails[_partyNumber].voterCardNo = voterCard;
        candidateDetails[_partyNumber].partyName = _partyName;
        hasRegistered[voterCard] = true;
        listOfParties.push(_partyName);
        partyCounter = partyCounter + 1;
    }

    function checkCandidateStatus(uint256 _voterCardNo)
        public
        view
        returns (bool)
    {
        bytes32 voterCard = keccak256(abi.encodePacked(_voterCardNo));
        return hasRegistered[voterCard];
    }

    function addVoterDetails(
        address _voterAddress,
        uint256 _voterCardNo,
        uint256 _partyNumber
    ) public {
        voterCounter = voterCounter + 1;
        bytes32 voterCard = keccak256(abi.encodePacked(_voterCardNo));
        require(hasVoted[voterCard] == false, "Candidate has already voted");
        require(
            listOfParties.length >= 2,
            "There can't be election with a single party"
        );
        voterDetails[voterCard].voterAddress = _voterAddress;
        voterDetails[voterCard].partyNumber = _partyNumber;
        candidateDetails[_partyNumber].totalVotes += 1;
        hasVoted[voterCard] = true;
    }

    function checkVoterStatus(uint256 _voterCardNo) public view returns (bool) {
        bytes32 voterCard = keccak256(abi.encodePacked(_voterCardNo));
        return hasVoted[voterCard];
    }

    function result() public returns (string memory) {
        uint256 temp;
        uint256 count;
        for (uint256 i = 0; i < listOfParties.length; i++) {
            if (temp < candidateDetails[i].totalVotes) {
                temp = candidateDetails[i].totalVotes;
                count = i;
            }
        }

        winner = candidateDetails[count].nameOfCandidate;
        return winner;
    }

    function updatecode(address newCode) public onlyOwner {
        updateCodeAddress(newCode);
    }
}

// contract MyContract is Proxiable, Logic {
// function updatecode(address newCode) public onlyOwner {
//     updateCodeAddress(newCode);
// }

// modifier onlyOwner() {
//     require(owner == address(0), "already initialised");
//     _;
// }
// }
