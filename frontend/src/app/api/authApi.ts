import { baseUrl } from "$api/_url";

/**
* function auth.login_with_password(
*     _email text,
*     _password text
* )
* returns table(
*     status integer,
*     name_identifier text,
*     name text
* )
* 
* @remarks
* comment on function auth.login_with_password is 'HTTP POST /auth/login
* anonymous';
* 
* @see FUNCTION auth.login_with_password
*/
export async function authLoginWithPassword(
    request: IAuthLoginWithPasswordRequest,
    parseUrl: (url: string) => string = url=>url,
    parseRequest: (request: RequestInit) => RequestInit = request=>request
) : Promise<{status: number, response: IAuthLoginWithPasswordResponse[] | string}> {
    const response = await fetch(parseUrl(baseUrl + "/auth/login"), parseRequest({
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(request)
    }));
    return {
        status: response.status,
        response: response.status == 200 ? await response.json() as IAuthLoginWithPasswordResponse[] : await response.text()
    };
}

/**
* function auth.register_with_password(
*     _email text,
*     _password text,
*     _repeat text
* )
* returns json
* 
* @remarks
* comment on function auth.register_with_password is 'HTTP POST /auth/register
* anonymous';
* 
* @see FUNCTION auth.register_with_password
*/
export async function authRegisterWithPassword(
    request: IAuthRegisterWithPasswordRequest,
    parseUrl: (url: string) => string = url=>url,
    parseRequest: (request: RequestInit) => RequestInit = request=>request
) : Promise<{status: number, response: string}> {
    const response = await fetch(parseUrl(baseUrl + "/auth/register"), parseRequest({
        method: "POST",
        body: JSON.stringify(request)
    }));
    return {
        status: response.status,
        response: await response.text()
    };
}
