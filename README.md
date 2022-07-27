Use Comments Tag Info Light
====

A plugin for [Logitech Media Server](https://github.com/Logitech/slimserver)<br>

This plugin uses (key)words in your music files' <u>comment tags</u> to add extra information to the song details page and to define/display custom title formats.
<br><br><br>

## Requirements

- LMS version >= 7.**9**
- LMS database = **SQLite**
<br><br><br>


## Features:
Using <b>(key)words</b> in your music files' <b><u>comments</u> tags</b> you can:<br>
- add **extra information** to the **song details page** / context menu information,<br>
- define and display **custom title formats**. They can be used to display a <i>short</i> string or a character on the <i>Now Playing screensaver</i> and the <i>Music Information plugin screensaver</i> or to append a string to the track title.
<br><br><br>


## Installation

### Using the repository URL

- Add the repository URL below at the bottom of *LMS* > *Settings* > *Plugins* and click *Apply*:
[https://raw.githubusercontent.com/AF-1/lms-usecommentstaginfolight/main/public.xml](https://raw.githubusercontent.com/AF-1/lms-usecommentstaginfolight/main/public.xml)

- Install the new version
<br>

### Manual Install

Please read notes on how to [install a plugin manually](https://github.com/AF-1/sobras/wiki/Manual-installation-of-LMS-plugins).
<br><br><br><br>


## Song Details

Use (key)words in a track's comments tag to display a string on the song details information page.<br><br>

### Examples

- You would like to include the record label on the **song details information page**. Add (key)words for record labels like DG, HM or Stax to the comments tag of your tracks. Then set the **Search String** to any of those words, set the **Menu Item Name** to "Record label" and the **Displayed Item String** to the full name of the record label.

- Not all **live** or **best of** albums include "live" or "best of" in their album title.
Just include the word "LIVE" or "BESTOF" in the comments tag of those tracks, set **Search String** to "LIVE" or "BESTOF", the **Menu Item Name** to "Live" or "Best of", and **Displayed Item String** to "yes" or "✔︎".

If you prefer a **custom** order for your **enabled** song details items, you can switch the ID values accordingly. Enabled items with lower ID values will be displayed above those with higher ID values (in the **same menu position**). This has no effect on custom title formats. <br>
The (content of the) ***More Info* menu** is displayed as part of the song details page in the **LMS web UI**. On piCorePlayer, Squeezebox Touch or in Material skin the "More Info" menu is actually a real menu you can open.
<br><br><br>


## Custom Title Formats

Use (key)words in a track's comments tag to display custom title formats.

**Title Formats** can be used in the web interface and on players<br>
- to display a **short** string or a character on the **Now Playing screensaver** and the **Music Information plugin screensaver** or<br>
- to append a string to the track title.

Once you've created and enabled a custom title format on this plugin's settings page, you'll find it on the **LMS settings > Interface** page.
<br><br><br>


## Notes

- For **<i>valid</i> <u>search</u> strings** (max. 60 characters) please use **alphanumeric characters, spaces or -**. Valid **menu names** can't include special characters like **^{}$@<>"#%?*:/|\**

- To **delete** a line (song details + title formats) just **empty the search string field and press **apply****. Or you could just **disable** it and keep it for later use by unchecking the **Enabled** box.

- You can use unicode **symbols** in displayed strings. **Hex code** works. Example: the hex code of a **black heart** is `&#x2665;` and would be displayed as &#x2665;. For more unicode characters see <a href="https://www.rapidtables.com/web/html/html-codes.html">here</a> or <a href="https://codepoints.net/U+2665">here</a>.

- ⚠️ Characters that are not part of a device's currently enabled **font** won't be displayed (properly). Either replace the character or use a different font on the device.
