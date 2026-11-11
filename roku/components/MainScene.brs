' The TV side: one channel on screen, kept in step with everyone else watching.
'
' The worker task answers "what is on this channel right now" with a small
' record (see BcDescribe). This file plays that record, counts down to its end
' on a local clock, then asks again.

sub init()
    m.video = m.top.findNode("video")
    m.music = m.top.findNode("music")
    m.card = m.top.findNode("card")
    m.cardStripe = m.top.findNode("cardStripe")
    m.cardChannel = m.top.findNode("cardChannel")
    m.cardText = m.top.findNode("cardText")
    m.cardSub = m.top.findNode("cardSub")
    m.banner = m.top.findNode("banner")
    m.bannerStripe = m.top.findNode("bannerStripe")
    m.bannerChannel = m.top.findNode("bannerChannel")
    m.bannerTitle = m.top.findNode("bannerTitle")
    m.bannerTime = m.top.findNode("bannerTime")
    m.bannerBlurb = m.top.findNode("bannerBlurb")
    m.guide = m.top.findNode("guide")
    m.guideList = m.top.findNode("guideList")
    m.guideStripe = m.top.findNode("guideStripe")
    m.guideName = m.top.findNode("guideName")
    m.guideDesc = m.top.findNode("guideDesc")
    m.guideNow = m.top.findNode("guideNow")
    m.guideNext = m.top.findNode("guideNext")
    m.menu = m.top.findNode("menu")
    m.menuList = m.top.findNode("menuList")
    m.browser = m.top.findNode("browser")
    m.toast = m.top.findNode("toast")
    m.tick = m.top.findNode("tick")

    ' video and music come over https
    for each node in [m.video, m.music]
        node.setCertificatesFile("common:/certs/ca-bundle.crt")
        node.initClientCertificates()
    end for
    m.video.enableTrickPlay = false

    m.clock = CreateObject("roTimespan")
    m.mode = "live"          ' live | guide | menu | browser
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

    m.menuItems = ["Channel guide", "Web browser", "Re-sync this channel", "About"]
    menuContent = CreateObject("roSGNode", "ContentNode")
    for each t in m.menuItems
        row = menuContent.createChild("ContentNode")
        row.title = t
    end for
    m.menuList.content = menuContent

    m.video.observeField("state", "onVideoState")
    m.guideList.observeField("itemSelected", "onGuideSelected")
    m.guideList.observeField("itemFocused", "onGuideFocused")
    m.menuList.observeField("itemSelected", "onMenuSelected")
    m.browser.observeField("closed", "onBrowserClosed")
    m.tick.observeField("fire", "onTick")

    m.task = CreateObject("roSGNode", "BroadcastTask")
    m.task.observeField("lineup", "onLineup")
    m.task.observeField("onAir", "onOnAir")
    m.task.observeField("peek", "onPeek")
    m.task.observeField("blurb", "onBlurb")
    m.task.observeField("found", "onFound")
    m.task.control = "run"

    showMessage("MEOWBOX", "Fetching the channel lineup...", "0x888888FF")
    m.tick.control = "start"
    m.top.setFocus(true)
end sub

function nowMs() as Integer
    return m.clock.TotalMilliseconds()
end function

function colorOf(hex as Dynamic) as String
    if hex = invalid then return "0x888888FF"
    h = hex.Replace("#", "")
    if Len(h) <> 6 then return "0x888888FF"
    return "0x" + UCase(h) + "FF"
end function

function channel() as Dynamic
    if m.chIndex < 0 or m.chIndex >= m.channels.Count() then return invalid
    return m.channels[m.chIndex]
end function

function channelLine(c as Object) as String
    return c.dial.ToStr() + "   " + c.name
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
        showMessage("NO SIGNAL", msg + " Trying again shortly.", "0x888888FF")
        m.retryAt = nowMs() + 15000
        m.entry = invalid
        return
    end if

    current = ""
    c = channel()
    if c <> invalid then current = c.id
    first = (m.channels.Count() = 0)
    m.channels = data.channels

    content = CreateObject("roSGNode", "ContentNode")
    for each ch in m.channels
        row = content.createChild("ContentNode")
        row.title = channelLine(ch)
    end for
    m.guideList.content = content

    if first
        want = 0
        for i = 0 to m.channels.Count() - 1
            if m.channels[i].id = data.last then want = i
        end for
        tune(want)
    else
        ' a refreshed lineup: stay where we are
        m.chIndex = 0
        for i = 0 to m.channels.Count() - 1
            if m.channels[i].id = current then m.chIndex = i
        end for
        if m.channels[m.chIndex].id <> current and m.mode <> "browser" then tune(m.chIndex)
    end if
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
end sub

sub onOnAir()
    e = m.task.onAir
    if e = invalid then return
    if e.seq <> m.seq or m.mode = "browser" then return
    m.asked = false
    if e.kind = "error"
        stopPlayback()
        m.entry = invalid
        showMessage("NO SIGNAL", e.message + " Trying again shortly.", stripeColor())
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
            startVideo(e.url, e.seekS)
        end if
        if e.kind = "video" and e.videoIndex >= 0
            m.blurbKey = e.channelId + ":" + e.key
            m.task.request = { cmd: "blurb", channelId: e.channelId, version: e.version, videoIndex: e.videoIndex, key: m.blurbKey }
        end if
    else
        m.video.control = "stop"
        m.videoShown = false
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
    if m.mode = "browser" or m.entry = invalid then return
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

