# Michael's Death Truck Road Trip

The official site for [michaelsdeathtruckroadtrip.com](https://michaelsdeathtruckroadtrip.com) &mdash;
a Jekyll site hosted on GitHub Pages, documenting a road trip that should not be happening.

## Local development

Requires Ruby (>= 3.1 recommended) and Bundler.

```sh
bundle install
bundle exec jekyll serve
```

Open <http://127.0.0.1:4000>.

### Windows note

If `bundle exec jekyll ...` fails with `'ruby.exe' is not recognized` (a known
bundler/Ruby 3.3 binstub issue on some Windows setups), use the included helper
instead &mdash; same effect, sidesteps the broken shim **and** PowerShell's
script execution policy:

```bat
serve            :: serve with live reload
serve build      :: one-shot build into _site\
```

(Or `.\serve.ps1 [build]` if your PowerShell execution policy allows local
scripts &mdash; `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.)

## Adding an episode

Create a new file in `_posts/` named `YYYY-MM-DD-slug.md`:

```yaml
---
title: "Episode title"
episode: 2
date: 2026-06-02 14:30:00 -0700
location: "Reno, NV"
lat: 39.5296
lng: -119.8138
excerpt: "One-line teaser for the home page and RSS feed."
video: /assets/video/ep-02.mp4
poster: /assets/img/ep-02-poster.jpg
---

Episode body in Markdown.
```

Field reference:

| Field      | Required | Notes |
|------------|----------|-------|
| `title`    | yes      | Episode title. |
| `episode`  | yes      | Episode number. Shown in card and on detail page. |
| `date`     | yes      | Drives ordering and the RSS feed. |
| `location` | no       | Short label, e.g. `"Reno, NV"`. |
| `lat`/`lng`| no       | If both present, the episode appears on the map. |
| `excerpt`  | no       | Shown on the home page card. |
| `video`    | no       | Path to MP4 under `/assets/video/`. Renders the player. |
| `poster`   | no       | Path to poster image under `/assets/img/`. |

## Videos (important)

Videos live in `assets/video/` and are tracked with **Git LFS** (see `.gitattributes`).
Install Git LFS once per machine, then `git lfs install`.

**GitHub Pages limits to plan around:**
- 100 MB hard limit per file.
- 1 GB total repo size for served content.
- 100 GB/month soft bandwidth cap.
- Git LFS free tier: 1 GB storage, 1 GB/month bandwidth.

Compress aggressively before committing. A reasonable starting point:

```sh
ffmpeg -i input.mov -vcodec libx264 -crf 28 -preset slow -acodec aac -b:a 96k -movflags +faststart -vf "scale=-2:720" ep-XX.mp4
```

If the trip generates more video than these limits comfortably allow, move
files to external storage (Cloudflare R2, Backblaze B2, or unlisted YouTube)
and put the external URL in the `video:` front matter field. The `<video>`
tag will use it directly.

## Deployment

Pushing to `main` deploys via GitHub Pages. The `CNAME` file binds the
custom domain. DNS for `michaelsdeathtruckroadtrip.com` must point to
GitHub Pages' IP addresses:

```
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

And a CNAME record for `www` &rarr; `<your-gh-username>.github.io`.

## Structure

```
_config.yml             site config
_layouts/               default, episode, page
_includes/              head, nav, episode-card
_posts/                 episode markdown files
assets/
  css/main.scss         single stylesheet
  img/                  posters, favicon
  video/                MP4s (LFS)
index.html              episode list (home)
about.md
map.html                Leaflet map of the route
episodes.json           data endpoint consumed by the map
CNAME                   custom domain binding
```
