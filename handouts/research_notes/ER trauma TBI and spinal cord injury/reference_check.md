# Reference check against PubMed (handout refs 1-126)

Started 2026-11-20. Method: PMIDs from trauma-reference-ledger.md and research notes; metadata via PubMed get_article_metadata; compared authors, title, journal, year, vol(issue):pages, DOI.

Skipped (not journal articles): 2, 3, 24, 25, 27, 28, 34, 50, 72, 87, 97, 99, 105, 108, 110, 113, 120, 122, 123

## Progress log
Note: handout was refreshed mid-check (titles of 76, 82, 83, 115, 119, 121, 125, 126 updated); comparisons use the refreshed list.

### Batch 1 (refs 1, 4-18)
- 1 OK. 4 OK. 6 OK. 7 OK. 9-18 OK (PubMed matches authors, title, vol/issue/pages, DOI).
- 5: PubMed title is "...significant haemorrhage (CRASH-2): a randomised, placebo-controlled trial" -> add subtitle.
- 8: JAMA Surg 2021;156(1):11-20 matches (epub 2020); title "(STAAMP)" is an added label (title already reviewed per coordinator).

### Batch 2 (refs 19-23, 26, 29-43) -- metadata tool returns max 20 PMIDs per call
- OK: 19, 20, 21, 22, 23, 30, 31, 32, 33, 35, 37, 39, 40, 41, 42, 43.
- 26: real title "Andexanet for Factor Xa Inhibitor-Associated Acute Intracerebral Hemorrhage." (no "(ANNEXA-I)").
- 29: real title ends "(PATCH): a randomised, open-label, phase 3 trial."
- 36: real title ends "(CRASH-3): a randomised, placebo-controlled trial." Author = CRASH-3 trial collaborators only.
- 38: third author is Brasel KJ (not Kerby JD); ROC Investigators.

### Batch 3 (refs 44-64)
- OK: 44, 45 (epub, no vol yet), 47, 48, 49, 51, 52, 53, 55, 56, 57, 58, 59, 60, 61, 64. 46 and 54 authors/vol/pages OK (titles cleared by coordinator; PubMed titles lack/extend trial labels).
- 62: Fehlings MG, Tetreault LA, Hachem L, et al. Global Spine J. 2024;14(3 Suppl):174S-186S (handout lacks co-authors and vol/pages).
- 63: Neal CJ, Rodrigues-Pinto R, Grassner L, et al. Global Spine J. 2026;16(4):1700-1706 (handout lacks vol/pages).

### Batch 4 (refs 65-85)
- OK: 68, 69, 70, 71, 73, 74, 75, 77, 78, 80, 81, 84, 85.
- 65: DOI given is the Circulation exec summary DOI; JACC full guideline DOI is 10.1016/j.jacc.2018.10.044; full title adds ": a report of the ACC/AHA Task Force on Clinical Practice Guidelines and the Heart Rhythm Society".
- 66: real title "...acute spinal-cord injury. Results of the Second National Acute Spinal Cord Injury Study."
- 67: real title "...acute spinal cord injury. Results of the Third National Acute Spinal Cord Injury Randomized Controlled Trial." (PubMed has no DOI).
- 76: authors Zampieri FG, Schmidt RC, Besen BAMP; no page/article no. in PubMed yet.
- 79: real title has no "(PREVENT CLOT)".
- 82: Niziolek GM, Mangan L, Weaver C, et al. 83: Alexander KM, Butts CC, Lee YL, et al. (other fields OK)

### Batch 5 (refs 86-111)
- OK: 86, 88, 89, 90, 91, 92, 93, 95, 96, 98, 100, 102, 103, 104, 106, 107, 109, 111.
- 94: real title "Trauma in pregnancy: a systematic review, meta-analysis, and practice management guideline from the Eastern Association for the Surgery of Trauma."
- 101: Suzuki T, Inui T, Sakai M, et al. (other fields OK).

### Batch 6 (refs 112-126 + Circulation exec summary for 65)
- OK: 112, 114, 115, 116, 117 (PubMed indexes 2nd author as "Brad Hall A" = A. Brad Hall), 118, 124, 125, 126.
- 65: Circulation exec summary verified PMID 30586771, 2019;140(8):e333-e381, doi:10.1161/CIR.0000000000000627. JACC full guideline PMID 30412709 doi:10.1016/j.jacc.2018.10.044.
- 119: first author is Porter BA (not AL); third is Hewes PD (not A).
- 121: only 4 authors (Silva CR, Nagy J, Zullo AR, Greene RA) -> drop "et al".
- 67: candidate DOI 10.1001/jama.1997.03540440031029 not resolvable via PubMed ID converter; left without DOI.
- 26: PubMed group author "ANNEXA-I Investigators" (keeps trial name once "(ANNEXA-I)" is dropped from the title).

## Summary (complete)
- Corrections needed: 5, 26, 29, 36, 38, 62, 63, 65, 66, 67, 76, 79, 82, 83, 94, 101, 119, 121.
- Confirmed correct: 1, 4, 6-23, 30-33, 35, 37, 39-49, 51-61, 64, 68-71, 73-75, 77, 78, 80, 81, 84-86, 88-93, 95, 96, 98, 100, 102-104, 106, 107, 109, 111, 112, 114-118, 124-126.
- Coordinator-cleared titles still differing from PubMed (not flagged): 8 (adds STAAMP), 14 (adds SWiFT), 15 (adds TOWAR), 46 (drops ": randomised placebo-controlled trial"), 54 (adds ProTECT III).
- Not found: none. Skipped (not journal articles): 2, 3, 24, 25, 27, 28, 34, 50, 72, 87, 97, 99, 105, 108, 110, 113, 120, 122, 123.