sub tapeTrouble()
    showCard(channel().name, "This tape isn't answering right now. The next show starts on time.")
end sub

sub onFound()
    f = m.task.found
    if f = invalid or m.entry = invalid then return
    if f.seq <> m.seq or m.mode = "browser" then return
    if f.url = "" or f.url = m.entry.url
        tapeTrouble()
        return
    end if
    m.entry.url = f.url
    m.triedFind = true
    m.fixed = false
    startVideo(f.url, expectedPosition())
end sub

' ---- cards -------------------------------------------------------------------------

function stripeColor() as String
    c = channel()
    if c = invalid then return "0x888888FF"
    return colorOf(c.color)
end function

sub showCard(big as String, small as String)
    c = channel()
    m.cardStripe.color = stripeColor()
    if c <> invalid
        m.cardChannel.text = channelLine(c)
    else
        m.cardChannel.text = ""
    end if
    m.cardText.text = big
    m.cardSub.text = small
    m.card.visible = true
end sub

sub showMessage(big as String, small as String, color as String)
    m.cardStripe.color = color
    m.cardChannel.text = ""
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
            labels = ["NEXT", "LATER"]
            for i = 0 to e.upcoming.Count() - 1
                if i < 2
                    if lines <> "" then lines = lines + Chr(10)
                    lines = lines + labels[i] + "   " + e.upcoming[i].title
                end if
            end for
        end if
        showCard("UP NEXT ON " + c.name, lines)
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

sub updateBanner()
    c = channel()
    if c = invalid then return
    m.bannerStripe.color = colorOf(c.color)
    m.bannerChannel.text = channelLine(c)
    e = m.entry
    if e = invalid
        m.bannerTitle.text = ""
        m.bannerTime.text = ""
        return
    end if
    title = e.title
    if e.kind = "bump" then title = "Back in a moment"
    if e.kind = "upnext" then title = "Up next"
    if e.year <> invalid
        if e.year <> "" and e.kind = "video" then title = title + "  (" + e.year + ")"
    end if
    m.bannerTitle.text = title
    left = (e.durMs - e.offsetMs - (nowMs() - m.entryAt)) \ 1000
    if left < 0 then left = 0
    line = minutesText(left) + " left"
    if e.upcoming <> invalid
        if e.upcoming.Count() > 0 then line = line + "   ·   Next: " + e.upcoming[0].title
    end if
    m.bannerTime.text = line
end sub

sub onBlurb()
    b = m.task.blurb
    if b = invalid then return
    if b.key = m.blurbKey then m.bannerBlurb.text = b.text
end sub

sub showToast(text as String, ms as Integer)
    m.toast.text = text
    m.toast.visible = true
    m.toastUntil = nowMs() + ms
end sub

' ---- the clock ---------------------------------------------------------------------

sub onTick()
    now = nowMs()
    if m.toast.visible and now > m.toastUntil then m.toast.visible = false
    if m.mode = "browser" then return
    if m.banner.visible
        if now > m.bannerUntil
            m.banner.visible = false
        else
            updateBanner()
        end if
    end if
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

' ---- guide and menu ------------------------------------------------------------------

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

sub describeGuideRow(i as Integer)
    if i < 0 or i >= m.channels.Count() then return
    c = m.channels[i]
    m.guideStripe.color = colorOf(c.color)
    m.guideName.text = c.name
    m.guideDesc.text = c.description
    m.guideNow.text = "..."
    m.guideNext.text = ""
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
    now = "On now: "
    if p.kind = "video"
        now = now + p.title
        if p.year <> "" then now = now + "  (" + p.year + ")"
    else if p.kind = "ad"
        now = now + "commercial break"
    else
        now = now + "between shows"
    end if
    m.guideNow.text = now
    if p.upcoming <> invalid
        if p.upcoming.Count() > 0
            m.guideNext.text = "Next, in " + minutesText(p.upcoming[0].inS) + ": " + p.upcoming[0].title
        end if
    end if
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

sub openMenu()
    m.guide.visible = false
    m.menu.visible = true
    m.mode = "menu"
    m.menuList.jumpToItem = 0
    m.menuList.setFocus(true)
end sub

sub onMenuSelected()
    i = m.menuList.itemSelected
    closeOverlays()
    if i = 0
        openGuide()
    else if i = 1
        openBrowser()
    else if i = 2
        if m.chIndex >= 0 then tune(m.chIndex)
    else if i = 3
        showToast("Meowbox 1.0  ·  an unofficial viewer for the channels at spelunkr.tv  ·  video from the Internet Archive", 9000)
    end if
end sub

' ---- browser -------------------------------------------------------------------------

sub openBrowser()
    stopPlayback()
    m.entry = invalid
    m.retryAt = 0
    m.seq = m.seq + 1
    m.card.visible = false
    m.banner.visible = false
    m.mode = "browser"
    m.browser.visible = true
    m.browser.active = true
end sub

sub onBrowserClosed()
    m.browser.active = false
    m.browser.visible = false
    m.mode = "live"
    m.top.setFocus(true)
    if m.chIndex >= 0
        tune(m.chIndex)
    else
        showMessage("MEOWBOX", "Fetching the channel lineup...", "0x888888FF")
        m.task.request = { cmd: "lineup" }
    end if
end sub

' ---- remote --------------------------------------------------------------------------

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if m.mode = "browser" then return false

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
    else if key = "play" or key = "replay"
        if m.chIndex >= 0 then tune(m.chIndex)
    else
        return false
    end if
    return true
end function
