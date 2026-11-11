sub init()
    m.pageTitle = m.top.findNode("pageTitle")
    m.pageUrl = m.top.findNode("pageUrl")
    m.lines = m.top.findNode("lines")
    m.popup = m.top.findNode("popup")
    m.popupTitle = m.top.findNode("popupTitle")
    m.popupList = m.top.findNode("popupList")
    m.imageView = m.top.findNode("imageView")
    m.image = m.top.findNode("image")
    m.imageNote = m.top.findNode("imageNote")
    m.media = m.top.findNode("media")
    m.media.setCertificatesFile("common:/certs/ca-bundle.crt")
    m.media.initClientCertificates()

    m.history = []           ' addresses behind the current one, with the line each was left on
    m.url = ""               ' "" is the start page
    m.seq = 0
    m.bookmarks = []
    m.popupKind = ""         ' "menu" | "links"
    m.popupData = []
    m.restoreLine = 0
    m.ask = invalid          ' what the open keyboard is for
    m.started = false

    m.lines.observeField("itemSelected", "onLineSelected")
    m.popupList.observeField("itemSelected", "onPopupSelected")
    m.media.observeField("state", "onMediaState")

    m.task = CreateObject("roSGNode", "BrowserTask")
    m.task.observeField("result", "onResult")
    m.task.observeField("bookmarks", "onBookmarks")
    m.task.control = "run"
    m.task.request = { cmd: "bookmarks" }
end sub

sub onActive()
    if m.top.active
        if not m.started
            m.started = true
            showHome()
        end if
        focusPage()
    else
        stopMedia()
        m.popup.visible = false
        m.imageView.visible = false
    end if
end sub

sub focusPage()
    m.lines.setFocus(true)
end sub

' ---- the start page ------------------------------------------------------------------

sub onBookmarks()
    b = m.task.bookmarks
    if b = invalid then return
    if b.list <> invalid then m.bookmarks = b.list
    if m.url = "" and m.started then showHome()
end sub

sub showHome()
    m.url = ""
    m.pageTitle.text = "Meowbox Web"
    m.pageUrl.text = "A reading browser: text and links, no scripts or styles."
    rows = [
        { title: "[Search the web]", url: "meow:search" }
        { title: "[Go to an address]", url: "meow:goto" }
        { title: "" }
        { title: "Bookmarks" }
    ]
    for each b in m.bookmarks
        rows.Push({ title: "  [" + b.title + "]", url: b.url })
    end for
    rows.Push({ title: "" })
    rows.Push({ title: "Pages are read, not rendered. Sites that are built entirely by scripts will come up empty;" })
    rows.Push({ title: "news sites' text or lite editions, wikis, forums and search results work well." })
    rows.Push({ title: "Links to pictures open full screen. Links to video or audio files play." })
    node = CreateObject("roSGNode", "ContentNode")
    node.update({ children: rows }, true)
    m.lines.content = node
    m.lines.jumpToItem = 0
end sub

' ---- going places --------------------------------------------------------------------

sub go(url as String, remember as Boolean)
    if url = "" then return
    if Left(url, 5) = "meow:"
        special(url)
        return
    end if
    kind = WebKindOf(url)
    if kind = "image"
        showImage(url)
        return
    else if kind = "media"
        playMedia(url)
        return
    end if
    if remember then m.history.Push({ url: m.url, line: m.lines.itemFocused })
    m.restoreLine = 0
    load(url)
end sub

sub load(url as String)
    m.url = url
    m.seq = m.seq + 1
    m.pageTitle.text = "Loading..."
    m.pageUrl.text = url
    m.task.request = { cmd: "load", url: url, seq: m.seq }
end sub

sub goBack()
    if m.history.Count() = 0
        m.top.closed = true
        return
    end if
    prev = m.history.Pop()
    m.restoreLine = prev.line
    if prev.url = ""
        m.seq = m.seq + 1
        showHome()
        m.lines.jumpToItem = prev.line
    else
        load(prev.url)
    end if
end sub

