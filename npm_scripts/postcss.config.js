
// postcss configuration

var npmConfig = require('./adjustpaths.js');

npmConfig.initRewritePaths(process.env.XDEPLOYDIR, '/system/modules/alkacon.mercury.theme');

module.exports = {
 plugins : [
     require('autoprefixer')(npmConfig.autoprefixerOpts),
     require('postcss-urlrewrite')({
         imports:  true,
         properties: ['src', 'background', 'background-image'],
         rules: [{
             from: '../fonts/',
             to: npmConfig.resourcePath('fonts/')
         }]
     })
   ]
}

