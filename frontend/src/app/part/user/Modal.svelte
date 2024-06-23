<script lang="ts">
    import UserForm from "$part/user/Form.svelte";
    import user from "$part/user";
    import Modal from "$lib/Modal.svelte";

    export let autoShow = true;

    let userModal = { open: false };
    if ($user.id == null && autoShow) {
        userModal.open = true;
    }
</script>

<Modal backdrop={false} keyboard={false} centered={false} {...userModal} class="user-modal">
    <UserForm />
</Modal>

<style lang="scss">
    // blur the backdrop when the user modal is open
    :global(.modal.fade.show:has(.user-modal)) {
        backdrop-filter: blur(2px);
    }
</style>
