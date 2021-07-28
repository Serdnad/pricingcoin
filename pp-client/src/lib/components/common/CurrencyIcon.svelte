<script lang="ts">
    export let currency: "eth" | "pp"
</script>

{#if currency == "eth"}
    <!-- TODO: Add ethereum icon to static folder -->
    <img src="pplogo.png" />
{:else}
    <img src="pplogo.png" />
{/if}

<style lang="scss">
    img {
        width: 16px;
    }
</style>
