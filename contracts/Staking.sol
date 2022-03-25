pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {BAT} from "./BAT.sol";


contract StakingRewards{

    IERC20 public stakingToken;
    IERC721 public BoredApeNFT;

 struct Account{
        uint currentStake;
        uint lastTimeStake;
        }
    mapping(address => Account) public AccountDetails;

    
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 30 days;
    uint256 minimumPeriod = 3 days;
  
  using SafeMath for uint256;

//   address BoredApeNFT = 0xBC4CA0EDA7647A8Ab7C2061C2E118A18A936F13D;
  

    address[] internal stakeholders;

   
    mapping(address => uint256) internal stakes;

   
    mapping(address => uint256) internal rewards;

    
   constructor(address _stakingToken, address _BoredApeNFT) {
        stakingToken = IERC20(_stakingToken);
        BoredApeNFT = IERC721(_BoredApeNFT);
    }

    // ---------- STAKES ----------

    
    // A method for a stakeholder to create a stake.
    // _stake The size of the stake to be created.
    
    function createStake(uint256 _stake)
        public
    {
        _burn(msg.sender, _stake);
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
    }

    // method for a stakeholder to remove a stake.
     //_stake The size of the stake to be removed.
    function stake(uint _amount) external {
      Account storage A = AccountDetails[msg.sender];
      require(IERC721(BoredApe).balanceOf(_address)>= 1, "buy one bored ape to stake");
      require(_amountIn >= 5* 10**18, "You need  to stake > 5 BAT tokens");
      if (A.lastTimeStake==0){
        A.currentStake = _amount;
      }
      else {
        if(A.lastTimeStake>= minimumPeriod){
        uint stakePeriod = block.timestamp - A.lastTimeStake;
        uint bonus = (o.currentStake * 347/1000000000 * stakePeriod);

        A.currentStake += bonus+_amount
        } else{
          A.currentStake += _amount;
        }
        
        A.lastTimeStake = block.timestamp;
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stake[msg.sender] += _amount;
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _amount);
    }

    /**
     A method to retrieve the stake for a stakeholder.
     _stakeholder The stakeholder to retrieve the stake for.
     uint256 The amount of wei staked.
     */
    function stakeOf(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stakes[_stakeholder];
    }

    /**
      A method to the aggregated stakes from all stakeholders.
      uint256 The aggregated stakes from all stakeholders.
     */
    function totalStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        return _totalStakes;
    }

    // ---------- STAKEHOLDERS ----------

    /**
      A method to check if an address is a stakeholder.
     _address The address to verify.
      bool, uint256 Whether the address is a stakeholder, 
     * and if so its position in the stakeholders array.
     */
    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
      require(IERC721(BoredApe).balanceOf(_address)>= 1, "buy one bored ape to stake");
      
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    /**
      A method to add a stakeholder.
      _stakeholder The stakeholder to add.
     */
    function addStakeholder(address _stakeholder)
        public
    {
      require(IERC721(BoredApe).balanceOf(_stakeholder)>= 1, "buy one bored ape to stake");
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }

    /**
      A method to remove a stakeholder.
      _stakeholder The stakeholder to remove.
     */
    function removeStakeholder(address _stakeholder)
        public
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        } 
    }

    // ---------- REWARDS ----------
    
    /**
     * A method to allow a stakeholder to check his rewards.
      _stakeholder The stakeholder to check rewards for.
     */
    function rewardOf(address _stakeholder) 
        public
        view
        returns(uint256)
    {
        return rewards[_stakeholder];
    }

    /**
     *  A method to the aggregated rewards from all stakeholders.
     * uint256 The aggregated rewards from all stakeholders.
     */
    function totalRewards()
        public
        view
        returns(uint256)
    {
        uint256 _totalRewards = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
        }
        return _totalRewards;
    }

    /** 
     * @notice A simple method that calculates the rewards for each stakeholder.
     * @param _stakeholder The stakeholder to calculate rewards for.
     */
    function calculateReward(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stakes[_stakeholder] * ();
    }

    /**
     * @notice A method to distribute rewards to all stakeholders.
     */
    function distributeRewards() 
        public
        onlyOwner
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address stakeholder = stakeholders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder].add(reward);
        }
    }

    /**
     * @notice A method to allow a stakeholder to withdraw his rewards.
     */
    function withdrawReward() 
        public
    {
         require(block.timestamp - stakedAt[msg.sender] >= 3 days, "You can only claim after 3days");
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    }
}