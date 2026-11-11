' ---------------------------------------------------------------------------
' Schedule engine.
'
' Every channel is a looping playlist of Internet Archive tapes with timed
' cards ("bumps"), "up next" cards and short ad-break clips between them.
' Nothing is streamed from a server clock: each client works out what is on
' air from the published lineup and the wall clock. To land on the same frame
' as everybody else this file has to reproduce the published arithmetic
' exactly, including the seeded shuffles, so it is deliberately literal.
'
' All times are whole milliseconds held in LongInteger (the "&" suffix).
' 32-bit hash / random maths is done on non-negative LongIntegers with plain
' arithmetic, so it does not depend on integer overflow behaviour.
' ---------------------------------------------------------------------------

' ---- numbers ---------------------------------------------------------------

function SpkIsNum(x as Dynamic) as Boolean
    if x = invalid then return false
    t = LCase(type(x))
    return t = "integer" or t = "rointeger" or t = "roint" or t = "longinteger" or t = "rolonginteger" or t = "float" or t = "rofloat" or t = "double" or t = "rodouble"
end function

function SpkIsWhole(x as Dynamic) as Boolean
    if x = invalid then return false
    t = LCase(type(x))
    if t = "integer" or t = "rointeger" or t = "roint" or t = "longinteger" or t = "rolonginteger" then return true
    if t = "float" or t = "rofloat" or t = "double" or t = "rodouble"
        d# = x
        return d# = SpkFloorD(d#)
    end if
    return false
end function

function SpkTrue(x as Dynamic) as Boolean
    if x = invalid then return false
    t = LCase(type(x))
    if t = "boolean" or t = "roboolean" then return x
    return false
end function

