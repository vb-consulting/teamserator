<script lang="ts">
    import SidebarLayout from "$lib/SidebarLayout.svelte";
    import UserModal from "$part/user/Modal.svelte";
    document.title = "Index";
</script>

<main class="sidebar-main">
    <SidebarLayout 
        expanded={false} 
        width="375px" 
        let:panel
        panels={[
            {name: "user", icon: "person"},
            {name: "app", icon: "gear"},
        ]}
    >
    <div class:d-none={panel!=="user"}>
        user
    </div>
    <div class:d-none={panel!=="app"}>
        app
    </div>
    </SidebarLayout>

    <div class="p-3">
        <p>Index</p>

        <UserModal />
    </div>
    
</main>

<style lang="scss">
</style>