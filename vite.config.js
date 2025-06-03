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

function getEnvValue(name, required) {
    required = false || required;
    if (env && env[name]) {
        return env[name];
    }
    if (process.env[name]) {
        return process.env[name];
    }
    if (required) {
        log.error(`Error: The variable \x1b[1m\x1b[36m${name}\x1b[31m is not set!`);
        exitProcess();
    }
    return null;
}

function toArray(val) {
    if (!val) return [];
    return Array.isArray(val) ? val : [val];
}

const opencmsServer = getEnvValue('OPENCMS_SERVER', true);
const workspacePath =  getEnvValue('OPENCMS_WORKSPACE');
const viteRoot = getEnvValue('OPENCMS_VITE_ROOT') || './';
const viteSecret = getEnvValue('OPENCMS_VITE_SECRET', true);
const opencmsSite = getEnvValue('OPENCMS_SITE');
const repositories = toArray(getEnvValue('OPENCMS_REPOSITORIES') || 'mercury-template');
const mercuryScssSrc = getEnvValue('OPENCMS_MERCURY_SCSS');
const mercuryJsSrc = getEnvValue('OPENCMS_MERCURY_JS');
const viteAdditionalPrefixes = toArray(getEnvValue('OPENCMS_VITE_PREFIX'));
const viteAdditionalCss = toArray(getEnvValue('OPENCMS_VITE_ADD_CSS'));
const viteAdditionalJs = toArray(getEnvValue('OPENCMS_VITE_ADD_JS'));
const viteReplaceCustom = getEnvValue('OPENCMS_VITE_REPLACE_CUSTOM');
const aliasAddition = toArray(getEnvValue('OPENCMS_VITE_ALIASES'));
const fontAddition = toArray(getEnvValue('OPENCMS_VITE_FONTS'));

const viteMercuryJsDir = mercuryJsSrc ? mercuryJsSrc.substring(0, mercuryJsSrc.lastIndexOf('/')) : null;

if ((repositories.length > 0) && (viteAdditionalCss.length == 0) && (viteAdditionalJs.length == 0) && !mercuryScssSrc && !mercuryJsSrc && !viteReplaceCustom){
    log.error(`Error: You must set at least one of the following variables:`);
    log.error(`➜ \x1b[1m\x1b[36mOPENCMS_VITE_REPLACE_CUSTOM\x1b[31m`);
    log.error(`➜ \x1b[1m\x1b[36mOPENCMS_MERCURY_SCSS\x1b[31m`);
    log.error(`➜ \x1b[1m\x1b[36mOPENCMS_MERCURY_JS\x1b[31m`);
    exitProcess();
}

const customCssPrefix = '/@opencms-vite-css/';
const customJsPrefix = '/@opencms-vite-js/';
const viteLocalCssPath = '/css/';
const viteLocalJsPath = '/js/';
const viteCustomReplaceRules = viteReplaceCustom ? [{
    find: customCssPrefix,
    replacement: viteLocalCssPath
}, {
    find: customJsPrefix,
    replacement: viteLocalJsPath
}] : [];
const viteCustomPrefixes = viteReplaceCustom ? [customCssPrefix, customJsPrefix] : [];

const defaultVitePrefixes = ['/@fs', '/@vite', '/scss/']
if (viteMercuryJsDir) defaultVitePrefixes.push(viteMercuryJsDir);

const viteRepoPrefixes = repositories.map(repo => `/@${repo}`);

const vitePrefixes = [...new Set([...defaultVitePrefixes, ...viteRepoPrefixes, ...viteAdditionalPrefixes, ...viteCustomPrefixes])];

const startupMessage = {
    name: 'opencms-vite-startup',
    config(config) {
                                          log.info(`OpenCms Server   ➜ \x1b[1m\x1b[33m${opencmsServer}`);
        if (workspacePath)                log.info(`User Workspace   ➜ \x1b[1m\x1b[33m${workspacePath}`);
        if (repositories.length > 0)      log.info(`Repositories     ➜ \x1b[32m${repositories.join(', ')}`);
        if (viteEnvFile)                  log.info(`Vite Env File    ➜ \x1b[32m${viteEnvFile}`);
                                          log.info(`Vite Root        ➜ \x1b[32m${viteRoot}`);
        if (opencmsSite)                  log.info(`OpenCms Site     ➜ \x1b[32m${opencmsSite}`);
        if (viteReplaceCustom)            log.info(`Customs replaced ➜ \x1b[35m${viteReplaceCustom}`);
        if (mercuryScssSrc)               log.info(`Mercury SCSS     ➜ \x1b[35m${mercuryScssSrc}`);
        if (mercuryJsSrc)                 log.info(`Mercury JS       ➜ \x1b[35m${mercuryJsSrc}`);
        if (viteAdditionalCss.length > 0) log.info(`Additional CSS   ➜ \x1b[35m${viteAdditionalCss.join(', ')}`);
        if (viteAdditionalJs.length > 0)  log.info(`Additional JS    ➜ \x1b[35m${viteAdditionalJs.join(', ')}`);
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
                ? repositories.flatMap(repo => ([
                    {
                        find: new RegExp(`^${repo}/`),
                        replacement: `${workspacePath}/${repo}/`
                    },
                    {
                        find: new RegExp(`^/@${repo}/`),
                        replacement: `${workspacePath}/${repo}/`
                    }
                ]))
                : []
            ),
            ...(viteCustomReplaceRules),
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
                target: opencmsServer,
                changeOrigin: true,
                bypass: (req) => {
                    if (
                        // These resources will be served from Vite
                        vitePrefixes.some(prefix => req.url.startsWith(prefix)) ||
                        req.url.includes('/vite/dist')
                    ) {
                        // Everything else is served through the proxy directly from OpenCms
                        return req.url;
                    }
                },
                configure: (proxy, options) => {
                    // Set "Vite" headers for the request to OpenCms
                    proxy.on('proxyReq', (proxyReq, req, res, options) => {
                        proxyReq.setHeader('X-Vite-Secret', viteSecret);
                        if (opencmsSite) {
                            proxyReq.setHeader('X-Vite-OpenCms-Site', opencmsSite);
                        }
                        if (viteReplaceCustom) {
                            proxyReq.setHeader('X-Vite-Replace-Custom', 'true');
                        }
                        if (mercuryScssSrc) {
                            proxyReq.setHeader('X-Vite-Mercury-Scss', mercuryScssSrc);
                        }
                        if (mercuryJsSrc) {
                            proxyReq.setHeader('X-Vite-Mercury-Js', mercuryJsSrc);
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
