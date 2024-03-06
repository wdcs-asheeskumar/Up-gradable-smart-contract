// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

// Standardised interface
interface VotingInterface {
    function addVoterDetails(
        address _voterAddress,
        uint256 _voterCardNo,
        uint256 _partyNumber
    ) external;

    function checkVoterStatus(uint256 _voterCardNo)
        external
        view
        returns (bool);

    function addCandidateDetails(
        string memory _nameOfCandidate,
        uint256 _voterCardNo,
        string memory _partyName
    ) external;

    function checkCandidateStatus(uint256 _voterCardNo)
        external
        view
        returns (bool);

    function result() external returns (string memory);
}

// Delegate contract
contract Eip897VotingContract is VotingInterface {
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

contract Owner {
    address public votingInterface;

    constructor(address _votingInterface) {
        votingInterface = _votingInterface;
    }

    function checkCandidate(uint256 _voterCardNo) public view returns (bool) {
        VotingInterface _candidateStatus = VotingInterface(votingInterface);
        return _candidateStatus.checkCandidateStatus(_voterCardNo);
    }

    function checkVoterStatus(uint256 _voterCardNo) public view returns (bool) {
        VotingInterface _voterStatus = VotingInterface(votingInterface);
        return _voterStatus.checkVoterStatus(_voterCardNo);
    }

    function checkResult() public returns (string memory) {
        VotingInterface _result = VotingInterface(votingInterface);
        return _result.result();
    }
}
