// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RewardContract is ERC1155, Ownable, ReentrancyGuard, ERC1155Supply {

    uint public idsCount;
    string public name;
    string public symbol;
    string public baseUri;
    bool public mintEnabled;

    mapping(address => bool) public whitelistedAddresses;

    error AmountMustBeAboveZero();
    error NotWhitelistedAddress();
    error AddressIsAlreadyWhitelisted();
    error MintingDisabled();
    error TokenIdNotExists();
    error TokenIdAlreadyExists();
    error IdsAndAccountsLengthMismatch();

    struct PlayerRewards {
        uint256 rewardCopies;
        uint256 rewardId;
    }
    
    event MintStatusUpdated(
        bool status,
        address updatedBy
    );
    
    event RewardMinted(
        uint rewardId,
        uint quantity,
        address mintedTo
    );

    event RewardsAddressMinted(
        uint[] rewardIds,
        uint[] quantities,
        address mintedTo 
    );

    event RewardsOnAddressesMinted(
        uint[] rewardIds,
        uint[] quantities,
        address[] mintedTo 
    );

    event DroneRewardUpdatedBy(
        uint rewardId,
        uint quantity,
        address updatedBy  
    );

    event SetBaseURI(
        string baseURI,
        address setBy
    );

    event AddedWhitelistAddress(
        address whitelistedAddress,
        address addedBy
    );

    event RemovedWhitelistAddress(
        address whitelistedAddress,
        address removeBy
    );

    constructor() ERC1155("") {
        name = "Drone Mania Rewards";
        symbol = "DR";
        baseUri = "https://staging-gateway.wrld.xyz/assets/getRewardMetaDataById/";
        
        mintEnabled = true;
        whitelistedAddresses[msg.sender] = true;
        emit SetBaseURI(baseUri, msg.sender);
    }

    modifier isWhitelisted() {
        if (!whitelistedAddresses[msg.sender]) {
            revert NotWhitelistedAddress();
        }
        _;   
    }

    function updateMintStatus(bool _status) 
    external 
    onlyOwner {
        mintEnabled = _status;

        emit MintStatusUpdated(_status, msg.sender);
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
        if(whitelistedAddresses[whitelistAddress]){
            revert AddressIsAlreadyWhitelisted();
        }
        whitelistedAddresses[whitelistAddress] = true;

        emit AddedWhitelistAddress(whitelistAddress, msg.sender);
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
        if(!whitelistedAddresses[whitelistAddress]){
            revert NotWhitelistedAddress();
        }

        whitelistedAddresses[whitelistAddress] = false;

        emit RemovedWhitelistAddress(whitelistAddress, msg.sender);
    }

    /**
     * @dev setBaseUri is used to set BaseURI.
     * Requirement:
     * - This function can only called by owner of contract
     *
     * @param _baseUri - New baseURI
     * Emits a {UpdatedBaseURI} event.
    */

    function updateBaseUri(
        string memory _baseUri
    ) external
      onlyOwner 
    {
        baseUri = _baseUri;
        
        emit SetBaseURI(baseUri, msg.sender);
    }

    /**
     * @dev MintReward is used to create a new Reward.
     * Requirement:
     *
     * @param id - id to mint
     * @param rewardSupply - Reward Copy to mint
     * @param account - address to
     *
     * Emits a {RewardMinted} event.
    */

    function mintReward(
        uint256 id,
        uint256 rewardSupply,
        address account
    ) public
      isWhitelisted
      nonReentrant
      returns(uint)
    {
        if(!mintEnabled){
          revert MintingDisabled();
        }

        if (rewardSupply <= 0) {
          revert AmountMustBeAboveZero();
        }

        if(!exists(id)){
            idsCount += id; 
        }

        _mint(account, id, rewardSupply, "");
        emit RewardMinted(id, rewardSupply, account);  

       return id;
    }

    /**
     * @dev mintRewardsOnAddress is used to create a Bulk Rewards of single player.

     * Requirement:

     * @param ids - ids to mint
     * @param rewardSupplies - Copies of reward that have to send
     * @param account - address to
     *
     * Emits a {RewardsAddressMinted} event.
    */

    function mintRewardsOnAddress(
        uint256[] memory ids,
        uint256[] memory rewardSupplies,
        address account
    ) public
      isWhitelisted
    {
       
        if(!mintEnabled){
           revert MintingDisabled();
        }
        for(uint i=0; i<ids.length; i++){

            if(!exists(ids[i])){
             idsCount += ids.length; 
            }
            
            if (rewardSupplies[i] <= 0) {
                revert AmountMustBeAboveZero();
            } 
        }

      _mintBatch(account, ids, rewardSupplies, "");

      emit RewardsAddressMinted(ids, rewardSupplies, account);
    }

    /**
     * @dev MintRewardsOnAddresses is used to create a Bulk Rewards of Multiple player.

     * Requirement:

     * @param ids - ids to mint
     * @param rewardSupplies - Copies of reward that have to send
     * @param accounts - addresses to
     *
     * Emits a {RewardsOnAddressesMinted} event.
    */

    function mintRewardsOnAddresses(
        uint[] memory ids,
        uint256[] memory rewardSupplies,
        address[] memory accounts
       
    ) public
      isWhitelisted
      nonReentrant
      returns(uint[] memory)
    {
        if(!mintEnabled){
          revert MintingDisabled();
        }
        for(uint i=0; i<ids.length; i++){
            if(!exists(ids[i])){
                idsCount += ids.length; 
            }
            if (rewardSupplies[i] <= 0) {
                revert AmountMustBeAboveZero();
            } 
        }
        if(ids.length != accounts.length){
            revert IdsAndAccountsLengthMismatch();
        }
        for(uint i=0; i<accounts.length; i++){
            _mint(accounts[i], ids[i], rewardSupplies[i], "");
        }
       
       emit RewardsOnAddressesMinted(ids, rewardSupplies, accounts);

       return ids;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev uri is used to get the uri by token ID.
     *
     * Requirement:
     *
     * @param _tokenId - tokenId 
    */

    function uri(uint256 _tokenId)  public override view returns (string memory){
        if(!exists(_tokenId)){
            revert TokenIdNotExists();
        }     
        return string(
         abi.encodePacked(
              baseUri,
              Strings.toString(_tokenId)
            )
        );
    }

    /**
     * @dev getRewardByAddress is used to get information of all Rewards hold by the player address.
     * Requirement:
     *
     * @param playerAddress - playerAddress 
    */

    function getRewardsByAddress(address playerAddress)
    external
    view
    returns(PlayerRewards[] memory){
        uint[] memory rewardTokens = new uint[](idsCount);

        uint256 rewardCount;

        for (uint i = 1; i <= idsCount; i++){
            if(balanceOf(playerAddress, i) > 0 ){ 
                rewardTokens[rewardCount] = i;
                rewardCount++;
            } 
        }

        PlayerRewards [] memory totalRewardsToReturn = new PlayerRewards[](rewardCount);

        for (uint i = 0; i < rewardCount; i++){
                totalRewardsToReturn[i].rewardCopies = balanceOf(playerAddress, rewardTokens[i]);
                totalRewardsToReturn[i].rewardId = rewardTokens[i];
        }

      return totalRewardsToReturn;
    }
}
