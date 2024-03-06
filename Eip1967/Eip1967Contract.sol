//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Eip1967LogicContract {
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
}

contract MyContract {
    address public Eip1967logiccontract;

    constructor(address _eip1967logiccontract) {
        Eip1967logiccontract = _eip1967logiccontract;
    }

    function addCandidateDetails(
        string memory _nameOfCandidate,
        uint256 _voterCardNo,
        string memory _partyName
    ) public {
        (bool success, ) = Eip1967logiccontract.delegatecall(
            abi.encodeWithSignature(
                "addCandidateDetails(string,uint256,string)",
                _nameOfCandidate,
                _voterCardNo,
                _partyName
            )
        );
        require(success, "Candidate registry failed");
    }

    function checkCandidateStatus(uint256 _voterCardNo) public returns (bool) {
        (bool success, bytes memory hasRegistered) = Eip1967logiccontract
            .delegatecall(
                abi.encodeWithSignature(
                    "checkCandidateStatus(uint256)",
                    _voterCardNo
                )
            );
        require(success, "Candidate not registered");
        return abi.decode(hasRegistered, (bool));
    }

    function addVoterDetails(
        address _voterAddress,
        uint256 _voterCardNo,
        uint256 _partyNumber
    ) public {
        (bool success, ) = Eip1967logiccontract.delegatecall(
            abi.encodeWithSignature(
                "addVoterDetails(address,uint256,uint256)",
                _voterAddress,
                _voterCardNo,
                _partyNumber
            )
        );
        require(success, "Voter has already voted or not elegible to vote");
    }

    function checkVoterStatus(uint256 _voterCardNo) public returns (bool) {
        (bool success, bytes memory hasVoted) = Eip1967logiccontract
            .delegatecall(
                abi.encodeWithSignature(
                    "checkVoterStatus(uint256)",
                    _voterCardNo
                )
            );
        require(success, "Voter has already voted or not elegible to vote");
        return abi.decode(hasVoted, (bool));
    }

    function result() public returns (string memory) {
        (bool success, bytes memory winner) = Eip1967logiccontract.delegatecall(
            abi.encodeWithSignature("result()")
        );
        require(success, "Error");
        return abi.decode(winner, (string));
    }
}
