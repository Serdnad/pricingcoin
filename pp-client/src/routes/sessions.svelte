<script lang="ts">
    import { onMount } from "svelte"
    import Button from "$lib/components/common/Button.svelte"
    import NavBar from "$lib/components/common/NavBar.svelte"
    import SessionsTable from "$lib/components/SessionsTable.svelte"
    import TextInput from "$lib/components/common/TextInput.svelte"
    import PpContract from "$lib/contract/pp_contract"
    import type Session from "$lib/models/session"

    let sessions: Session[] = []

    let poolSize: string
    let active: boolean
    let timeLeft: ethers.BigNumberish

    let newSessionAddress
    let newSessionTokenId

    onMount(async () => {
        sessions = await PpContract.getPricingSessions()

        PpContract.getLossPoolRemainder().then((num) => (poolSize = num.toString()))
        PpContract.getTimeLeft().then((num) => {
            timeLeft = num
            active = timeLeft.toNumber() == 0
        })
    })

    async function createSession() {
        PpContract.createPricingSession(newSessionAddress, newSessionTokenId)
    }

    async function findActiveSession() {}

    async function findPastSession() {}
</script>

<NavBar />

<div class="container">
    <div>
        <div class="status-card">
            <p class="header">Claim Pool Status:</p>
            <p>Size: {poolSize} ETH</p>
            <p>Active: {active ? "Yes" : "No"}</p>
            <p>Time Left: {timeLeft}s</p>
        </div>

        <h4>Active Sessions Leaderboard</h4>
        <SessionsTable {sessions} />

        <div class="input-row">
            <!-- Note: when you hook these up, it may be most convenient to create a component -->
            <div>
                <p>Create New Session</p>
                <div>
                    <TextInput placeholder="NFT contract address here" bind:value={newSessionAddress} />
                    <br />
                    <TextInput placeholder="NFT token ID here" bind:value={newSessionTokenId} />
                    <br />
                    <Button text={"Submit"} on:click={createSession} />
                </div>
            </div>

            <div>
                <p>Find Active Session</p>
                <div>
                    <TextInput placeholder="NFT contract address here" />
                    <br />
                    <TextInput placeholder="NFT token ID here" />
                    <br />
                    <Button text={"Submit"} />
                </div>
            </div>

            <div>
                <p>Find Past Sessions</p>
                <div>
                    <TextInput placeholder="NFT contract address here" />
                    <br />
                    <TextInput placeholder="NFT token ID here" />
                    <br />
                    <Button text={"Submit"} />
                </div>
            </div>
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

        p {
            margin: 0;
            text-align: center;
        }
    }
</style>
