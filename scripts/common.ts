import * as dotenv from "dotenv";
import contract from '../artifacts/contracts/guild.sol/Guild.json';
import { ethers } from "hardhat";
dotenv.config();

// const contract_address = "0x5Ad583b5f10EE1ddABF242160f5E71d6B571D2Ff";
// const contract_address = "0x34a1c130e4a0358dec1f1cc945da2a3381aaeb1e";
const contract_address = "0x543a22a81bc7d56cebaf56cb0bf1c9911d9708bd";
const ct = new ethers.Contract(contract_address, contract.abi, ethers.provider);

export {
    contract,
    ct,
    dotenv,
    contract_address,
    ethers,
}
