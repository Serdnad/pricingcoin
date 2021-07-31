import type { ethers } from "ethers"

enum SessionStatus {
    voting, weight, setFinal, calcBase, issue, harvest
}

class Session {
    contract: string
    tokenid: string
    participants: string
    totalStake: string
    status: string
    end: Date

    constructor(contract: string, tokenid: ethers.BigNumber, end: ethers.BigNumber, participants: ethers.BigNumber, totalStake: ethers.BigNumber, status: ethers.BigNumber) {
        this.contract = contract
        this.tokenid = tokenid.toString()
        this.end = new Date(end.toNumber())
        this.participants = participants.toString()
        this.totalStake = totalStake.toString()
        this.status = SessionStatus[status.toNumber() - 1]
    }
}

export default Session