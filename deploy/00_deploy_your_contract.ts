import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("Balloons", {
    from: deployer,
    log: true,
    autoMine: true,
  });

  const balloons = await hre.ethers.getContract("Balloons", deployer);

  await deploy("DEX", {
    from: deployer,
    args: [balloons.address],
    log: true,
    autoMine: true,
  });

  const dex = await hre.ethers.getContract("DEX", deployer);

  await balloons.transfer("0x80584B69e51DAE0D0b03BE93EBc014FAAB6D15dF", "" + 10 * 10 ** 18);

  console.log("Approving DEX (" + dex.address + ") to take Balloons from main account...");
  //If you are going to the testnet make sure your deployer account has enough ETH
  await balloons.approve(dex.address, hre.ethers.utils.parseEther("100"));
  console.log("INIT exchange...");
  await dex.init(hre.ethers.utils.parseEther("5"), {
    value: hre.ethers.utils.parseEther("5"),
    gasLimit: 200000,
  });
};

export default deployYourContract;

deployYourContract.tags = ["Balloons", "DEX"];
