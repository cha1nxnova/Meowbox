' ---------------------------------------------------------------------------
' Room lights. When a channel comes on, Meowbox can tell Home Assistant its
' colour, so the lights behind the TV can match it. Off until an address is
' entered in the menu. Nothing leaves the house: Home Assistant's webhooks
' answer on the local network only.
'
' Home Assistant side: an automation with a Webhook trigger, id "meowbox"
' (see homelab/homeassistant/meowbox-automations.yaml).
'
' Plain data in, plain data out: the HTTP call is in BroadcastTask.
' ---------------------------------------------------------------------------

' What was typed in the menu, as the webhook's address. "" when it can not be one.
'   "192.168.1.50"             -> http://192.168.1.50:8123/api/webhook/meowbox
'   "homeassistant.local"      -> http://homeassistant.local:8123/api/webhook/meowbox
'   "192.168.1.50:8124"        -> port kept
'   "https://ha.example.com/"  -> scheme kept, no port added
'   "http://x:8123/api/webhook/other" -> used as it is
function LightsUrl(typed as Dynamic) as String
    if typed = invalid then return ""
    s = typed.Trim()
    if s = "" then return ""
    if s.InStr(" ") >= 0 then return ""
    if s.InStr("/api/webhook/") >= 0 then return s

    scheme = "http://"
    lower = LCase(s)
    if Left(lower, 7) = "http://"
        s = Mid(s, 8)
    else if Left(lower, 8) = "https://"
        scheme = "https://"
        s = Mid(s, 9)
    end if

    slash = s.InStr("/")
    if slash >= 0 then s = Left(s, slash)
    if s = "" then return ""
    if s.InStr(":") < 0 and scheme = "http://" then s = s + ":8123"
    return scheme + s + "/api/webhook/meowbox"
end function

' "#12AB9f" -> [18, 171, 159]; anything else -> invalid
function LightsRgb(hex as Dynamic) as Dynamic
    if hex = invalid then return invalid
    h = hex.Replace("#", "")
    if Len(h) <> 6 then return invalid
    digits = "0123456789abcdef"
    out = []
    for i = 0 to 2
        hi = digits.InStr(LCase(Mid(h, i * 2 + 1, 1)))
        lo = digits.InStr(LCase(Mid(h, i * 2 + 2, 1)))
        if hi < 0 or lo < 0 then return invalid
        out.Push(hi * 16 + lo)
    end for
    return out
end function

' What Home Assistant receives, as trigger.json.
'   event  "tune" when a channel comes on, "leave" when Meowbox closes
function LightsPayload(event as String, c as Dynamic) as Object
    out = { event: event }
    if c = invalid then return out
    out.channel = c.name
    out.channel_id = c.id
    out.dial = c.dial
    rgb = LightsRgb(c.color)
    if rgb <> invalid
        out.color = "#" + UCase(c.color.Replace("#", ""))
        out.rgb = rgb
    end if
    return out
end function

' ---- theatre timing ----------------------------------------------------------------

' A tape this long (or longer) is a feature: the lights go down for it.
function LightsIsFeature(durS as Dynamic) as Boolean
    if durS = invalid then return false
    return durS >= 3600
end function

' Is it time to start dimming for the next show? upcoming is the first entry of
' the on-air record's "upcoming" list ({ inS, durS } at the moment the record
' arrived); sinceS is how long ago that was.
function LightsPredimDue(upcoming as Dynamic, sinceS as Integer) as Boolean
    if upcoming = invalid then return false
    if upcoming.inS = invalid then return false
    if not LightsIsFeature(upcoming.durS) then return false
    left = upcoming.inS - sinceS
    return left <= 60 and left > 0
end function
