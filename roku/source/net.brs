' One HTTP request, waited for with a time limit.
' Returns { code, body, headers }. code is 0 or negative when nothing came back.
' opts (all optional): head (Boolean), agent (String), toFile (String)
function NetGet(url as String, timeoutMs as Integer, opts = invalid as Dynamic) as Object
    out = { code: 0, body: "", headers: {} }
    x = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    x.SetMessagePort(port)
    x.SetUrl(url)
    if LCase(Left(url, 6)) = "https:"
        x.SetCertificatesFile("common:/certs/ca-bundle.crt")
        x.InitClientCertificates()
    end if
    x.EnableEncodings(true)
    x.RetainBodyOnError(true)
    x.EnableCookies()
    head = false
    if opts <> invalid
        if opts.agent <> invalid then x.AddHeader("User-Agent", opts.agent)
        if opts.head <> invalid then head = opts.head
    end if
    started = false
    if head
        started = x.AsyncHead()
    else
        started = x.AsyncGetToString()
    end if
    if not started then return out
    msg = wait(timeoutMs, port)
    if type(msg) = "roUrlEvent"
        out.code = msg.GetResponseCode()
        if not head then out.body = msg.GetString()
        h = msg.GetResponseHeaders()
        if h <> invalid then out.headers = h
    else
        x.AsyncCancel()
        out.code = -1
    end if
    return out
end function

' One JSON POST, waited for with a time limit. Returns the HTTP code, or 0 /
' negative when nothing came back.
function NetPostJson(url as String, body as String, timeoutMs as Integer) as Integer
    x = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    x.SetMessagePort(port)
    x.SetUrl(url)
    if LCase(Left(url, 6)) = "https:"
        x.SetCertificatesFile("common:/certs/ca-bundle.crt")
        x.InitClientCertificates()
    end if
    x.AddHeader("Content-Type", "application/json")
    if not x.AsyncPostFromString(body) then return 0
    msg = wait(timeoutMs, port)
    if type(msg) = "roUrlEvent" then return msg.GetResponseCode()
    x.AsyncCancel()
    return -1
end function

' a header by name whatever its capitals, "" when absent
function NetHeader(headers as Object, name as String) as String
    want = LCase(name)
    for each k in headers
        if LCase(k) = want
            v = headers[k]
            if v <> invalid then return v
        end if
    end for
    return ""
end function

' "Wed, 11 Nov 2026 00:38:35 GMT" as seconds since 1970, 0 when it cannot be read
function NetDateSeconds(s as String) as Integer
    parts = CreateObject("roRegex", "[\s,]+", "").Split(s.Trim())
    if parts.Count() < 5 then return 0
    months = { jan: "01", feb: "02", mar: "03", apr: "04", may: "05", jun: "06", jul: "07", aug: "08", sep: "09", oct: "10", nov: "11", dec: "12" }
    mo = months[LCase(parts[2])]
    if mo = invalid then return 0
    day = parts[1]
    if Len(day) = 1 then day = "0" + day
    dt = CreateObject("roDateTime")
    dt.FromISO8601String(parts[3] + "-" + mo + "-" + day + "T" + parts[4] + "Z")
    return dt.AsSeconds()
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
