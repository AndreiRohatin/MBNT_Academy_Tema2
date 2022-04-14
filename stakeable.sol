contract Stakeable {


    constructor() {
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders.push();
    }

    struct Stake{
        address user;
        uint256 amount;
        uint256 since;
        // This claimable field is new and used to tell how big of a reward is currently available
        uint256 claimable;
    }
  
    struct Stakeholder{
        address user;
        Stake[] address_stakes;
        
    }
 
     struct StakingSummary{
         uint256 total_amount;
         Stake[] stakes;
     }

    Stakeholder[] internal stakeholders;

    mapping(address => uint256) internal stakes;

     event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);


    uint256 internal rewardPerHour = 1000;


    function _addStakeholder(address staker) internal returns (uint256){
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex; 
    }

    function _stake(uint256 _amount) internal{
        // Simple check so that user does not stake 0 
        require(_amount > 0, "Cannot stake nothing");
        

        uint256 index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;
        if(index == 0){
            index = _addStakeholder(msg.sender);
        }

        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp,0));
        // Emit an event that the stake has occured
        emit Staked(msg.sender, _amount, index,timestamp);
    }

      function calculateStakeReward(Stake memory _current_stake) internal view returns(uint256){
          return (((block.timestamp - _current_stake.since) / 1 hours) * _current_stake.amount) / rewardPerHour;
      }

     function _withdrawStake(uint256 amount, uint256 index) internal returns(uint256){
         // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[index];
        require(current_stake.amount >= amount, "Staking: Cannot withdraw more than you have staked");

         // Calculate available Reward first before we start modifying data
         uint256 reward = calculateStakeReward(current_stake);
         // Remove by subtracting the money unstaked 
         current_stake.amount = current_stake.amount - amount;
         // If stake is empty, 0, then remove it from the array of stakes
         if(current_stake.amount == 0){
             delete stakeholders[user_index].address_stakes[index];
         }else {
             // If not empty then replace the value of it
             stakeholders[user_index].address_stakes[index].amount = current_stake.amount;
             // Reset timer of stake
            stakeholders[user_index].address_stakes[index].since = block.timestamp;    
         }

         return amount+reward;
     }
    function hasStake(address _staker) public view returns(StakingSummary memory){
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount; 
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1){
           uint256 availableReward = calculateStakeReward(summary.stakes[s]);
           summary.stakes[s].claimable = availableReward;
           totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
       }
       // Assign calculate amount to summary
       summary.total_amount = totalStakeAmount;
        return summary;
    }

}