---
layout: page
title: "Manual"
permalink: /manual/
---

## Manual list according to **Sandy** versions:

{% assign doc_paths = site.pages
  | where_exp:"item", "item.path contains 'manual/'"
  | where_exp:"item", "item.version"
  | where_exp:"item", "item.status"
  | map: "path"
  | sort
  | reverse %}

{% if doc_paths %}
<table>
  <thead>
    <tr>
      <th style="text-align: center">Release</th>
      <th style="text-align: center">Status</th>
      <th style="text-align: center">Link</th>
    </tr>
  </thead>
  <tbody>
  {% for path in doc_paths %}
    {% assign page = site.pages | where: "path", path | first %}
    <tr>
      {% if page.status == "latest" %}
      <td style="text-align: center"><strong>v{{ page.version }}</strong></td>
      <td style="text-align: center"><strong><em>{{ page.status }}</em></strong></td>
      {% else %}
      <td style="text-align: center">v{{ page.version }}</td>
      <td style="text-align: center"><em>{{ page.status }}</em></td>
      {% endif %}
      <td style="text-align: center"><a href="{{ page.url | relative_url }}"><img src="https://img.shields.io/badge/sandy-v{{ page.version }}-success" alt="docs" /></a></td>
    </tr>
  {% endfor %}
  </tbody>
</table>
{% endif %}
