export async function bash(strings, values) {
    const cmd = typeof strings === "string" ? strings : strings
        .flatMap((str, i) => str + `${values[i] ?? ""}`)
        .join("");

    return Utils.execAsync(["bash", "-c", cmd]).catch(err => {
        console.error(cmd, err);
        return "";
    });
}

/**
 * @returns execAsync(cmd)
 */
export async function sh(cmd) {
    return Utils.execAsync(cmd).catch(err => {
        console.error(typeof cmd === "string" ? cmd : cmd.join(" "), err);
        return "";
    });
}
/**
 * @returns [start...length]
 */
export function range(length, start) {
    return Array.from({ length }, (_, i) => i + start);
}

/**
 * promisified timeout
 */
export function wait(ms, callback) {
    return new Promise(resolve => Utils.timeout(ms, () => {
        resolve(callback());
    }));
}

/**
 * @returns true if all of the `bins` are found
 */
export function dependencies(...bins) {
    const missing = bins.filter(bin => {
        return !Utils.exec(`which ${bin}`);
    });

    if (missing.length > 0)
        console.warn("missing dependencies:", missing.join(", "));

    return missing.length === 0;
}

/**
 * run app detached
 */
export function launchApp(app) {
    const exe = app.executable
        .split(/\s+/)
        .filter(str => !str.startsWith("%") && !str.startsWith("@"))
        .join(" ");

    bash(`${exe} &`);
    app.frequency += 1;
}

