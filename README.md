# Meowbox

A sideloadable Roku channel for the 24/7 channels from [spelunkr.tv](https://spelunkr.tv), kept in step with the website and captioned where words exist. Unofficial; video comes from the Internet Archive.

The ready-to-install package is `dist/Meowbox.zip` (about 60 KB).

## Install

1. Put the Roku in developer mode: on the remote press Home ×3, Up ×2, Right, Left, Right, Left, Right. Note the IP address it shows and set a password.
2. On a computer on the same network, open `http://<roku-ip>` and sign in as `rokudev` with that password.
3. Upload `dist/Meowbox.zip` and choose **Install** (or **Replace** if a dev channel is already there).

The channel starts on its own and stays on the home screen as the dev channel.

## Remote

| Watching | |
|---|---|
| Up / Down | Channel up / down |
| Left or Right | Channel guide |
| OK | Show or hide what's on |
| `*` | Menu: guide, captions, re-sync, about |
| Instant replay | Step captions: on, translations only, off |
| Play | Re-sync the channel |
| Back | Leave the app |

## What to expect

Each channel plays what the website is playing, at the same point, including the text cards between shows, "up next" cards and the ad-break clips. The last channel is remembered. The lineup is re-read every ten minutes, so new playlists arrive without reinstalling.

The channels' pixel logos are drawn from the same data the website uses, so they match it.

Not carried over from the website: chat, accounts, clips, and the music laid over the silent-film channel (Vacation Slides plays silent).

## Captions

Meowbox does not listen to the sound and does not use a captioning service, so there is nothing to pay for and nothing to run. It looks for words that already exist for the tape on air, in this order:

1. **The website's subtitles**: English for tapes in other languages. A few hundred tapes have them, mostly on Waku Waku and Rocket Punch.
2. **Caption files on the Internet Archive**, next to the video: ones people uploaded, then the ones the Archive's own speech recognition made. Roughly three tapes in ten have one, most often on the Computer Chronicles, classroom-film and old-movie channels.

A tape with neither plays without captions; the `CC` mark in the banner shows which case you are in. Machine-made captions are as good as the machine was: expect wrong words and loose timing here and there.

The setting has three steps: **on** (anything found), **translations** (only the website's subtitles), **off**. It is remembered.

## Build

```sh
./build.sh        # writes dist/Meowbox.zip from roku/
```

The pictures in `roku/images/` are drawn by a script, and the caption and logo helpers have checks that run off-device:

```sh
node art/make-art.js      # needs Playwright; Pillow, if present, shrinks the files
npx @rokucommunity/brs roku/source/captions.brs roku/source/logo.brs tests/captions_test.brs
```

## Layout

```
roku/manifest
roku/source/engine.brs       schedule maths: what is on a channel at a given moment
roku/source/broadcast.brs    lineup loading and the "on air" record the screen plays
roku/source/captions.brs     finding and reading captions: SubRip, WebVTT, the website's files
roku/source/logo.brs         the channels' pixel logos as rectangles and colours
roku/source/net.brs          HTTP helper and addresses
roku/components/MainScene      the screen: player, captions, cards, banner, guide, menu
roku/components/BroadcastTask  background worker for the schedule
roku/components/CaptionTask    background worker for captions
roku/components/PixelLogo      draws a channel logo
roku/components/MeowRow        one row of the guide or the menu
roku/fonts/                    Jersey 15 (SIL Open Font License), cut down to Latin
art/                           the Meowbox mark and the script that draws the images
```

The lineup is read from `https://data.spelunkr.tv/` and, if that does not answer, from the snapshot at `https://spelunkr.tv/broadcast/`.
