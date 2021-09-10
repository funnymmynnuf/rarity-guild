
import * as cm from "./common";

async function run() {
    console.log('Viewing wanderers in guild belonging to address:', process.env.ADDRESS);
    let res = await cm.ct.view_wanderers(process.env.ADDRESS);
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