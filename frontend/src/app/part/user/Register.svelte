
<script lang="ts">
    import Icon from "$lib/Icon.svelte";
    import { onMount } from "svelte";
    export let working = false;
    export let formType: UserFormType;

    let alert = false;
    let email = "";
    let pass = "";
    let repeat = "";

    onMount(() => {
        setTimeout(() => {
            document.getElementById("register-email")?.focus();
        }, 1000);
    });
</script>

<label class="h5" for="register-email">Create New Teamserator Account</label>
<div class="form-group">
    <label for="register-email">Enter email</label>
    <input type="email" 
        id="register-email"
        autocomplete="off"
        autocorrect="off"
        spellcheck="false"
        class="form-control"
        bind:value={email}
        on:keydown={() => alert = false}>
    <label for="register-password">Enter password</label>
    <input type="password"
        id="register-password"
        autocomplete="off"
        autocorrect="off"
        spellcheck="false" 
        class="form-control" 
        bind:value={pass}
        on:keydown={() => alert = false}>
    <label for="register-repeat">Repeat password</label>
    <input type="repeat"
        id="register-repeat"
        autocomplete="off"
        autocorrect="off"
        spellcheck="false" 
        class="form-control" 
        bind:value={repeat}
        on:keydown={() => alert = false}>
</div>
<button class="btn btn-sm btn-outline-primary text-uppercase" class:disabled={working}>
    <Icon type="person-check" class="me-2"></Icon>
    Register
</button>
{#if alert}
    <div class="alert alert-danger alert-dismissible" role="alert">
        The user name or password was incorrect.
        <button type="button" class="btn-close" on:click={() => alert = false}></button>
    </div>
{/if}
<hr class="w-75" />
<div class="form-group d-flex flex-row gap-3">
    <a class="btn btn-sm btn-outline-primary text-uppercase" class:disabled={working} href="/signin-google?register">
        <Icon type="google" class="me-2"></Icon>
        Register with Google
    </a>
    <a class="btn btn-sm btn-outline-primary text-uppercase" class:disabled={working} href="/signin-github?register">
        <Icon type="github" class="me-2"></Icon>
        Register with Github
    </a>
</div>
<hr class="w-75" />
<button class="btn btn-sm btn-link" on:click={()=> { formType = "login" }}>Already Registered?</button>

<style lang="scss">
</style>
