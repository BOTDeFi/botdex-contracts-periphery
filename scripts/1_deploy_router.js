const FACTORY_ADDRESS = "0x219864AC21AFe9B03386B172cc58334d949cDC88";
const WETH_ADDRESS = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";

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