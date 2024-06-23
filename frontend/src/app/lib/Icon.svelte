<script lang="ts">
    /**
     * HTML element name that contains an icon class in lowercase.
     * @default "i"
     */
    export let element: keyof HTMLElementTagNameMap = "i";
    /**
     * Bootstrap icon name.
     * @default none
     */
    export let type: BootstrapIconsType;
    
    $: {
        let classes = "";
        if (type) {
            classes = classes ? " " : "" + "bi bi-" + type;
        }
        if (classes) {
            $$restProps.class = ($$restProps.class ? $$restProps.class.trim() + " " : "") + classes;
        }
    }
</script>
<svelte:element this={element} {...$$restProps}></svelte:element>
