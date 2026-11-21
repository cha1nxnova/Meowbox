# Meowbox homelab

A plan for one old PC that runs the smart home (lots of Govee lights first), a media server and a seedbox, all in Docker, and that knows what Meowbox is doing on the TV.

```
                    ┌───────────────── the old PC (Linux + Docker) ─────────────────┐
  Govee app/cloud ──┤ govee2mqtt ──► Mosquitto (MQTT) ──► Home Assistant ◄── Roku   │
  Govee lights  ◄───┤   (LAN first, cloud as backup)          ▲   ▲            (Meowbox,
     (Wi-Fi)        │                                         │   │             Jellyfin)
  Zigbee / Thread ──┤ Connect ZBT-2 stick ────────────────────┘   │               │
  Bluetooth gear ───┤ ESP32 Bluetooth proxy ──────────────────────┘               │
                    │ Jellyfin ◄──── your media ◄──── qBittorrent ◄── gluetun (VPN)│
                    └──────────────────────────────────────────────────────────────┘
```

**Home Assistant** is the hub. It's free, open source, runs entirely in your house, and talks to around 3,000 kinds of devices. The Govee app and Alexa/Google can stay as they are. Home Assistant sits on top of them and gets them all working together.

---

## 1. Things to do tonight (no hardware needed)

1. **Inventory the lights.** Every Govee box has a model number (`H6199`, `H61A2`, …). Write down each one with the room it's going to, and note whether it uses **Wi-Fi + Bluetooth** or **Bluetooth only**. That one detail decides how each light connects.
2. **Turn on LAN Control.** In the Govee Home app, open each device and tap ⚙️ → *LAN Control* → on. Only some models offer this. The ones that do will work fast and keep working when the internet is down.
3. **Request a Govee API key.** In the Govee Home app go to Profile → ⚙️ → *Apply for API Key*. It arrives by email. Home Assistant uses it for scenes and for models that don't have LAN Control.
4. **Give lights fixed addresses.** In your router, set up "DHCP reservations" so each light keeps the same IP address. This prevents a lot of mystery disconnects later.
5. **Name things consistently**, e.g. `Bedroom Strip`, `Living TV Backlight`. Home Assistant picks up these names.

## 2. Hardware

| Priority | Item | Why | Rough cost |
|---|---|---|---|
| **Must** | **Used business mini/SFF PC**: Dell OptiPlex, HP EliteDesk/ProDesk, or Lenovo ThinkCentre, **Intel 8th gen or newer** (i5-8500 / i5-9500 / i5-10500 are good picks) | Quiet, uses about 10–20 W idle, and Intel's built-in graphics (Quick Sync) lets Jellyfin transcode video without a separate graphics card | $80–180 |
| **Must** | 16 GB RAM, plus a **256–512 GB SSD** for the OS and containers | Home Assistant's database likes an SSD | often included |
| **Must** | **Ethernet cable** to the router | Don't run the hub over Wi-Fi | $5 |
| Media | 1–2 big **3.5" hard drives** (SFF cases fit 1–2; get an SFF, not a "Micro", if you want internal drives). Refurbished 12–16 TB enterprise drives are good value | NAS storage | $100–180 each |
| Soon | **Home Assistant Connect ZBT-2** (Zigbee *or* Thread USB stick, ~$49) + a **USB extension cable** | Cheap, reliable, fully local sensors and buttons: door/motion sensors, IKEA/Aqara remotes, smart plugs. The extension cable keeps it away from USB 3 interference | $55 |
| Soon | **ESP32 board** flashed as a Bluetooth proxy (~$8–15; flash it from your browser at esphome.io) | For Bluetooth-only Govee gear (thermometers etc.) or a PC without Bluetooth | $10 |
| Nice | **Small UPS** | Keeps the server (and your drives) safe through power blips | $60–90 |
| Nice | A couple of **Zigbee smart buttons** | Physical "movie mode / goodnight" buttons, better than talking to your phone | $10–15 each |

Skip anything sold as a "hub" from a specific brand. The PC *is* the hub.

## 3. Operating system: my pick

**Debian 12/13 or Ubuntu Server LTS + Docker Compose**, using the `docker-compose.yml` in this folder. This is what you asked about: every service is a container, defined in one file and backed up as one folder.

The trade-off: Home Assistant in a container (the "Container" install type) has no **Add-on store**. Add-ons are only containers anyway, and this compose file already sets up the ones you need. If you ever want the one-click experience, the alternative is **Proxmox** with Home Assistant OS in a VM and a second VM for Docker. That's powerful, but it adds a layer to learn. Start with plain Docker.

