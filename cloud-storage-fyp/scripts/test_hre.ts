import hre from "hardhat";

async function main() {
    const net = await hre.network.create();
    console.log(Object.keys(net));
    if ('ethers' in net) {
        console.log("ethers is in net!");
    }
}
main();
