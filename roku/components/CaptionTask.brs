sub init()
    m.top.functionName = "runLoop"
end sub

sub runLoop()
    port = CreateObject("roMessagePort")
    m.top.observeField("request", port)
    ' indexPath/tapes: the website's subtitle index, re-read when the lineup names a new one
    ' archive: tape id -> the caption files that tape has, so a tape is asked about once
    st = { indexPath: "", tapes: invalid, archive: {}, held: 0 }
    while true
        msg = wait(0, port)
        if type(msg) = "roSGNodeEvent"
            req = msg.getData()
            ' a newer request is already waiting: this one is stale
            if req <> invalid and port.PeekMessage() = invalid
                out = FindCaptions(st, req)
                out.seq = req.seq
                out.credit = CapCredit(out.source)
                m.top.result = out
            end if
        end if
    end while
end sub

' JSON from the lineup's home, live copy first and the website's snapshot second
function SiteJson(path as String) as Dynamic
    for each base in ["https://data.spelunkr.tv/", "https://spelunkr.tv/broadcast/"]
        r = NetGet(base + path, 12000)
        if r.code = 200
            if Left(r.body.Trim(), 1) = "{"
                j = ParseJson(r.body)
                if j <> invalid then return j
            end if
        end if
    end for
    return invalid
end function

function FindCaptions(st as Object, req as Object) as Object
    none = { cues: [], source: "" }
    if req.tapeId = invalid or req.tapeId = "" then return none

    ' 1. the website's own subtitles
    index = ""
    if req.index <> invalid then index = req.index
    if index <> st.indexPath
        st.indexPath = index
        st.tapes = invalid
        if CreateObject("roRegex", "^subtitles/index-[0-9a-f]{16}\.json$", "").IsMatch(index)
            j = SiteJson(index)
            if j <> invalid
                if type(j.tapes) = "roAssociativeArray" then st.tapes = j.tapes
            end if
            ' not read this time: ask again with the next show
            if st.tapes = invalid then st.indexPath = ""
        end if
    end if
    if st.tapes <> invalid and req.capKey <> invalid
        ' Lookup, not [], because tape names differ only by capitals now and then
        st.tapes.SetModeCaseSensitive()
        row = st.tapes.Lookup(req.capKey)
        if type(row) = "roAssociativeArray"
            if type(row.file) = "roString" or type(row.file) = "String"
                if CreateObject("roRegex", "^subtitles/[0-9a-f]{16}\.json$", "").IsMatch(row.file)
                    j = SiteJson(row.file)
                    if j <> invalid
                        ' the file says which video it was written for: believe it
                        same = true
                        if j.file <> invalid and req.file <> invalid
                            if req.file <> "" then same = (j.file = req.file)
                        end if
                        cues = CapFromSite(j)
                        if same and cues.Count() > 0
                            source = "site-archive"
                            if row.source = "machine" then source = "site-machine"
                            return { cues: cues, source: source }
                        end if
                    end if
                end if
            end if
        end if
    end if

    ' 2. caption files next to the video on the Internet Archive
    wide = false
    if req.wide <> invalid then wide = req.wide
    if not wide or req.file = invalid or req.file = "" then return none
    st.archive.SetModeCaseSensitive()
    files = st.archive.Lookup(req.tapeId)
    if files = invalid
        r = NetGet("https://archive.org/metadata/" + BcEscape(req.tapeId) + "/files", 12000)
        if r.code <> 200 then return none
        j = ParseJson(r.body)
        if type(j) <> "roAssociativeArray" then return none
        files = []
        if type(j.result) = "roArray"
            for each f in j.result
                if type(f) = "roAssociativeArray"
                    if type(f.name) = "roString" or type(f.name) = "String"
                        ext = LCase(Right(f.name, 4))
                        if ext = ".srt" or ext = ".vtt" then files.Push({ name: f.name, size: f.size })
                    end if
                end if
            end for
        end if
        ' a short memory is plenty: the same tapes come round within a channel
        if st.held >= 60
            st.archive = {}
            st.archive.SetModeCaseSensitive()
            st.held = 0
        end if
        st.archive[req.tapeId] = files
        st.held = st.held + 1
    end if
    pick = CapPickArchive(files, req.file)
    if pick = invalid then return none
    r = NetGet(BcTapeUrl(req.tapeId, pick.name), 15000)
    if r.code <> 200 then return none
    cues = CapParseTimed(r.body)
    if cues.Count() = 0 then return none
    source = "ia-person"
    if pick.machine then source = "ia-machine"
    return { cues: cues, source: source }
end function
