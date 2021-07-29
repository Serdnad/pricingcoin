<script lang="ts">
    export let text: string
</script>

<button on:click>{text}</button>

<style lang="scss">
    button {
        cursor: pointer;

        height: 31px;
        color: white;
        background: #1a54ff;
        border: none;
        border-radius: 5px;
        box-sizing: border-box;

        padding: 8px 12px 4px 12px;
        margin-left: 70px;
        margin-top: 10px;
    }
</style>
