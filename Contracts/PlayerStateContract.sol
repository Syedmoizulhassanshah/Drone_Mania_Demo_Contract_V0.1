// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PlayerStateContract is Ownable, ReentrancyGuard {

    struct Player {
        string ipfsHash;
        uint256 playerScore;
    }

    struct PlayersStateReturn {
        address playerAddress;
        string ipfsHash;
        uint256 playerScore;     
    }
    
    uint256 public playerCount;
    string public baseURI;

    mapping(uint256 => address) public playerAddresses;
    mapping(address => Player) public playerStates;
    mapping(address => bool) public whitelistedAddresses;
    
    modifier isWhitelisted() {
        require(whitelistedAddresses[msg.sender], "Unauthorized Address");
        _;
    }

    event AddedNewPlayer(
        uint256 indexed playerId,
        string ipfsHash,
        address playerAddress
    );

    event UpdatedPlayerState(
        address playerAddress,
        string ipfsHash,
        uint256 playerScore
    );

    event AddedWhitelistAddress(
        address whitelistedAddress,
        address addedBy
    );

    event RemovedWhitelistAddress(
        address whitelistedAddress,
        address addedBy
    );

    event UpdatedBaseURI(
        string baseURI,
        address addedBy
    );

    constructor() {
        baseURI = "http://ipfs.io/";

        emit UpdatedBaseURI(baseURI, msg.sender);
    }

    /**
     * @dev addWhitelistedAddress is used to add address in whitelist mapping.
     *
     * Requirement:
     *
     * - This function can only called by owner of contract
     *
     * @param whitelistAddress - New whitelist address
     *
     * Emits a {AddedWhitelistAddress} event.
     */

    function addWhitelistedAddress(address whitelistAddress)
    external
    onlyOwner
    nonReentrant {
        require(!whitelistedAddresses[whitelistAddress], "Already whitelisted address");

        whitelistedAddresses[whitelistAddress] = true;

        emit AddedWhitelistAddress(whitelistAddress, msg.sender);
    }

    /**
     * @dev updateBaseURI is used to update BaseURI.
     *
     * Requirement:
     *
     * - This function can only called by owner of contract
     *
     * @param _baseURI - New baseURI
     *
     * Emits a {UpdatedBaseURI} event.
     */

    function updateBaseURI(string memory _baseURI)
    external
    onlyOwner
    nonReentrant {
        baseURI = _baseURI;

        emit UpdatedBaseURI(baseURI, msg.sender);
    }

    /**
     * @dev removeWhitelistedAddress is used to remove address from whitelist mapping.
     *
     * Requirement:
     *
     * - This function can only called by owner of contract
     *
     * @param whitelistAddress - Remove whitelist address
     *
     * Emits a {RemovedWhitelistAddress} event.
     */

    function removeWhitelistedAddress(address whitelistAddress)
    external
    onlyOwner
    nonReentrant {
        require(whitelistedAddresses[whitelistAddress], "Not whitelisted address");

        whitelistedAddresses[whitelistAddress] = false;

        emit RemovedWhitelistAddress(whitelistAddress, msg.sender);
    }

    /**
     * @dev updatePlayerInfo is used to add new player in PlayerStateContract.
     *
     * Requirement:
     *
     * - This function can only called by whitelisted Addresses
     *
     * @param ipfsHash - IPFS URI of player
     * @param playerAddress - Address of player
     * @param playerScore - Score of player
     *
     * Emits a {AddedNewPlayer} event when player address is new.
     * Emits a {UpdatedPlayerState} event when player address already exists.
     */

    
    function updatePlayerInfo(
        string memory ipfsHash,
        address playerAddress,
        uint256 playerScore
    ) external
    isWhitelisted
    nonReentrant returns (uint256 playerId)
    {
        require(bytes(ipfsHash).length == 46, "Invalid IPFS Hash");
        if(bytes(playerStates[playerAddress].ipfsHash).length != 0){
            playerStates[playerAddress] = Player(ipfsHash, playerScore);

            emit UpdatedPlayerState(playerAddress, ipfsHash, playerScore);
      
        } else {
            playerCount++;
            playerAddresses[playerCount] = playerAddress;
            playerStates[playerAddress] = Player(ipfsHash, playerScore);

            emit AddedNewPlayer(playerCount, ipfsHash, playerAddress);
            return playerCount;
        }
    }

    /**
     * @dev getPlayerInfo is used to get information of player in PlayerStateContract.
     *
     * @param playerAddress - ID of player
     *
     * @return Player Tuple.
     */

    function getPlayerInfo(address playerAddress)
    external
    view
    returns (Player memory)
    {
        require(bytes(playerStates[playerAddress].ipfsHash).length != 0, "Address Not Exists");
        
        return playerStates[playerAddress];
    }

    /**
     * @dev getPlayerHash is used to get information of player in PlayerStateContract.
     *
     * @param playerAddress - ID of player
     *
     * @return Player Tuple.
     */

    function getPlayerIpfsHash(address playerAddress)
    external
    view
    returns (string memory)
    {
        require(bytes(playerStates[playerAddress].ipfsHash).length != 0, "Player Not Exists");
        return string.concat(
            baseURI,
            playerStates[playerAddress].ipfsHash
        );
    }

    /**
     * @dev getAllPlayer is used to get information of All players (Hashes,Score) in PlayerStateContract.
     *
     * @return PlayerDetails Tuple.
     */

    function getAllPlayers() public view returns (PlayersStateReturn[] memory)
    {
        PlayersStateReturn[] memory playerDetails = new PlayersStateReturn[](playerCount);

        for(uint i = 1; i <= playerCount; i++){
            playerDetails[i-1].playerAddress = playerAddresses[i];
            playerDetails[i-1].ipfsHash = playerStates[playerAddresses[i]].ipfsHash;
            playerDetails[i-1].playerScore = playerStates[playerAddresses[i]].playerScore;
        }
        return playerDetails;
    }
}
