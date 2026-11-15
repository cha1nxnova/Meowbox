' One channel on screen, kept in step with everyone else watching.
'
' The broadcast worker answers "what is on this channel right now" with a small
' record (see BcDescribe). This file plays that record, counts down to its end
' on a local clock, then asks again. The caption worker is asked, separately,
' whether anyone has written down the words of the tape on air.

sub init()
    for each id in ["video", "music", "caption", "capPlate", "capText", "card", "cardStripe", "cardHead", "cardLogo", "cardDial", "cardChannel", "cardCat", "cardText", "cardSub", "banner", "bannerStripe", "bannerLogo", "bannerDial", "bannerChannel", "bannerTitle", "bannerBar", "bannerTime", "bannerNextLabel", "bannerNext", "bannerBlurb", "bannerClock", "ccNote", "ccBox", "ccMark", "guide", "guideList", "guideCount", "guideStripe", "guideLogo", "guideDial", "guideName", "guideDesc", "guideNow", "guideBar", "guideLeft", "guideNext", "menu", "menuList", "menuHint", "toast", "toastText", "tick"]
        m[id] = m.top.findNode(id)
    end for

    ' video and music come over https
    for each node in [m.video, m.music]
        node.setCertificatesFile("common:/certs/ca-bundle.crt")
        node.initClientCertificates()
    end for
    m.video.enableTrickPlay = false

    m.clock = CreateObject("roTimespan")
    m.mode = "live"          ' live | guide | menu
    m.channels = []
    m.chIndex = -1
    m.seq = 0
    m.entry = invalid
    m.entryAt = 0
    m.asked = false          ' the next record has been asked for
    m.fixed = false          ' the playing position has been checked once
    m.triedFind = false
    m.retryAt = 0
    m.bannerUntil = 0
    m.toastUntil = 0
    m.blurbKey = ""
    m.slideAt = -1
    m.videoShown = false
    m.peekSeq = 0
    m.peekAt = 0
    m.peek = invalid
    m.clockText = ""

    ' captions
    m.capMode = "on"         ' on | translated | off
    m.subIndex = ""          ' where the lineup says the website's subtitles are
    m.cues = []
    m.cueShown = -2          ' index of the cue on screen; -1 none; -2 nothing drawn yet
    m.capSeq = 0
    m.capFor = ""            ' the tape the cues (or the search for them) belong to
    m.capState = "none"      ' none | looking | ready
    m.capLow = true          ' captions sit low; they move up when the banner is showing
    m.credited = {}
    m.posS = -1
    m.posAt = 0

    m.video.observeField("state", "onVideoState")
    m.video.observeField("position", "onVideoPosition")
    m.guideList.observeField("itemSelected", "onGuideSelected")
    m.guideList.observeField("itemFocused", "onGuideFocused")
    m.menuList.observeField("itemSelected", "onMenuSelected")
    m.menuList.observeField("itemFocused", "onMenuFocused")
    m.tick.observeField("fire", "onTick")

    m.task = CreateObject("roSGNode", "BroadcastTask")
    m.task.observeField("lineup", "onLineup")
    m.task.observeField("onAir", "onOnAir")
    m.task.observeField("peek", "onPeek")
    m.task.observeField("blurb", "onBlurb")
    m.task.observeField("found", "onFound")
    m.task.control = "run"

    m.capTask = CreateObject("roSGNode", "CaptionTask")
    m.capTask.observeField("result", "onCaptions")
    m.capTask.control = "run"

    fillMenu()
    showMessage("MEOWBOX", "Fetching the channel lineup...")
    m.tick.control = "start"
    m.top.setFocus(true)
end sub

function nowMs() as Integer
    return m.clock.TotalMilliseconds()
end function

function colorOf(hex as Dynamic) as String
    if hex = invalid then return "0xFFA630FF"
    h = hex.Replace("#", "")
    if Len(h) <> 6 then return "0xFFA630FF"
    return "0x" + UCase(h) + "FF"
end function

