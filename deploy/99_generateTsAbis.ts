import * as fs from "fs";
import prettier from "prettier";
import { DeployFunction } from "hardhat-deploy/types";

function getDirectories(path: string) {
  return fs
    .readdirSync(path, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory())
    .map(dirent => dirent.name);
}

function getContractNames(path: string) {
  return fs
    .readdirSync(path, { withFileTypes: true })
    .filter(dirent => dirent.isFile() && dirent.name.endsWith(".json"))
    .map(dirent => dirent.name.split(".")[0]);
}

const DEPLOYMENTS_DIR = "./deployments";

function getContractDataFromDeployments() {
  if (!fs.existsSync(DEPLOYMENTS_DIR)) {
    throw Error("At least one other deployment script should exist to generate an actual contract.");
  }
  const output = {} as Record<string, any>;
  for (const chainName of getDirectories(DEPLOYMENTS_DIR)) {
    const chainId = fs.readFileSync(`${DEPLOYMENTS_DIR}/${chainName}/.chainId`).toString();
    const contracts = {} as Record<string, any>;
    for (const contractName of getContractNames(`${DEPLOYMENTS_DIR}/${chainName}`)) {
      const { abi, address } = JSON.parse(
        fs.readFileSync(`${DEPLOYMENTS_DIR}/${chainName}/${contractName}.json`).toString(),
      );
      contracts[contractName] = { address, abi };
    }
    output[chainId] = [
      {
        chainId,
        name: chainName,
        contracts,
      },
    ];
  }
  return output;
}

const generateTsAbis: DeployFunction = async function () {
  const TARGET_DIR = "frontend/generated/";
  const allContractsData = getContractDataFromDeployments();

  const fileContent = Object.entries(allContractsData).reduce((content, [chainId, chainConfig]) => {
    return `${content}${parseInt(chainId).toFixed(0)}:${JSON.stringify(chainConfig, null, 2)},`;
  }, "");

  if (!fs.existsSync(TARGET_DIR)) {
    fs.mkdirSync(TARGET_DIR);
  }
  fs.writeFileSync(
    `${TARGET_DIR}deployedContracts.ts`,
    prettier.format(`const contracts = {${fileContent}} as const; \n\n export default contracts`, {
      parser: "typescript",
    }),
  );

  console.log(`📝 Updated TypeScript contract definition file on ${TARGET_DIR}deployedContracts.ts`);
};

export default generateTsAbis;

generateTsAbis.tags = ["generateTsAbis"];

generateTsAbis.runAtTheEnd = true;
