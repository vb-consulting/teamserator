<script lang="ts">
    import Icon from "$lib/Icon.svelte";
    import Theme from "$lib/Theme.svelte";
    import Login from "$part/user/Login.svelte";
    import Register from "$part/user/Register.svelte";
    import Forgot from "$part/user/Forgot.svelte";
    import { slide } from "svelte/transition";
    
    let formType: UserFormType = "login";
    let working = false;
</script>

<div class="user">

    <h1>The Teamserator</h1>
    <h5 class="text-muted">Full Of Agile</h5>

    <div class="form-group d-flex flex-column align-items-center">
        <div class="label">Select Visual Theme</div>
        <Theme />
    </div>
    <hr class="w-75" />

    {#if formType == "login"}
        <div in:slide out:slide class="user-form">
            <Login bind:formType bind:working />
        </div>
    {:else if formType == "register"}
        <div in:slide out:slide class="user-form">
            <Register bind:formType bind:working />
        </div>
    {:else if formType == "forgot"}
        <div in:slide out:slide class="user-form">
            <Forgot bind:formType bind:working />
        </div>
    {/if}

    <hr class="w-100" />
    <div class="text-muted small d-flex flex-column align-items-center">
        <div>
            Copyright (C) VB-Consulting {new Date().getFullYear()}
        </div>
        <a href="/privacy" style="margin-top: -.25rem;">
            Privacy Policy
        </a>
        <a href="/privacy" style="margin-top: .25rem;" title="Source">
            <Icon type="github" class=""></Icon>
        </a>
    </div>
</div>

<style lang="scss">
    .user, .user-form {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
    }
    .user {
        width: 350px;
        padding-top: 1rem;
        padding-bottom: 1rem;
        margin-left: auto;
        margin-right: auto;
    }
</style>
