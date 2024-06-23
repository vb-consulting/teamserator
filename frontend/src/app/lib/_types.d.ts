type PromiseString = (() => Promise<string>) | undefined;
type UseCallbackType =
    | ((node: HTMLElement) => { destroy?: () => void; update?: () => void } | void)
    | undefined;
type IModalButton = IButton;
type ThemesType = "light" | "dark";
type ColorThemeType =
    | "primary"
    | "secondary"
    | "success"
    | "danger"
    | "warning"
    | "info"
    | "light"
    | "dark"
    | "none";

type SearchFuncType<T> = ((request: {search: string; skip: number; take: number;}) => Promise<{ count: number; page: T[] }>);

interface IButton {
    /**
     * Button text
     *
     * @default undefined
     */
    text: string;
    /**
     * Button click handler
     *
     * @default undefined
     */
    click: () => void;
    /**
     * Extra classes. If not defined, default class is btn-primary
     *
     * @default undefined
     */
    classes?: string;
}

interface IShowable {
    show: () => void;
    hide: () => void;
}

interface IValueName {
    value: any;
    name: string;
}

interface IMultiSelectChangeEvent {
    /**
     * Selected keys
     */
    keys: string[];
    /**
     * Selected items
     */
    values: TItem[];
}

interface IMultiselect<TItem> {
    getSelectedItems: () => TItem[];
    getSelectedKeys: () => string[];
    toggleItem: (item: TItem) => boolean;
    containsKey: (key: string) => boolean;
}

interface IMultiSelectChangeEvent {
    /**
     * Selected keys
     */
    keys: string[];
    /**
     * Selected items
     */
    values: TItem[];
}