function channel() as Dynamic
    if m.chIndex < 0 or m.chIndex >= m.channels.Count() then return invalid
    return m.channels[m.chIndex]
end function

function dialText(c as Object) as String
    return "CH " + c.dial.ToStr()
end function

function markOf(c as Object) as Object
    return { logo: c.logo, color: c.color }
end function

' ---- lineup ------------------------------------------------------------------------

sub onLineup()
    data = m.task.lineup
    if data = invalid then return
    if data.channels = invalid then return
    if data.channels.Count() = 0
        msg = "The channel lineup could not be loaded."
        if data.error <> invalid
            if data.error <> "" then msg = data.error
        end if
        showMessage("NO SIGNAL", msg + " Trying again shortly.")
        m.retryAt = nowMs() + 15000
        m.entry = invalid
        return
    end if

    current = ""
    c = channel()
    if c <> invalid then current = c.id
    first = (m.channels.Count() = 0)
    m.channels = data.channels
    if data.subtitles <> invalid then m.subIndex = data.subtitles

    if first
        if data.captions = "on" or data.captions = "translated" or data.captions = "off"
            m.capMode = data.captions
            fillMenu()
        end if
        want = 0
        for i = 0 to m.channels.Count() - 1
            if m.channels[i].id = data.last then want = i
        end for
        m.chIndex = want
        fillGuide()
        tune(want)
    else
        ' a refreshed lineup: stay where we are
        m.chIndex = 0
        for i = 0 to m.channels.Count() - 1
            if m.channels[i].id = current then m.chIndex = i
        end for
        fillGuide()
        if m.channels[m.chIndex].id <> current then tune(m.chIndex)
    end if
end sub

sub fillGuide()
    content = CreateObject("roSGNode", "ContentNode")
    for i = 0 to m.channels.Count() - 1
        ch = m.channels[i]
        row = content.createChild("ContentNode")
        row.title = ch.name
        value = ""
        if i = m.chIndex then value = "ON AIR"
        row.addFields({ dial: ch.dial.ToStr(), chip: colorOf(ch.color), value: value })
    end for
    m.guideList.content = content
    m.guideCount.text = m.channels.Count().ToStr() + " channels"
end sub

' move the "ON AIR" tag in the guide to the channel now tuned
sub markTuned()
    content = m.guideList.content
    if content = invalid then return
    for i = 0 to content.getChildCount() - 1
        row = content.getChild(i)
        value = ""
        if i = m.chIndex then value = "ON AIR"
        if row.value <> value then row.value = value
    end for
end sub

' ---- tuning ------------------------------------------------------------------------

sub tune(index as Integer)
    n = m.channels.Count()
    if n = 0 then return
    m.chIndex = ((index mod n) + n) mod n
    c = channel()
    stopPlayback()
    m.entry = invalid
    m.retryAt = 0
    m.triedFind = false
    dropCaptions()
    markTuned()
    showCard(c.name, "Tuning...")
    askNow("")
    m.task.request = { cmd: "save", key: "lastChannel", value: c.id }
    showBanner(5000)
end sub

sub askNow(at as String)
    c = channel()
    if c = invalid then return
    m.seq = m.seq + 1
    m.asked = true
    m.task.request = { cmd: "tune", channelId: c.id, at: at, seq: m.seq }
end sub

sub stopPlayback()
    m.video.control = "stop"
    m.music.control = "stop"
    m.videoShown = false
    m.posS = -1
end sub

sub onOnAir()
    e = m.task.onAir
    if e = invalid then return
    if e.seq <> m.seq then return
    m.asked = false
    if e.kind = "error"
        stopPlayback()
        m.entry = invalid
        showCard("NO SIGNAL", e.message + " Trying again shortly.")
        m.retryAt = nowMs() + 15000
        return
    end if
    m.entry = e
    m.entryAt = nowMs()
    m.fixed = false
    m.triedFind = false
    m.slideAt = -1
    m.bannerBlurb.text = ""

    if e.kind = "video" or e.kind = "ad"
        m.music.control = "stop"
        if e.url = ""
            m.video.control = "stop"
            showCard(channel().name, "This tape could not be found. The next show starts on time.")
        else
            if not m.videoShown then showCard(channel().name, "Tuning...")
            m.posS = -1
            startVideo(e.url, e.seekS)
        end if
        if e.kind = "video" and e.videoIndex >= 0
            m.blurbKey = e.channelId + ":" + e.key
            m.task.request = { cmd: "blurb", channelId: e.channelId, version: e.version, videoIndex: e.videoIndex, key: m.blurbKey }
        end if
        if e.kind = "video"
            askCaptions()
        else
            dropCaptions()
        end if
    else
        m.video.control = "stop"
        m.videoShown = false
        dropCaptions()
        startMusic(e.music)
        drawCard()
    end if
    updateBanner()
end sub

sub startVideo(url as String, seekS as Dynamic)
    content = CreateObject("roSGNode", "ContentNode")
    content.url = url
    content.streamFormat = "mp4"
    content.title = m.entry.title
    start = Int(seekS)
    if start < 0 then start = 0
    content.playStart = start
    m.video.content = content
    m.video.control = "play"
end sub

sub startMusic(track as Dynamic)
    m.music.control = "stop"
    if track = invalid then return
    if track.url = invalid then return
    content = CreateObject("roSGNode", "ContentNode")
    content.url = track.url
    content.streamFormat = "mp3"
    if track.startS <> invalid then content.playStart = Int(track.startS)
    m.music.content = content
    m.music.control = "play"
end sub

' where the tape should be right now, in seconds
function expectedPosition() as Float
    return m.entry.seekS + (nowMs() - m.entryAt) / 1000
end function

sub onVideoState()
    state = m.video.state
    if m.entry = invalid then return
    if m.entry.kind <> "video" and m.entry.kind <> "ad" then return
    if state = "playing"
        m.videoShown = true
        m.card.visible = false
        ' the player may have ignored the start point, or taken long to load:
        ' put it where the broadcast is, once
        if not m.fixed
            m.fixed = true
            want = expectedPosition()
            if Abs(m.video.position - want) > 6 then m.video.seek = want + 1
        end if
    else if state = "error"
        m.videoShown = false
        if m.entry.kind = "video" and m.entry.tapeId <> "" and not m.triedFind
            ' the named file is gone: ask the Archive what else the tape has
            m.triedFind = true
            showCard(channel().name, "Looking for this tape...")
            m.task.request = { cmd: "find", id: m.entry.tapeId, seq: m.seq }
        else
            tapeTrouble()
        end if
    else if state = "finished"
        m.videoShown = false
        showCard(channel().name, "")
    end if
end sub

sub onVideoPosition()
    m.posS = m.video.position
    m.posAt = nowMs()
end sub

sub tapeTrouble()
    showCard(channel().name, "This tape isn't answering right now. The next show starts on time.")
end sub

sub onFound()
    f = m.task.found
    if f = invalid or m.entry = invalid then return
    if f.seq <> m.seq then return
    if f.url = "" or f.url = m.entry.url
        tapeTrouble()
        return
    end if
    m.entry.url = f.url
    m.triedFind = true
    m.fixed = false
    startVideo(f.url, expectedPosition())
end sub

' ---- captions ----------------------------------------------------------------------

sub dropCaptions()
    m.cues = []
    m.capFor = ""
    m.capState = "none"
    m.capSeq = m.capSeq + 1
    hideCaption()
    updateCcBadge()
end sub

sub hideCaption()
    if m.cueShown = -1 then return
    m.cueShown = -1
    m.caption.visible = false
end sub

' ask whether the tape on air has words written down for it
sub askCaptions()
    e = m.entry
    if e = invalid then return
    if m.capMode = "off" or e.kind <> "video" or e.tapeId = ""
        dropCaptions()
        return
    end if
    key = m.capMode + "|" + e.tapeId + "|" + e.file
    if key = m.capFor then return        ' same tape as before: keep what we have
    m.cues = []
    m.capFor = key
    m.capState = "looking"
    m.capSeq = m.capSeq + 1
    hideCaption()
    updateCcBadge()
    m.capTask.request = { seq: m.capSeq, tapeId: e.tapeId, file: e.file, capKey: e.capKey, index: m.subIndex, wide: (m.capMode = "on") }
