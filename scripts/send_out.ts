
import * as cm from "./common";

export async function run() {
    console.log('Viewing wanderers in guild belonging to address:', process.env.ADDRESS);
    let res = await cm.ct.view_wanderers(process.env.ADDRESS);
    console.log(res);

    return res;
}