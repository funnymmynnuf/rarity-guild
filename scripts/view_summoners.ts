
import * as cm from "./common";

async function run() {
    console.log('Viewing summoners in guild belonging to address:', process.env.ADDRESS);
    let res = await cm.ct.member_view_summoners(process.env.ADDRESS);
    console.log(res);
    res = await cm.ct.gm_get_active_summoner_count();
    console.log("Active:");
    console.log(res);
    res = await cm.ct.gm_get_idle_summoner_count();
    console.log("Idle:");
    console.log(res);
}

async function main() {
    await run();
}

run()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });