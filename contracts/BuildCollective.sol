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

  function compareUsers(User memory a, User memory b) public returns (bool) {
    return compareString(a.username, b.username)
    && a.balance == b.balance
    && a.registered == b.registered
    ;
  }

  mapping(address => User) private users;

  event UserSignedUp(address indexed userAddress, User indexed user);

  //function User qui renvoie les données d'un user
  function user(address userAddress) public view returns (User memory) {
    return users[userAddress];
  }

  // TEST ONLY
  function createUser(address userAddress, User memory u) public returns (User memory){
    users[userAddress] = u;
  }

  function signUp(string memory username) public returns (User memory) {
    require(bytes(username).length > 0);
    if(users[msg.sender].registered == false){
      users[msg.sender] = User(username, 0, true);
    }
    emit UserSignedUp(msg.sender, users[msg.sender]);
  }

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
    User[] members;
    uint256 balance;
    bool registered;
  }

  function compareCompanies(Company memory a, Company memory b) public returns (bool) {
    return compareString(a.name, b.name)
    && compareUsers(a.owner, b.owner)
    && a.balance == b.balance
    && a.registered == b.registered;
  }

  mapping(string => Company) private companies;
  mapping(address => Company) private members;

  event CompanyCreated(string indexed companyName, User indexed owner, Company indexed comp);

  function company(string memory companyName) public view returns (Company memory) {
    return companies[companyName];
  }

  function memberOf(address userAddress) public view returns (Company memory) {
    return members[userAddress];
  }

  function createCompany(string memory companyName) public returns (Company memory) {
    require(bytes(companyName).length > 0);
    require(users[msg.sender].registered); // If user aldready registred

    if(companies[companyName].registered == false){
      companies[companyName].name = companyName;
      companies[companyName].owner = users[msg.sender];
      companies[companyName].balance = 0;
      companies[companyName].registered = true;

      members[msg.sender] = companies[companyName];
    }
    emit CompanyCreated(companyName, users[msg.sender], companies[companyName]);

    return companies[companyName];
  }

  function addCompanyMember(string memory companyName, address newMember) public returns (Company memory){
    require(users[msg.sender].registered); // If user aldready registred
    require(users[newMember].registered); // If user aldready registred
    require(companies[companyName].registered); // If company aldready registred
    require(compareString(companies[companyName].owner.username, users[msg.sender].username)); // If user is company's owner

    members[newMember] = companies[companyName];
  }

  function addCompanyBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered); // User registred
    require(members[msg.sender].registered); // His company too
    users[msg.sender].balance -= amount;
    members[msg.sender].balance += amount;
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

  mapping(string => Project) private projects;
  mapping(address => string[]) private contributors;

  function compareProject(Project memory a, Project memory b) public returns (bool) {
    return compareString(a.name, b.name)
    && compareUsers(a.user_owner, b.user_owner)
    && compareCompanies(a.company_owner, b.company_owner)
    && a.balance == b.balance
    && a.registered == b.registered;
  }

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

  function project(string memory projectName) public view returns (Project memory) {
    return projects[projectName];
  }

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
        require(members[msg.sender].registered); // If user is in company
        projects[projectName].company_owner = members[msg.sender];
      }
      projects[projectName].balance = 0;
      projects[projectName].registered = true;
    }
    emit ProjectCreated(projectName, projects[projectName]);

    return projects[projectName];
  }

  function addProjectContributors(string memory projectName, address newContributor) public {
    require(users[msg.sender].registered); // If user aldready registred
    require(users[newContributor].registered); // If user aldready registred
    require(projects[projectName].registered); // If project aldready registred

    string[] storage projectContributionList = contributors[newContributor]; // Extract list
    projectContributionList.push(projectName); //
    contributors[newContributor] = projectContributionList;
    // return contributors[newContributor];
  }

  function addBalanceToProject(string memory projectName, uint256 amount, bool perso) public returns (bool) {
    require(users[msg.sender].registered); // If user aldready registred
    require(projects[projectName].registered); // If project aldready registred

    if (perso){
      require(users[msg.sender].balance >= amount);
      users[msg.sender].balance = users[msg.sender].balance - amount;
    }
    else{
      require(members[msg.sender].balance >= amount);
      members[msg.sender].balance = members[msg.sender].balance - amount;
    }

    Project memory currentProject = projects[projectName];
    projects[projectName].balance = currentProject.balance + amount;

    return true;
  }

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
      require(compareString(members[msg.sender].name, projects[projectName].company_owner.name));
    }
    else{
      revert("User or his company doesnt own the project");
    }

    projects[projectName].balance -= amount;
    projects[projectName].balance -= amount;
  }


}
