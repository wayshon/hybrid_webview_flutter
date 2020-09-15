// js 被调用
class __Bridge {
    /**
     * 拼接 UA
     * @param {string} prifix 
     * @param {(s:string) => void} callback 
     */
    static getUserAgent(prifix, callback) {
        callback(`${prifix}_${window.navigator.userAgent}`);
    }
}

// js 调用 flutter
class Bridge {
    static share(value) {
        return new Promise((resolve, reject)  => {
            try {
                __jsCallFlutter('share', [value], result => resolve(result));
            } catch (e) {
                reject(e);
            }
        });
    }
    static exchangeHeight(height) {
        return new Promise((resolve, reject)  => {
            try {
                __jsCallFlutter('exchangeHeight', [height], result => resolve(result));
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
    }
    throw new TypeError('param only supply null,undefined,number,boolean,string,array/object');
}

function __flutterCallJs(action, params, callback) {
    const cb = (params) => {
        validateParam(params);
        callback(params);
    }
    if (Bridge[action]) {
        Bridge[action](params, cb);
    }
}

function __jsCallFlutter(action, params, cb) {
    validateParam(params);
    __OCObj.jsCallFlutter(action, params, function (...params) {
        cb(params);
    });
}
