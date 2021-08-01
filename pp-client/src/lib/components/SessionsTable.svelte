<script lang="ts">
    import type Session from "$lib/models/session"
    import { selectedSession } from "$lib/stores/session"
    import { shortenId } from "$lib/util"
    import { ethers, utils } from "ethers"
    import SessionPopup from "./SessionPopup.svelte"

    export let sessions: Session[]
    export let isMySessions: boolean = false

    let isPopupVisible: boolean = false
    // let selectedSession: Session | undefined

    function showPopup(session: Session) {
        selectedSession.set(session)
        isPopupVisible = true
    }
</script>

{#if isPopupVisible}
    <SessionPopup isMyOwn={isMySessions} onExit={() => (isPopupVisible = false)} />
{/if}

<table>
    <thead>
        <tr>
            <th />
            <th>NFT Contract</th>
            <th>Token ID</th>
            <th>End Time</th>
            {#if isMySessions}
                <th>Status</th>
            {/if}
            <th>Participants</th>
            <th>Total Stake</th>
        </tr>
    </thead>

    <tbody>
        {#each sessions as session, index}
            <tr>
                <td>{index + 1}</td>
                <td>{session.contract}</td>
                <td>{shortenId(session.tokenid)}</td>
                <td>{session.end.toLocaleString()}</td>
                {#if isMySessions}
                    <td>{session.status}</td>
                {/if}
                <td>{session.participants}</td>
                <td>{ethers.utils.formatEther(session.totalStake)}</td>
                <td
                    ><button on:click={() => showPopup(session)}>{isMySessions ? "Next Steps" : "Price Now!"}</button
                    ></td
                >
            </tr>
        {/each}
    </tbody>
</table>

<style lang="scss">
    table {
        background: #fcfbfb;
        border: 1px solid #000000;
        box-sizing: border-box;
        border-radius: 5px;
        padding: 8px 64px;
    }

    th {
        text-decoration: underline;
    }

    th {
        padding: 0 8px;
    }

    td {
        text-align: center;
        padding: 4px 16px;

        font-size: 14px;
    }

    button {
        cursor: pointer;
        color: white;
        background: #1a54ff;
        border: none;
        border-radius: 5px;
        padding: 4px 12px;
    }
</style>
