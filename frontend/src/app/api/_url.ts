export const baseUrl = "";
export const parseQuery = (query: Record<any, any>) => {
    return "?" + Object.keys(query)
        .map(key => {
            const value = query[key] != null ? query[key] : "";
            if (Array.isArray(value)) {
                return value.map(s => s ? `${key}=${encodeURIComponent(s)}` : `${key}=`).join("&");
            }
            return `${key}=${encodeURIComponent(value)}`;
        })
        .join("&");
};
