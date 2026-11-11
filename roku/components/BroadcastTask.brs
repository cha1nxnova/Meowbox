sub init()
    m.top.functionName = "runLoop"
end sub

' Where the published lineup lives. The first is the live copy; the second is
' the snapshot the website itself falls back to. Paths are the same on both.
function NewFetcher() as Object
    return {
        bases: ["https://data.spelunkr.tv/", "https://spelunkr.tv/broadcast/"]
        skipFirst: 0
        dateSeconds: 0
        dateAtMs: 0&
        getJson: function(path as String) as Dynamic
            for i = 0 to m.bases.Count() - 1
                skip = false
                if i = 0 and m.skipFirst > 0
                    m.skipFirst = m.skipFirst - 1
                    skip = true
                end if
                if not skip
                    r = NetGet(m.bases[i] + path, 15000)
                    if r.code = 200
                        first = Left(r.body.Trim(), 1)
                        if first = "{" or first = "["
                            j = ParseJson(r.body)
                            if j <> invalid
                                d = NetDateSeconds(NetHeader(r.headers, "date"))
                                if d > 0
                                    m.dateSeconds = d
                                    m.dateAtMs = SpkNowMs()
                                end if
                                return j
                            end if
                        end if
                    end if
                    ' the live copy did not answer: leave it alone for a while
                    if i = 0 then m.skipFirst = 400
                end if
            end for
            return invalid
        end function
    }
end function

' If this box's clock is off, lean on the server's (to the second)
sub UpdateSkew(st as Object)
    f = st.fetcher
    if f.dateSeconds = 0 then return
    server& = f.dateSeconds
    server& = server& * 1000& + 500&
    skew& = server& - f.dateAtMs
    if skew& > 2500& or skew& < -2500&
        st.skewMs = skew&
    else
        st.skewMs = 0&
    end if
end sub

sub SendLineup(st as Object, err as String)
    reg = CreateObject("roRegistrySection", "meowbox")
    last = ""
    if reg.Exists("lastChannel") then last = reg.Read("lastChannel")
    m.top.lineup = { channels: BcChannelList(st), last: last, error: err }
end sub

sub runLoop()
    port = CreateObject("roMessagePort")
    m.top.observeField("request", port)
    st = BcNew(NewFetcher())
    lineupAt& = 0&

    err = BcLoadLineup(st)
    UpdateSkew(st)
    if err = "" then lineupAt& = SpkNowMs()
    SendLineup(st, err)

    while true
        msg = wait(0, port)
        if type(msg) = "roSGNodeEvent"
            req = msg.getData()
            cmd = ""
            if req <> invalid
                if req.cmd <> invalid then cmd = req.cmd
            end if

            if cmd = "lineup"
                err = BcLoadLineup(st)
                UpdateSkew(st)
                if err = "" then lineupAt& = SpkNowMs()
                SendLineup(st, err)

            else if cmd = "tune"
                t& = BcNow(st)
                if req.at <> invalid
                    if req.at <> ""
                        at& = SpkLong(req.at)
                        if at& > t& then t& = at&
                    end if
                end if
                out = BcDescribe(st, req.channelId, t&)
                out.seq = req.seq
                if out.kind = "video" and out.url = "" and out.lookupId <> ""
                    out.url = FindTape(out.lookupId)
                end if
                m.top.onAir = out
                ' keep the lineup fresh: new playlists are published through it
                if SpkNowMs() - lineupAt& > 600000&
                    lineupAt& = SpkNowMs()
                    if BcLoadLineup(st) = ""
                        UpdateSkew(st)
                        SendLineup(st, "")
                    end if
                end if

            else if cmd = "peek"
                ' a newer request is already waiting: this one is stale
                if port.PeekMessage() = invalid
                    out = BcDescribe(st, req.channelId, BcNow(st))
                    out.seq = req.seq
                    m.top.peek = out
                end if

            else if cmd = "blurb"
                text = BcBlurb(st, req.channelId, req.version, req.videoIndex)
                m.top.blurb = { key: req.key, text: text }

            else if cmd = "find"
                m.top.found = { seq: req.seq, url: FindTape(req.id) }

            else if cmd = "save"
                reg = CreateObject("roRegistrySection", "meowbox")
                reg.Write(req.key, req.value)
                reg.Flush()
            end if
        end if
    end while
end sub

' Ask the Internet Archive which file of a tape a TV can play
function FindTape(id as String) as String
    r = NetGet("https://archive.org/metadata/" + BcEscape(id), 10000)
    if r.code <> 200 then return ""
    meta = ParseJson(r.body)
    name = BcPickArchiveFile(meta)
    if name = "" then return ""
    return BcTapeUrl(id, name)
end function
