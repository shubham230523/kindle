"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const app_js_1 = require("./app.js");
const env_js_1 = require("./config/env.js");
const start = async () => {
    const app = await (0, app_js_1.buildApp)();
    try {
        await app.listen({ port: env_js_1.env.PORT, host: env_js_1.env.HOST });
        app.log.info(`Kindle Backend listening at http://${env_js_1.env.HOST}:${env_js_1.env.PORT}`);
    }
    catch (err) {
        app.log.error(err);
        process.exit(1);
    }
};
start();
