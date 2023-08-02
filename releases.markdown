---
layout: page
title: "Releases"
permalink: /releases/
---

## Manual list according to **Sandy** versions:

{% assign doc_paths = site.pages
  | where_exp:"item", "item.path contains 'releases/'"
  | where_exp:"item", "item.version"
  | where_exp:"item", "item.release_date"
  | map: "path"
  | sort
  | reverse %}

{% if doc_paths %}
<table>
  <thead>
    <tr>
      <th style="text-align: center">Release</th>
      <th style="text-align: center">Version</th>
      <th style="text-align: center">Get the code</th>
      <th style="text-align: center">Manual</th>
    </tr>
  </thead>
  <tbody>
  {% for path in doc_paths %}
    {% assign page = site.pages | where: "path", path | first %}
    <tr>
      <td style="text-align: center">{{ page.release_date }}</td>
      <td style="text-align: center">{{ page.version }}</td>
      <td>
{% highlight bash %}
# Clone repository from Github
git clone \
 --single-branch \
 --branch "v{{ page.version }}" \
 https://github.com/galantelab/sandy.git
{% endhighlight %}

{% highlight bash %}
# Install from CPAN
cpanm App::Sandy~"== {{ page.version }}"
{% endhighlight %}
      </td>
      <td style="text-align: center">
        <a href="{{ page.url | relative_url }}">
          <img src="https://img.shields.io/badge/sandy-v{{ page.version }}-success" alt="docs" />
        </a>
      </td>
    </tr>
  {% endfor %}
  </tbody>
</table>
{% endif %}