end sub

sub onCaptions()
    r = m.capTask.result
    if r = invalid then return
    if r.seq <> m.capSeq then return
    m.cues = r.cues
    m.cueShown = -2
    if m.cues.Count() > 0
        m.capState = "ready"
        ' say once where each kind of caption comes from
        if r.credit <> "" and not m.credited.DoesExist(r.source)
            m.credited[r.source] = true
            showToast(r.credit, 5000)
        end if
    else
        m.capState = "none"
    end if
    updateCcBadge()
end sub

sub updateCcBadge()
    lit = false
    note = "OFF"
    if m.capMode <> "off"
        if m.capState = "ready"
            lit = true
            note = "ON"
        else if m.capState = "looking"
            note = "LOOKING"
        else
            note = "NONE HERE"
        end if
    end if
    m.ccNote.text = note
    if lit
        m.ccBox.color = "0xFFA630FF"
        m.ccMark.color = "0x120E1FFF"
    else
        m.ccBox.color = "0x3A3157FF"
        m.ccMark.color = "0xA99FBFFF"
    end if
end sub

' the caption for this instant, drawn only when it changes
sub drawCaption()
    show = (m.cues.Count() > 0 and m.mode = "live" and m.videoShown and not m.card.visible and m.posS >= 0)
    if not show
        hideCaption()
        return
    end if
    secs = m.posS
    if m.video.state = "playing"
        ahead = (nowMs() - m.posAt) / 1000
        if ahead > 1.5 then ahead = 1.5
        secs = secs + ahead
    end if
    i = CapCueAt(m.cues, Int(secs * 1000))
    low = not m.banner.visible
    if i = m.cueShown and low = m.capLow then return
    if i < 0
        hideCaption()
        return
    end if
    if i <> m.cueShown then m.capText.text = m.cues[i].text
    m.cueShown = i
    m.capLow = low
    r = m.capText.boundingRect()
    h = r.height
    if h <= 0 then h = 40 * (m.cues[i].text.Split(Chr(10)).Count())
    w = r.width
    if w <= 0 or w > 920 then w = 920
    bottom = 664
    if not low then bottom = 436
    m.capText.translation = [180, 10]
    m.capPlate.translation = [640 - w / 2 - 24, 0]
    m.capPlate.width = w + 48
    m.capPlate.height = h + 20
    m.caption.translation = [0, bottom - h - 20]
    m.caption.visible = true
end sub

function capModeText() as String
    if m.capMode = "on" then return "ON"
    if m.capMode = "translated" then return "TRANSLATIONS"
    return "OFF"
end function

sub nextCapMode()
    if m.capMode = "on"
        m.capMode = "translated"
    else if m.capMode = "translated"
        m.capMode = "off"
    else
        m.capMode = "on"
    end if
    m.task.request = { cmd: "save", key: "captions", value: m.capMode }
    m.capFor = ""
    askCaptions()
    updateCcBadge()
end sub

' ---- cards -------------------------------------------------------------------------

function stripeColor() as String
    c = channel()
    if c = invalid then return "0xFFA630FF"
    return colorOf(c.color)
end function

' a card that belongs to the channel: its logo and number up top
sub showCard(big as String, small as String)
    c = channel()
    m.cardStripe.color = stripeColor()
    if c <> invalid
        m.cardLogo.mark = markOf(c)
        m.cardDial.text = dialText(c)
        m.cardChannel.text = c.name
        m.cardHead.visible = true
    else
        m.cardHead.visible = false
    end if
    m.cardCat.visible = false
    m.cardText.translation = [140, 150]
    m.cardText.height = 380
    m.cardSub.translation = [140, 560]
    m.cardText.text = big
    m.cardSub.text = small
    m.card.visible = true