Add [Tailscale](https://tailscale.com) on the server so you can reach Home Assistant from rotations or anywhere else without opening ports on your router.

## 4. Getting it running

```sh
# on the server, after installing Docker (https://docs.docker.com/engine/install/)
git clone https://github.com/cha1nxnova/Meowbox && cd Meowbox/homelab
cp .env.example .env && nano .env                 # fill in Govee + MQTT details

# create the MQTT password file (uses the same user/password as .env)
docker run --rm -v "$PWD/mosquitto/config:/mosquitto/config" eclipse-mosquitto:2 \
  mosquitto_passwd -c -b /mosquitto/config/passwd meow change-me

docker compose up -d                              # smart home
docker compose --profile media up -d              # + Jellyfin & seedbox, when the drives are in
```

Then open `http://<server-ip>:8123`, create your account, and:

1. **Settings → Devices & services → Add → MQTT**: broker `127.0.0.1`, port `1883`, user/password from `.env`. Your Govee lights will start to appear.
2. **Roku** usually turns up on its own under *Discovered*. Accept it.
3. Install the **Home Assistant companion app** on your phone. It gives you presence detection ("is anyone home?") and notifications.

## 5. Three ways to connect Govee lights

| Route | Use it for | Notes |
|---|---|---|
| **[govee2mqtt](https://github.com/wez/govee2mqtt)** (in the compose file) | **Most of your lights**: the default | Uses LAN control where it can and falls back to Govee's cloud for everything else. Also gives you Govee's scenes, music modes and segments. Wi-Fi models only. It needs host networking for discovery. |
| **[Govee lights local](https://www.home-assistant.io/integrations/govee_light_local/)** (built into HA) | A simple fully-local option, or a fallback | Only for LAN-capable models, and only covers on/off, colour and brightness. Fine to run alongside govee2mqtt, but don't add the same light through both. |
| **Matter** | Newer Govee models with a Matter logo on the box | Works, but in HA you get [fewer features](https://community.home-assistant.io/t/better-integration-for-govee-matter-lights-limited-functionality-in-home-assistant/950525) than govee2mqtt gives you. HA's docs themselves say to prefer a native local integration where one exists. |

**Bluetooth-only** Govee lights are the awkward ones. Plan them for spots where the Govee app alone is good enough, or replace them over time.

## 6. TV and Meowbox ideas

What's ready to use now:

- **Theater mode**: [`homeassistant/meowbox-automations.yaml`](homeassistant/meowbox-automations.yaml). When the Roku opens Meowbox, the TV backlight turns Meowbox purple and the room lights dim to 8%. When you leave Meowbox, the room goes back to exactly how it was (via a scene snapshot).
- **Jellyfin on the Roku**: install the official Jellyfin channel from the Roku store and point it at `http://<server-ip>:8096`.

More ideas, roughly from easiest to most ambitious:

1. **Pause = lights up.** Pausing Jellyfin or Playlet brings the lights up to 40% so you can find snacks. Resuming dims them again.
2. ~~Channel mood lighting~~ **Built.** In Meowbox, press `*` → **Room lights** and type the server's address (e.g. `192.168.1.50`). Choosing *Save and test* sends the current channel straight away and tells you whether Home Assistant answered. From then on each channel's colour goes to the `meowbox` webhook when it comes on, so the backlight turns *Waku Waku* pink or *Computer Chronicles* green. Automation #3 in `meowbox-automations.yaml` handles the other end. Nothing leaves your network.
3. ~~"Up next" pre-dim~~ **Built.** A minute before a feature-length tape starts, Meowbox posts `predim` and the room fades over that minute. `showtime` takes it the rest of the way down. When the film ends, the channel colour comes back.
4. **Internet Archive cache on the NAS.** Meowbox streams tapes straight from archive.org. A small container on the server could cache the tapes and captions for your favourite channels on the NAS drives, which means faster starts and less buffering when archive.org is slow.

## 7. Ideas for rotations

- **Sunrise alarm.** For early pre-rounding mornings, the bedroom lights fade from deep red to warm white over the 20 minutes before your phone alarm. It's gentler on cortisol than a phone alarm at 4:45 am.
- **Pomodoro study light.** A desk strip stays a calm colour for 25 minutes of NAPLEX/MPJE review, then pulses a different colour for your 5-minute break. Controlled from a Zigbee button or your phone.
- **Study break, built in.** The YouTube side has a *Study break* setting (Settings > Sleep timer). After 25 to 60 minutes of videos it pauses, nudges you back to the books, and posts `study_break`. Automation #3 pulses the lights amber three times, then switches to bright focus white.
- **"Did I take it?" light.** For your own meds (or a pet's): one light glows amber at dose time until you press a button, and the press gets logged. It's the same adherence-cue idea you counsel patients on, in light-strip form.
- **Wind-down.** At a set time all the lights shift to warm, dim amber, a light-hygiene nudge for sleep after long clinical days.

## 8. Security basics

- Don't port-forward Home Assistant, qBittorrent or Jellyfin to the internet. Use **Tailscale** instead.
- Keep `.env` and `mosquitto/config/passwd` out of git (the included `.gitignore` already excludes them).
- Later, consider putting the many cheap Wi-Fi lights on a separate **IoT Wi-Fi network**. govee2mqtt's discovery uses multicast, so check that it still finds the lights after any network change. If it doesn't, list their fixed IPs in govee2mqtt's config.
- Back up the `homelab/` folder. It *is* the whole setup.
