<script lang="ts">
    import Erc721Contract from "$lib/contract/erc721_contract"

    import PpContract from "$lib/contract/pp_contract"
    import { selectedSession } from "$lib/stores/session"
    import { BigNumber, ethers } from "ethers"
    import { onMount } from "svelte"
    import Button from "./common/Button.svelte"
    import TextInput from "./common/TextInput.svelte"

    // Note: this might be better as a dispatch
    export let onExit: () => {}
    export let isMyOwn: boolean = false

    let isActive: boolean

    // Input fields for active session
    let appraisalPrice
    let stakeAmount

    // Data labels
    let stake = BigNumber.from(0)
    let appraisal = BigNumber.from(0)
    let participants = BigNumber.from(0)
    let sessionStake = BigNumber.from(0)
    let finalAppraisal = BigNumber.from(0)

    // NFT metadata
    let nftName = ""
    let nftDescription = ""
    let nftImage = ""

    onMount(async () => {
        isActive = $selectedSession.isActive()

        stake = await PpContract.getStake($selectedSession.contract, $selectedSession.tokenid)
        participants = $selectedSession.participants
        appraisal = participants
        sessionStake = await PpContract.getTotalSessionStake($selectedSession.contract, $selectedSession.tokenid)
        finalAppraisal = await PpContract.getFinalAppraisal($selectedSession.contract, $selectedSession.tokenid)

        // Get NFT metadata
        let { name, description, image } = await Erc721Contract.getInfo(
            $selectedSession.contract,
            $selectedSession.tokenid
        )

        nftName = name
        nftDescription = description
        nftImage = image

        console.log(name)
        console.log(description)
        console.log(image)
    })

    async function setVote() {
        PpContract.setVote(
            ethers.utils.parseEther(appraisalPrice),
            ethers.utils.parseEther(stakeAmount),
            $selectedSession.contract,
            $selectedSession.tokenid
        )
    }
</script>

<div class="shadow">
    <div class="container">
        <div class="exit-button" on:click={onExit}>X</div>

        {#if isActive || isMyOwn}
            <div class="top-left-panel">
                {#if !isMyOwn}
                    <p>Session Stake: {ethers.utils.formatEther(sessionStake)}</p>
                {/if}
                <p>Participants: {participants}</p>
                {#if isMyOwn}
                    <p>Stake: {ethers.utils.formatEther(stake)}</p>
                    <p>Appraisal: {ethers.utils.formatEther(appraisal)}</p>
                    <p>Session Stake: {ethers.utils.formatEther(sessionStake)}</p>
                    <p>Final Appraisal: {ethers.utils.formatEther(finalAppraisal)}</p>
                {/if}
            </div>
        {/if}

        <div class="nft">
            <img src={nftImage} />
            <div>
                <h4>{nftName}</h4>
                <p>{nftDescription}</p>
            </div>
        </div>

        <div class="footer">
            {#if isMyOwn}
                <p>Status: CalcBase</p>
                <div class="row">
                    <!-- TODO (Alan): Make these do something, I'd think -->
                    <button on:click={() => PpContract.weightVote($selectedSession.contract, $selectedSession.tokenid)}>
                        Weight
                    </button>
                    <button
                        on:click={() =>
                            PpContract.setFinalAppraisal($selectedSession.contract, $selectedSession.tokenid)}
                    >
                        SetFinal
                    </button>
                    <button
                        on:click={() => PpContract.calculateBase($selectedSession.contract, $selectedSession.tokenid)}
                    >
                        CalcBase
                    </button>
                    <button on:click={() => PpContract.issueCoins($selectedSession.contract, $selectedSession.tokenid)}>
                        IssueCoin
                    </button>
                    <button
                        on:click={() => PpContract.harvestLoss($selectedSession.contract, $selectedSession.tokenid)}
                    >
                        Harvest
                    </button>
                </div>
            {:else if isActive}
                <div class="row">
                    <TextInput placeholder="Appraisal Price (ETH)" bind:value={appraisalPrice} />
                    &nbsp;&nbsp; <!-- little hacky but it works -->
                    <TextInput placeholder="Stake Amount (ETH)" bind:value={stakeAmount} />
                    <Button text="Submit" on:click={setVote} />
                </div>
            {:else}
                <div class="row">
                    <p>Final Appraisal: {ethers.utils.formatEther(finalAppraisal)}</p>
                    <!-- <p>$PP Issued: #</p> -->
                    <!-- <p>Profits Distributed: #</p> -->
                    <p>Total Votes: {$selectedSession.participants}</p>
                </div>
            {/if}
        </div>
    </div>
</div>

<style lang="scss">
    .shadow {
        position: absolute;
        top: 0;
        left: 0;
        height: 100vh;
        width: 100vw;
        background: #000000cc;
        z-index: 100;
    }

    .container {
        margin: 80px auto;
        position: relative;

        width: 60%;
        height: 60%;
        background: white;
        border-radius: 5px;
        box-shadow: 0 0 6px 3px #00000088;
    }

    .exit-button {
        cursor: pointer;

        position: absolute;
        top: 16px;
        right: 16px;

        font-size: 24px;
        border: 1px solid black;
        padding: 8px 8px 0 8px;
    }

    .top-left-panel {
        position: absolute;
        top: 16px;
        left: 16px;
        width: 160px;

        background: #1a54ff;
        border-radius: 5px;
        padding: 0 12px;

        p {
            color: white;
        }
    }

    .nft {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        height: 100%;

        h4,
        p {
            margin: 0;
        }

        div {
            padding: 32px;
        }

        img {
            margin-top: 16px;
            max-width: 50%;
            max-height: 50%;
        }
    }

    .footer {
        position: absolute;
        bottom: 20px;
        width: 100%;

        justify-content: center;

        .row {
            display: flex;
            justify-content: center;
        }

        button {
            cursor: pointer;

            color: white;
            background: #1a54ff;
            border-radius: 5px;
            border: none;

            padding: 6px 12px 4px 12px;
            margin: 0 10px;
            margin-top: 16px;
        }

        p {
            text-align: center;
            margin: 0 12px;
        }
    }
</style>
