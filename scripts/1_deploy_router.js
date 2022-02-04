const FACTORY_ADDRESS = "0x0176783aa9160c8fFA7E8f31F51dFbfFD63A8b1c";
const WETH_ADDRESS = "0xd0A1E359811322d97991E03f863a0C30C2cF029C";

async function main() {
    // We get the contract to deploy
    const Router = await ethers.getContractFactory("BotdexRouter");
    const router = await Router.deploy(FACTORY_ADDRESS, WETH_ADDRESS);
  
    console.log("BotdexRouter deployed to:", router.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });