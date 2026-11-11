' ---------------------------------------------------------------------------
' Lineup bookkeeping on top of the schedule engine: which channels exist,
' loading the playlists a channel needs, and turning "what is on air" into a
' small plain record the screen can act on.
'
' Nothing here touches the network directly. The caller hands in a fetcher,
' an object with getJson(path) that returns parsed JSON or invalid, so this
' file can be exercised off-device.
' ---------------------------------------------------------------------------

function BcNew(fetcher as Object) as Object
    return {
        fetcher: fetcher
        lineup: invalid
        channels: []
        byId: {}
        scheds: {}
        platforms: {}
        details: {}
        refused: {}
        audioBase: ""
        skewMs: 0&
    }
end function

function BcNow(st as Object) as LongInteger
    return SpkNowMs() + st.skewMs
end function

function BcDial(c as Object) as Integer
    if SpkIsWhole(c.dial) then return Int(c.dial)
    return 9999
end function

' Fetch (or refresh) the lineup. Returns "" or what went wrong.
function BcLoadLineup(st as Object) as String
    j = st.fetcher.getJson("lineup.json")
    if j = invalid then return "The channel lineup could not be loaded."
    if j.channels = invalid then return "The channel lineup came back empty."
    chans = []
    for each c in j.channels
        ok = (c.id <> invalid and c.versions <> invalid)
        if ok then ok = (c.versions.Count() > 0)
        if ok then ok = (not SpkTrue(c.comingSoon)) and (not SpkTrue(c.debugOnly))
        if ok
            ' insertion sort by dial number
            at = chans.Count()
            chans.Push(c)
            while at > 0
                if BcDial(chans[at - 1]) > BcDial(c)
                    chans[at] = chans[at - 1]
                    at = at - 1
                else
                    exit while
                end if
            end while
            chans[at] = c
        end if
    end for
    if chans.Count() = 0 then return "The channel lineup has no channels."
    st.lineup = j
    st.channels = chans
    st.byId = {}
    for each c in chans
        st.byId[c.id] = c
    end for
    if j.audioBase <> invalid then st.audioBase = j.audioBase
    return ""
end function

' the short list the screen shows
function BcChannelList(st as Object) as Object
    out = []
    for each c in st.channels
        name = c.id
        if c.name <> invalid then name = c.name
        desc = ""
        if c.description <> invalid then desc = c.description
        color = "#888888"
        if c.color <> invalid then color = c.color
        out.Push({ id: c.id, name: name, dial: BcDial(c), color: color, description: desc })
    end for
    return out
end function

' Make sure the playlists that matter at time t are loaded. Returns "" or why not.
function BcEnsure(st as Object, channelId as String, t as LongInteger) as String
    c = st.byId[channelId]
    if c = invalid then return "That channel is not in the lineup."
    sched = st.scheds[channelId]
    if sched = invalid
        sched = SpkNewSchedule(channelId)
        st.scheds[channelId] = sched
    end if
    cur = invalid
    for each v in c.versions
        if SpkIsWhole(v.v)
            eff& = SpkLong(v.epochMs)
            if v.effectiveAtMs <> invalid then eff& = SpkLong(v.effectiveAtMs)
            if eff& <= t
                if cur = invalid
                    cur = v
                else if v.v > cur.v
                    cur = v
                end if
            end if
        end if
    end for
    for each v in c.versions
        need = SpkIsWhole(v.v) and v.manifest <> invalid
        if need and cur <> invalid then need = (v.v >= cur.v)
        if need
            key = channelId + ":" + v.v.ToStr()
            if (not SpkHasVersion(sched, Int(v.v))) and (not st.refused.DoesExist(key))
                mf = st.fetcher.getJson(v.manifest)
                if mf <> invalid
                    pf = invalid
                    if mf.platform <> invalid
                        pf = st.platforms[mf.platform]
                        if pf = invalid
                            pf = st.fetcher.getJson(mf.platform)
                            if pf <> invalid then st.platforms[mf.platform] = pf
                        end if
                    end if
                    err = SpkAddVersion(sched, mf, pf, v)
                    if err <> "" then st.refused[key] = err
                end if
            end if
        end if
    end for
    if sched.versions.Count() = 0 then return "This channel's schedule could not be loaded."
    return ""
end function

' ---- addresses ---------------------------------------------------------------------

' encodeURIComponent over UTF-8 bytes
function BcEscape(s as String) as String
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(s)
    hex = "0123456789ABCDEF"
    out = ""
    for each b in ba
        keep = (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122)
        if not keep then keep = (b = 45 or b = 95 or b = 46 or b = 33 or b = 126 or b = 42 or b = 39 or b = 40 or b = 41)
        if keep
            out = out + Chr(b)
        else
            out = out + "%" + Mid(hex, (b \ 16) + 1, 1) + Mid(hex, (b mod 16) + 1, 1)
        end if
    end for
    return out
end function

function BcTapeUrl(id as String, file as String) as String
    parts = file.Split("/")
    path = ""
    for each p in parts
        if path <> "" then path = path + "/"
        path = path + BcEscape(p)
    end for
    return "https://archive.org/download/" + id + "/" + path
end function

' the playable file for a playlist item, "" when the item names none
function BcItemUrl(item as Object) as String
    if item.id = invalid then return ""
    if item.file <> invalid
        if item.file <> "" then return BcTapeUrl(item.id, item.file)
    end if
    if item.mp4 <> invalid
        if item.mp4 <> "" then return BcTapeUrl(item.id, item.mp4)
    end if
    return ""
end function

' From an Internet Archive metadata answer, the best file a TV can play
function BcPickArchiveFile(meta as Dynamic) as String
    if meta = invalid then return ""
    files = meta.files
    if files = invalid then return ""
    for each want in ["h.264 IA", "h.264", "512Kb MPEG4", "MPEG4"]
        for each f in files
            if f.format <> invalid and f.name <> invalid
                if f.format = want then return f.name
            end if
        end for
    end for
    for each f in files
        if f.name <> invalid
            if LCase(Right(f.name, 4)) = ".mp4" then return f.name
        end if
    end for
    return ""
end function

' ---- what is on ----------------------------------------------------------------------

function BcTitle(item as Object) as String
    if item.title <> invalid then return item.title
    if item.id <> invalid then return item.id
    return ""
end function

function BcYearText(item as Object) as String
    if item.year = invalid then return ""
    return item.year.ToStr().Trim()
end function

sub BcAddSlides(tl as Object, bump as Dynamic, who as String)
    if bump = invalid then return
    if bump.slides = invalid then return
    for each s in bump.slides
        t = ""
        if s.text <> invalid then t = s.text
        tl.Push({ text: t, ms: SpkSlideMs(s), who: who })
    end for
end sub

function BcMusic(st as Object, pick as Dynamic) as Dynamic
    if pick = invalid or st.audioBase = "" then return invalid
    track = pick.track
    if track = invalid then return invalid
    if track.filename = invalid then return invalid
    title = ""
    if track.title <> invalid then title = track.title
    artist = ""
    if track.artist <> invalid then artist = track.artist
    return { url: st.audioBase + BcEscape(track.filename), startS: pick.startOffset, title: title, artist: artist }
end function

' The next few shows after time t: [{ title, year, inMs }]
function BcUpcoming(st as Object, sched as Object, fromMs as LongInteger, nowMs as LongInteger, want as Integer) as Object
    out = []
    t& = fromMs
    for i = 1 to 12
        r = SpkOnAir(sched, t&)
        if r = invalid then exit for
        if r.entry.type = "video"
            wait& = r.startMs - nowMs
            if wait& < 0 then wait& = 0
            w% = wait& \ 1000&
            out.Push({ title: BcTitle(r.entry.item), year: BcYearText(r.entry.item), inS: w% })
            if out.Count() >= want then exit for
        end if
        t& = r.endMs
    end for
    return out
end function