end sub

' a card from Meowbox itself, before any channel is known
sub showMessage(big as String, small as String)
    m.cardStripe.color = "0xFFA630FF"
    m.cardHead.visible = false
    m.cardCat.visible = true
    m.cardText.translation = [140, 392]
    m.cardText.height = 80
    m.cardSub.translation = [140, 486]
    m.cardText.text = big
    m.cardSub.text = small
    m.card.visible = true
end sub

function musicCredit(e as Object) as String
    if e.music = invalid then return ""
    if e.music.title = invalid then return ""
    if e.music.title = "" then return ""
    s = "Music: " + e.music.title
    if e.music.artist <> invalid
        if e.music.artist <> "" then s = s + " by " + e.music.artist
    end if
    return s
end function

' the card for the record on air, at the right moment within it
sub drawCard()
    e = m.entry
    if e = invalid then return
    c = channel()
    if e.kind = "upnext"
        if m.slideAt = 0 then return
        m.slideAt = 0
        lines = ""
        if e.upcoming <> invalid
            labels = ["Next", "Later"]
            for i = 0 to e.upcoming.Count() - 1
                if i < 2
                    if lines <> "" then lines = lines + Chr(10)
                    lines = lines + labels[i] + ":   " + e.upcoming[i].title
                end if
            end for
        end if
        showCard("UP NEXT", lines)
        return
    end if
    if e.kind <> "bump" then return
    at = e.offsetMs + (nowMs() - m.entryAt)
    index = -1
    acc = 0
    for i = 0 to e.slides.Count() - 1
        acc = acc + e.slides[i].ms
        if at < acc
            index = i
            exit for
        end if
    end for
    if index = m.slideAt and m.card.visible then return
    m.slideAt = index
    text = ""
    if index >= 0
        s = e.slides[index]
        if s.who = "intro"
            text = c.name
        else
            text = s.text
        end if
    end if
    showCard(text, musicCredit(e))
end sub

' ---- banner ------------------------------------------------------------------------

sub showBanner(ms as Integer)
    updateBanner()
    m.banner.visible = true
    m.bannerUntil = nowMs() + ms
end sub

function minutesText(seconds as Integer) as String
    if seconds < 60 then return "under a minute"
    mins = seconds \ 60
    if mins < 60 then return mins.ToStr() + " min"
    h = mins \ 60
    r = mins mod 60
    if r = 0 then return h.ToStr() + " h"
    return h.ToStr() + " h " + r.ToStr() + " min"
end function

' "9:42 PM", by this box's clock and time zone
function clockText() as String
    dt = CreateObject("roDateTime")
    dt.ToLocalTime()
    h = dt.GetHours()
    half = "AM"
    if h >= 12 then half = "PM"
    h = h mod 12
    if h = 0 then h = 12
    mins = dt.GetMinutes().ToStr()
    if Len(mins) < 2 then mins = "0" + mins
    return h.ToStr() + ":" + mins + " " + half
end function

' how far through a record of this length we are, 0 to 1
function shareDone(offsetMs as Integer, durMs as Integer, sinceMs as Integer) as Float
    if durMs <= 0 then return 0
    f = (offsetMs + sinceMs) / durMs
    if f < 0 then f = 0
    if f > 1 then f = 1
    return f
end function

