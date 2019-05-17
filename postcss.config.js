// postcss configuration

var npmConfig = require('./npmpostcss.js');

npmConfig.initRewritePaths('deployTargetVfsDir', 'mercuryBaseVfsDir');

module.exports = {
    plugins : [
        require('autoprefixer')(npmConfig.autoprefixerOpts), // add vendor prefixes
        // require('postcss-sorting')({"sort-order": 'default'}), // sort the rules in the output
        // require('stylefmt')(), // pretty-print the output
        require('postcss-urlrewrite')({
            imports:  true,
            properties: ['src', 'background', 'background-image'],
            rules: [{
                from: '../photoswipe/',
                to: npmConfig.resourcePath('photoswipe/')
            },{
                from: '../fonts/',
                to: npmConfig.resourcePath('fonts/')
            // revolution slider, does not hurt if this is here even if revslider is not enabled
            },{
                from: '../revolution-slider/',
                to: npmConfig.resourcePath('../alkacon.mercury.xtensions/revolution-slider/')
            }]
        })
    ]
}
