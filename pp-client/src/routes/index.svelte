<script lang="ts">
    function launchApp() {
        location.href = "/sessions"
    }

    function openWhitePaper() {
        // TODO (Alan): Replace link
        open("https://www.google.com", "blank")
    }

    function openGithub() {
        // TODO (Alan): Replace link
        open("https://www.github.com", "blank")
    }

    function openTwitter() {
        open("https://twitter.com/PricingProtocol", "blank")
    }

    function openDiscord() {
        open("http://discord.gg/WZUv4y5rPd", "blank")
    }
</script>

<div class="container">
    <img src="pplogo.png" />

    <h1>Pricing Protocol</h1>

    <h2>A valuation tool for NFTs.</h2>

    <div class="info-row">
        <div>
            <button class="special" on:click={launchApp}>Launch App</button>

            <div class="text-block">
                <p>100.3 ETH</p>
                <p>Earned</p>
            </div>
        </div>

        <div>
            <button on:click={openWhitePaper}>White-paper</button>

            <div class="text-block">
                <p>131</p>
                <p>NFTs Priced</p>
            </div>
        </div>

        <div>
            <button on:click={openGithub}>Github</button>

            <div class="text-block">
                <p>50M PP</p>
                <p>Earned</p>
            </div>
        </div>
    </div>

    <div class="socials">
        <!-- TODO (Alan): The images you had on Figma were fugged,
			but should be able to just replace them in static folder -->
        <img on:click={openTwitter} src="twitter.svg" />
        <img on:click={openDiscord} src="discord.svg" />
    </div>
</div>

<style lang="scss">
    .container {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;

        margin-top: 20vh;
    }

    img {
        width: 120px;
    }

    h1 {
        font-size: 80px;
        font-weight: 400;
        margin: 16px;
        margin-top: 24px;
    }

    h2 {
        font-size: 32px;
        font-weight: 400;
        margin-top: 0;
        margin-bottom: 32px;
    }

    button {
        cursor: pointer;

        width: 180px;
        border-radius: 10px;
        background: white;
        border: 1px solid black;
        padding: 12px 0;
        margin: 0 32px;

        font-size: 24px;
    }

    .info-row {
        display: flex;
        margin-top: 16px;
        margin-bottom: 32px;

        .text-block {
            margin-top: 48px;

            p {
                text-align: center;
                margin: 0 48px;
                font-size: 24px;
            }
        }
    }

    .special {
        color: white;
        background: #1a54ff;
        border: none;
    }

    .socials {
        cursor: pointer;
        position: absolute;
        bottom: 30px;
        right: 50px;

        img {
            width: 50px;
            margin: 0 12px;
        }
    }
</style>
