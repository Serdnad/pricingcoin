class Session {
    contract: string
    participants: number
    totalStake: string
    status: string
    end: string

    constructor(contract: string, end: string, participants: number, status: string, totalStake: string) {
        this.contract = contract;
        this.end = end;
        this.participants = participants;
        this.status = status;
        this.totalStake = totalStake;
    }
}

export default Session