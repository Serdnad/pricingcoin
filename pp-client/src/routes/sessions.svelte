<script lang="ts">
    import Button from "$lib/components/common/Button.svelte"
    import NavBar from "$lib/components/common/NavBar.svelte"
    import SessionsTable from "$lib/components/SessionsTable.svelte"
    import TextInput from "$lib/components/common/TextInput.svelte"
    import Session from "$lib/models/session"
    import CurrencyIcon from "$lib/components/common/CurrencyIcon.svelte"

    // TODO (Alan): Load sessions from wherever
    let tmp = new Session("0x28990a298acd67cfe133ef37758930ce92adbf64", Date.now() + 5000 + "", 1000, "Voting", "200.5")
    let sessions = [tmp, tmp, tmp, tmp, tmp, tmp, tmp, tmp, tmp, tmp]
</script>

<NavBar />

<div class="container">
    <div>
        <div class="status-card">
            <p class="header">Claim Pool Status:</p>
            <p>Size: 100.3 <CurrencyIcon currency="eth" /></p>
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
                    <TextInput placeholder="NFT contract number here" />
                    <Button text={"Submit"} />
                </div>
            </div>

            <div>
                <p>Find Active Session</p>
                <div>
                    <TextInput placeholder="NFT contract number here" />
                    <Button text={"Submit"} />
                </div>
            </div>

            <div>
                <p>Find Past Sessions</p>
                <div>
                    <TextInput placeholder="NFT contract number here" />
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