' floor() of a double that may be far outside 32 bits
function SpkFloorD(d as Double) as LongInteger
    neg = false
    if d < 0
        neg = true
        d = -d
    end if
    hi% = Int(d / 1000000000#)
    rm# = d - hi% * 1000000000#
    if rm# < 0
        hi% = hi% - 1
        rm# = rm# + 1000000000#
    else if rm# >= 1000000000#
        hi% = hi% + 1
        rm# = rm# - 1000000000#
    end if
    lo% = Int(rm#)
    r& = hi%
    r& = r& * 1000000000& + lo%
    if neg
        if rm# > lo% then r& = r& + 1
        r& = 0& - r&
    end if
    return r&
end function

function SpkLong(x as Dynamic) as LongInteger
    if x = invalid then return 0&
    t = LCase(type(x))
    if t = "float" or t = "rofloat" or t = "double" or t = "rodouble"
        d# = x
        return SpkFloorD(d#)
    end if
    if t = "string" or t = "rostring" then return ParseJson(x)
    r& = x
    return r&
end function

function SpkNowMs() as LongInteger
    dt = CreateObject("roDateTime")
    s& = dt.AsSeconds()
    return s& * 1000& + dt.GetMilliseconds()
end function

' ---- 32-bit helpers on non-negative LongIntegers -----------------------------

function SpkXor32(a as LongInteger, b as LongInteger) as LongInteger
    ah% = a \ 65536&
    al% = a mod 65536&
    bh% = b \ 65536&
    bl% = b mod 65536&
    xh% = (ah% or bh%) - (ah% and bh%)
    xl% = (al% or bl%) - (al% and bl%)
    r& = xh%
    return r& * 65536& + xl%
end function

function SpkOrSmall(a as LongInteger, k as Integer) as LongInteger
    al% = a mod 65536&
    return (a - al%) + (al% or k)
end function

function SpkImul(a as LongInteger, b as LongInteger) as LongInteger
    ah& = a \ 65536&
    al& = a mod 65536&
    bh& = b \ 65536&
    bl& = b mod 65536&
    md& = (ah& * bl& + al& * bh&) mod 65536&
    return (md& * 65536& + al& * bl&) mod 4294967296&
end function

function SpkRng(seed as LongInteger) as Object
    return { s: seed }
end function

' next value in [0, 1)
function SpkRand(r as Object) as Double
    t& = r.s
    t& = (t& + 1831565813&) mod 4294967296&
    r.s = t&
    n& = SpkImul(SpkXor32(t&, t& \ 32768&), SpkOrSmall(t&, 1))
    n& = SpkXor32(n&, (n& + SpkImul(SpkXor32(n&, n& \ 128&), SpkOrSmall(n&, 61))) mod 4294967296&)
    n& = SpkXor32(n&, n& \ 16384&)
    d# = n&
    return d# / 4294967296#
end function

function SpkPick(r as Object, n as Integer) as Integer
    return Int(SpkRand(r) * n)
end function

' String hash over UTF-16 code units (the text is decoded from its UTF-8 bytes
' here so the answer does not depend on how the platform counts characters).
function SpkHash(s as String) as LongInteger
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(s)
    n = ba.Count()
    ' the 32-bit value is kept as two 16-bit halves so plain integers never overflow
    hi = 0
    lo = 0
    i = 0
    while i < n
        b = ba[i]
        if b < 128
            c = b
            i = i + 1
        else if b < 224
            c = (b and 31) * 64 + (ba[i + 1] and 63)
            i = i + 2
        else if b < 240
            c = (b and 15) * 4096 + (ba[i + 1] and 63) * 64 + (ba[i + 2] and 63)
            i = i + 3
        else
            cp = (b and 7) * 262144 + (ba[i + 1] and 63) * 4096 + (ba[i + 2] and 63) * 64 + (ba[i + 3] and 63)
            cp = cp - 65536
            lo = lo * 31 + 55296 + (cp \ 1024)
            hi = (hi * 31 + (lo \ 65536)) and 65535
            lo = lo and 65535
            c = 56320 + (cp mod 1024)
            i = i + 4
        end if
        lo = lo * 31 + c
        hi = (hi * 31 + (lo \ 65536)) and 65535
        lo = lo and 65535
    end while
    t& = hi
    return t& * 65536& + lo
end function

' length in UTF-16 code units
function SpkLen16(s as String) as Integer
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(s)
    n = 0
    for each b in ba
        if b < 128 or b >= 192 then n = n + 1
        if b >= 240 then n = n + 1
    end for
    return n
end function

' ordinal "a < b"
function SpkStrLess(a as String, b as String) as Boolean
    x = CreateObject("roByteArray")
    x.FromAsciiString(a)
    y = CreateObject("roByteArray")
    y.FromAsciiString(b)
    n = x.Count()
    if y.Count() < n then n = y.Count()
    for i = 0 to n - 1
        if x[i] <> y[i] then return x[i] < y[i]
    end for
    return x.Count() < y.Count()
end function

' leading whole number of a value ("1985", "1985-86", 1985) or invalid
function SpkYear(item as Dynamic) as Dynamic
    if item = invalid then return invalid
    y = item.year
    if y = invalid then return invalid
    if SpkIsNum(y) then return Int(y)
    s = y.ToStr().Trim()
    digits = ""
    for i = 1 to Len(s)
        ch = Mid(s, i, 1)
        if ch >= "0" and ch <= "9"
            digits = digits + ch
        else
            exit for
        end if
    end for
    if digits = "" or Len(digits) > 9 then return invalid
    return digits.ToInt()
end function

' ---- card timing -------------------------------------------------------------

function SpkSlideMs(slide as Object) as Integer
    if slide._ms <> invalid then return slide._ms
    t = ""
    if slide.text <> invalid then t = slide.text
    ms = 1500 + SpkLen16(t) * 55
    if ms < 2500 then ms = 2500
    slide._ms = ms
    return ms
end function

function SpkSlidesMs(bump as Object) as LongInteger
    if bump._ms <> invalid then return bump._ms
    total& = 0&
    if bump.slides <> invalid
        for each s in bump.slides
            total& = total& + SpkSlideMs(s)
        end for
    end if
    bump._ms = total&
    return total&
end function

' ---- seasonal bumps ------------------------------------------------------------

function SpkIsoSeconds(s as String) as LongInteger
    dt = CreateObject("roDateTime")
    dt.FromISO8601String(s)
    r& = dt.AsSeconds()
    return r&
end function

function SpkMonthDay(s as String) as Integer
    parts = s.Split("-")
    if parts.Count() < 2 then return 0
    return parts[0].ToInt() * 100 + parts[1].ToInt()
end function

function SpkInRange(range as Object, t as LongInteger) as Boolean
    a = range[0]
    b = range[1]
    if Len(a) >= 5 and Mid(a, 5, 1) = "-" and Left(a, 4).ToInt() > 999
        lo& = SpkIsoSeconds(a + "T00:00:00Z") * 1000&
        hi& = SpkIsoSeconds(b + "T23:59:59Z") * 1000& + 999&
        return t >= lo& and t <= hi&
    end if
    dt = CreateObject("roDateTime")
    secs& = t \ 1000&
    if t < 0 and (t mod 1000&) <> 0 then secs& = secs& - 1
    si% = secs&
    dt.FromSeconds(si%)
    o = dt.GetMonth() * 100 + dt.GetDayOfMonth()
    x = SpkMonthDay(a)
    y = SpkMonthDay(b)
    if x <= y then return o >= x and o <= y
    return o >= x or o <= y
end function

' { live, yearRound, seasonal } for one bump list; every bump gets an index tag
function SpkSplitBumps(bumps as Object) as Object
    info = { all: bumps, live: [], yearRound: [], seasonal: [] }
    i = 0
    for each b in bumps
        b._ix = i
        i = i + 1
        active = true
        if b.active <> invalid and SpkTrue(b.active) = false then active = false
        if active
            info.live.Push(b)
            if b.date_range <> invalid
                info.seasonal.Push(b)
            else
                info.yearRound.Push(b)
            end if
        end if
    end for
    return info
end function

' The bumps that may air at time t, and the names of the seasonal ones in
' season. Seasons turn over at midnight UTC, so the answer is kept per day.
function SpkSeason(info as Object, t as LongInteger) as Object
    day& = t \ 86400000&
    if t < 0 and (t mod 86400000&) <> 0 then day& = day& - 1
    dayNumber = day&
    dk = dayNumber.ToStr()
    if info.dayKey <> invalid
        if info.dayKey = dk then return info.dayHit
    end if
    key = ""
    for each b in info.seasonal
        if SpkInRange(b.date_range, t)
            if key <> "" then key = key + "|"
            key = key + b.id
        end if
    end for
    pool = info.yearRound
    if key <> ""
        pool = []
        for each b in info.live
            if b.date_range = invalid
                pool.Push(b)
            else if SpkInRange(b.date_range, t)
                pool.Push(b)
            end if
        end for
    end if
    info.dayKey = dk
    info.dayHit = { pool: pool, key: key }
    return info.dayHit
end function

function SpkBumpPool(info as Object, t as LongInteger) as Object
    return SpkSeason(info, t).pool
end function

function SpkPickBump(info as Dynamic, breakIndex as Integer, channelId as String, seed as String, t as LongInteger) as Dynamic
    if info = invalid then return invalid
    if info.all.Count() = 0 then return invalid
    pool = SpkBumpPool(info, t)
    if pool.Count() = 0 then return invalid
    r = SpkRng(SpkHash(channelId + "-break-" + breakIndex.ToStr() + "-" + seed))
    return pool[SpkPick(r, pool.Count())]
end function

' ---- the bump deck (engine 5+): every bump once before any repeats ---------------

function SpkIndexOfBump(list as Object, bump as Object) as Integer
    for i = 0 to list.Count() - 1
        if list[i]._ix = bump._ix then return i
    end for
    return -1
end function

function SpkDeckShuffle(pool as Object, recent as Object, seed as LongInteger) as Object
    r = SpkRng(seed)
    s = []
    for each b in pool
        s.Push(b)
    end for
    n = s.Count()
    if n >= 2
        for l = n - 1 to 1 step -1
            u = SpkPick(r, l + 1)
            tmp = s[l]
            s[l] = s[u]
            s[u] = tmp
        end for
    end if
    half = n \ 2
    mk = half
    if recent.Count() < mk then mk = recent.Count()
    if mk < 1 then return s
    floorOf = {}
    for l = mk to 1 step -1
        floorOf[recent[recent.Count() - l]._ix.ToStr()] = half + 1 - l
    end for
    for l = 1 to mk
        u = recent[recent.Count() - l]
        d = SpkIndexOfBump(s, u)
        au = floorOf[u._ix.ToStr()]
        if d >= 0 and d < au
            f = []
            if au <= n - 1
                for p = au to n - 1
                    ap = floorOf[s[p]._ix.ToStr()]
                    if ap = invalid then ap = 0
                    if ap <= d then f.Push(p)
                end for
            end if
            pick = SpkPick(r, f.Count())
            if f.Count() > 0
                h = f[pick]
                tmp = s[d]
                s[d] = s[h]
                s[h] = tmp
            end if
        end if
    end for
    return s
end function

function SpkNewDeck(carry as Dynamic) as Object
    if carry = invalid then return { order: [], pos: 0, key: invalid, recent: [], rounds: 0 }
    recent = []
    for each b in carry.recent
        recent.Push(b)
    end for
    return { order: carry.order, pos: carry.pos, key: carry.key, recent: recent, rounds: 0 }
end function

function SpkDeckDraw(deck as Object, info as Dynamic, channelId as String, seed as String, t as LongInteger) as Dynamic
    if info = invalid then return invalid
    if info.all.Count() = 0 then return invalid
    pool = SpkBumpPool(info, t)
    if pool.Count() = 0 then return invalid
    key = SpkSeason(info, t).key
    reshuffle = false
    if deck.key = invalid
        reshuffle = true
    else if deck.key <> key
        reshuffle = true
    else if deck.pos >= deck.order.Count()
        reshuffle = true
    end if
    if reshuffle
        deck.order = SpkDeckShuffle(pool, deck.recent, SpkHash(channelId + "-deck-" + seed + "-" + deck.rounds.ToStr()))
        deck.rounds = deck.rounds + 1
        deck.pos = 0
        deck.key = key
    end if
    b = deck.order[deck.pos]
    deck.pos = deck.pos + 1
    deck.recent.Push(b)
    if deck.recent.Count() > deck.order.Count() then deck.recent.Shift()
    return b
end function

' music under a card: { filename, title, artist, startOffset } or invalid
function SpkPickAudio(pool as Dynamic, bumpId as String, breakIndex as Integer, seed as String) as Dynamic
    if pool = invalid then return invalid
    if pool.Count() = 0 then return invalid
    r = SpkRng(SpkHash(bumpId + "-audio-" + breakIndex.ToStr() + "-" + seed))
    track = pool[SpkPick(r, pool.Count())]
    offset = SpkPick(r, 60)
    return { track: track, startOffset: offset }
end function

function SpkPickSting(stings as Dynamic, breakIndex as Integer, channelId as String, seed as String) as Dynamic
    if stings = invalid then return invalid
    if stings.Count() = 0 then return invalid
    r = SpkRng(SpkHash(channelId + "-card-" + breakIndex.ToStr() + "-" + seed))
    return stings[SpkPick(r, stings.Count())]
end function

' ---- ad breaks: which short clip plays in which break ------------------------------

function SpkYearKey(y as Dynamic) as String
    if y = invalid then return "null"
    return y.ToStr()
end function

' how often a lineup makes room for an ad break
function SpkAdRates(lineup as Object, block as Dynamic, gapMs as LongInteger, sliceMs as Double) as Object
    s# = 0
    i# = 0
    o# = 0
    total = 0
    byYear = {}
    years = []
    n = lineup.Count()
    for d = 0 to n - 1
        u = lineup[d]
        f# = u.duration * 1000#
        s# = s# + f#
        i# = i# + f#
        o# = o# + f#
        carded = false
        if block <> invalid
            if d < n - 1 and o# < block.lengthMs
                s# = s# + block.cardMs
                i# = i# + block.cardMs
                o# = o# + block.cardMs
                carded = true
            end if
        end if
        if not carded
            o# = 0
            h = lineup[(d + 1) mod n]
            if (not SpkTrue(u.offAir)) and (not SpkTrue(h.offAir)) and i# >= gapMs
                total = total + 1
                y = SpkYear(u)
                k = SpkYearKey(y)
                if byYear[k] = invalid
                    byYear[k] = 0
                    years.Push(y)
                end if
                byYear[k] = byYear[k] + 1
                s# = s# + (20000 + sliceMs)
                i# = 10000
            else
                s# = s# + 20000
                i# = i# + 20000
            end if
        end if
    end for
    return { cycleMs: s#, total: total, byYear: byYear, years: years }
end function

function SpkAdPlan(ver as Object) as Object
    ads = ver.ads
    slices = ads.slices
    n = slices.Count()
    keys = []
    sum# = 0
    ' the same clips turn up on many channels: remember each one's key
    g = GetGlobalAA()
    if g.spkAdKeys = invalid
        g.spkAdKeys = CreateObject("roAssociativeArray")
        g.spkAdKeys.SetModeCaseSensitive()
    end if
    known = g.spkAdKeys
    for each sl in slices
        k = known[sl.id]
        if k = invalid
            k = Int(SpkRand(SpkRng(SpkHash("ad-" + sl.id))) * 1000000)
            known[sl.id] = k
        end if
        keys.Push(k)
        sum# = sum# + sl.lengthMs
    end for
    ' slice numbers in order of (key, id, number)
    rows = []
    for i = 0 to n - 1
        rows.Push({ k: keys[i], i: i })
    end for
    rows.SortBy("k")
    order = []
    for each row in rows
        order.Push(row.i)
    end for
    ' the sort above only looked at the key: put any run of equal keys right
    i = 1
    while i < n
        j = i
        moving = (keys[order[j]] = keys[order[j - 1]])
        while moving
            x = order[j]
            p = order[j - 1]
            before = false
            if slices[x].id <> slices[p].id
                before = SpkStrLess(slices[x].id, slices[p].id)
            else
                before = x < p
            end if
            if before
                order[j] = p
                order[j - 1] = x
                j = j - 1
                moving = false
                if j > 0 then moving = (keys[order[j]] = keys[order[j - 1]])
            else
                moving = false
            end if
        end while
        i = i + 1
    end while
    phases = CreateObject("roArray", n, true)
    for i = 0 to n - 1
        phases[i] = 0
    end for
    for s = 0 to n - 1
        v& = s
        ph% = (v& * 1000000&) \ n
        phases[order[s]] = ph%
    end for
    years = []
    for each sl in slices
        years.Push(SpkYear(sl))
    end for
    ' where each slice sits in the order, filed by year, so a tier can be
    ' gathered without walking every slice
    rankByYear = {}
    yearList = []
    anywhere = []
    for r = 0 to n - 1
        idx = order[r]
        if SpkTrue(slices[idx].anywhere)
            anywhere.Push(r)
        else if years[idx] <> invalid
            yk = years[idx].ToStr()
            if rankByYear[yk] = invalid
                rankByYear[yk] = []
                yearList.Push(years[idx])
            end if
            rankByYear[yk].Push(r)
        end if
    end for
    gapMs& = 1200000&
    if SpkIsWhole(ads.gapMs) then gapMs& = SpkLong(ads.gapMs)
    start& = 0&
    useStart = false
    if SpkIsWhole(ads.start)
        if ads.start >= 0 and ads.start < 1000 then useStart = true
    end if
    if useStart
        start& = SpkLong(ads.start)
    else
        start& = SpkHash("ads-" + ver.channelId) mod 1000&
    end if
    start& = start& * 1000&
    decades = invalid
    if SpkIsWhole(ads.decades)
        if ads.decades >= 1 then decades = Int(ads.decades)
    end if
    return {
        slices: slices
        phases: phases
        order: order
        years: years
        start: start&
        gapMs: gapMs&
        decades: decades
        rates: SpkAdRates(ver.tapes, ver.block, gapMs&, sum# / n)
        rankByYear: rankByYear
        yearList: yearList
        anywhere: anywhere
        listCache: {}
    }
end function

function SpkYearFits(kind as String, tol as Integer, y as Dynamic, mk as Dynamic) as Boolean
    if kind = "inf" then return true
    if mk = invalid or y = invalid then return false
    if kind = "dec" then return Abs((mk \ 10) - (y \ 10)) <= tol
    return Abs(mk - y) <= tol
end function

function SpkAdTier(plan as Object, y as Dynamic, kind as String, tol as Integer) as Object
    key = kind
    if kind <> "inf" then key = SpkYearKey(y) + "|" + kind + tol.ToStr()
    hit = plan.listCache[key]
    if hit <> invalid then return hit
    list = []
    places = []
    if kind = "inf"
        for each idx in plan.order
            list.Push(idx)
            places.Push(plan.phases[idx])
        end for
    else
        ranks = []
        for each r in plan.anywhere
            ranks.Push(r)
        end for
        for each yr in plan.yearList
            if SpkYearFits(kind, tol, y, yr) then ranks.Append(plan.rankByYear[yr.ToStr()])
        end for
        ranks.Sort()
        for each r in ranks
            idx = plan.order[r]
            list.Push(idx)
            places.Push(plan.phases[idx])
        end for
    end if
    breaks = 0
    for each yr in plan.rates.years
        if SpkYearFits(kind, tol, y, yr) then breaks = breaks + plan.rates.byYear[SpkYearKey(yr)]
    end for
    cycleMs# = plan.rates.cycleMs
    need# = 0
    if cycleMs# > 0 then need# = (breaks * 1209600000#) / cycleMs#
    healthy = list.Count() > 0 and list.Count() >= need#
    roundMs& = 1209600000&
    if (not healthy) and list.Count() > 0
        roundMs& = SpkFloorD((list.Count() * cycleMs#) / breaks)
        if roundMs& < 3600000& then roundMs& = 3600000&
    end if
    tier = { kind: kind, list: list, places: places, roundMs: roundMs&, healthy: healthy }
    plan.listCache[key] = tier
    return tier
end function

' The tiers a break may draw from, nearest years first. Tiers are worked out
' only when a pick reaches them: most picks are settled by the first.
function SpkAdTierWalk(plan as Object, y as Dynamic) as Object
    specs = []
    if y <> invalid
        specs.Push(["abs", 3])
        specs.Push(["abs", 6])
        if plan.decades <> invalid then specs.Push(["dec", plan.decades])
    end if
    specs.Push(["inf", 0])
    first = 0
    while first < specs.Count() - 1
        if SpkAdTier(plan, y, specs[first][0], specs[first][1]).healthy then exit while
        first = first + 1
    end while
    return { plan: plan, y: y, specs: specs, at: first, tiers: [] }
end function

' the next tier that has anything in it, or invalid when there are no more
function SpkAdNextTier(walk as Object) as Dynamic
    while walk.at < walk.specs.Count()
        sp = walk.specs[walk.at]
        walk.at = walk.at + 1
        t = SpkAdTier(walk.plan, walk.y, sp[0], sp[1])
        if t.list.Count() > 0
            walk.tiers.Push(t)
            return t
        end if
    end while
    return invalid
end function

function SpkPhaseAt(t as LongInteger, roundMs as LongInteger, start as LongInteger) as LongInteger
    r& = ((t mod roundMs) + roundMs) mod roundMs
    return (((r& * 1000000&) \ roundMs) + start) mod 1000000&
end function

function SpkLowerBound(arr as Object, v as LongInteger) as Integer
    lo = 0
    hi = arr.Count()
    while lo < hi
        md = (lo + hi) \ 2
        if arr[md] < v
            lo = md + 1
        else
            hi = md
        end if
    end while
    return lo
end function

' the slice for a break at time nowMs; used = { set: {}, n: count }
function SpkPickAd(plan as Object, used as Object, y as Dynamic, nowMs as LongInteger, fromMs as LongInteger) as Integer
    if used.n >= plan.phases.Count()
        used.set = {}
        used.n = 0
    end if
    walk = SpkAdTierWalk(plan, y)
    marks = []
    while true
        l = SpkAdNextTier(walk)
        if l = invalid then exit while
        u = l.list.Count()
        d& = SpkPhaseAt(fromMs, l.roundMs, plan.start)
        f& = SpkPhaseAt(nowMs, l.roundMs, plan.start)
        h& = 0&
        if nowMs > fromMs
            if nowMs - fromMs >= l.roundMs
                h& = 1000000&
            else
                h& = (f& - d& + 1000000&) mod 1000000&
            end if
        end if
        span& = 86400000&
        if l.roundMs < span& then span& = l.roundMs
        p& = (span& * 1000000&) \ l.roundMs
        mk = SpkLowerBound(l.places, d& + 1)
        marks.Push(mk)
        for y2 = 0 to u - 1
            g = (mk + y2) mod u
            dist& = (l.places[g] - d& + 1000000&) mod 1000000&
            if dist& = 0 then dist& = 1000000&
            if dist& > h& then exit for
            if not used.set.DoesExist(l.list[g].ToStr())
                used.set[l.list[g].ToStr()] = true
                used.n = used.n + 1
                return l.list[g]
            end if
        end for
        for y2 = 1 to u
            g = (mk - y2 + u * 2) mod u
            if (d& - l.places[g] + 1000000&) mod 1000000& >= p& then exit for
            if not used.set.DoesExist(l.list[g].ToStr())
                used.set[l.list[g].ToStr()] = true
                used.n = used.n + 1
                return l.list[g]
            end if
        end for
    end while
    tiers = walk.tiers
    for l = 0 to tiers.Count() - 1
        u = tiers[l]
        d = u.list.Count()
        for f = 1 to d
            h = u.list[(marks[l] - f + d * 2) mod d]
            if not used.set.DoesExist(h.ToStr())
                used.set[h.ToStr()] = true
                used.n = used.n + 1
                return h
            end if
        end for
    end for
    return -1
end function

' ---- versions and cycles -------------------------------------------------------------

function SpkNewSchedule(channelId as String) as Object
    return { channelId: channelId, versions: [] }
end function

function SpkHasVersion(sched as Object, v as Integer) as Boolean
    for each ver in sched.versions
        if ver.v = v then return true
    end for
    return false
end function

' manifest: the channel's published playlist; platform: the network-wide cards;
' vinfo: this version's line from the lineup. Returns "" or why it was refused.
function SpkAddVersion(sched as Object, manifest as Object, platform as Dynamic, vinfo as Object) as String
    v = Int(vinfo.v)
    if SpkHasVersion(sched, v) then return ""
    items = manifest.Lookup("items")
    if items = invalid then return "no items"
    if items.Count() = 0 then return "no items"
    for each it in items
        if not SpkIsWhole(it.duration) then return "bad runtime"
        if it.duration <= 0 then return "bad runtime"
    end for
    startIndex = 0
    if SpkIsWhole(vinfo.startIndex) then startIndex = Int(vinfo.startIndex)
    if startIndex < 0 or startIndex >= items.Count() then return "startIndex out of range"
    epoch& = SpkLong(vinfo.epochMs)
    eff& = epoch&
    if vinfo.effectiveAtMs <> invalid then eff& = SpkLong(vinfo.effectiveAtMs)

    bumps = invalid
    cb = manifest.bumps
    pb = invalid
    if platform <> invalid then pb = platform.bumps
    if cb <> invalid and pb <> invalid
        if cb.Count() > 0 and pb.Count() > 0
            chAudio = manifest.audio
            if SpkTrue(manifest.audioOverlay) then chAudio = []
            if chAudio = invalid then chAudio = []
            plAudio = platform.audio
            if plAudio = invalid then plAudio = []
            bumps = { channel: SpkSplitBumps(cb), platform: SpkSplitBumps(pb), channelAudio: chAudio, platformAudio: plAudio }
        end if
    end if
    ads = invalid
    if manifest.ads <> invalid
        if manifest.ads.slices <> invalid
            if manifest.ads.slices.Count() > 0 then ads = manifest.ads
        end if
    end if
    engine = 1
    if SpkIsWhole(manifest.engine) then engine = Int(manifest.engine)

    ver = {
        v: v
        channelId: sched.channelId
        epochMs: epoch&
        effectiveAtMs: eff&
        startIndex: startIndex
        tapes: items
        bumps: bumps
        block: manifest.block
        ads: ads
        engine: engine
        audioOverlay: SpkTrue(manifest.audioOverlay)
        fwd: []
        back: []
        adCarry: {}
        deckCarry: {}
        built: {}
        builtKeys: []
        plan: invalid
    }
    ' keep versions in order of v
    at = sched.versions.Count()
    sched.versions.Push(ver)
    while at > 0
        if sched.versions[at - 1].v > v
            sched.versions[at] = sched.versions[at - 1]
            at = at - 1
        else
            exit while
        end if
    end while
    sched.versions[at] = ver
    return ""
end function

function SpkVersionAt(sched as Object, t as LongInteger) as Dynamic
    vs = sched.versions
    for i = vs.Count() - 1 to 0 step -1
        if vs[i].effectiveAtMs <= t then return vs[i]
    end for
    best = invalid
    for each ver in vs
        if best = invalid
            best = ver
        else if ver.effectiveAtMs < best.effectiveAtMs
            best = ver
        else if ver.effectiveAtMs = best.effectiveAtMs and ver.v > best.v
            best = ver
        end if
    end for
    return best
end function

' when a newer version takes over after t, or invalid
function SpkNextCutover(sched as Object, ver as Object, t as LongInteger) as Dynamic
    r = invalid
    for each s in sched.versions
        if s.v > ver.v and s.effectiveAtMs > t
            if r = invalid
                r = s.effectiveAtMs
            else if s.effectiveAtMs < r
                r = s.effectiveAtMs
            end if
        end if
    end for
    return r
end function

' One trip through the playlist. k: cycle number (0 starts at the epoch from
' startIndex; negative cycles run backwards from it).
function SpkBuildCycle(ver as Object, k as Integer, cycleStartMs as LongInteger) as Object
    first = 0
    if k = 0 then first = ver.startIndex
    items = ver.tapes
    n = items.Count()
    out = []
    if ver.bumps = invalid
        for j = first to n - 1
            d& = items[j].duration
            out.Push({ type: "video", item: items[j], durMs: d& * 1000& })
        end for
        return out
    end if

    hasAds = (ver.ads <> invalid)
    adOut = invalid
    if hasAds and k >= 0 then adOut = {}
    useDeck = (ver.engine >= 5)
    deckOut = invalid
    if useDeck and k >= 0 then deckOut = {}
    adCarry = invalid
    if hasAds and k >= 1 then adCarry = ver.adCarry[k.ToStr()]
    deckCarry = invalid
    if useDeck and k >= 1 then deckCarry = ver.deckCarry[k.ToStr()]

    channelId = ver.channelId
    seed = ver.v.ToStr() + "." + k.ToStr()
    block = ver.block
    seasonal = (k < 0)
    f& = 0&
    if not seasonal then f& = cycleStartMs
    cycleStart& = f&
    h& = 0&
    sinceAd& = 0&
    cardIndex = 0

    plan = invalid
    slices = invalid
    used = { set: {}, n: 0 }
    fromMs = invalid
    newAds = []
    gapMs& = 0&
    if hasAds
        if ver.plan = invalid then ver.plan = SpkAdPlan(ver)
        plan = ver.plan
        slices = plan.slices
        gapMs& = plan.gapMs
        if adCarry <> invalid
            if adCarry.recent <> invalid
                for each pair in adCarry.recent
                    ix = pair[0]
                    if ix >= 0 and ix < slices.Count()
                        if not used.set.DoesExist(ix.ToStr())
                            used.set[ix.ToStr()] = true
                            used.n = used.n + 1
                        end if
                    end if
                end for
            end if
            if adCarry.fromMs <> invalid then fromMs = adCarry.fromMs
        end if
    end if
    deck = invalid
    if useDeck then deck = SpkNewDeck(deckCarry)

    last = n - 1
    for j = first to last
        item = items[j]
        d& = item.duration
        d& = d& * 1000&
        out.Push({ type: "video", item: item, durMs: d& })
        f& = f& + d&
        h& = h& + d&
        sinceAd& = sinceAd& + d&
        carded = false
        if block <> invalid
            if j < last and h& < block.lengthMs
                sting = SpkPickSting(block.stings, j, channelId, seed)
                c& = block.cardMs
                if sting <> invalid then c& = sting.lengthMs
                out.Push({ type: "up-next", breakIndex: j, cardIndex: cardIndex, sting: sting, durMs: c& })
                cardIndex = cardIndex + 1
                f& = f& + c&
                h& = h& + c&
                sinceAd& = sinceAd& + c&
                carded = true
            end if
        end if
        if not carded
            h& = 0&
            at& = f&
            if seasonal then at& = ver.epochMs
            if useDeck
                cb = SpkDeckDraw(deck, ver.bumps.channel, channelId, seed, at&)
            else
                cb = SpkPickBump(ver.bumps.channel, j, channelId, seed, at&)
            end if
            pb = SpkPickBump(ver.bumps.platform, j, "spelunkr", seed, at&)
            if cb <> invalid and pb <> invalid
                chAudio = SpkPickAudio(ver.bumps.channelAudio, cb.id, j, seed)
                plAudio = SpkPickAudio(ver.bumps.platformAudio, pb.id, j, seed)
                didAd = false
                if hasAds
                    nxt = items[0]
                    if j < last then nxt = items[j + 1]
                    if (not SpkTrue(item.offAir)) and (not SpkTrue(nxt.offAir)) and sinceAd& >= gapMs&
                        from& = f& - sinceAd&
                        if fromMs <> invalid then from& = fromMs
                        fromMs = invalid
                        ix = SpkPickAd(plan, used, SpkYear(item), f&, from&)
                        if ix >= 0
                            newAds.Push([ix, f&])
                            sl = slices[ix]
                            openMs& = 3500& + SpkSlidesMs(cb) + 2000&
                            closeMs& = SpkSlidesMs(pb) + 2000&
                            adMs& = sl.lengthMs
                            out.Push({ type: "bump-break", half: "open", breakIndex: j, channelBump: cb, channelAudio: chAudio, durMs: openMs& })
                            out.Push({ type: "ad", breakIndex: j, slice: sl, sliceIndex: ix, durMs: adMs& })
                            out.Push({ type: "bump-break", half: "close", breakIndex: j, platformBump: pb, platformAudio: plAudio, durMs: closeMs& })
                            f& = f& + openMs& + adMs& + closeMs&
                            sinceAd& = closeMs&
                            if adOut <> invalid then adOut.fromMs = f&
                            didAd = true
                        end if
                    end if
                end if
                if not didAd
                    b& = 3500& + SpkSlidesMs(cb) + 2000& + 300& + SpkSlidesMs(pb) + 2000&
                    out.Push({ type: "bump-break", half: "", breakIndex: j, channelBump: cb, platformBump: pb, channelAudio: chAudio, platformAudio: plAudio, durMs: b& })
                    f& = f& + b&
                    sinceAd& = sinceAd& + b&
                end if
            end if
        end if
    end for

    if hasAds and adOut <> invalid
        if newAds.Count() = 0
            if fromMs <> invalid
                adOut.fromMs = fromMs
            else
                adOut.fromMs = cycleStart&
            end if
        end if
        cut& = f& - 86400000&
        recent = []
        if adCarry <> invalid
            if adCarry.recent <> invalid
                for each pair in adCarry.recent
                    if pair[1] >= cut& then recent.Push(pair)
                end for
            end if
        end if
        for each pair in newAds
            if pair[1] >= cut& then recent.Push(pair)
        end for
        adOut.recent = recent
        nk = (k + 1).ToStr()
        if not ver.adCarry.DoesExist(nk) then ver.adCarry[nk] = adOut
    end if
    if deck <> invalid and deckOut <> invalid
        deckOut.order = deck.order
        deckOut.pos = deck.pos
        deckOut.key = deck.key
        deckOut.recent = deck.recent
        nk = (k + 1).ToStr()
        if not ver.deckCarry.DoesExist(nk) then ver.deckCarry[nk] = deckOut
    end if
    return out
end function

function SpkCycleLength(entries as Object) as LongInteger
    total& = 0&
    for each e in entries
        total& = total& + e.durMs
    end for
    return total&
end function

sub SpkRemember(ver as Object, k as Integer, entries as Object)
    key = k.ToStr()
    if ver.built.DoesExist(key) then return
    ver.built[key] = entries
    ver.builtKeys.Push(key)
    if ver.builtKeys.Count() > 3
        old = ver.builtKeys.Shift()
        ver.built.Delete(old)
    end if
end sub

' { startMs, lengthMs } of cycle k
function SpkCycleBounds(ver as Object, k as Integer) as Object
    if k >= 0
        fwd = ver.fwd
        while fwd.Count() <= k
            s& = ver.epochMs
            c = fwd.Count()
            if c > 0 then s& = fwd[c - 1].startMs + fwd[c - 1].lengthMs
            entries = SpkBuildCycle(ver, c, s&)
            SpkRemember(ver, c, entries)
            fwd.Push({ startMs: s&, lengthMs: SpkCycleLength(entries) })
        end while
        return fwd[k]
    end if
    back = ver.back
    r = -k - 1
    while back.Count() <= r
        s& = ver.epochMs
        c = back.Count()
        if c > 0 then s& = back[c - 1].startMs
        entries = SpkBuildCycle(ver, -(c + 1), 0&)
        SpkRemember(ver, -(c + 1), entries)
        l& = SpkCycleLength(entries)
        back.Push({ startMs: s& - l&, lengthMs: l& })
    end while
    return back[r]
end function

function SpkCycleAt(ver as Object, t as LongInteger) as Integer
    if t >= ver.epochMs
        k = 0
        while true
            b = SpkCycleBounds(ver, k)
            if t < b.startMs + b.lengthMs then return k
            k = k + 1
        end while
    end if
    k = -1
    while SpkCycleBounds(ver, k).startMs > t
        k = k - 1
    end while
    return k
end function

function SpkCycleEntries(ver as Object, k as Integer) as Object
    key = k.ToStr()
    hit = ver.built[key]
    if hit = invalid
        b = SpkCycleBounds(ver, k)
        hit = ver.built[key]
        if hit = invalid
            hit = SpkBuildCycle(ver, k, b.startMs)
            SpkRemember(ver, k, hit)
        end if
    end if
    if hit.Count() > 0
        if hit[0].offMs = invalid
            off& = 0&
            vi = 0
            if k = 0 then vi = ver.startIndex
            for each e in hit
                e.offMs = off&
                off& = off& + e.durMs
                if e.type = "video"
                    e.videoIndex = vi
                    vi = vi + 1
                end if
            end for
        end if
    end if
    return hit
end function

' What is on air at t:
' { entry, index, startMs, endMs, version, cycle, ver, entries }
function SpkOnAir(sched as Object, t as LongInteger) as Dynamic
    ver = SpkVersionAt(sched, t)
    if ver = invalid then return invalid
    k = SpkCycleAt(ver, t)
    b = SpkCycleBounds(ver, k)
    entries = SpkCycleEntries(ver, k)
    rel& = t - b.startMs
    lo = 0
    hi = entries.Count() - 1
    while lo < hi
        md = (lo + hi + 1) \ 2
        if entries[md].offMs <= rel&
            lo = md
        else
            hi = md - 1
        end if
    end while
    e = entries[lo]
    s& = b.startMs + e.offMs
    en& = s& + e.durMs
    cut = SpkNextCutover(sched, ver, t)
    if cut <> invalid
        if cut < en& then en& = cut
    end if
    return { entry: e, index: lo, startMs: s&, endMs: en&, version: ver.v, cycle: k, ver: ver }
end function
