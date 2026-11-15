sub init()
    m.front = m.top.findNode("front")
    m.rings = [m.top.findNode("ring0"), m.top.findNode("ring1")]
    m.tv = invalid

    ' a play button, drawn the way the channel logos are
    m.top.findNode("play").mark = {
        color: "#E5352B"
        logo: {
            type: "pixel"
            rows: [
                "..cccccccccccc..", ".cccccccccccccc.", "cccccccccccccccc", "cccccccccccccccc",
                "cccccppccccccccc", "cccccppppccccccc", "cccccppppppccccc", "cccccppppppppccc",
                "cccccppppppppccc", "cccccppppppccccc", "cccccppppccccccc", "cccccppccccccccc",
                "cccccccccccccccc", "dddddddddddddddd", ".dddddddddddddd.", "..dddddddddddd.."
            ]
        }
    }

    ' start on whichever was opened last
    m.at = 0
    reg = CreateObject("roRegistrySection", "meowbox")
    if reg.Exists("lastApp")
        if reg.Read("lastApp") = "youtube" then m.at = 1
    end if
    light()
    m.watch = m.top.findNode("watch")
    m.watch.observeField("fire", "holdRemote")
    m.watch.control = "start"
end sub

sub onActive()
    if m.top.active then m.top.setFocus(true)
end sub

' The front door is the only thing on screen, so the remote must be here (or
' with the television, once open). If it is anywhere else, take it back.
sub holdRemote()
    if m.top.getParent() = invalid then return
    if m.top.isInFocusChain() then return
    if m.tv <> invalid
        m.tv.setFocus(true)
    else
        m.top.setFocus(true)
    end if
end sub

sub light()
    for i = 0 to 1
        m.rings[i].visible = (i = m.at)
    end for
end sub

sub remember(app as String)
    reg = CreateObject("roRegistrySection", "meowbox")
    reg.Write("lastApp", app)
    reg.Flush()
end sub

sub openTv()
    remember("tv")
    m.tv = m.top.createChild("MeowTV")
    m.front.visible = false
    m.tv.active = true
end sub

sub closeTv()
    m.tv.active = false
    m.top.removeChild(m.tv)
    m.tv = invalid
    m.front.visible = true
    m.top.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if m.tv <> invalid
        ' the television did not want this key: only Back means anything here
        if key = "back"
            closeTv()
            return true
        end if
        return false
    end if
    if key = "left" or key = "right"
        m.at = 1 - m.at
        light()
        return true
    else if key = "OK"
        if m.at = 0
            openTv()
        else
            remember("youtube")
            m.watch.control = "stop"
            m.top.choice = "youtube"
        end if
        return true
    end if
    return false
end function
