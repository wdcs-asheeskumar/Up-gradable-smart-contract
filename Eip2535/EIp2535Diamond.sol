//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@solidstate/contracts/proxy/diamond/SolidStateDiamond.sol";

interface IDiamond {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }
    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4 functionSelector;
        // uint256 gaslimit;
    }

    // mapping(bytes4 => address) functionSelectorCode;
    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    event CandidateAdded(
        string _nameOfCandidate,
        uint256 indexed _voterCardNo,
        string _partyName
    );
    event VoteCasted(
        address _voterAddress,
        uint256 indexed _voterCardNo,
        uint256 _partyNumber
    );

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    // function setOwner(address _owner) external;

    function addCandidateDetails(
        string memory _nameOfCandidate,
        uint256 _voterCardNo,
        string memory _partyName
    ) external;

    function addVoterDetails(
        address _voterAddress,
        uint256 _voterCardNo,
        uint256 _partyNUmber
    ) external;
}

contract Eip2535VotingContract {
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

    event CandidateAdded(
        string _nameOfCandidate,
        uint256 indexed _voterCardNo,
        string _partyName
    );

    event VoteCasted(
        address _voterAddress,
        uint256 indexed _voterCardNo,
        uint256 _partyNumber
    );

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

        emit CandidateAdded(_nameOfCandidate, _voterCardNo, _partyName);
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
        emit VoteCasted(_voterAddress, _voterCardNo, _partyNumber);
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

// contract Eip2535AdminFacet {
//     address public owner;
//     address public diamond;

//     constructor(address _diamond) {
//         owner = msg.sender;
//         diamond = _diamond;
//     }

//     function addFacet(address _facet) external {
//         IDiamond.FacetCut[] memory _facetCuts = new IDiamond.FacetCut[](1);
//         _facetCuts[0] = IDiamond.FacetCut({
//             facetAddress: _facet,
//             action: IDiamond.FacetCutAction.Add,
//             functionSelector: bytes4(
//                 keccak256("addCandidateDetails(string,utin256,string)")
//             )
//             // gaslimit: 100000
//         });
//         IDiamond(diamond).diamondCut(_facetCuts, address(0), ""); //(bytes,)
//     }
// }

contract Eip2535Diamond is IDiamond {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function addFacet(address _facet) external {
        IDiamond.FacetCut[] memory _facetCuts = new IDiamond.FacetCut[](1);
        _facetCuts[0] = IDiamond.FacetCut({
            facetAddress: _facet,
            action: IDiamond.FacetCutAction.Add,
            functionSelector: bytes4(
                keccak256("addCandidateDetails(string,utin256,string)")
            )
        });
        IDiamond(address(this)).diamondCut(_facetCuts, address(0), ""); //(bytes,)
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external {
        for (uint256 i; i < _diamondCut.length; i++) {
            if (_diamondCut[i].facetAddress == address(0)) {
                require(_init != address(0), "Invalid initialize address");
                _init.delegatecall(_calldata);
            } else {
                (bool success, ) = _diamondCut[i].facetAddress.delegatecall(
                    abi.encodePacked(
                        _diamondCut[i].functionSelector,
                        abi.encode(_diamondCut[i], address(0), _calldata)
                    )
                );
                require(success, "Facet modification failed");
                emit DiamondCut(_diamondCut, _init, _calldata);
            }
        }
    }

    function addCandidateDetails(
        string memory _nameOfCandidate,
        uint256 _voterCardNo,
        string memory _partyName
    ) external {
        emit CandidateAdded(_nameOfCandidate, _voterCardNo, _partyName);
    }

    function addVoterDetails(
        address _voterAddress,
        uint256 _voterCardNo,
        uint256 _partyNumber
    ) public {
        emit VoteCasted(_voterAddress, _voterCardNo, _partyNumber);
    }
}
