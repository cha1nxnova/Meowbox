# Handoff: trauma, TBI and spinal cord injury in the ER (2026-11-20)

Owner: Kadin Booker, P4 pharmacy student, emergency medicine rotation. Same format as the shock and agitation handouts: handout plus presenter's copy, ER stabilization only, each society's own grade wording, dagger on anything not confirmed in a primary source, Kadin's voice, no em dashes or semicolons.

## Documents (Claude Docs are the source of truth)

| Item | Link | Doc id | Tab file id | Body node id |
| --- | --- | --- | --- | --- |
| Handout | https://claude.ai/artifact/9Umtx7gYkJtiQqLZzTP4ow | 44a9dbe9-07aa-4bc7-993a-7cbac09c373e | 1f12c261-1d95 | 4f4b2303-2e76 |
| Presenter's copy | https://claude.ai/artifact/Ga3mhYnmemnd29Md5FJSY3 | 7e1654f0-bef2-4e5d-bb6c-4a21b328e694 | 3005d167-cd02 | 646bea85-3987 |

Diagram widgets in the handout: hemorrhage algorithm 473fd624-0f69, TBI algorithm de900ca8-e3af (both checked as rendered images).
`trauma-tbi-sci-handout.md` is a markdown snapshot. `trauma-reference-ledger.md` maps reference numbers to PMIDs.

## What was done

- Six research tracks, notes in `research_notes/ER trauma TBI and spinal cord injury/`, every fact tagged verified, secondary or recalled.
- Titles and DOIs of 40 journal references checked against PubMed; 8 titles corrected.

## Review and reference check (done Nov 20, 2026)

- **Adversarial review** against the six notes files is done and every finding was fixed in both docs. The main fixes:
  - 4F-PCC fixed dose reconciled (TQIP 2,000 units vs ACS 2026 3,000 units, now shown side by side with "use one institutional dose").
  - Warfarin PCC row now carries the label caps.
  - The TBI TXA row now mentions ACS's 2 g bolus.
  - Pediatric calcium added (CaCl2 5 mg/kg or gluconate 50 mg/kg, no faster than 100 mg/min), checked in the ACS PDF.
  - Cryo clarified as single-donor units. 23.4% saline is now central or IO preferred, peripheral only under a written policy.
  - The succinylcholine window is 24 to 72 h everywhere. Platelet TBI threshold (TQIP 75k), the neurogenic shock MAP ceiling, and daggers on penetrating abdominal antibiotic doses were added.
  - Omissions added: TXA past 3 h only with viscoelastic fibrinolysis, post-intubation sedation starts, TBI antibiotic stewardship.
- **PubMed check of all 126 references** is done (log in `research_notes/ER trauma TBI and spinal cord injury/reference_check.md`). 18 corrections applied: authors on 38, 119 and 121, the DOI on 65, volume and pages on 62 and 63, and titles on 5, 26, 29, 36, 66, 67, 79 and 94.
- **Final consistency pass** (scripted plus by hand): no em dashes, no prose semicolons, uncited references are exactly the background list, and doses match between the handout, both diagrams and the presenter's copy. Last fixes: the unverified-values note no longer says "central-line-only" for 23.4%, daggers added to "shock-reduced" RSI doses in the TBI chart and diagram, and presenter case 4 now says rocuronium "after the first day".

## Open verification items

1. ATLS 11 details beyond xABCDE (manual paywalled).
2. Doses no guideline prints: open fracture and penetrating abdominal antibiotic doses, hypertonic saline volumes and routes, levetiracetam and fosphenytoin loads, protamine, desmopressin 0.3 mcg/kg, RSI shock doses, steroid bolus timing. All daggered.
3. Abstract-only sources: EAST 2011 open fractures, EAST 2020 BCVI, AAST/ACS 2022 VTE protocol, WTA 2023 to 2026 algorithms, NCS/SCCM 2026 reversal update.
4. Pending trials: CRASH-4 (primary completion Dec 2026), BOOST-3, CAVALIER, MATIC-2, NCT06451133 (SCI MAP).
5. PROCOAG citation: the shock handout already prints JAMA 2023;329:1367-1375 (correct). A researcher's claim that it said volume 330 was wrong.
6. Site-specific checklist at the end of the presenter's copy.

## Notes for next time

- Three research agents at once worked; six spread over two waves finished. The review agents hit the 5-hour limit the first time and were resumed with SendMessage after the reset, so start reviews earlier in the session.
- New big sources this round: ACS TQP Best Practices Guidelines: Transfusion in Trauma (November 2026) and NCS/SCCM antithrombotic reversal focused update (September 2026).
