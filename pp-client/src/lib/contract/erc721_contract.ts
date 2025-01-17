import { fetchJson } from "@ethersproject/web"
import { BigNumber, ethers } from "ethers"

import CONTRACT_ABI from "./erc721_metadata_abi.json"

export module Erc721Contract {
    let provider

    /** Initialize contract. */
    async function initialize() {
        // guard against unecessary initializations
        if (provider != undefined) return

        if (window.ethereum == undefined) {
            // TODO: help users install MetaMask if they haven't
            //  also, to keep the website functional, you may want to fallback on
            //  a default provider of your own
            alert("INSTALL METAMASK")
            return
        }

        provider = new ethers.providers.Web3Provider(window.ethereum)
    }

    export async function getInfo(address: string, tokenId: string): Promise<any> {
        if (provider == null) await initialize()

        const contract = new ethers.Contract(address, CONTRACT_ABI, provider)

        return contract.tokenURI(tokenId, { gasLimit: 2000000 }).then(async (metadataUri) => {
            return (await fetch(metadataUri)).json()
        }).catch(() => {
            return {
                name: "Unknown",
                description: "Doesn't comply with ERC721 standard, view on Etherscan",
                image: "/pplogo.png"
            }
        })
    }
}

export default Erc721Contract
