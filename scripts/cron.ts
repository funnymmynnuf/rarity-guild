
import { run as send_out } from "./send_out";
import * as cm from "./common";
import * as cron from "node-cron";

cron.schedule("0 */30 * * * *", async () => {
    console.log("Run time: ", new Date().toLocaleString());

    let last_block = await cm.ethers.provider.getBlockNumber();
    last_block = (await cm.ethers.provider.getBlock(last_block)).timestamp;

    let wait_block = await cm.ct.next_excursion();

    if (last_block > wait_block) {
        let res = await send_out();
    } else {
        console.log("Don't leave the barracks.");
    }
});