sub onResult()
    r = m.task.result
    if r = invalid then return
    if r.seq <> m.seq then return
    if r.kind = "page"
        m.pageTitle.text = r.title
        m.pageUrl.text = r.url
        m.lines.content = m.task.page
        line = m.restoreLine
        if line < 0 then line = 0
        m.lines.jumpToItem = line
        m.restoreLine = 0
        if not m.popup.visible and not m.imageView.visible then focusPage()
    else if r.kind = "image"
        stepBackQuietly()
        showImage(r.url)
    else if r.kind = "media"
        stepBackQuietly()
        playMedia(r.url)
    else
        m.pageTitle.text = "Could not open this page"
        rows = [
            { title: r.message }
            { title: "" }
            { title: "[Try again]", url: r.url }
            { title: "[Search the web]", url: "meow:search" }
        ]
        node = CreateObject("roSGNode", "ContentNode")
        node.update({ children: rows }, true)
        m.lines.content = node
        m.lines.jumpToItem = 0
    end if
end sub

' the address turned out not to be a page: the page we came from is still on screen
sub stepBackQuietly()
    if m.history.Count() > 0
        prev = m.history.Pop()
        m.url = prev.url
    end if
    if m.url = ""
        m.pageTitle.text = "Meowbox Web"
        m.pageUrl.text = ""
    else
        m.pageTitle.text = m.url
        m.pageUrl.text = m.url
    end if
end sub

sub special(url as String)
    if url = "meow:search"
        askFor("search", "Search the web", "", invalid)
    else if url = "meow:goto"
        text = "https://"
        if m.url <> "" then text = m.url
        askFor("goto", "Go to an address", text, invalid)
    else if Left(url, 9) = "meow:ask|"
        parts = url.Split("|")
        if parts.Count() >= 4 then askFor("form", parts[3], "", { action: parts[1], name: parts[2] })
    end if
end sub

' ---- lines and links -----------------------------------------------------------------

sub onLineSelected()
    row = m.lines.content.getChild(m.lines.itemSelected)
    if row = invalid then return
    if row.url = invalid or row.url = "" then return
    if row.description <> invalid and row.description <> ""
        urls = row.description.Split(Chr(10))
        labels = row.shortDescriptionLine1.Split(Chr(10))
        items = []
        data = []
        for i = 0 to urls.Count() - 1
            label = urls[i]
            if i < labels.Count() then label = labels[i]
            items.Push(label)
            data.Push(urls[i])
        end for
        openPopup("links", "Which link?", items, data)
    else
        go(row.url, true)
    end if
end sub

sub openPopup(kind as String, title as String, items as Object, data as Object)
    m.popupKind = kind
    m.popupData = data
    m.popupTitle.text = title
    node = CreateObject("roSGNode", "ContentNode")
    for each t in items
        row = node.createChild("ContentNode")
        row.title = t
    end for
    m.popupList.content = node
    m.popupList.jumpToItem = 0
    m.popup.visible = true
    m.popupList.setFocus(true)
end sub

sub closePopup()
    m.popup.visible = false
    focusPage()
end sub

function bookmarkIndex() as Integer
    for i = 0 to m.bookmarks.Count() - 1
        if m.bookmarks[i].url = m.url then return i
    end for
    return -1
end function

sub openMenu()
    items = ["Search the web", "Go to an address", "Start page", "Reload this page"]
    data = ["search", "goto", "home", "reload"]
    if m.url <> ""
        if bookmarkIndex() >= 0
            items.Push("Remove this bookmark")
            data.Push("unmark")
        else
            items.Push("Bookmark this page")
            data.Push("mark")
        end if
    end if
    items.Push("Back to TV")
    data.Push("exit")
    openPopup("menu", "Menu", items, data)
end sub

