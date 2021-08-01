<script lang="ts">
    import { onMount } from "svelte"
    import Button from "$lib/components/common/Button.svelte"
    import NavBar from "$lib/components/common/NavBar.svelte"
    import SessionsTable from "$lib/components/SessionsTable.svelte"
    import TextInput from "$lib/components/common/TextInput.svelte"
    import PpContract from "$lib/contract/pp_contract"
    import type Session from "$lib/models/session"
    import { BigNumber, ethers, utils } from "ethers"
    import SessionSearch from "$lib/components/Sessions/SessionSearch.svelte"
    import SessionPopup from "$lib/components/SessionPopup.svelte"
    import { selectedSession } from "$lib/stores/session"

    let sessions: Session[] = []
    let isPopupVisible: boolean = false

    let poolSize = BigNumber.from(0)
    let active: boolean
    let timeLeft: ethers.BigNumberish

    onMount(async () => {
        sessions = await PpContract.getPricingSessions()

        PpContract.getLossPoolRemainder().then((num) => (poolSize = num))
        PpContract.getTimeLeft().then((num) => {
            timeLeft = num
            active = timeLeft.toNumber() == 0
        })
    })

    async function createSession(contractAddress: string, tokenId: string) {
        PpContract.createPricingSession(contractAddress, tokenId)
    }

    async function findActiveSession(contractAddress: string, tokenId: string) {
        const session = sessions.filter((session) => {
            return session.contract == contractAddress && session.tokenid.toString() == tokenId && session.isActive()
        })[0]

        if (session == null) {
            alert("Could not find active session")
            return
        }

        selectedSession.set(session)
        isPopupVisible = true
    }

    async function findPastSession(contractAddress: string, tokenId: string) {
        const session = sessions.filter((session) => {
            return session.contract == contractAddress && session.tokenid.toString() == tokenId && !session.isActive()
        })[0]

        if (session == null) {
            alert("Could not find past session")
            return
        }

        selectedSession.set(session)
        isPopupVisible = true
    }
</script>

<NavBar />

{#if isPopupVisible}
    <SessionPopup onExit={() => (isPopupVisible = false)} />
{/if}

<div class="container">
    <div>
        <div class="status-card">
            <p class="header">Claim Pool Status:</p>
            <p>Size: {ethers.utils.formatEther(poolSize)} ETH</p>
            <p>Active: {active ? "Yes" : "No"}</p>
            <p>Time Left: {timeLeft}s</p>
        </div>

        <h4>Active Sessions Leaderboard</h4>
        <SessionsTable {sessions} />

        <div class="input-row">
            <SessionSearch label={"Create New Session"} onSubmit={createSession} />

            <SessionSearch label={"Find Active Sessions"} onSubmit={findActiveSession} />

            <SessionSearch label={"Find Past Sessions"} onSubmit={findPastSession} />
        </div>
    </div>
</div>

<style lang="scss">
    .container {
        display: flex;
        flex-direction: column;
        align-items: center;

        margin-top: -16px;
    }

    .status-card {
        margin: 0 auto 16px auto;
        padding: 8px;
        width: fit-content;

        color: white;
        background: #1a54ff;
        border-radius: 5px;

        .header {
            font-weight: 600;
            text-decoration: underline;
        }

        p {
            margin: 0;
            font-size: 20px;
        }
    }

    h4 {
        font-size: 18px;
        font-weight: 400;
        margin: 0 0 2px 0;
        text-align: center;
    }

    .input-row {
        display: flex;
        justify-content: space-around;
        margin-top: 16px;
    }
</style>
