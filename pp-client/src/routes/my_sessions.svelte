<script lang="ts">
    import Button from "$lib/components/common/Button.svelte"
    import NavBar from "$lib/components/common/NavBar.svelte"
    import SessionsTable from "$lib/components/SessionsTable.svelte"
    import TextInput from "$lib/components/common/TextInput.svelte"
    import type Session from "$lib/models/session"
    import { onMount } from "svelte"
    import PpContract from "$lib/contract/pp_contract"
    import SessionPopup from "$lib/components/SessionPopup.svelte"
    import { selectedSession } from "$lib/stores/session"
    import SessionSearch from "$lib/components/Sessions/SessionSearch.svelte"

    let sessions: Session[] = []
    let isPopupVisible: boolean = false

    onMount(async () => {
        sessions = await PpContract.getMyPricingSessions()
    })

    async function findSession(contractAddress: string, tokenId: string) {
        const session = sessions.filter((session) => {
            return session.contract == contractAddress && session.tokenid.toString() == tokenId
        })[0]

        if (session == null) {
            alert("Could not find session")
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
    <h4>My Pricing Sessions</h4>
    <SessionsTable {sessions} isMySessions={true} />

    <br />
    <SessionSearch
        label={"Know NFT address? Find it faster by\npasting contract address below!"}
        onSubmit={findSession}
    />
</div>

<style lang="scss">
    .container {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;

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
