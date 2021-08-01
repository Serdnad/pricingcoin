<script lang="ts">
    import Button from "../common/Button.svelte"

    import TextInput from "../common/TextInput.svelte"

    export let label: string
    export let onSubmit: (address: string, tokenId: string) => void

    let address: string
    let tokenId: string

    async function submit() {
        onSubmit(address, tokenId)
    }
</script>

<div>
    <p>{label}</p>
    <div>
        <TextInput placeholder="NFT contract address" bind:value={address} />
        <br />
        <TextInput placeholder="NFT token ID" bind:value={tokenId} />
        <br />

        <Button text={"Submit"} on:click={submit} />
    </div>
</div>

<style lang="scss">
    p {
        margin: 0;
        margin-bottom: 8px;
        text-align: center;
    }
</style>
