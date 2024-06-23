interface IUser {
    id: string | null;
    name: string | null;
    permissions: string[];
    roles: string[];
}

type UserFormType = "login" | "register" | "forgot";