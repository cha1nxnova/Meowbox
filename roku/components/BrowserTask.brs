sub init()
    m.top.functionName = "runLoop"
end sub

function Agent() as String
    return "Mozilla/5.0 (Roku; text reader) Meowbox/1.0"
end function

sub runLoop()
    port = CreateObject("roMessagePort")
    m.top.observeField("request", port)
    while true
        msg = wait(0, port)
        if type(msg) = "roSGNodeEvent"
            req = msg.getData()
            cmd = ""
            if req <> invalid
                if req.cmd <> invalid then cmd = req.cmd
            end if
            if cmd = "load"
                ' only the newest address matters
                if port.PeekMessage() = invalid then LoadPage(req.url, req.seq)
            else if cmd = "bookmarks"
                m.top.bookmarks = { list: ReadBookmarks() }
            else if cmd = "saveBookmarks"
                reg = CreateObject("roRegistrySection", "meowbox")
                reg.Write("bookmarks", FormatJson(req.list))
                reg.Flush()
                m.top.bookmarks = { list: req.list }
            end if
        end if
    end while
end sub

function ReadBookmarks() as Object
    reg = CreateObject("roRegistrySection", "meowbox")
    if reg.Exists("bookmarks")
        list = ParseJson(reg.Read("bookmarks"))
        if list <> invalid then return list
    end if
    return [
        { title: "Wikipedia", url: "https://en.wikipedia.org/wiki/Main_Page" }
        { title: "Hacker News", url: "https://news.ycombinator.com/" }
        { title: "NPR (text only)", url: "https://text.npr.org/" }
        { title: "CNN (lite)", url: "https://lite.cnn.com/" }
        { title: "Internet Archive", url: "https://archive.org/" }
        { title: "Spelunkr", url: "https://spelunkr.tv/about" }
    ]
end function

sub Fail(seq as Integer, url as String, message as String)
    m.top.result = { seq: seq, kind: "error", url: url, title: "", message: message }
end sub

function KindOfType(ctype as String) as String
    t = LCase(ctype)
    if Left(t, 6) = "image/" then return "image"
    if Left(t, 6) = "video/" or Left(t, 6) = "audio/" or Instr(1, t, "mpegurl") > 0 or Instr(1, t, "dash+xml") > 0 then return "media"
    if Instr(1, t, "html") > 0 then return "html"
    if Left(t, 5) = "text/" or Instr(1, t, "json") > 0 or Instr(1, t, "xml") > 0 then return "text"
    if t = "" then return "html"
    return "file"
end function

sub LoadPage(url as String, seq as Integer)
    sc = WebScheme(url)
    if sc <> "http" and sc <> "https"
        Fail(seq, url, "That is not a web address.")
        return
    end if
    guess = WebKindOf(url)
    if guess = "image" or guess = "media"
        m.top.result = { seq: seq, kind: guess, url: url, title: url, message: "" }
        return
    end if
    if guess = "file"
        ' ask what it is before fetching something that may be huge
        h = NetGet(url, 12000, { head: true, agent: Agent() })
        k = KindOfType(NetHeader(h.headers, "content-type"))
        if h.code = 200 and (k = "image" or k = "media")
            m.top.result = { seq: seq, kind: k, url: url, title: url, message: "" }
            return
        end if
        if h.code = 200 and k = "file"
            Fail(seq, url, "This is a file to download, not a page to read.")
            return
        end if
    end if

    r = NetGet(url, 25000, { agent: Agent() })
    if r.code <= 0
        Fail(seq, url, "The site did not answer. Check the address and the network connection.")
        return
    end if
    k = KindOfType(NetHeader(r.headers, "content-type"))
    if k = "image" or k = "media"
        m.top.result = { seq: seq, kind: k, url: url, title: url, message: "" }
        return
    end if
    if k = "file"
        Fail(seq, url, "This is a file to download, not a page to read.")
        return
    end if
    body = r.body
    if body = invalid then body = ""
    if Len(body) > 1500000 then body = Left(body, 1500000)
    if body.Trim() = ""
        Fail(seq, url, "The site answered with an empty page (code " + r.code.ToStr() + ").")
        return
    end if

    page = invalid
    if k = "text" and Instr(1, LCase(Left(body, 2000)), "<html") = 0
        page = WebPlainToPage(body, url, 96)
    else
        page = WebHtmlToPage(body, url, 96)
    end if
    if r.code >= 400
        page.lines.Unshift({ t: "", links: [] })
        page.lines.Unshift({ t: "(The site answered with error " + r.code.ToStr() + ".)", links: [] })
    end if

    rows = []
    for each ln in page.lines
        row = { title: ln.t }
        n = ln.links.Count()
        if n > 0
            row.url = ln.links[0].u
            if n > 1
                urls = []
                labels = []
                for each lk in ln.links
                    urls.Push(lk.u)
                    labels.Push(lk.label.Replace(Chr(10), " "))
                end for
                row.description = urls.Join(Chr(10))
                row.shortDescriptionLine1 = labels.Join(Chr(10))
            end if
        end if
        rows.Push(row)
    end for
    node = CreateObject("roSGNode", "ContentNode")
    node.update({ children: rows }, true)
    m.top.page = node
    m.top.result = { seq: seq, kind: "page", url: url, title: page.title, message: "" }
end sub
