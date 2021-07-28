<script lang="ts">
    import PpContract from "$lib/contract/pp_contract";

    function connect() {
        PpContract.connect()
    }
</script>

<nav>
    <div>
        <div on:click={() => (location.href = "/")}>
            <img src="pplogo.png" />
        </div>
        <a href="/sessions">Home</a>
        <a href="/my_sessions">My Sessions</a>
        <a href="/claim_pool">Claim Pool</a>
    </div>

    <button on:click={connect}>Connect</button>
</nav>

<style lang="scss">
    nav {
        display: flex;
        justify-content: space-between;
    }

    div {
        display: flex;

        img {
            cursor: pointer;
            height: 56px;
        }

        a {
            color: black;
            font-size: 20px;
            margin: 8px 12px 16px 12px;
            text-decoration: none;
        }
    }

    button {
        cursor: pointer;

        height: fit-content;
        background: #1a54ff;
        border: none;
        border-radius: 5px;
        padding: 8px 12px;
        margin: 8px 12px;

        color: #ffffff;
        font-family: Roboto;
        font-style: normal;
        font-weight: bold;
        font-size: 20px;
        font-weight: 500;
        line-height: 27px;
        display: flex;
        align-items: center;
        text-align: center;
    }
</style>
