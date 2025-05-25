import { defineConfig } from 'vite';
import postcssUrlRewrite from 'postcss-urlrewrite';

let env = {};
const viteEnvFile = process.env.OPENCMS_VITEENV ? process.env.OPENCMS_VITEENV : './vite.env.js';
try {
    env = require(viteEnvFile);
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
    log.info(`or in the \x1b[36m${viteEnvFile}\x1b[0m file in the project.\n`);
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

function toArray(val) {
    if (!val) return [];
    return Array.isArray(val) ? val : [val];
}

const openCmsServer = getEnvValue('OPENCMS_SERVER');
const viteSecret = getEnvValue('OPENCMS_VITE_SECRET');
const workspacePath =  getEnvValue('OPENCMS_WORKSPACE', true);
const viteRoot = getEnvValue('OPENCMS_VITE_ROOT', true) || './';
const vitePrefixes = toArray(getEnvValue('OPENCMS_VITE_PREFIX', true));
const repositories = toArray(getEnvValue('OPENCMS_REPOSITORIES', true));
const viteMercuryScss = getEnvValue('OPENCMS_MERCURY_SCSS', true);
const openCmsSite = getEnvValue('OPENCMS_SITE', true);
const viteMercuryJs = getEnvValue('OPENCMS_MERCURY_JS', true);
const viteAdditionalCss = toArray(getEnvValue('OPENCMS_VITE_ADD_CSS', true));
const viteAdditionalJs = toArray(getEnvValue('OPENCMS_VITE_ADD_JS', true));
const viteReplaceCustom = getEnvValue('OPENCMS_VITE_REPLACE_CUSTOM', true);
const aliasAddition = toArray(getEnvValue('OPENCMS_VITE_ALIASES', true));
const fontAddition = toArray(getEnvValue('OPENCMS_VITE_FONTS', true));

const viteMercuryJsDir = viteMercuryJs ? viteMercuryJs.substring(0, viteMercuryJs.lastIndexOf('/')) : null;

if ((repositories.length > 0) && (viteAdditionalCss.length == 0) && (viteAdditionalJs.length == 0) && !viteMercuryScss && !viteMercuryJs){
    log.error(`Error: You must set at least one of the following variables:`);
    log.error(`➜ \x1b[1m\x1b[36mOPENCMS_VITE_CSS\x1b[31m`);
    log.error(`➜ \x1b[1m\x1b[36mOPENCMS_VITE_JS\x1b[31m`);
    log.error(`➜ \x1b[1m\x1b[36mOPENCMS_MERCURY_SCSS\x1b[31m`);
    log.error(`➜ \x1b[1m\x1b[36mOPENCMS_MERCURY_JS\x1b[31m`);
    exitProcess();
}

const opencmsViteSssPrefix = '/scss/';
if (viteMercuryScss && !vitePrefixes.includes(opencmsViteSssPrefix)) {
    vitePrefixes.push(opencmsViteSssPrefix);
}

const opencmsViteCssPrefix = '/@opencms-vite-css/';
const opencmsViteJsPrefix = '/@opencms-vite-js/';
const viteLocalCssPath = '/css/';
const viteLocalJsPath = '/js/';
if (viteReplaceCustom) {
    if (!vitePrefixes.includes(opencmsViteCssPrefix)) {
        vitePrefixes.push(opencmsViteCssPrefix);
    }
    if (!vitePrefixes.includes(opencmsViteJsPrefix)) {
        vitePrefixes.push(opencmsViteJsPrefix);
    }
}

const startupMessage = {
    name: 'opencms-vite-startup',
    config(config) {
                                     log.info(`OpenCms Server   ➜ \x1b[1m\x1b[33m${openCmsServer}`);
        if (workspacePath)           log.info(`User Workspace   ➜ \x1b[1m\x1b[33m${workspacePath}`);
        if (repositories.length > 0) log.info(`Repositories     ➜ \x1b[32m${repositories.join(', ')}`);
        if (viteEnvFile)             log.info(`Vite Env File    ➜ \x1b[32m${viteEnvFile}`);
                                     log.info(`Vite Root        ➜ \x1b[32m${viteRoot}`);
        if (openCmsSite)             log.info(`OpenCms Site     ➜ \x1b[32m${openCmsSite}`);
        if (viteMercuryScss)         log.info(`Mercury SCSS     ➜ \x1b[35m${viteMercuryScss}`);
        if (viteMercuryJs)           log.info(`Mercury JS       ➜ \x1b[35m${viteMercuryJs}`);
        if (viteAdditionalCss.length > 0) log.info(`Custom CSS       ➜ \x1b[35m${viteAdditionalCss.join(', ')}`);
        if (viteAdditionalJs.length > 0)  log.info(`Custom JS        ➜ \x1b[35m${viteAdditionalJs.join(', ')}`);
    }
};

export default defineConfig({
    root: viteRoot,
    plugins: [
        startupMessage
    ],
    css: {
        devSourcemap: true,
        preprocessorOptions: {
            scss: {
                ...((workspacePath && (repositories.length > 0))
                    ? { includePaths: repositories.map(repo => `${workspacePath}/${repo}`) }
                    : {})
            }
        },
        postcss: {
            plugins: [
                postcssUrlRewrite({
                    rules: [
                        { from: '../fonts/', to: '/system/modules/alkacon.mercury.theme/fonts/' },
                        ...(fontAddition)
                    ]
                })
            ]
        }
    },
    resolve: {
        alias: [
            ...((workspacePath && (repositories.length > 0))
                ? repositories.map(repo => ({
                    find: new RegExp(`^${repo}/`),
                    replacement: `${workspacePath}/${repo}/`
                }))
                : []
            ),
            ...(viteReplaceCustom
                ? [{
                    find: opencmsViteCssPrefix,
                    replacement: viteLocalCssPath
                }, {
                    find: opencmsViteJsPrefix,
                    replacement: viteLocalJsPath
                }]
                : []
            ),
            ...(aliasAddition)
        ]
    },
    server: {
        port: 8099,
        fs: {
            strict: false
        },
        proxy: {
            '^/': {
                target: openCmsServer,
                changeOrigin: true,
                bypass: (req) => {
                    // These resources will be served from Vite
                    if (
                        vitePrefixes.some(prefix => req.url.startsWith(prefix)) ||
                        (viteMercuryJsDir && req.url.startsWith(viteMercuryJsDir)) ||
                        req.url.includes('/vite/dist') ||
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
                        proxyReq.setHeader('X-Vite-Secret', viteSecret);
                        if (openCmsSite) {
                            proxyReq.setHeader('X-Vite-OpenCms-Site', openCmsSite);
                        }
                        if (viteReplaceCustom) {
                            proxyReq.setHeader('X-Vite-Replace-Custom', 'true');
                        }
                        if (viteMercuryScss) {
                            proxyReq.setHeader('X-Vite-Mercury-Scss', viteMercuryScss);
                        }
                        if (viteMercuryJs) {
                            proxyReq.setHeader('X-Vite-Mercury-Js', viteMercuryJs);
                        }
                        if (viteAdditionalCss.length > 0) {
                            proxyReq.setHeader('X-Vite-Additional-Css', viteAdditionalCss.join(','));
                        }
                        if (viteAdditionalJs.length > 0) {
                            proxyReq.setHeader('X-Vite-Additional-Js', viteAdditionalJs.join(','));
                        }
                    });
                },
            }
        }
    }
})
