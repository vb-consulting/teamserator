<script lang="ts">
    import Icon from "$lib/Icon.svelte";
    import { onMount } from "svelte";
    export let working = false;
    export let formType: UserFormType;

    let email = "";
    let alert = false;

    onMount(() => {
        setTimeout(() => {
            document.getElementById("reset-email")?.focus();
        }, 1000);
    });
</script>

<label class="h5" for="reset-email">Reset the Teamserator Password</label>
<div class="form-group">
    <label for="reset-email">Enter email</label>
    <input type="email" 
        id="reset-email"
        autocomplete="off"
        autocorrect="off"
        spellcheck="false"
        class="form-control"
        bind:value={email}
        on:keydown={() => alert = false}>

</div>
<button class="btn btn-sm btn-outline-primary text-uppercase" class:disabled={working}>
    <Icon type="person-check" class="me-2"></Icon>
    Send
</button>
{#if alert}
    <div class="alert alert-danger alert-dismissible" role="alert">
        The user name or password was incorrect.
        <button type="button" class="btn-close" on:click={() => alert = false}></button>
    </div>
{/if}
<hr class="w-75" />
<button class="btn btn-sm btn-link" on:click={()=> { formType = "login" }}>Return To Login</button>

<style lang="scss">
</style>