sub onPopupSelected()
    i = m.popupList.itemSelected
    if i < 0 or i >= m.popupData.Count() then return
    what = m.popupData[i]
    kind = m.popupKind
    closePopup()
    if kind = "links"
        go(what, true)
        return
    end if
    if what = "search"
        special("meow:search")
    else if what = "goto"
        special("meow:goto")
    else if what = "home"
        if m.url <> ""
            m.history.Push({ url: m.url, line: m.lines.itemFocused })
            m.seq = m.seq + 1
            showHome()
        end if
    else if what = "reload"
        if m.url <> ""
            m.restoreLine = m.lines.itemFocused
            load(m.url)
        end if
    else if what = "mark"
        title = m.pageTitle.text
        if Len(title) > 60 then title = Left(title, 57) + "..."
        m.bookmarks.Push({ title: title, url: m.url })
        m.task.request = { cmd: "saveBookmarks", list: m.bookmarks }
    else if what = "unmark"
        at = bookmarkIndex()
        if at >= 0
            m.bookmarks.Delete(at)
            m.task.request = { cmd: "saveBookmarks", list: m.bookmarks }
        end if
    else if what = "exit"
        m.top.closed = true
    end if
end sub

' ---- typing --------------------------------------------------------------------------

sub askFor(kind as String, title as String, text as String, extra as Dynamic)
    m.ask = { kind: kind, extra: extra }
    dlg = CreateObject("roSGNode", "StandardKeyboardDialog")
    dlg.title = title
    dlg.text = text
    dlg.buttons = ["OK", "Cancel"]
    dlg.observeFieldScoped("buttonSelected", "onAskButton")
    dlg.observeFieldScoped("wasClosed", "onAskClosed")
    m.dialog = dlg
    m.top.getScene().dialog = dlg
end sub

sub onAskButton()
    dlg = m.dialog
    if dlg = invalid then return
    picked = dlg.buttonSelected
    text = dlg.text
    ask = m.ask
    dlg.close = true
    if picked <> 0 or ask = invalid then return
    text = text.Trim()
    if text = "" then return
    if ask.kind = "search"
        go(WebSearchUrl(text), true)
    else if ask.kind = "goto"
        go(WebFromTyped(text), true)
    else if ask.kind = "form"
        action = ask.extra.action
        last = Right(action, 1)
        if last <> "?" and last <> "&"
            if Instr(1, action, "?") > 0
                action = action + "&"
            else
                action = action + "?"
            end if
        end if
        go(action + ask.extra.name + "=" + WebEscape(text), true)
    end if
end sub

sub onAskClosed()
    m.dialog = invalid
    if m.top.active and not m.popup.visible then focusPage()
end sub

' ---- pictures and media ----------------------------------------------------------------

sub showImage(url as String)
    m.image.uri = url
    m.imageNote.text = url
    m.imageView.visible = true
    m.top.setFocus(true)
end sub

sub playMedia(url as String)
    content = CreateObject("roSGNode", "ContentNode")
    content.url = url
    content.streamFormat = WebMediaFormat(url)
    content.title = url
    m.media.content = content
    m.media.visible = true
    m.media.control = "play"
    m.media.setFocus(true)
end sub

sub stopMedia()
    if m.media.visible
        m.media.control = "stop"
        m.media.visible = false
    end if
end sub

sub onMediaState()
    s = m.media.state
    if not m.media.visible then return
    if s = "finished" or s = "error"
        stopMedia()
        if s = "error" then m.pageTitle.text = "That file could not be played."
        if m.top.active then focusPage()
    end if
end sub

' ---- remote ----------------------------------------------------------------------------

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not m.top.active then return false
    if not press then return true

    if m.media.visible
        if key = "back"
            stopMedia()
            focusPage()
        end if
        return true
    end if
    if m.imageView.visible
        if key = "back" or key = "OK"
            m.imageView.visible = false
            m.image.uri = ""
            focusPage()
        end if
        return true
    end if
    if m.popup.visible
        if key = "back" or key = "options" then closePopup()
        return true
    end if

    if key = "back"
        goBack()
    else if key = "options"
        openMenu()
    else if key = "play"
        special("meow:goto")
    else if key = "fastforward" or key = "rewind"
        count = 0
        if m.lines.content <> invalid then count = m.lines.content.getChildCount()
        at = m.lines.itemFocused
        if key = "fastforward"
            at = at + 18
        else
            at = at - 18
        end if
        if at > count - 1 then at = count - 1
        if at < 0 then at = 0
        m.lines.jumpToItem = at
    else if key = "replay"
        if m.url <> ""
            m.restoreLine = m.lines.itemFocused
            load(m.url)
        end if
    end if
    return true
end function
