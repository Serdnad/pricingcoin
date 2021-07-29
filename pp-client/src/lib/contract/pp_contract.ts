import Session from "$lib/models/session"
import { ethers } from "ethers"

const CONTRACT_ADDRESS = "0x8a03E90bFE59D6CFF6D8f9feAD1b2cc3FcE293d8"
import CONTRACT_ABI from "./pp_contract_abi.json"

export module PpContract {
    let contract

    /** Initialize Web3 connection with any available provider. */
    async function initialize() {
        if (window.ethereum == undefined) {
            // TODO: help users install MetaMask if they haven't
            //  also, to keep the website functional, you may want to fallback on
            //  a default provider of your own
            alert("INSTALL METAMASK")
            return
        }

        const provider = new ethers.providers.Web3Provider(window.ethereum)
        contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider)
    }

    /** Connect to Ethereum wallet. */
    export async function connect() {
        await window.ethereum.enable()
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()


        // replace contract connection with signer
        contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer)
    }


    // placeholder (without error handling)
    export async function getSessions(): Promise<Session[]> {
        if (contract == null) await initialize()

        // TODO: replace with actual call
        let tmp = new Session("0x28990a298acd67cfe133ef37758930ce92adbf64", Date.now() + 5000 + "", 1000, "Voting", "200.5")
        return [tmp, tmp, tmp, tmp, tmp, tmp, tmp, tmp, tmp, tmp]
    }

    // example with sample contract
    export async function retrieve(): Promise<string> {
        if (contract == null) await initialize()

        return contract.retrieve()
    }

    // example with sample contract
    export async function store(value: ethers.BigNumberish) {
        if (contract == null) await initialize()

        return contract.store(value)
    }

    export async function getLossPoolRemainder(): Promise<ethers.BigNumberish> {
        if (contract == null) await initialize()

        return contract.getLossPoolRemainder()
    }

    export async function getProfitsGenerated(): Promise<ethers.BigNumberish> {
        if (contract == null) await initialize()

        return contract.getProfitsGenerated()
    }

    export async function getTotalCoinsIssued() {
        if (contract == null) await initialize()

        return contract.getTotalCoinsIssued()
    }

    // TODO (Alan): Write wrappers for other contract methods

}

export default PpContract