import { defineConfig } from 'vite';
import postcssUrlRewrite from 'postcss-urlrewrite';

let env = {};
const viteEnvPath = process.env.OPENCMS_VITEENV ? process.env.OPENCMS_VITEENV : './npm_scripts/vite.env.js';
try {
    env = require(viteEnvPath);
} catch (e) {
    env = {};
}

const log = {
    info: (msg) => {
        const time = (new Date()).toTimeString().slice(0, 8);
        console.log(`\x1b[30m${time} \x1b[1m\x1b[36m[opencms-vite]\x1b[m ${msg}\x1b[0m`);
    },
    error: (msg) => {
        const time = (new Date()).toTimeString().slice(0, 8);
        console.error(`\x1b[30m${time} \x1b[41;37m[opencms-vite]\x1b[0m\x1b[31m\x1b[1m ${msg}\x1b[0m`);
    }
};

function exitProcess() {
    log.info(`You can set variables either in your environment,`);
    log.info(`or in the \x1b[36m${viteEnvPath}\x1b[0m file in the project.\n`);
    process.exit(1);
}

function getEnvValue(name, optional) {
    optional = false || optional;
    if (env && env[name]) {
        return env[name];
    }
    if (process.env[name]) {
        return process.env[name];
    }
    if (! optional) {
        log.error(`Error: The variable \x1b[1m\x1b[36m${name}\x1b[31m is not set!`);
        exitProcess();
    }
    return null;
}

const openCmsServer = getEnvValue('OPENCMS_SERVER');
const workspacePath =  getEnvValue('OPENCMS_WORKSPACE');
const viteCssPath = getEnvValue('OPENCMS_VITE_CSS', true);
const viteMercurySrc = getEnvValue('OPENCMS_MERCURY_SRC', true);
const viteMercuryTgt = getEnvValue('OPENCMS_MERCURY_TGT', true);
const viteMercuryJs = getEnvValue('OPENCMS_MERCURY_JS', true);
const vitePrefixes = getEnvValue('OPENCMS_VITE_PREFIX', true) || ['/scss/'];
const repositories = getEnvValue('OPENCMS_REPOSITORIES', true) || ['mercury-template'];
const viteMercuryJsDir = viteMercuryJs ? viteMercuryJs.substring(0, viteMercuryJs.lastIndexOf('/')) : null;

if (!viteCssPath && !viteMercurySrc && !viteMercuryJs){
    log.error(`Error: You must set at least one of the following variables:`);
    log.error(`➜ \x1b[1m\x1b[36mOPENCMS_VITE_CSS\x1b[31m`);
    log.error(`➜ \x1b[1m\x1b[36mOPENCMS_MERCURY_SRC\x1b[31m`);
    log.error(`➜ \x1b[1m\x1b[36mOPENCMS_MERCURY_JS\x1b[31m`);
    exitProcess();
}

const startupMessage = {
    name: 'opencms-vite-startup',
    config(config) {
                            log.info(`OpenCms Server   ➜ \x1b[1m\x1b[33m${openCmsServer}`);
                            log.info(`User Workspace   ➜ \x1b[1m\x1b[33m${workspacePath}`);
                            log.info(`Repositories     ➜ \x1b[32m${repositories.join(', ')}`);
        if (viteEnvPath)    log.info(`Vite env file    ➜ \x1b[32m${viteEnvPath}`);
        if (viteMercuryTgt) log.info(`Mercury targert  ➜ \x1b[32m${viteMercuryTgt}`);
        if (viteCssPath)    log.info(`Custom CSS       ➜ \x1b[35m${viteCssPath}`);
        if (viteMercurySrc) log.info(`Mercury SCSS     ➜ \x1b[35m${viteMercurySrc}`);
        if (viteMercuryJs)  log.info(`Mercury JS       ➜ \x1b[35m${viteMercuryJs}`);
    }
};

export default defineConfig({
    root: './template-src',
    plugins: [
        startupMessage
    ],
    resolve: {
        alias: repositories.map(repo => ({
            find: new RegExp(`^${repo}/`),
            replacement: `${workspacePath}/${repo}/`
        }))
    },
    css: {
        devSourcemap: true,
        preprocessorOptions: {
            scss: {
                includePaths: repositories.map(repo => `${workspacePath}/${repo}`)
            }
        },
        postcss: {
            plugins: [
                postcssUrlRewrite({
                    rules: [{ from: '../fonts/', to: '/system/modules/alkacon.mercury.theme/fonts/' }]
                })
            ]
        }
    },
    server: {
        port: 8099,
        proxy: {
            '^/': {
                target: openCmsServer,
                changeOrigin: true,
                bypass: (req) => {
                    // These resources will be served from Vite
                    if (
                        vitePrefixes.some(prefix => req.url.startsWith(prefix)) ||
                        (viteMercuryJsDir && req.url.startsWith(viteMercuryJsDir)) ||
                        req.url.includes('/@fs') ||
                        req.url.includes('/@vite')
                    ) {
                        // Everything else is served through the proxy
                        return req.url;
                    }
                },
                configure: (proxy, options) => {
                    // Set "Vite" headers for the request to OpenCms
                    proxy.on('proxyReq', (proxyReq, req, res, options) => {
                        if (viteCssPath) {
                            proxyReq.setHeader('Vite-css-path', viteCssPath);
                        }
                        if (viteMercurySrc) {
                            proxyReq.setHeader('Vite-mercury-src', viteMercurySrc);
                        }
                        if (viteMercuryTgt) {
                            proxyReq.setHeader('Vite-mercury-tgt', viteMercuryTgt);
                        }
                        if (viteMercuryJs) {
                            proxyReq.setHeader('Vite-mercury-js', viteMercuryJs);
                        }
                    });
                },
            }
        }
    }
})
