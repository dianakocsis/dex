import * as chains from "wagmi/chains";

export type ScaffoldConfig = {
  targetNetwork: chains.Chain;
  pollingInterval: number;
  alchemyApiKey: string;
  walletConnectProjectId: string;
  onlyLocalBurnerWallet: boolean;
  walletAutoConnect: boolean;
};

const scaffoldConfig = {
  targetNetwork: chains.hardhat,

  pollingInterval: 30000,

  alchemyApiKey: process.env.NEXT_PUBLIC_ALCHEMY_API_KEY ?? "",

  walletConnectProjectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID ?? "",

  onlyLocalBurnerWallet: true,

  walletAutoConnect: true,
} satisfies ScaffoldConfig;

export default scaffoldConfig;
