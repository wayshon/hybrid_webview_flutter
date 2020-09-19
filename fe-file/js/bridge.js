// js 被调用
class __Bridge {
    /**
     * 拼接 UA
     * @param {string} prifix 
     * @param {(s:string) => void} callback 
     */
    static getUserAgent(prifix, callback) {
        callback([`${prifix}_${window.navigator.userAgent}`]);
    }

    static barItemCallback(action, callback) {
        if (__Bridge.barItemCallbackMap[action]) {
            __Bridge.barItemCallbackMap[action]();
            callback([true]);
        } else {
            callback([false]);
        }
    }
}

__Bridge.barItemCallbackMap = {};

// js 调用 flutter
class Bridge {
    static share(value) {
        return new Promise((resolve, reject)  => {
            try {
                __jsCallFlutter('share', [value], (error, results) => {
                    if (error) {
                        reject(new Error(error));
                    } else {
                        resolve(results);
                    }
                });
            } catch (e) {
                reject(e);
            }
        });
    }
    static exchangeHeight(height) {
        return new Promise((resolve, reject)  => {
            try {
                __jsCallFlutter('exchangeHeight', [height], (error, results) => {
                    if (error) {
                        reject(new Error(error));
                    } else {
                        resolve(results[0]);
                    }
                });
            } catch (e) {
                reject(e);
            }
        });
    }
    static setRightBarItems(configs) {
        __Bridge.barItemCallbackMap = {};
        const params = [];
        for (const { icon, callback } of configs) {
            __Bridge.barItemCallbackMap[`${icon}`] = callback;
            params.push({ icon });
        }
        return new Promise((resolve, reject)  => {
            try {
                __jsCallFlutter('setRightBarItems', params, (error, results) => {
                    if (error) {
                        reject(new Error(error));
                    } else {
                        resolve();
                    }
                });
            } catch (e) {
                reject(e);
            }
        });
    }
}

function validateParam(param) {
    if (
        param === null ||
        param === undefined ||
        typeof param === 'number' ||
        typeof param === 'boolean' ||
        typeof param === 'string'
    ) {
        return;
    }
    if (Array.isArray(param)) {
        for (const v of param) {
            validateParam(v);
        }
    } else if (Object.prototype.toString.call(param) === '[object Object]') {
        for (const k in param) {
            validateParam(param[k]);
        }
    } else {
        throw new TypeError(`param only supply null,undefined,number,boolean,string,array/object;value is ${param}`);
    }
}

function __flutterCallJs(action, params, callback) {
    console.log(`__flutterCallJs -- ${action} -- ${params.toString()}`);
    const cb = (params) => {
        validateParam(params);
        callback(params);
    }
    if (__Bridge[action]) {
        __Bridge[action](params, cb);
    }
}

function __jsCallFlutter(action, params, cb) {
    validateParam(params);
    __OCObj.jsCallFlutter(action, params, cb);
}
