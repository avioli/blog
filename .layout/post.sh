#!/bin/bash

cat << _EOF_
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
      <title>$(echo $POST_TITLE) - Manila Functional</title>
      <link href="https://fonts.googleapis.com/css?family=Overpass+Mono:400,700" rel="stylesheet">
      <link href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.9.0/styles/arduino-light.min.css" rel="stylesheet">
      <link href="data:image/x-icon;base64,AAABAAEAEBAQAAEABAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAgAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAANjY2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARERERAAAAAAAAAAAAAAAAEQEBEQAAAAAAAAAAAAAAABEREREAAAAAAAAAAAAAAAARAREBAAAAAAAAAAAAAAAAEREBEQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD//wAA//8AAP//AADwDwAA//8AAPKPAAD//wAA8A8AAP//AADyLwAA//8AAPCPAAD//wAA//8AAP//AAD//wAA" rel="icon" type="image/x-icon">
      <style>
        body {
          background-color: white;
          color: #222;
          font-size: 14px;
          padding: 1em;
          font-family: 'Overpass Mono', sans-serif;
          line-height: 1.5em;
        }
        @media (min-width: 760px) { body { font-size: 15px } }
        @media (min-width: 1367px) { body { font-size: 16px } }
        article { padding: 0; margin: 1em 0; max-width: 860px; }
        article a { color: #b58900; }
        article img { max-width: 100% }
        article blockquote { border-left: 2px solid #CCC; padding: 1em; border-radius: 3px; background-color: #f4f4f4; }
        article blockquote,
        article pre { margin: 0; border-bottom: 1px solid #DDD; }
        article pre,
        article code { background-color: #f4f4f4; border-radius: 3px; font-family: 'Overpass Mono'; font-size: 14px; display: inline-block; color: #333; }
        article pre { word-break: break-all; width: 100%; }
        article blockquote :first-of-type { margin-top: 0; }
        article blockquote :last-of-type { margin-bottom: 0; }
        article hr { border: 0; border-bottom: 3px solid #CCC; }
        .heading { font-family: 'Overpass Mono'; }
        .heading a { text-decoration: none; }
        .heading .title { max-width: 600px; font-size: 1.4em; color: #222; display: inline-block; text-transform: uppercase; margin: 0 0 1em; font-weight:bold; line-height:1.25em  }
        .heading .title:hover { text-decoration: underline; }
        .heading .stamp { color: #999; }
        .heading .stamp,
        .home { display: inline-block; width: 2.66em; text-align:right; margin-right: 1.5em; }
        .home { text-decoration: none; margin-bottom: 1.5em; text-align: left;  color: #cb4b16; } .home:hover { color: #dc322f; }
        .contents { display: inline-block; max-width: 79ch; vertical-align: top; width: 100%; }
        .contents :first-child { margin-top: 0; }
        h1, h2, h3, h4, h5, h6 { font-size: 1.4em; font-weight: bold; text-transform: uppercase; margin: 2em 0 1em; }
        h3, h4, h5, h6 { font-size: 1.25em; }
        h4, h5, h6 { font-size: 1em; }
        ol, ul { padding-left: 1em; }
        .footnotes { padding: 1em 0 0; font-size: .9em; }
        .footnotes hr { display: none; }
        .footnotes ol { padding: 0; }
        .footnote { vertical-align: super; font-size: .8em; text-decoration: none; line-height: 0; }
        .tags { border-top: 2px solid #EEE; margin-top: 2.5em; padding-top: 1.5em; font-size: .9em; }
        .tags a { background-color: #EEE; display:inline-block;padding: 0 .5em;border-radius: 4px; }
        .wrap { max-width: 1024px; margin: 0 auto; }
        figure { margin: 0 }
        .hljs { background-color: #fbfbfb; }
      </style>
    </head>
    <body>
      <div class="wrap">
        <article>
        <div class="heading"><a href="$(echo $POST_URL)"><span class="stamp">$(echo $POST_DATE)</span><h1 class="title">$(echo $POST_TITLE)</h1></a></div>
          <a href="/" class="home">←</a><div class="contents">
          $(echo "$POST_CONTENTS")
          <div class="tags">$(for i in $TAGS; do echo "<a href=\"/tag/$i\">$i</a>"; done;)</div>
          </div>
        </article>
      </div>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.9.0/highlight.min.js"></script>
      <script>hljs.initHighlightingOnLoad();</script>
    </body>
  </html>
_EOF_
