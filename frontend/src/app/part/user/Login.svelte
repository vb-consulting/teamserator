
<script lang="ts">
    import Icon from "$lib/Icon.svelte";
    import { onMount } from "svelte";
    export let working = false;
    export let formType: UserFormType;

    let email = "";
    let pass = "";

    let alert = false;

    onMount(() => {
        setTimeout(() => {
            document.getElementById("login-email")?.focus();
        }, 1000);
    });
</script>

<label class="h5" for="login-email">Please login to the Teamserator</label>
<div class="form-group">
    <label for="login-email">Enter email</label>
    <input type="email" 
        id="login-email"
        autocomplete="off"
        autocorrect="off"
        spellcheck="false"
        class="form-control"
        bind:value={email}
        on:keydown={() => alert = false}>
    <label for="login-password">Enter password</label>
    <input type="password"
        id="login-password"
        autocomplete="off"
        autocorrect="off"
        spellcheck="false" 
        class="form-control" 
        bind:value={pass}
        on:keydown={() => alert = false}>
</div>
<button class="btn btn-sm btn-outline-primary text-uppercase" class:disabled={working}>
    <Icon type="person-check" class="me-2"></Icon>
    Login
</button>
{#if alert}
    <div class="alert alert-danger alert-dismissible" role="alert">
        The user name or password was incorrect.
        <button type="button" class="btn-close" on:click={() => alert = false}></button>
    </div>
{/if}
<hr class="w-75" />
<div class="form-group d-flex flex-row gap-3">
    <a class="btn btn-sm btn-outline-primary text-uppercase" class:disabled={working} href="/signin-google">
        <Icon type="google" class="me-2"></Icon>
        Continue with Google
    </a>
    <a class="btn btn-sm btn-outline-primary text-uppercase" class:disabled={working} href="/signin-github">
        <Icon type="github" class="me-2"></Icon>
        Continue with Github
    </a>
</div>
<hr class="w-75" />
<button class="btn btn-sm btn-link" on:click={()=> { formType = "forgot" }}>Forgot password?</button>
<button class="btn btn-sm btn-link" on:click={()=> { formType = "register" }}>New User?</button>

<style lang="scss">
</style>
