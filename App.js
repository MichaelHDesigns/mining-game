import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import MiningRigFactoryABI from "./abis/MiningRigFactory.json";  // Your Factory contract ABI
import MiningRigABI from "./abis/MiningRig.json";  // MiningRig contract ABI
import NFTContractABI from "./abis/ERC1155NFT.json";  // Your NFT contract ABI

// Contract addresses
const MiningRigFactoryAddress = "0xYourMiningRigFactoryAddress"; // Replace with deployed factory contract
const NFTContractAddress = "0x970a8b10147e3459d3cbf56329b76ac18d329728"; // NFT contract for XL1, TX120, GP50

function App() {
  const [account, setAccount] = useState("");
  const [provider, setProvider] = useState(null);
  const [nftContract, setNFTContract] = useState(null);
  const [factoryContract, setFactoryContract] = useState(null);
  const [userNFTs, setUserNFTs] = useState([]);
  const [selectedNFTs, setSelectedNFTs] = useState([]); // NFTs selected for rig config
  const [userRigs, setUserRigs] = useState([]);

  // Function to load the user's MetaMask account and contracts
  const loadBlockchainData = async () => {
    if (window.ethereum) {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const account = await signer.getAddress();
      
      setAccount(account);
      setProvider(provider);
      
      // Initialize the contracts
      const nftContract = new ethers.Contract(NFTContractAddress, NFTContractABI, signer);
      const factoryContract = new ethers.Contract(MiningRigFactoryAddress, MiningRigFactoryABI, signer);
      
      setNFTContract(nftContract);
      setFactoryContract(factoryContract);

      // Load the NFTs owned by the user
      loadUserNFTs(nftContract, account);
      
      // Load deployed rigs for the user
      const rigs = await factoryContract.getUserRigs(account);
      setUserRigs(rigs);
    } else {
      alert("Please install MetaMask to use this app.");
    }
  };

  // Function to load user's NFTs from the NFT contract
  const loadUserNFTs = async (contract, userAddress) => {
    const tokenIds = [3, 4, 5]; // XL1 CPU (3), TX120 (4), GP50 (5)
    let nfts = [];
    
    for (let id of tokenIds) {
      const balance = await contract.balanceOf(userAddress, id);
      if (balance > 0) {
        nfts.push({ id, balance: balance.toNumber() });
      }
    }

    setUserNFTs(nfts);
  };

  // Handle selecting NFTs for the rig
  const handleSelectNFT = (nftId) => {
    setSelectedNFTs([...selectedNFTs, nftId]);
  };

  // Handle removing NFTs from the rig
  const handleRemoveNFT = (nftId) => {
    setSelectedNFTs(selectedNFTs.filter(id => id !== nftId));
  };

  // Deploy a new mining rig
  const deployMiningRig = async () => {
    if (factoryContract) {
      try {
        const tx = await factoryContract.createMiningRig(selectedNFTs);
        await tx.wait();
        alert("Mining rig deployed successfully!");
      } catch (error) {
        console.error("Error deploying mining rig", error);
      }
    }
  };

  // Function to remove NFTs from the Mining Rig
  const removeNFTsFromRig = async (rigAddress, nftIds) => {
    try {
      const miningRigContract = new ethers.Contract(rigAddress, MiningRigABI, provider.getSigner());
      const tx = await miningRigContract.removeNFTs(nftIds);
      await tx.wait();
      alert("NFTs removed from mining rig!");
    } catch (error) {
      console.error("Error removing NFTs from rig", error);
    }
  };

  // useEffect to load data when the app loads
  useEffect(() => {
    loadBlockchainData();
  }, []);

  return (
    <div>
      <header>
        <h1>Mining Game</h1>
        {account ? <p>Connected as: {account}</p> : <button onClick={() => window.ethereum.request({ method: "eth_requestAccounts" })}>Connect Wallet</button>}
      </header>

      <div>
        <h2>Your NFTs</h2>
        <div>
          {userNFTs.length === 0 ? <p>You have no NFTs.</p> : 
            userNFTs.map((nft, index) => (
              <div key={index}>
                <p>{nft.id === 3 ? "XL1 CPU" : nft.id === 4 ? "TX120 GPU" : "GP50 GPU"} - Balance: {nft.balance}</p>
                <button onClick={() => handleSelectNFT(nft.id)}>Select</button>
              </div>
            ))
          }
        </div>

        <h2>Selected NFTs</h2>
        <div>
          {selectedNFTs.length === 0 ? <p>No NFTs selected.</p> : 
            selectedNFTs.map((id, index) => (
              <div key={index}>
                <p>{id === 3 ? "XL1 CPU" : id === 4 ? "TX120 GPU" : "GP50 GPU"}</p>
                <button onClick={() => handleRemoveNFT(id)}>Remove</button>
              </div>
            ))
          }
        </div>

        <button onClick={deployMiningRig}>Deploy Mining Rig</button>
      </div>

      <div>
        <h2>Your Deployed Mining Rigs</h2>
        {userRigs.length === 0 ? <p>You have no rigs deployed.</p> : 
          userRigs.map((rig, index) => (
            <div key={index}>
              <p>Rig {index + 1}: {rig}</p>
              <button onClick={() => removeNFTsFromRig(rig, selectedNFTs)}>Remove NFTs from Rig</button>
            </div>
          ))
        }
      </div>
    </div>
  );
}

export default App;
