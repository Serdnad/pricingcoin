<script>
    import NavBar from "$lib/components/common/NavBar.svelte"
</script>

<NavBar />

<div class="page">
    <h1>Claim Pool</h1>
    <div class="container">
        <!-- TODO (Alan): Substitute placeholders -->
        <!-- TODO: Include images -->
        <p>Pool Size: 100.3 ETH</p>
        <p>Active: No</p>
        <p>Time Left: 13 days</p>
        <p>Coin Balance: 10k $PP</p>
        <p>Claim Size: 0.02 ETH</p>

        <div class="button-container">
            <button>Claim</button>
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
