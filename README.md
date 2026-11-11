# Meowbox

A sideloadable Roku channel with two parts:

- **TV**: the 24/7 channels from [spelunkr.tv](https://spelunkr.tv), kept in step with the website. Unofficial; video comes from the Internet Archive.
- **Web**: a small reading browser (text and links).

The ready-to-install package is `dist/Meowbox.zip`.

## Install

1. Put the Roku in developer mode: on the remote press Home ×3, Up ×2, Right, Left, Right, Left, Right. Note the IP address it shows and set a password.
2. On a computer on the same network, open `http://<roku-ip>` and sign in as `rokudev` with that password.
3. Upload `dist/Meowbox.zip` and choose **Install** (or **Replace** if a dev channel is already there).

The channel starts on its own and stays on the home screen as the dev channel.

## Remote

| Watching TV | |
|---|---|
| Up / Down | Channel up / down |
| Left or Right | Channel guide |
| OK | Show or hide what's on |
| `*` | Menu: guide, web browser, re-sync, about |
| Play | Re-sync the channel |
| Back | Leave the app |

| Web browser | |
|---|---|
| Up / Down | Move line by line |
| OK | Follow the `[link]` on the line (a line with several asks which) |
| Rewind / Fast-forward | Page up / down |
| Play | Type an address |
| `*` | Menu: search, address, start page, reload, bookmark, back to TV |
| Back | Previous page; from the first page, back to TV |

## What to expect

**TV.** Each channel plays what the website is playing, at the same point, including the text cards between shows, "up next" cards and the ad-break clips. The last channel is remembered. The lineup is re-read every ten minutes, so new playlists arrive without reinstalling.

Not carried over from the website: chat, accounts, clips, subtitles, the pixel logos, and the music laid over the silent-film channel (Vacation Slides plays silent).

**Web.** A Roku has no web engine, and sideloaded channels can't bring one, so this is a reader rather than a Chromium-style browser. It fetches a page and shows its text and links. No JavaScript, no CSS, no logins or forms beyond a site's search box. Sites built entirely by scripts come up empty; wikis, forums, search results and "lite" news editions read well. Picture links open full screen, and links to video or audio files play.

## Build

```sh
./build.sh        # writes dist/Meowbox.zip from roku/
```

## Layout

```
roku/manifest
roku/source/engine.brs       schedule maths: what is on a channel at a given moment
roku/source/broadcast.brs    lineup loading and the "on air" record the screen plays
roku/source/web.brs          addresses and HTML-to-lines for the browser
roku/source/net.brs          HTTP helper
roku/components/MainScene    the TV screen: player, cards, banner, guide, menu
roku/components/BroadcastTask  background worker for the TV side
roku/components/BrowserView  the browser screen
roku/components/BrowserTask  background worker for the browser
```

The lineup is read from `https://data.spelunkr.tv/` and, if that does not answer, from the snapshot at `https://spelunkr.tv/broadcast/`.
