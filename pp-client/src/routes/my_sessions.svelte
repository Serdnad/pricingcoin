<script lang="ts">
    import Button from "$lib/components/common/Button.svelte"
    import NavBar from "$lib/components/common/NavBar.svelte"
    import SessionsTable from "$lib/components/SessionsTable.svelte"
    import TextInput from "$lib/components/common/TextInput.svelte"
    import Session from "$lib/models/session"

    // TODO (Alan): Load sessions from wherever
    let tmp = new Session("0x28990a298acd67cfe133ef37758930ce92adbf64", 123412, Date.now() + "", 1000, "Voting", "200.5")
    let sessions = [tmp, tmp, tmp, tmp, tmp, tmp, tmp, tmp, tmp, tmp]
</script>

<NavBar />

<div class="container">
    <h4>My Pricing Sessions</h4>
    <SessionsTable {sessions} isMySessions="true" />

    <p>Know NFT address? Find it faster by<br />pasting contract address below!</p>
    <div class="input-group">
        <TextInput placeholder="NFT contract address here" />
        <br />
        <TextInput placeholder="NFT token ID here" />
        <br />
        <Button text={"Submit"} />
    </div>
</div>

<style lang="scss">
    .container {
        display: flex;
        flex-direction: column;
        align-items: center;

        margin-top: 16px;
    }

    h4 {
        font-size: 18px;
        font-weight: 400;
        margin: 0 0 2px 0;
    }

    p {
        text-align: center;
        font-size: 14px;
        line-height: 1.4;
        margin: 32px 0 4px 0;
    }
</style>
