//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Eip1822ProxiableContract {
    function addVoterDetails(
        address _voterAddress,
        uint256 _voterCardNo,
        uint256 _partyNumber
    ) public virtual {}

    function checkVoterStatus(uint256 _voterCArdNo)
        public
        view
        virtual
        returns (bool)
    {}

    function addCandidateDetails(
        string memory _nameOfCandidate,
        uint256 _voterCardNo,
        string memory _partyName
    ) public virtual {}

    function checkCandidateStatus(uint256 _voterCardNo)
        public
        view
        virtual
        returns (bool)
    {}

    function result() public virtual returns (string memory) {}
}

contract Eip1822LogicContract is Eip1822ProxiableContract {
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

    function addCandidateDetails(
        string memory _nameOfCandidate,
        uint256 _voterCardNo,
        string memory _partyName
    ) public override {
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
        override
        returns (bool)
    {
        bytes32 voterCard = keccak256(abi.encodePacked(_voterCardNo));
        return hasRegistered[voterCard];
    }

    function addVoterDetails(
        address _voterAddress,
        uint256 _voterCardNo,
        uint256 _partyNumber
    ) public override {
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

    function checkVoterStatus(uint256 _voterCardNo)
        public
        view
        override
        returns (bool)
    {
        bytes32 voterCard = keccak256(abi.encodePacked(_voterCardNo));
        return hasVoted[voterCard];
    }

    function result() public override returns (string memory) {
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
}

contract ProxyEip1822Contract {
    bytes32 private constant IMPLEMENTATION_SLOT =
        keccak256("IMPLEMENTATION_SLOT");

    fallback() external payable {
        address _implementation = implementation();
        require(implementation() != address(0), "Implementation not set");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(
                gas(),
                _implementation,
                ptr,
                calldatasize(),
                0,
                0
            )
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    function implementation() public view returns(address) {
        address implementationAddress;
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            implementationAddress := sload(slot)
        }

        return implementationAddress;
    }

    function setImplementation(address newImplementation) public {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    } 

    receive() external payable { }
}
