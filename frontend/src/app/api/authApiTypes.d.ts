interface IAuthLoginWithPasswordRequest {
    email: string | null;
    password: string | null;
}

interface IAuthLoginWithPasswordResponse {
    status: number | null;
    nameIdentifier: string | null;
    name: string | null;
}

interface IAuthRegisterWithPasswordRequest {
    email: string | null;
    password: string | null;
    repeat: string | null;
}

