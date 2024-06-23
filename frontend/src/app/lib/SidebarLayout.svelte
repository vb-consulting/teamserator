<script lang="ts">
    import Icon from "$lib/Icon.svelte";

    type T = $$Generic;

    interface $$Slots {
        default: { panel: T };
        header: { panel: T };
    }

    export let expanded = true;
    export let panels: {name: T, icon: BootstrapIconsType}[];
    export let labels: Record<any, string> = {};
    export let panel: T = panels[0].name;
    export let width: string = "auto";
    export let widthCollapseTreshold = 150;

    export { classes as class };
    export { styles as style };

    let classes: string = "";
    let styles: string = "height: 100vh;";

    let currentWidth = width;
    let collapseTreshold = true;
    let moving = false;
    let lastWidth = currentWidth;

    function resizable(node: Element) {
        let x: number | undefined;
        let w: number;
        
        function onMouseDown(e: MouseEvent | Event) {
            x = (e as MouseEvent).clientX;
            w = node.parentElement?.getBoundingClientRect().width as number;
            node.ownerDocument.addEventListener("mousemove", onMouseMove);
            node.ownerDocument.addEventListener("mouseup", onMouseUp);
            if (!expanded) {
                expanded = true;
                currentWidth = `${collapseTreshold}px`;
                collapseTreshold = false;
            } else {
                collapseTreshold = true;
            }
            moving = true;
        }

        function onMouseMove(e: MouseEvent) {
            if (x !== undefined) {
                let newWidth = w + e.clientX - x + e.movementX;
                if (newWidth <= widthCollapseTreshold && collapseTreshold) {
                    expanded = false;
                    x = undefined;
                    collapseTreshold = false;
                    currentWidth = "min-content";
                } else {
                    if (newWidth < widthCollapseTreshold) {
                        currentWidth = `${widthCollapseTreshold}px`;
                    } else {
                        currentWidth = `${newWidth}px`;
                    }
                    lastWidth = currentWidth;
                }
            }
        }

        function onMouseUp() {
            x = undefined;
            node.ownerDocument.removeEventListener('mousemove', onMouseMove);
            node.ownerDocument.removeEventListener('mouseup', onMouseUp);
            moving = false;
        }

        node.addEventListener('mousedown', onMouseDown);

        return {
            destroy() {
                node.removeEventListener('mousedown', onMouseDown);
                node.ownerDocument.removeEventListener('mousemove', onMouseMove);
                node.ownerDocument.removeEventListener('mouseup', onMouseUp);
            }
        }
    }

    function togglePanel(name: T) {
        if (panel === name) {
            expanded = !expanded;
        } else {
            panel = name;
            expanded = true;
        }

        if (expanded) {
            currentWidth = lastWidth;
        } else {
            lastWidth = currentWidth;
            currentWidth = "min-content";
        }
    }

    function doubleClick() {
        if (expanded) {
            expanded = false;
            lastWidth = currentWidth;
            currentWidth = "min-content";
        }
    }
</script>

<div class="toolbar {classes || ''}" class:toolbar-header={$$slots.header} style="{expanded ? `width: ${currentWidth};` : "width: min-content;"}{styles || ''}">
    {#if $$slots.header}
        <div class="toolbar-header-content border-bottom p-2">
            <slot name="header" {panel} />
        </div>
    {/if}
    <div class="toolbar-tabs" class:collapsed={!expanded}>
        {#each panels as {name, icon}}
            <button class="btn btn-lg" class:selected={panel==name && expanded} on:click={() => togglePanel(name)}>
                <Icon type={icon} />
                {#if labels[name]}
                    <span class="tab-label">{labels[name]}</span>
                {/if}
            </button>
        {/each}
        <button class="btn btn-lg mt-auto" on:click={() => expanded = !expanded}><Icon type="{expanded ? "chevron-bar-left" : "chevron-bar-right"}" /></button>
    </div>
    <div class="toolbar-content shadow-lg" class:d-none={!expanded}>
        <slot {panel} />
    </div>
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div class="toolbar-divider border-end" class:moving use:resizable on:dblclick={doubleClick}></div>
</div>

<style lang="scss">
    .toolbar-header {
        grid-template-rows: minmax(max-content, 4.2rem) auto;
        grid-template-areas: 
            "header header divider"
            "tabs content divider" !important;
    }
    .toolbar {
        background-color: var(--bs-secondary-bg);
        display: grid;
        grid-template-columns: min-content auto min-content;
        grid-template-areas: "tabs content divider";
        user-select: none;
        overflow-y: auto;
        
        .toolbar-header-content {
            grid-area: header;
        }

        .toolbar-tabs.collapsed {
            margin-right: -6px;
        }
        .toolbar-tabs {
            grid-area: tabs;
            width: max-content;
            display: flex;
            flex-direction: column;
            background-color: var(--bs-tertiary-bg);
            & > * {
                background-color: var(--bs-tertiary-bg);
                border-radius: 0;
                color: var(--bs-body-color);
                border: 0;
                background-image: none;
                box-shadow: none;
                opacity: 0.5;
            }
            & > .selected {
                background-color: var(--bs-secondary-bg);
                opacity: 1;
                border-left: 4px solid var(--bs-primary);
            }
            & > *:hover {
                opacity: 1;
            }
        }

        .toolbar-content {
            grid-area: content;
            margin-right: -6px;
            overflow-x: hidden;
        }
        .toolbar-content.d-none {
            margin-right: initial;
        }

        .toolbar-divider {
            grid-area: divider;
            width: 6px;
            z-index: 1;
        }
        .toolbar-divider:hover, .toolbar-divider.moving {
            animation: animateDivider 4s 1;
            cursor: e-resize;
        }
    }

    @keyframes animateDivider
    {
        0%      {background-color: initial;}
        25%     {background-color: var(--bs-primary-border-subtle);}
        75%     {background-color: var(--bs-primary-border-subtle);}
        100%    {background-color: initial;}
    }

    :global(.toolbar .toolbar-content > *) {
        padding: 0.5rem 0.5rem 0.5rem 1rem;
        & > div {
            margin-bottom: 0.5rem;
        }
    }
    :global(.tab-label) {
        background-color: var(--bs-primary);
        border-radius: 20px;
        font-size: 9px;
        height: 14px;
        line-height: 14px;
        min-width: 8px;
        padding: 0 2px;
        position: relative;
        right: 16px;
        text-align: center;
        left: 8px;
        display: block;
        margin-top: -15px;
        color: var(--bs-white);
    }
</style>