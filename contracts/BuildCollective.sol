pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BuildCollective is Ownable {
  // ===========
  // || UTILS ||
  // ===========

  function compareString(string memory a, string memory b) public returns (bool) {
    return keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b)));
  }

  // ==========
  // || USER ||
  // ==========

  struct User {
    string username;
    uint256 balance;
    bool registered;
  }

  // Do matching between user adress and users struct with their data
  mapping(address => User) private users;

  event UserSignedUp(address indexed userAddress, User indexed user);

  //function User qui renvoie les données d'un user
  function user(address userAddress) public view returns (User memory) {
    return users[userAddress];
  }

  // Allow user creation
  function signUp(string memory username) public returns (User memory) {
    require(bytes(username).length > 0);
    if(users[msg.sender].registered == false){
      users[msg.sender] = User(username, 0, true);
    }
    emit UserSignedUp(msg.sender, users[msg.sender]);
  }

  // Give the 'amount' of token to the user who sent the msg
  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }

  // Withdraw from an user account
  function withdraw(uint256 amount) public returns (bool) {
      require(users[msg.sender].registered);
      require(users[msg.sender].balance >= amount);

      users[msg.sender].balance -= amount;

      address payable sender = address(uint160(msg.sender));
      sender.transfer(amount);

      return true;
  }

  // =============
  // || COMPANY ||
  // =============

  struct Company {
    string name;
    User owner;
    address[] members;
    uint256 balance;
    bool registered;
  }

  // Do matching between companies and their names
  mapping(string => Company) private companies;
  // Do matching between user's address and their company's name
  mapping(address => string) private members;

  event CompanyCreated(string indexed companyName, User indexed owner, Company indexed comp);

  // Return an company according to her name
  function getCompanie(string memory companyName) public view returns (Company memory) {
    return companies[companyName];
  }

  // Return company's name according to an member's address
  function memberOf(address userAddress) public view returns (string memory) {
    return members[userAddress];
  }

  // Create a company from it's name
  function createCompany(string memory companyName) public returns (Company memory) {
    require(bytes(companyName).length > 0);
    require(bytes(members[msg.sender]).length == 0, "Havent got aldready a company.");
    require(users[msg.sender].registered); // If user aldready registred

    if(companies[companyName].registered == false){
      companies[companyName].name = companyName;
      companies[companyName].owner = users[msg.sender];
      companies[companyName].balance = 0;
      companies[companyName].registered = true;

      addCompanyMember(companyName, msg.sender);
    }
    emit CompanyCreated(companyName, users[msg.sender], companies[companyName]);

    return companies[companyName];
  }

  // Adds a new user to the company whose name is specified
  function addCompanyMember(string memory companyName, address newMember) public returns (Company memory){
    require(users[msg.sender].registered); // If user aldready registred
    require(users[newMember].registered); // If user aldready registred
    require(companies[companyName].registered); // If company aldready registred
    require(compareString(companies[companyName].owner.username, users[msg.sender].username)); // If user is company's owner

    companies[companyName].members.push(newMember);
    members[newMember] = companies[companyName].name;
    return companies[companyName];
  }

  // Allow compny owner to transfer token from his balance to his company
  function addCompanyBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered); // User registred
    require(users[msg.sender].balance >= amount); // User balance is sufficient
    require(companies[members[msg.sender]].registered); // His company too
    users[msg.sender].balance -= amount;
    companies[members[msg.sender]].balance += amount;
    return true;
  }

  // =============
  // || PROJECT ||
  // =============

  struct Project {
    string name;
    uint256 balance;
    User user_owner;
    Company company_owner;
    bool registered;
  }

  string[] existingProject;

  // Do matching between project and their names
  mapping(string => Project) private projects;

  // Do matching between user and their multiple projects's names
  mapping(address => string[]) private contributors;

  // return all existing project
  function getProjectMapping() public view returns (string[] memory){
    return existingProject;
  }

  // Check if an user contribute to the project whose name is specified
  function checkIfContributeToProject(address contributor, string memory projectName) public returns (bool) {
    uint i = 0;
    string[] memory projectsList = contributors[contributor];
    for(i = 0; i < projectsList.length; i++){
      if (compareString(projectName, projectsList[i])){
        return true;
      }
    }
    return false;
  }

  event ProjectCreated(string indexed projectName, Project indexed pro);
  event ProjectFailedCreated(string indexed projectName, string explanation);

  // Return project according to his name
  function project(string memory projectName) public view returns (Project memory) {
    return projects[projectName];
  }

  // Return project according to an contributor address
  function contributorOf(address userAddress) public view returns (string[] memory) {
    return contributors[userAddress];
  }

  // If perso is true then the msg send is the owner, if it's false it will be his company
  function createProject(string memory projectName, bool perso) public returns (Project memory) {
    require(bytes(projectName).length > 0);
    require(users[msg.sender].registered); // If user aldready registred

    if(projects[projectName].registered == false){
      projects[projectName].name = projectName;
      if (perso){
        projects[projectName].user_owner = users[msg.sender];
      }
      else{
        require(companies[members[msg.sender]].registered); // If user is in company
        projects[projectName].company_owner = companies[members[msg.sender]];
      }
      projects[projectName].balance = 0;
      projects[projectName].registered = true;
    }
    emit ProjectCreated(projectName, projects[projectName]);

    existingProject.push(projectName);

    return projects[projectName];
  }

  // Add contributors to the project
  function addProjectContributors(string memory projectName, address newContributor) public {
    require(users[msg.sender].registered); // If user aldready registred
    require(users[newContributor].registered); // If user aldready registred
    require(projects[projectName].registered); // If project aldready registred

    // string[] storage projectContributionList = contributors[newContributor]; // Extract list
    // projectContributionList.push(projectName); //
    // contributors[newContributor] = projectContributionList;
    // return contributors[newContributor];
    contributors[newContributor].push(projectName);
  }

  // Allow project owner to transfer token from his balance to his project balance
  function addBalanceToProject(string memory projectName, uint256 amount, bool perso) public returns (bool) {
    require(users[msg.sender].registered); // If user aldready registred
    require(projects[projectName].registered); // If project aldready registred

    if (perso){
      require(users[msg.sender].balance >= amount);
      users[msg.sender].balance = users[msg.sender].balance - amount;
    }
    else{
      require(companies[members[msg.sender]].balance >= amount);
      companies[members[msg.sender]].balance = companies[members[msg.sender]].balance - amount;
    }

    Project memory currentProject = projects[projectName];
    projects[projectName].balance = currentProject.balance + amount;

    return true;
  }

  // Pay an project contributor with some token from the project balance
  function payContributor(string memory projectName, address contributor, uint256 amount) public {
    require(users[msg.sender].registered); // If user aldready registred
    require(users[contributor].registered); // If contributor aldready registred
    require(checkIfContributeToProject(contributor, projectName)); // If contributor aldready registred
    require(projects[projectName].registered); // If project aldready registred
    require(projects[projectName].balance >= amount); // If project had a balance with enough token

    // check if user or his company own the project
    if (bytes(projects[projectName].user_owner.username).length > 0){
      require(compareString(users[msg.sender].username, projects[projectName].user_owner.username));
    }
    else if (bytes(projects[projectName].company_owner.name).length > 0){
      require(compareString(members[msg.sender], projects[projectName].company_owner.name));
    }
    else{
      revert("User or his company doesnt own the project");
    }

    projects[projectName].balance -= amount;
    projects[projectName].balance -= amount;
  }

  // Too high gas cost

  // ============
  // || Bounty ||
  // ============

  // struct Bounty {
  //   string name;
  //   string desc;
  //   uint256 value;
  //   User owner;
  //   string relatedProject;
  //   bool archived;
  //   bool registered;
  // }
  //
  // mapping(string => Bounty) private bounties;
  // mapping(string => string[]) private relatedTo;
  //
  // event BountyCreated(string indexed bountyName, Bounty indexed bou);
  //
  //
  // function getBounty(string memory bountyName) public view returns (Bounty memory) {
  //   return bounties[bountyName];
  // }
  //
  // function getBountyRelatedTo(string memory projectName) public view returns (string[] memory) {
  //   return relatedTo[projectName];
  // }
  // // Create an bounty from their data
  // function createBounty(string memory BountyName,string memory desc , uint256 value, string memory relatedProject) public returns (Bounty memory) {
  //   require(bytes(BountyName).length > 0);
  //   require(bytes(desc).length > 0);
  //   require(projects[relatedProject].balance >= value);
  //   require(value > 0);
  //   require(projects[relatedProject].registered);
  //   require(users[msg.sender].registered); // If user aldready registred
  //
  //   if(!bounties[BountyName].registered){
  //     bounties[BountyName].name = BountyName;
  //     bounties[BountyName].desc = desc;
  //
  //     projects[relatedProject].balance -= value;
  //     bounties[BountyName].value = value;
  //
  //     bounties[BountyName].owner = users[msg.sender];
  //     bounties[BountyName].relatedProject = relatedProject;
  //     relatedTo[relatedProject].push(BountyName);
  //
  //     bounties[BountyName].archived = false;
  //     bounties[BountyName].registered = true;
  //   }
  //
  //   emit BountyCreated(BountyName, bounties[BountyName]);
  //
  //   return bounties[BountyName];
  // }
  // // Close an bounty and pay the dev who fixed the issue
  // function closeBountyAndPay(string memory bountyName, address receiver) public {
  //   require(bytes(bountyName).length > 0);
  //   // require(bytes(bounties[bountyName].owner.username) == bytes(users[msg.sender].username));
  //   require(compareString(bounties[bountyName].owner.username, users[msg.sender].username));
  //   require(users[msg.sender].registered); // If user aldready registred
  //   require(users[receiver].registered); // If receiver aldready registred
  //   require(!bounties[bountyName].archived); // If receiver aldready registred
  //
  //   users[receiver].balance += bounties[bountyName].value;
  //   bounties[bountyName].archived = true;
  // }




}
