
import * as cm from "./common";

export async function run() {
    console.log("Send out the army!!");

    const [wallet] = await cm.ethers.getSigners();
    let res = await cm.ct.connect(wallet).send_out();
    await res.wait();

    console.log(res);
}
