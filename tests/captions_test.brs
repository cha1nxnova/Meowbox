' Off-device checks for the caption and logo helpers.
'   npx @rokucommunity/brs roku/source/captions.brs roku/source/logo.brs tests/captions_test.brs

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
    nl = Chr(10)

    ' --- keys, as the website makes them
    Check("key: tape only", CapTapeKey("00001_20260321", ""), "00001_20260321")
    Check("key: file", CapTapeKey("0124-154229", "0124_154652.mp4"), "0124-154229/0124-154652")
    Check("key: folders and brackets", CapTapeKey("angels-egg", "03b. Extras/Megazone 23 - Extra - PV 01 (1080p).ia.mp4"), "angels-egg/03b-Extras-Megazone-23-Extra-PV-01-1080p-ia")
    Check("key: leading bracket", CapTapeKey("dengeki", "[Bunny_Hat_Raw]Strada_5_05_(A9F893C7).mp4"), "dengeki/Bunny-Hat-Raw-Strada-5-05-A9F893C7")

    ' --- times
    Check("time: srt", CapTimeMs("01:25:25,000"), 5125000)
    Check("time: two-digit fraction", CapTimeMs("00:00:16,03"), 16030)
    Check("time: vtt without hours", CapTimeMs("00:08.140"), 8140)
    Check("time: no fraction", CapTimeMs("00:01:02"), 62000)
    Check("time: nonsense", CapTimeMs("WEBVTT"), -1)

    ' --- SubRip, with a byte-order mark and Windows line ends
    srt = Chr(65279) + "1" + Chr(13) + nl + "00:00:16,03 --> 00:00:16,53" + Chr(13) + nl + "No known" + Chr(13) + nl + Chr(13) + nl
    srt = srt + "2" + nl + "00:00:23,45 --> 00:00:26,55" + nl + "how to say no that's the" + nl + "subject under <i>discussion</i>" + nl + nl
    srt = srt + "3" + nl + "00:00:30,00 --> 00:01:30,00" + nl + "{\an8}Tom &amp; Jerry" + nl
    cues = CapParseTimed(srt)
    Check("srt: count", cues.Count(), 3)
    Check("srt: first", cues[0], { t0: 16030, t1: 16530, text: "No known" })
    Check("srt: two lines, tags out", cues[1].text, "how to say no that's the" + nl + "subject under discussion")
    Check("srt: entities and a long cue cut to 12 s", cues[2], { t0: 30000, t1: 42000, text: "Tom & Jerry" })

    ' --- WebVTT, the rolling kind
    vtt = "WEBVTT" + nl + "Kind: captions" + nl + "Language: en" + nl + nl
    vtt = vtt + "00:00:01.220 --> 00:00:04.309 align:start position:0%" + nl + " " + nl + "[Applause]" + nl + nl
    vtt = vtt + "00:00:04.309 --> 00:00:04.319 align:start position:0%" + nl + "[Applause]" + nl + " " + nl + nl
    vtt = vtt + "00:00:04.319 --> 00:00:06.550 align:start position:0%" + nl + "[Applause]" + nl + "hello<00:00:04.720><c> ontario</c><00:00:05.279><c> and</c>" + nl + nl
    vtt = vtt + "NOTE a comment" + nl + nl + "00:08.140 --> 00:16.140" + nl + "Wormtown!" + nl
    cues = CapParseTimed(vtt)
    Check("vtt: count (the 10 ms frame is dropped)", cues.Count(), 3)
    Check("vtt: blank line kept out", cues[0], { t0: 1220, t1: 4309, text: "[Applause]" })
    Check("vtt: word timing out", cues[1].text, "[Applause]" + nl + "hello ontario and")
    Check("vtt: short stamps", cues[2], { t0: 8140, t1: 16140, text: "Wormtown!" })
    Check("empty", CapParseTimed("").Count(), 0)

    ' cues separated by a line of spaces instead of an empty one
    cues = CapParseTimed("1" + nl + "00:00:01,000 --> 00:00:02,000" + nl + "one" + nl + "  " + nl + "2" + nl + "00:00:03,000 --> 00:00:04,000" + nl + "two" + nl)
    Check("srt: sloppy separators", [cues.Count(), cues[0].text, cues[1].text], [2, "one", "two"])

    ' out of order
    cues = CapParseTimed("00:00:10.000 --> 00:00:12.000" + nl + "b" + nl + nl + "00:00:01.000 --> 00:00:02.000" + nl + "a" + nl)
    Check("sorted", [cues[0].text, cues[1].text], ["a", "b"])

    ' --- the website's files
    site = ParseJson("{""format"":1,""cues"":[{""t0"":204289,""t1"":205483,""kind"":""line"",""en"":""Daigo!""},{""t0"":300000,""t1"":301000,""kind"":""beat"",""of"":""lost"",""en"":""[???]""},{""t0"":400000,""t1"":401000,""kind"":""mark""},{""t0"":5,""t1"":2,""kind"":""line"",""en"":""backwards""},{""t0"":9,""t1"":20,""kind"":""other"",""en"":""x""}]}")
    cues = CapFromSite(site)
    Check("site: count", cues.Count(), 3)
    Check("site: line", cues[0], { t0: 204289, t1: 205483, text: "Daigo!" })
    Check("site: mark", cues[2].text, "[...]")
    Check("site: junk", CapFromSite("nope").Count(), 0)

    ' --- which cue is on
    cues = [{ t0: 1000, t1: 2000, text: "a" }, { t0: 3000, t1: 6000, text: "b" }, { t0: 5000, t1: 5500, text: "c" }]
    Check("at: before", CapCueAt(cues, 500), -1)
    Check("at: first", CapCueAt(cues, 1000), 0)
    Check("at: gap", CapCueAt(cues, 2500), -1)
    Check("at: overlap, the later one wins", CapCueAt(cues, 5200), 2)
    Check("at: after", CapCueAt(cues, 9000), -1)
    Check("at: none", CapCueAt([], 10), -1)

    ' --- choosing among an Archive item's files
    f = [{ name: "HowtoSay1951.mp4", size: "9" }, { name: "HowtoSay1951.asr.srt", size: "10954" }, { name: "HowtoSay1951.asr.vtt", size: "11015" }]
    Check("ia: asr srt over vtt", CapPickArchive(f, "HowtoSay1951.mp4"), { name: "HowtoSay1951.asr.srt", machine: true })
    f = [{ name: "T.autogenerated.vtt", size: "19929" }, { name: "T.asr.srt", size: "2000" }, { name: "T.srt", size: "21959" }]
    Check("ia: a person's file first", CapPickArchive(f, "T.mp4"), { name: "T.srt", machine: false })
    f = [{ name: "Cookingw2000_512kb.autogenerated.vtt", size: "9000" }, { name: "Cookingw2000.autogenerated.vtt", size: "9000" }]
    Check("ia: the same cut of the video", CapPickArchive(f, "Cookingw2000.mp4").name, "Cookingw2000.autogenerated.vtt")
    f = [{ name: "saddle_mountain_roundup.asr.srt", size: "37816" }]
    Check("ia: _512kb video", CapPickArchive(f, "saddle_mountain_roundup_512kb.mp4").name, "saddle_mountain_roundup.asr.srt")
    f = [{ name: "ToT.autogenerated.vtt", size: "30923" }]
    Check("ia: .ia video", CapPickArchive(f, "ToT.ia.mp4").name, "ToT.autogenerated.vtt")
    f = [{ name: "B.es.vtt", size: "9000" }, { name: "B.en.vtt", size: "9000" }]
    Check("ia: English", CapPickArchive(f, "B.mp4").name, "B.en.vtt")
    f = [{ name: "D.disc.srt", size: "43000" }, { name: "D.cc5.srt", size: "43034" }, { name: "D.autogenerated.vtt", size: "9000" }]
    Check("ia: disc menus skipped, broadcast captions kept", CapPickArchive(f, "D.mp4"), { name: "D.cc5.srt", machine: false })
    f = [{ name: "E.disc.srt", size: "237" }, { name: "Other.asr.srt", size: "9000" }, { name: "E.mp4", size: "1" }]
    Check("ia: nothing that fits", CapPickArchive(f, "E.mp4"), invalid)
    f = [{ name: "dir/Ep 1.asr.srt", size: "9000" }, { name: "dir/Ep 10.asr.srt", size: "9000" }]
    Check("ia: folders, and Ep 1 is not Ep 10", CapPickArchive(f, "dir/Ep 10.mp4").name, "dir/Ep 10.asr.srt")

    ' --- logos
    rows = ["cc..", "cc..", ".kk.", ".kkp"]
    Check("logo: boxes", LogoRects(rows), [{ h: 2, t: "c", w: 2, x: 0, y: 0 }, { h: 2, t: "k", w: 2, x: 1, y: 2 }, { h: 1, t: "p", w: 1, x: 3, y: 3 }])
    Check("logo: rows ok", LogoRows({ type: "pixel", rows: rows }) <> invalid, true)
    Check("logo: ragged rows refused", LogoRows({ type: "pixel", rows: ["cc", "c"] }), invalid)
    Check("logo: other kinds refused", LogoRows({ type: "vector", rows: rows }), invalid)
    pal = LogoPalette("#FF6F00")
    Check("logo: channel colour", pal.c, "0xFF6F00FF")
    Check("logo: shade", pal.d, "0x991F00FF")
    Check("logo: highlight", pal.l, "0xFFC266FF")
    Check("logo: no colour", LogoPalette(invalid).c, "0x666666FF")
    pal = LogoPalette("#035e12")
    Check("logo: dark green", [pal.d, pal.l], ["0x003816FF", "0x50BF50FF"])
    pal = LogoPalette("#1A237E")
    Check("logo: navy", [pal.d, pal.l], ["0x130A4CFF", "0x726BCBFF"])
    pal = LogoPalette("#E8DFC8")
    Check("logo: cream", [pal.d, pal.l], ["0x8B8076FF", "0xF6F2E1FF"])
    pal = LogoPalette("#00E5FF")
    Check("logo: cyan", [pal.d, pal.l], ["0x006699FF", "0x66FFF5FF"])

    print m.pass.ToStr() + " passed, " + m.fail.ToStr() + " failed"
end sub