sub updateBanner()
    c = channel()
    if c = invalid then return
    m.bannerStripe.color = colorOf(c.color)
    m.bannerLogo.mark = markOf(c)
    m.bannerDial.text = c.dial.ToStr()
    m.bannerChannel.text = c.name
    t = clockText()
    if t <> m.clockText
        m.clockText = t
        m.bannerClock.text = t
    end if
    e = m.entry
    if e = invalid
        m.bannerTitle.text = ""
        m.bannerTime.text = ""
        m.bannerNext.text = ""
        m.bannerNextLabel.visible = false
        m.bannerBar.width = 0
        return
    end if
    title = e.title
    if e.kind = "bump" then title = "Back in a moment"
    if e.kind = "upnext" then title = "Up next"
    if e.year <> invalid
        if e.year <> "" and e.kind = "video" then title = title + "  (" + e.year + ")"
    end if
    if m.bannerTitle.text <> title then m.bannerTitle.text = title
    since = nowMs() - m.entryAt
    left = (e.durMs - e.offsetMs - since) \ 1000
    if left < 0 then left = 0
    m.bannerTime.text = minutesText(left) + " left"
    m.bannerBar.width = Int(560 * shareDone(e.offsetMs, e.durMs, since))
    nextUp = ""
    if e.upcoming <> invalid
        if e.upcoming.Count() > 0 then nextUp = e.upcoming[0].title
    end if
    m.bannerNextLabel.visible = (nextUp <> "")
    if m.bannerNext.text <> nextUp then m.bannerNext.text = nextUp
end sub

sub onBlurb()
    b = m.task.blurb
    if b = invalid then return
    if b.key = m.blurbKey then m.bannerBlurb.text = b.text
end sub

sub showToast(text as String, ms as Integer)
    m.toastText.text = text
    m.toast.visible = true
    m.toastUntil = nowMs() + ms
end sub

' ---- the clock ---------------------------------------------------------------------

sub onTick()
    now = nowMs()
    if m.toast.visible and now > m.toastUntil then m.toast.visible = false
    if m.banner.visible
        if now > m.bannerUntil
            m.banner.visible = false
        else
            updateBanner()
        end if
    end if
    drawCaption()
    if m.mode = "guide" then updateGuideBar()
    if m.retryAt > 0 and now > m.retryAt
        m.retryAt = 0
        if m.channels.Count() = 0
            m.task.request = { cmd: "lineup" }
        else
            askNow("")
        end if
        return
    end if
    e = m.entry
    if e = invalid then return
    if e.kind = "bump" or e.kind = "upnext" then drawCard()
    left = e.durMs - e.offsetMs - (now - m.entryAt)
    if left <= 0 and not m.asked then askNow(e.endMs)
    ' the worker has been silent for a long while after a hand-over: ask again
    if left < -20000 and m.asked
        m.asked = false
    end if
end sub

' ---- guide -------------------------------------------------------------------------

sub openGuide()
    m.menu.visible = false
    m.guide.visible = true
    m.mode = "guide"
    m.guideList.jumpToItem = m.chIndex
    m.guideList.setFocus(true)
    describeGuideRow(m.chIndex)
end sub

sub closeOverlays()
    m.guide.visible = false
    m.menu.visible = false
    m.mode = "live"
    m.top.setFocus(true)
end sub

function familyText(f as Dynamic) as String
    if f = invalid then return ""
    if f = "" then return ""
    return "   ·   " + UCase(f.Replace("-", " "))
end function

sub describeGuideRow(i as Integer)
    if i < 0 or i >= m.channels.Count() then return
    c = m.channels[i]
    m.guideStripe.color = colorOf(c.color)
    m.guideLogo.mark = markOf(c)
    m.guideDial.text = dialText(c) + familyText(c.family)
    m.guideName.text = c.name
    m.guideDesc.text = c.description
    m.guideNow.text = "..."
    m.guideNext.text = ""
    m.guideLeft.text = ""
    m.guideBar.width = 0
    m.peek = invalid
    m.peekSeq = m.peekSeq + 1
    m.task.request = { cmd: "peek", channelId: c.id, seq: m.peekSeq }
end sub

sub onGuideFocused()
    if m.mode = "guide" then describeGuideRow(m.guideList.itemFocused)
end sub

