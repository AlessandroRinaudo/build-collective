# implemented functionalities

### front
- Page to open a user account. Which each user is identified by its wallet address.
- Page to open an entreprise account.
- Page to create a project.

### back

- User account, with a name and a balance.
- Entreprise account, with a name, an owner and some members, possibly with a balance

- projects on which we can give money for sponsoring. 
Each project has a :
    - Balance
    - Name 
    - List of contributors.
- Bounties

# The application

To use the app you need to connect :

![](https://codimd.alessandroserver.com/uploads/upload_87cd8ee150627b9efcca02f6d70d2a05.png)

Then you can choise to use your personal account or your company account : 

![](https://codimd.alessandroserver.com//uploads/upload_e4a73c91eb53eeea2bf66a03a813689f.png)

Create an user account if you are not subscribed :

![](https://codimd.alessandroserver.com//uploads/upload_2069d56570c4e37a92d28a715656be98.png)

Create a company account to associate to your account (you will become the owner) : 

![](https://codimd.alessandroserver.com//uploads/upload_1c4f58943ac50756c23215d35ec879b5.png)

Add other members with other user address : 

![](https://codimd.alessandroserver.com//uploads/upload_ca3529467a183048fc2ffd82fd533e9b.png)

Add a Project to your personal account (Your project will be visible to all users of build collective)

![](https://codimd.alessandroserver.com//uploads/upload_cf502b48b50214776e3788ff39cb1771.png)

Choise a name for your project : 
![](https://codimd.alessandroserver.com//uploads/upload_33f2bd042d081089bd76650f0d008251.png)

You can look projects created by yourself or other community member :

![](https://codimd.alessandroserver.com//uploads/upload_9942f781b11792847c81410c4eb60881.png)





# Build Collective

Welcome to the DAAR project. The idea will be to implement an OpenCollective competitor
in a decentralized way, on Ethereum. This will have cool side effects, like not
be forced to pay for servers.

# Installation

```bash
# With HTTPS
git clone https://github.com/AlessandroRinaudo/build-collective.git
# Or with SSH
git clone git@github.com:AlessandroRinaudo/build-collective.git
```

You’ll need to install dependencies. You’ll need [`Ganache`](https://www.trufflesuite.com/ganache), [`Node.js`](https://nodejs.org/en/) and [`NPM`](https://www.npmjs.com/) or [`Yarn`](https://yarnpkg.com/). You’ll need to install [`Metamask`](https://metamask.io/) as well to communicate with your blockchain.

- `Ganache` is a local blockchain development, to iterate quickly and avoiding wasting Ether during development.
- `Node.js` is used to build the frontend and running `truffle`, which is a utility to deploy contracts.
- `NPM` or `Yarn` is a package manager, to install dependencies for your frontend development. Yarn is recommended.
- `Metamask` is a in-browser utility to interact with decentralized applications.

# Some setup

Once everything is installed, launch `Ganache`. Create a new workspace, give it a name, and accept. You should have a local blockchain running in local. Now you can copy the mnemonic phrase Ganache generated, open Metamask, and when it asks to import a mnemonic, paste the mnemonic. Create the password of your choice and that’s fine.
Now you can connect Metamask to the blockchain. To do this, add a network by clicking on `main network` and `personalized RPC`. Here, you should be able to add a network.

![Ganache Config](public/ganache-config.png)

Once you have done it, you’re connected to the Ganache blockchain!

# Run the frontend

Install the dependencies.

```bash
# Yarn users
yarn
# NPM users
npm install
```

Compile the contracts.

```bash
# Yarn users
yarn contracts:migrate
# NPM users
npm run contracts:migrate
```

Create a symlink for your OS if this is not done for you.

```bash
# Windows
mklink /D src\build "..\build"

# Unix and macOS
ln -s ../build ./src/build
```

Run the frontend

```bash
# Yarn users
yarn serve
# NPM users
npm run serve
```

You’re good to go!

# Subject

Implement an OpenCollective from scratch in Solidity.

# Smart Contract

- Open user account, with a name and a balance.
- Open an entreprise account, with a name, an owner and some members, possibly with a balance.
- Create projects on which we can give money for sponsoring. Each project has a balance, a name and a list of contributors. Each project belongs to a user or an entreprise. The money given to the project can be send to contributors, and contributors only.
- On a project, you should be able to create bounties. Bounties are bugs with a reward: if you spot a bug and you want to have it fix quickly, open a bounty and put some eth on it. When the fix is pushed, the author will get the eth. He’s a bounty hunter.
- Add the ability to put some link to commits from GitHub or GitLab in the projects, to keep a track of what has been done.

# Front

- Create a page to open a user account. Remember, each user is identified by its wallet address.
- Create a page to open an entreprise account.
- Create a page to create a project.
- Create a page to get a full recap of everything that happened on a project as a timeline.
