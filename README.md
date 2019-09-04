# The OpenCms Mercury Template #

### A full-featured, customizable, great looking responsive template for OpenCms ###

The Mercury Template is a complete, modular template for [OpenCms](http://opencms.org).
It is based on Bootstrap 4 and allows you to create even complex grid-layouts with drag & drop.
It packs a ton of CSS features and JavaScript plugins that have carefully been integrated to be simple to use for the content manager. And it ships with all Java and SASS sources so you can fully customize it for your unique requirements.

### Release history ###

**Version 11.0.1** - September 4, 2019:

* Updated for OpenCms 11.0.1.
* New flexible header layout group added.
* Additional options to display content section links.
* Option to display categories in download lists.
* Added many new fonts and improved font handling in SCSS.
* Added support for hyphenation, enabled by default.

**Version 11.0.0** - April 30, 2019:

* Initial release with OpenCms 11.0.0.

## Main Mercury features ##

* Create simple or complex grid-layouts via drag & drop using layout row / area  / group elements.
* 'Content section' element that can be formatted in many ways to place text, images or a combination thereof everywhere on a page.
* 'Article' element that supports tags, all kind of sort options as well as archive display.
* 'Event' element including support for recurring events.
* 'Image series' element that create gallery like image series with support for zooming individual images.
* 'Media" element that for referencing to external media files. e.g. YouTube videos.
* 'List' configuration that can be used to create lists from articles, events, image series, media and more elements.
* 'Decoy' element that allows to create content for lists that point to external pages.
* 'Contact information' element with hcard [microformat](http://microformats.org/) generation for persons or organizations.
* 'Point of interest (POI)' to describe locations with geo coordinates.
* 'Location map' allows to display interactive maps with multiple points based on OpenStreetMap or Google maps.
* 'FAQ entry' element to build basic lists for FAQs.
* 'Job advertisement' element to create job ads.
* 'Link sequence' element to simple bullet point lists for navigation and other purposes.
* 'Slider' element that allows the content manger to create image slideshows or logo carousels.
* 'Flexible content' element that can be used to place any kind of HTML or JavaScript markup on a page.
* 'Meta info' element element that can be dropped on any page to add SEO meta information
* 'Form' element that allows you to create even complex email forms without a single line of code.
* 'Navigation' element for the generation of head menu and / or sidebar navigations.
* 'Sitemap' element for the generation of sitemaps.
* 'Shariff social media' element based on [Shariff](https://github.com/heiseonline/shariff).
* [Disqus](https://disqus.com/) comments function that can be placed on any page.
* Full featured search function with support for categories, facets and "did you mean" suggestions in case of misspellings.
* Privacy policy functions that display a cookie banner and enable users to manage their cookie preferences.
* Flexible header layout group that allows to create multiple header layouts easily.

Each of the above functionality can be placed on a web page using OpenCms unique drag & drop mechanism. Many of the elements include multiple format options and can create dozens of output variations.

For the technical minded here are some more background facts about Mercury:

* **SASS sources** CSS gurus can style the complete HTML output with individual CSS-themes using Mercurys [SASS](https://sass-lang.com) and [npm](https://www.npmjs.com) infrastructure.
* **All minified** Mercurys npm build process minifies all CSS and JavaScript to give website visitors the best page loading performance.
* **Source maps provided** Mercury provides full CSS and JavaScript source maps so you can see the original sources in the Chrome or Firefox developer tools.

**The Mercury Template is shipped as demo website as part of the main [OpenCms](http://opencms.org) download.**

## Customizing Mercury from source ##

The rest of this page deals explains the technical process of how to customize the template from source. This is required only if you require full control of all aspects of the HTML / CSS being generated.

### Structure of the repository source files  ###

The Mercury template source code is available on [GitHub](https://github.com/alkacon/mercury-template).

This repository contains all the Mercury functionality shipped with the demo.

The template's static resources, i.e., CSS, JavaScript, fonts and images are all bundled in the module *alkacon.mercury.theme*. Here you find all CSS and JavaScript used by Mercury in minified CSS and JavaScript files.

Java sources are located in the folders starting with `./alkacon.mercury`. The structure of these folders is required by OpenCms.

The CSS themes are generated from the resources under `./template-src/scss`.

The JavaScript is generated from the resources under `./template-src/js`.

### Building the Mercury OpenCms modules ###

Mercurys modules are built using [Gradle](https://gradle.org). The interesting targets are:

* `dist_{module name}` to build a single module (includes building the module's JAR if required)
* `jar_{module name}` to build only a modules JAR
* `bindist` to build all modules

The module *alkacon.mercury.template.democontents* contains a complete web site built with the Mercury Template. It serves as demonstration of the various content elements that are part of the template.

The  [OpenCms Documentation](http://documentation.opencms.org) has more details about the general process required to build general OpenCms modules. Here we want to focus on the special way the Mercury CSS / JavaScript sources are build.

### Building the Mercury CSS  and JavaScript  ###

To customize the template, you can add or change files under `template-src` and then use SASS / npm to compile the sources and place the results in the  *alkacon.mercury.theme* module.

To create Mercurys CSS and JavaScript resources from source, you need to setup a compile environment with [SASS](https://sass-lang.com) and [npm](https://www.npmjs.com). There are many articles available in the web on the details on how to setup such an environment, so we will provide only some brief details about the process here. We will assume that you have the basic environment already in place here.

Of course, you need to check out this repository first. Then run

```shell
sudo npm install
```
to install all dependencies required to compile the template's sources.

Once all dependencies are installed, you can trigger the compilation by running

```shell
npm dist
```
in the repository's root folder.

After running `npm`, the repository will have a new folder `./build/npm/` with three sub-folders. The sub-folder `03_minified/` contains the final CSS resources that you can copy to the *alkacon.mercury.theme* module. The result has to be copied to the folder `/system/modules/alkacon.mercury.theme/`.

You can also set the environment variable `OCMOUNTS` to point to a folder where the compilation result should be copied to. The intention is to mount the VFS of the OpenCms installation you develop on and set `OCMOUNTS` to point to the mount point. Then the CSS and JavaScript sources are updated automatically in the installation and you can see your changes in action.

### Customizing Mercurys CSS ###

Our npm process uses [SASS](https://sass-lang.com/) to generate minified CSS files (with source maps).

The Mercury Template uses CSS themes. By default, the themes *theme-blue* and *theme-red* are available.

Our npm process generates one minified CSS file (with source map) for each theme. There is also one additional CSS file generated that contains resources shared by all themes.

To write your own theme, you could add add an `.scss` file in the folder `./template-src/scss-themes/`, e.g., `theme-custom.scss`.

The simplest adjustment to do in your theme is to change the color values of `$main-theme`, `$main-theme-hover` and `$main-theme-additional`, but you can overwrite any of the variables defined in one of the `.scss` files under `./template-src/scss/`. Of course, you can also add your own variables and style definitions.

### Customizing Mercurys JavaScript ###

Our npm process uses Webpack to generate minified JavaScript files (with source maps) that are shared by all generated CSS themes.

The main entry script is called `mercury.js`. Other scripts are either directly included here, or loaded on demand when required on the web page.

You can modify or extend the files found in `./template-src/js` according to your requirements.

## License ##

The Mercury template is copyright (c) by Alkacon Software GmbH & Co. KG [http://www.alkacon.com](http://www.alkacon.com)

This template is free software: you can redistribute it and/or modify
it under the terms of the *GNU Affero General Public License* as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This template is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

See [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/) for the
full text of the GNU Affero General Public License.


