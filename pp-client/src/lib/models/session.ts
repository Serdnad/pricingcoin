class Session {
    contract: string
    tokenid: number
    participants: number
    totalStake: string
    status: string
    end: string

    constructor(contract: string, tokenid: number, end: string, participants: number, status: string, totalStake: string) {
        this.contract = contract;
        this.tokenid = tokenid;
        this.end = end;
        this.participants = participants;
        this.status = status;
        this.totalStake = totalStake;
    }
}

export default Session