' A plain record of what the channel is showing at time t.
' kind: "video" | "ad" | "bump" | "upnext" | "error"
function BcDescribe(st as Object, channelId as String, t as LongInteger) as Object
    err = BcEnsure(st, channelId, t)
    if err <> "" then return { kind: "error", channelId: channelId, message: err }
    sched = st.scheds[channelId]
    r = SpkOnAir(sched, t)
    if r = invalid then return { kind: "error", channelId: channelId, message: "Nothing is scheduled on this channel." }
    e = r.entry
    off% = t - r.startMs
    dur% = r.endMs - r.startMs
    out = {
        channelId: channelId
        kind: e.type
        key: r.version.ToStr() + ":" + r.cycle.ToStr() + ":" + r.index.ToStr()
        version: r.version
        endMs: r.endMs.ToStr()
        offsetMs: off%
        durMs: dur%
        title: ""
        year: ""
        url: ""
        seekS: 0
        lookupId: ""
        tapeId: ""
        videoIndex: -1
        slides: []
        music: invalid
        upcoming: BcUpcoming(st, sched, r.endMs, t, 2)
    }
    if e.type = "video"
        item = e.item
        out.title = BcTitle(item)
        out.year = BcYearText(item)
        out.url = BcItemUrl(item)
        if item.id <> invalid then out.tapeId = item.id
        if out.url = "" and item.id <> invalid then out.lookupId = item.id
        inS = 0
        if SpkIsWhole(item.inS)
            if item.inS > 0 then inS = Int(item.inS)
        end if
        out.seekS = inS + off% / 1000
        out.videoIndex = e.videoIndex
    else if e.type = "ad"
        out.title = "Commercial break"
        sl = e.slice
        if sl.year <> invalid then out.year = sl.year.ToStr().Trim()
        if sl.tape <> invalid and sl.file <> invalid then out.url = BcTapeUrl(sl.tape, sl.file)
        inMs = 0
        if SpkIsWhole(sl.inMs)
            if sl.inMs > 0 then inMs = Int(sl.inMs)
        end if
        out.seekS = (inMs + off%) / 1000
    else if e.type = "bump-break"
        out.kind = "bump"
        tl = []
        if e.half = "" or e.half = "open"
            tl.Push({ text: "", ms: 3500, who: "intro" })
            BcAddSlides(tl, e.channelBump, "channel")
            tl.Push({ text: "", ms: 2000, who: "gap" })
        end if
        if e.half = "" then tl.Push({ text: "", ms: 300, who: "gap" })
        if e.half = "" or e.half = "close"
            BcAddSlides(tl, e.platformBump, "network")
            tl.Push({ text: "", ms: 2000, who: "gap" })
        end if
        out.slides = tl
        if e.channelAudio <> invalid
            out.music = BcMusic(st, e.channelAudio)
        else
            out.music = BcMusic(st, e.platformAudio)
        end if
    else if e.type = "up-next"
        out.kind = "upnext"
        if e.sting <> invalid and st.audioBase <> ""
            if e.sting.track <> invalid
                startS = 0
                if SpkIsWhole(e.sting.startMs) then startS = Int(e.sting.startMs) \ 1000
                out.music = { url: st.audioBase + BcEscape(e.sting.track), startS: startS, title: "", artist: "" }
            end if
        end if
    end if
    return out
end function

' The blurb for one show, "" when there is none
function BcBlurb(st as Object, channelId as String, version as Integer, videoIndex as Integer) as String
    c = st.byId[channelId]
    if c = invalid or videoIndex < 0 then return ""
    key = channelId + ":" + version.ToStr()
    d = st.details[key]
    if d = invalid
        path = ""
        for each v in c.versions
            if SpkIsWhole(v.v)
                if v.v = version and v.details <> invalid then path = v.details
            end if
        end for
        if path = "" then return ""
        d = st.fetcher.getJson(path)
        if d = invalid then return ""
        st.details[key] = d
    end if
    list = d.Lookup("items")
    if list = invalid then return ""
    if videoIndex >= list.Count() then return ""
    row = list[videoIndex]
    if row = invalid then return ""
    if row.description = invalid then return ""
    return row.description
end function
