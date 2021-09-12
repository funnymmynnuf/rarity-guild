
import * as cm from "./common";

async function run() {
    console.log('Viewing summoners in guild belonging to address:', process.env.ADDRESS);
    let res = await cm.ct.member_view_summoners(process.env.ADDRESS);
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