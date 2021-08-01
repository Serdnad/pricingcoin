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

    export async function getInfo(address: string, tokenId: string) {
        if (provider == null) await initialize()

        const contract = new ethers.Contract(address, CONTRACT_ABI, provider)
        const name = await contract.name()
        console.log(name)

        try {
            const metadataUri = await contract.tokenURI(tokenId, { gasLimit: 2000000 })
            const metadata = await (await fetch(metadataUri)).json()

            console.log()
            return metadata
        } catch (e) {
            console.error(e)
        }
    }
}

export default Erc721Contract
