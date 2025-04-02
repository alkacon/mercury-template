# The OpenCms Mercury Template #

## Release history ##

### Version 19 ###

*April 2, 2025*:

* Updated for OpenCms 19.
* "Link sequences" can now be displayed as a row of "icon buttons".
* The "Hero silder" can now be shown / hidden for selected screen sizes.
* The "Logo slider" can now optionally show the title text below the image.
* For "Events", there is a new element setting to display the name of the event location / place in list teasers.
* Map info windows have been optimized to show more information on smaller screens.
* The full text search results can now optionally show the site or subsite where the content was found.
* Added support for the Matomo and Piwik Pro tag managers.
* See [the Mercury documentation website](https://mercury-template.opencms.org/version/) for a detailed description of all the new features.
* All NPM dependencies have been updated to a recent version.

### Version 18 ###

*October 8, 2024*:

* Updated for OpenCms 18.
* The "Meta info" keywords can be used to boost pages in the internal search.
* Place / POI now supports opening hours.
* The "Map" can be displayed with a different ratio for mobile and desktop.
* The "Media" video can be displayed in vertical "portrait" format.
* New "Place detail view (like article)" formatter shows the description of the place above the address.
* Images in most formatters can now be displayed with a different ratio for mobile and desktop.
* Unwanted HTML tags such as 'frame', 'object', etc. entered in the WYSIWYG editor source code are now automatically removed.
* Replaced all mentions of 'twitter' with 'X', including replacing the logo.
* Support for the Piwik Pro" analytics platform.
* Added a new set of custom 'Mercury' icons.
* All NPM dependencies have been updated to a recent version.

### Version 17 ###

*April 9 , 2024*:

* Updated for OpenCms 17.
* "Job posting" allows to set detailed SEO meta information for employment type, salary and more.
* New "Spacer" dynamic function to add customizable spacing between elements.
* The "Map" now supports clustering nearby markers.
* The "Map" marker info popups can now optionally display a link and the facility icons.
* The "Event" now can now optionally show a map for the event location.
* New "Link sequence" formatter with fold / unfold option.
* The "Dynamic list" now returns to the last page and scroll position when using the browser "back" button.
* Combined list filters for a "Dynamic list" are displayed more prominently and can easier be removed.
* Selected individual "Form" data sets for CSV or Excel export.
* Individual icons in link sequences can be placed behind the text using "icon-last".
* "Person" and "Organization" have an additional field "Notice".
* Option to set "robots" meta information for individual pages.
* Updated all icon sets.
* All NPM dependencies have been updated to a recent version.

### Version 16 ###

*October 2, 2023*:

* Updated for OpenCms 16.
* New "Image tile display" formatter for the "Tabs / Accordion" element.
* New "Search slot" function to display a full text search input anywhere on a page.
* For the "Dynamic list", several content filters on the same page are now combined.
* Option to generate contact forms instead of email links for person and organization.
* Option to hide the text of list teasers on mobile displays.
* Added an icon collection with 267 national flags.
* Added the open source Font Awesome icon collections "Brand", "Solid" and "Regular".
* Updated all included Google fonts to a recent version.
* Bootstrap updated to 5.3.2.
* jQuery updated to 3.7.1.
* All NPM dependencies have been updated to a recent version.

### Version 15 ###

*April 25, 2023*:

* Updated for OpenCms 15.
* Bootstrap updated to 5.2.3.
* Improvements / bug fixes in SCSS / CSS.
* Integrated over 1800 [Bootstrap icons](https://icons.getbootstrap.com/).
* Events now feature an optional link to mark them as online or mixed events.
* Events now feature an optional cost table.
* Image series can now displayed as square images, slides or in masonry layout.
* Images in a slider now have an optional reelease and expiration date.
* New "Link box" formatter for the content section.
* The "Image tile" formatter for the content section has more options for letter placement.
* Places / POI can now be displayed in lists.
* Advanced options to output sections in article and event detail pages.
* If an image has a description property, this is now used as "alt" text instead of the title.
* All NPM dependencies have been updated to a recent version.

### Version 14 ###

*October 11, 2022*:

* Updated for OpenCms 14.
* Bootstrap updated to 5.2.
* SCSS / CSS now makes use of CSS variables (custom properties).
* New dynamic function "Search slot".
* Page in tabs and accordions can new directly be opened with a hash-URL (#).
* Flexible content now uses source code editor based on CodeMirror.
* Cookie-free page request statistic collection support when using Matomo.
* Cookie banner can now be closed with an "x" without consenting to anything.
* Decoys in lists show a special marker in the page editor.
* Simple layout rows with 3-3-3-3 or 2-2-2-2-2-2 now can show either one or two columns in XS screens.
* Improved options for lists using image tile teasers.
* New font option "Work Sans".
* Updated the Slider element to use the jQuery free Embla slider, also adding some new element settings.
* Updated PhotoSwipe to the lasted, jQuery free version.

### Version 13 ###

*April 13, 2022*:

* Updated for OpenCms 13.
* Added the 'Burger' template variant that displays a burger menu for all display sizes.
* Greatly improved the accessibility of template.
* Added a 'skip to content' link for screen readers.
* Added automatic tab indexing for all headings on a page.
* Integrated the Hyvor Talk comment service with a dynamic function.
* New setting for the accordion formatter to allow multiple open entries at once.
* The link sequence formatters can now generate icon, text, css, title and id for each entry in a sequence.
* The POI content has a new facility option 'Accessible public restrooms available'.
* The flexible content formatter has a new setting to hide the output depending on screen size.
* The dynamic list content filters formatter allows to show filters either folded or unfolded depending on screen size.
* Improved the export options for the webform data.
* A new setting on layout areas allows to show the side column on top of the main content on mobile devices.
* Fixed the display of image copyright information for certain formatters.
* Bootstrap updated to 4.6.1.
* All NPM dependencies have been updated to a recent version.

### Version 12 ###

*October 12, 2021*:

* Updated for OpenCms 12.
* Configurable cookie banner that allows users to opt-out of statistical and external cookies.
* Contact informations in lists.
* iCalendar links for events.
* Media element extended with SoundCloud audio, external video and external audio option.
* Added several options to show the copyright information for images.
* Content sections can be displayed as image tile.
* Content sections can be hidden based on the screen size.
* Image size for content sections can be set separately for 'desktop' and 'mobile'.
* Added center / left / right alignment options to the content section.
* Decoys linking to an invalid content are automatically hidden.
* Improved the CAPTCHA session handling for the webform.
* Using maplibre-gl instead of mapbox-gl to display OSM vector maps.
* Using 'Fork awesome' instead of 'Font awesome' for icons.
* The SCSS has been improved for several edge cases.
* Bootstrap updated to 4.6.0.
* jQuery updated to 3.6.0.
* Using recent dart sass to compile the SASS sources to CSS.
* All NPM dependencies have been updated to a recent version.

### Version 11,0.2 ###

*August 18, 2020*:

* Updated for OpenCms 11.0.2.

### Version 11,0.1 ###

*September 4, 2019*:

* Updated for OpenCms 11.0.1.
* New flexible header layout group added.
* Additional options to display content section links.
* Option to display categories in download lists.
* Added many new fonts and improved font handling in SCSS.
* Added support for hyphenation, enabled by default.

### Version 11,0.0 ###

*April 30, 2019*:

* Initial release with OpenCms 11.0.0.