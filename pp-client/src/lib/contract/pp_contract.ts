import Session from "$lib/models/session"
import { BigNumber, ethers } from "ethers"

const CONTRACT_ADDRESS = "0x4fd04a0d04d19944e6f2F91420ef944ddC28E4c6"
import CONTRACT_ABI from "./pp_contract_abi.json"

export module PpContract {
    let contract: ethers.Contract
    let currentAccount: string

    /** Initialize Web3 connection with any available provider. */
    async function initialize() {
        // guard against unecessary initializations
        if (contract != undefined) return

        if (window.ethereum == undefined) {
            // TODO: help users install MetaMask if they haven't
            //  also, to keep the website functional, you may want to fallback on
            //  a default provider of your own
            alert("INSTALL METAMASK")
            return
        }

        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()
        currentAccount = (await provider.listAccounts())[0]
        contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer)
    }

    /** Connect to Ethereum wallet. */
    export async function connect() {
        await window.ethereum.enable() // this is the important line
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()

        // replace contract connection with signer
        contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer)
        console.log(contract.wallet)
    }

    // - Overview Info

    export async function getProfitGenerated(): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        return contract.getProfitGenerated()
    }

    export async function nftsPriced(): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        return contract.getProfitGenerated()
    }

    export async function getTotalCoinsIssued(): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        return contract.getTotalCoinsIssued()
    }

    // - Claim Pool

    export async function getLossPoolRemainder(): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        return contract.getLossPoolRemainder()
    }

    export async function getTimeLeft(): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        return contract.getTimeLeft()
    }

    /** Returns the Pp balance of the currently connect wallet. */
    export async function balanceOfSelf(): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        // if (account == null) await connect()
        // console.log(account)

        console.log("ASD", currentAccount)
        return contract.balanceOf(currentAccount)
    }

    export async function getClaimSize(): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        return contract.getClaimSize()
    }

    // - Session Management

    /**
     * Get all pricing sessions.
     */
    export async function getPricingSessions(): Promise<Session[]> {
        if (contract == null) await initialize()

        let sessions: Session[] = []

        for (let i = 0; i < Number.MAX_SAFE_INTEGER; i++) {
            try {
                const nft = await contract.listOfNfts(i)
                const sessionData = await contract.getSession(nft.nftAddress, nft.tokenid)

                const session = new Session(
                    nft.nftAddress,
                    nft.tokenid,
                    sessionData[0].mul(1000),
                    sessionData[1],
                    sessionData[2],
                    sessionData[3],
                )

                sessions.push(session)
            } catch (e) {
                break
            }
        }

        return sessions
    }

    export async function getMyPricingSessions(): Promise<Session[]> {
        if (contract == null) await initialize()

        let sessions: Session[] = []

        for (let i = 0; i < Number.MAX_SAFE_INTEGER; i++) {
            try {
                const nft = await contract.userSessionsParticipated(currentAccount, i)
                const sessionData = await contract.getSession(nft.nftAddress, nft.tokenid)

                const session = new Session(
                    nft.nftAddress,
                    nft.tokenid,
                    sessionData[0].mul(1000),
                    sessionData[1],
                    sessionData[2],
                    sessionData[3],
                )

                sessions.push(session)
            } catch (e) {
                break
            }
        }

        return sessions
    }

    export async function createPricingSession(address: string, tokenid: ethers.BigNumberish) {
        if (contract == null) await initialize()
        contract.createPricingSession(address, tokenid)
    }

    // - Session Actions

    export async function setVote(appraisal: ethers.BigNumberish, stake: ethers.BigNumberish, address: string, tokenid: ethers.BigNumberish) {
        if (contract == null) await initialize()
        return contract.setVote(appraisal, address, tokenid, { value: stake })
    }

    export async function weightVote(address: string, tokenid: ethers.BigNumberish) {
        if (contract == null) await initialize()
        contract.weightVote(address, tokenid)
    }

    export async function setFinalAppraisal(address: string, tokenid: ethers.BigNumberish) {
        if (contract == null) await initialize()
        contract.setFinalAppraisal(address, tokenid)
    }

    export async function calculateBase(address: string, tokenid: ethers.BigNumberish) {
        if (contract == null) await initialize()
        contract.calculateBase(address, tokenid)
    }

    export async function issueCoins(address: string, tokenid: ethers.BigNumberish) {
        if (contract == null) await initialize()
        contract.issueCoins(address, tokenid)
    }

    export async function harvestLoss(address: string, tokenid: ethers.BigNumberish) {
        if (contract == null) await initialize()
        contract.harvestLoss(address, tokenid)
    }

    // - Session details

    export async function getStake(address: string, tokenid: ethers.BigNumberish): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        return contract.getStake(address, tokenid)
    }

    export async function getTotalVoters(address: string, tokenid: ethers.BigNumberish): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        return contract.getTotalVoters(address, tokenid)
    }

    // TODO
    export async function getAppraisal(address: string, tokenid: ethers.BigNumberish): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        return contract.getAppraisal(address, tokenid)
    }


    export async function getTotalSessionStake(address: string, tokenid: ethers.BigNumberish): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        const sessionData = await contract.getSession(address, tokenid)
        return sessionData[2]
    }

    export async function getFinalAppraisal(address: string, tokenid: ethers.BigNumberish): Promise<ethers.BigNumber> {
        if (contract == null) await initialize()
        return contract.getFinalAppraisal(address, tokenid)
    }

    // - misc

    export async function endSession(address: string, tokenid: ethers.BigNumberish) {
        if (contract == null) await initialize()
        contract.endSession(address, tokenid)
    }

    export async function distributeLossPool() {
        if (contract == null) await initialize()
        contract.distributeLossPool()
    }
}

export default PpContract