sub onPeek()
    p = m.task.peek
    if p = invalid then return
    if p.seq <> m.peekSeq then return
    if p.kind = "error"
        m.guideNow.text = "Schedule unavailable"
        return
    end if
    now = ""
    if p.kind = "video"
        now = p.title
        if p.year <> "" then now = now + "  (" + p.year + ")"
    else if p.kind = "ad"
        now = "Commercial break"
    else
        now = "Between shows"
    end if
    m.guideNow.text = now
    m.peek = p
    m.peekAt = nowMs()
    updateGuideBar()
    if p.upcoming <> invalid
        if p.upcoming.Count() > 0
            m.guideNext.text = p.upcoming[0].title + "   (in " + minutesText(p.upcoming[0].inS) + ")"
        end if
    end if
end sub

sub updateGuideBar()
    p = m.peek
    if p = invalid then return
    since = nowMs() - m.peekAt
    left = (p.durMs - p.offsetMs - since) \ 1000
    if left < 0 then left = 0
    m.guideLeft.text = minutesText(left) + " left"
    m.guideBar.width = Int(400 * shareDone(p.offsetMs, p.durMs, since))
end sub

sub onGuideSelected()
    i = m.guideList.itemSelected
    closeOverlays()
    if i <> m.chIndex
        tune(i)
    else
        showBanner(5000)
    end if
end sub

' ---- menu --------------------------------------------------------------------------

sub fillMenu()
    content = CreateObject("roSGNode", "ContentNode")
    for each item in [["Channel guide", ""], ["Captions", capModeText()], ["Re-sync this channel", ""], ["About", ""]]
        row = content.createChild("ContentNode")
        row.title = item[0]
        row.addFields({ value: item[1] })
    end for
    m.menuList.content = content
end sub

sub openMenu()
    m.guide.visible = false
    m.menu.visible = true
    m.mode = "menu"
    m.menuList.jumpToItem = 0
    m.menuList.setFocus(true)
    describeMenuRow(0)
end sub

sub describeMenuRow(i as Integer)
    text = ""
    if i = 0
        text = "Every channel, and what is on it right now."
    else if i = 1
        if m.capMode = "on"
            text = "Shown whenever a tape has them, written by people or by machine."
        else if m.capMode = "translated"
            text = "English subtitles on tapes in other languages, and nothing else."
        else
            text = "No captions."
        end if
    else if i = 2
        text = "Jump back in step with everyone else watching."
    else if i = 3
        text = "Version 2.0. Unofficial. Video from the Internet Archive."
    end if
    m.menuHint.text = text
end sub

sub onMenuFocused()
    if m.mode = "menu" then describeMenuRow(m.menuList.itemFocused)
end sub

sub onMenuSelected()
    i = m.menuList.itemSelected
    if i = 1
        ' stay in the menu, so the setting can be stepped through
        nextCapMode()
        m.menuList.content.getChild(1).value = capModeText()
        describeMenuRow(1)
        return
    end if
    closeOverlays()
    if i = 0
        openGuide()
    else if i = 2
        if m.chIndex >= 0 then tune(m.chIndex)
    else if i = 3
        showToast("Meowbox 2.0  ·  an unofficial viewer for the channels at spelunkr.tv  ·  video from the Internet Archive  ·  captions from spelunkr.tv and the Archive", 9000)
    end if
end sub

' ---- remote --------------------------------------------------------------------------

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if m.mode = "guide" or m.mode = "menu"
        if key = "back" or key = "left"
            closeOverlays()
            return true
        else if key = "options"
            if m.mode = "menu"
                closeOverlays()
            else
                openMenu()
            end if
            return true
        end if
        return false
    end if

    ' watching
    if key = "up"
        tune(m.chIndex + 1)
    else if key = "down"
        tune(m.chIndex - 1)
    else if key = "OK"
        if m.banner.visible
            m.banner.visible = false
        else
            showBanner(8000)
        end if
    else if key = "left" or key = "right"
        if m.channels.Count() > 0 then openGuide()
    else if key = "options"
        openMenu()
    else if key = "play"
        if m.chIndex >= 0 then tune(m.chIndex)
    else if key = "replay"
        nextCapMode()
        m.menuList.content.getChild(1).value = capModeText()
        showToast("Captions: " + LCase(capModeText()), 2500)
    else
        return false
    end if
    return true
end function
