require('dotenv').config();
const ethers = require('ethers');
const API_URL = process.env.API_URL;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const Contract_Address = process.env.CONTRACT_ADDRESS;
const contractAbi = require("./artifacts/PlayerStateContract_metadata.json");



// Connect to the network
let customHttpProvider = new ethers.providers.JsonRpcProvider(API_URL);


async function updatePlayerInfo(playerURI,playerAddress,playerScore) {
	
    let wallet = new ethers.Wallet(PRIVATE_KEY, customHttpProvider);
    let contractWithSigner = new ethers.Contract(Contract_Address, contractAbi.output.abi, wallet);
    
    const getPlayerInfo = await contractWithSigner.updatePlayerInfo(playerURI,playerAddress,playerScore);
    console.log("Transaction Successfully Done");
    console.log("Tx Hash :", getPlayerInfo.hash);
    console.log("Confirmation :",getPlayerInfo.confirmations);
            
}
	

updatePlayerInfo(
	"QmbFYtJqYuDwAYucwxyvYPLfgegpjGpNMWPt5p3cxTY9sy",
	"0x8c8e240C723F5F850c6fdfD04a1B08598DaF6B53",
	200
);
