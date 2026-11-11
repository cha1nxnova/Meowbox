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
