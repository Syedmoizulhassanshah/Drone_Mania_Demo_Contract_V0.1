# Drone_Mania_Demo_Contract_V0.1

### 1. Clone/Download the Repository

### 2. Smart Contracts
a) Deploy smart contract on rinkeby/polgon testnet.
b) Create .env file add the API_URL , Private key and deployed contract address.

### 3. Script ./getReadOnlyFunction
`$ node Scripts/getReadOnlyFunc.js`
it will return the read only functions 

### 4. Run Script getNonConstantFunction

`$ node Scripts/getNonConstantFunc.js`
it will sign the transaction and update contract state 
