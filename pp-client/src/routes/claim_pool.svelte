<script lang="ts">
    import NavBar from "$lib/components/common/NavBar.svelte"
    import PpContract from "$lib/contract/pp_contract"
    import { formatEther } from "@ethersproject/units"
    import { BigNumber, ethers } from "ethers"
    import { onMount } from "svelte"

    let poolSize = BigNumber.from(0)
    let active: boolean
    let timeLeft: ethers.BigNumberish
    let coinBalance: string
    let claimSize = BigNumber.from(0)

    onMount(() => {
        // Note: using callbacks instead of await allows all of these fetches to be done concurrently
        PpContract.getLossPoolRemainder().then((num) => (poolSize = num))
        PpContract.balanceOfSelf().then((num) => (coinBalance = num.toString()))
        PpContract.getClaimSize().then((num) => (claimSize = num))
        PpContract.getTimeLeft().then((num) => {
            timeLeft = num
            active = timeLeft.toNumber() == 0
        })
    })

    function claimPool() {
        PpContract.distributeLossPool()
    }
</script>

<NavBar />

<div class="page">
    <h1>Claim Pool</h1>
    <div class="container">
        <p>Pool Size: {ethers.utils.formatEther(poolSize)} ETH</p>
        <p>Active: {active ? "Yes" : "No"}</p>
        <p>Time Left: {timeLeft}s</p>
        <p>Coin Balance: {coinBalance} $PP</p>
        <p>Claim Size: {ethers.utils.formatEther(claimSize)} ETH</p>

        <div class="button-container">
            <button on:click={claimPool}>Claim</button>
        </div>
    </div>
</div>

<style lang="scss">
    .page {
        margin-top: 10vh;
    }

    h1 {
        text-align: center;
        font-weight: 400;
        margin: 8px;
    }

    .container {
        margin: auto;
        padding: 16px;

        border: 3px solid #000000;
        box-sizing: border-box;
        width: fit-content;
        border-radius: 10px;

        p {
            margin: 0;
            font-size: 18px;
        }

        .button-container {
            display: flex;
            justify-content: center;

            button {
                cursor: pointer;
                color: white;
                background: #1a54ff;
                border: none;
                border-radius: 5px;
                box-sizing: border-box;

                margin-top: 16px;
                padding: 10px 24px 6px 24px;
                font-size: 20px;
                font-weight: 600;
            }
        }
    }
</style>
