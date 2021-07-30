<script lang="ts">
    import { onMount } from "svelte";
    import Button from "$lib/components/common/Button.svelte"
    import NavBar from "$lib/components/common/NavBar.svelte"
    import SessionsTable from "$lib/components/SessionsTable.svelte"
    import TextInput from "$lib/components/common/TextInput.svelte"
    import CurrencyIcon from "$lib/components/common/CurrencyIcon.svelte"
    import PpContract from "$lib/contract/pp_contract";
    import type Session from "$lib/models/session"

    let sessions: Session[] = []

    onMount(async () => {
        // TODO: Delete me
        let exampleValue = await PpContract.retrieve()
        console.log(exampleValue)

        sessions = await PpContract.getSessions()
    })
</script>

<NavBar />

<div class="container">
    <div>
        <div class="status-card">
            <p class="header">Claim Pool Status:</p>
            <p>Size: 100.3 ETH</p>
            <p>Active: No</p>
            <p>Time Left: 13 days</p>
        </div>

        <h4>Active Sessions Leaderboard</h4>
        <SessionsTable {sessions} />

        <div class="input-row">
            <!-- Note: when you hook these up, it may be most convenient to create a component -->
            <div>
                <p>Create New Session</p>
                <div>
                    <TextInput placeholder="NFT contract address here" />
                    <br />
                    <TextInput placeholder="NFT token ID here" />
                    <br />
                    <Button text={"Submit"} />
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
