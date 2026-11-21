' Off-device checks for the room-lights helper.
'   npx @rokucommunity/brs roku/source/lights.brs tests/lights_test.brs

sub Check(name as String, got as Dynamic, want as Dynamic)
    g = FormatJson(got)
    w = FormatJson(want)
    if g = w
        m.pass = m.pass + 1
    else
        m.fail = m.fail + 1
        print "FAIL  "; name
        print "  got   "; g
        print "  want  "; w
    end if
end sub

sub Main()
    m.pass = 0
    m.fail = 0

    hook = "/api/webhook/meowbox"
    Check("url: bare ip", LightsUrl("192.168.1.50"), "http://192.168.1.50:8123" + hook)
    Check("url: spaces round it", LightsUrl("  192.168.1.50 "), "http://192.168.1.50:8123" + hook)
    Check("url: name", LightsUrl("homeassistant.local"), "http://homeassistant.local:8123" + hook)
    Check("url: own port", LightsUrl("192.168.1.50:8124"), "http://192.168.1.50:8124" + hook)
    Check("url: http with trailing slash", LightsUrl("http://10.0.0.2/"), "http://10.0.0.2:8123" + hook)
    Check("url: https keeps its port", LightsUrl("https://ha.example.com/"), "https://ha.example.com" + hook)
    Check("url: full webhook", LightsUrl("http://x:8123/api/webhook/other"), "http://x:8123/api/webhook/other")
    Check("url: empty", LightsUrl(""), "")
    Check("url: invalid", LightsUrl(invalid), "")
    Check("url: words", LightsUrl("my house"), "")

    Check("rgb: hex", LightsRgb("#12AB9f"), [18, 171, 159])
    Check("rgb: no hash", LightsRgb("FFA630"), [255, 166, 48])
    Check("rgb: short", LightsRgb("#FFF"), invalid)
    Check("rgb: not hex", LightsRgb("#GGGGGG"), invalid)

    c = { id: "waku", name: "Waku Waku", dial: 7, color: "#ff3d8b" }
    Check("payload: tune", LightsPayload("tune", c), { channel: "Waku Waku", channel_id: "waku", color: "#FF3D8B", dial: 7, event: "tune", rgb: [255, 61, 139] })
    Check("payload: leave", LightsPayload("leave", invalid), { event: "leave" })
    Check("payload: no colour", LightsPayload("tune", { id: "x", name: "X", dial: 1, color: "grey" }), { channel: "X", channel_id: "x", dial: 1, event: "tune" })

    Check("feature: film", LightsIsFeature(5400), true)
    Check("feature: short", LightsIsFeature(1500), false)
    Check("feature: unknown", LightsIsFeature(invalid), false)
    film = { title: "Metropolis", inS: 300, durS: 5400 }
    Check("predim: five minutes out", LightsPredimDue(film, 0), false)
    Check("predim: a minute out", LightsPredimDue(film, 240), true)
    Check("predim: started", LightsPredimDue(film, 300), false)
    Check("predim: a short", LightsPredimDue({ inS: 30, durS: 1200 }, 0), false)
    Check("predim: old record", LightsPredimDue({ inS: 30 }, 0), false)
    Check("predim: none", LightsPredimDue(invalid, 0), false)

    print m.pass; " passed, "; m.fail; " failed"
end sub
