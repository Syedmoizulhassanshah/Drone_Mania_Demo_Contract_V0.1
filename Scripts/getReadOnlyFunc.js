require('dotenv').config();

const ethers = require('ethers');
const API_URL = process.env.API_URL
const PUBLIC_KEY = process.env.PUBLIC_KEY
const PRIVATE_KEY = process.env.PRIVATE_KEY
const Contract_Address = process.env.CONTRACT_ADDRESS;
const contractAbi = require("./artifacts/PlayerStateContract_metadata.json")
	
// Connect to the network
let customHttpProvider = new ethers.providers.JsonRpcProvider(API_URL);
const contract = new ethers.Contract(Contract_Address, contractAbi.output.abi, customHttpProvider);
	


//Calling readOnly Method
async function getAllPlayers(){
    const getAllPlayers = await contract.getAllPlayers();
	const owner = await contract.owner();
	console.log("All Player Details",getAllPlayers.toString());
	
}


getAllPlayers();

