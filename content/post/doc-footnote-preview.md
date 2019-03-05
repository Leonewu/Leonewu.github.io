---
title: "Hugo tutorial with Jane"
date: 2018-03-01T16:01:23+08:00
lastmod: 2018-03-01T16:01:23+08:00
draft: true
tags: ["Hugo", "theme", "Jane"]
categories: ["docs", "index"]
author: "leone"
---

Hugo-theme-jane optimized for footnote. When you mouse hover the footnote[^example] , footnote content will be displayed.

[^example]: example footnote show.

<!--more-->

## Install
You can create footnotes like this[^Install].
[^Install]: Here is the *text* of the **Install**.

init a folder
```
snap install hugo --channel=extended
```


## Init

You can create footnotes like this[^Init].
[^Init]: Here is the *text* of the **Init**.
```
hugo new site leone-website
 cd leone-website
 git clone https://github.com/xianmin/hugo-theme-jane.git --depth=1 themes/jane
 cp -r themes/jane/exampleSite/content ./
 cp themes/jane/exampleSite/config.toml ./
```


