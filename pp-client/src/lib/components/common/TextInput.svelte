<script lang="ts">
    export let value: string
    export let placeholder: string
</script>

<input {placeholder} bind:value />

<style lang="scss">
    input {
        height: 31px;
        width: 200px;
        border: 1px solid #000000;
        box-sizing: border-box;
        border-radius: 5px;

        padding: 2px 8px 0 8px;
    }
</style>
