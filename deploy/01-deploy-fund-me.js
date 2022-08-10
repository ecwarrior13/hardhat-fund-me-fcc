//import

const {
    getNamedAccounts,
    networkConfig,
    developmentChains
} = require("../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")
//main function
//calling of main function
/*
function deployFunc(hre) {
    console.log("Hi")
}
module.exports.default = deployFunc
below is the same as the function
module.exports = async (hre) => {
    const { getNamedAccounts, deployments } = hre
}
another way to write above
*/
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    // if chain x use y
    // if chain z use A
    //const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    let ethUsdPriceFeedAddress
    if (developmentChains.includes(network.name)) {
        const ethUdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    //what happens when we change chains

    //when going localhost or hardhat network we want to us a mock
    //if contract does not exist
    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args, //put price feed address
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1
    })
    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        //VERIFY
        await verify(fundMe.address, args)
    }
    log("---------------------------------------------")
}

module.exports.tags = ["all", "fundme"]
