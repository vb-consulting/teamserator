import { writable } from "svelte/store";

const user = writable<IUser>((window as any)["user"] || { id: null, name: null, permissions: [], roles: [] });
delete (window as any)["user"];
document.head.querySelector("script:not([defer]):not([src])")?.remove();

export default user;