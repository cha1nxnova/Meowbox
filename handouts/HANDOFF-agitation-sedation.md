# Handoff: acute agitation and procedural sedation in the ER (2026-11-16)

Owner: Kadin Booker, P4 pharmacy student, emergency medicine rotation. Format follows the shock states handoff (handout plus presenter's copy, ER stabilization only, society grade wording, dagger on anything not confirmed in a primary source, Kadin's voice, no em dashes or semicolons).

## Documents (Claude Docs are the source of truth)

| Item | Link | Doc id | Tab file id | Body node id |
| --- | --- | --- | --- | --- |
| Handout | https://claude.ai/artifact/AgfF6UinAJMD9bFWGs9jJ6 | 4e6bd2b4-1c9a-4955-a6ee-e26071eb08c7 | 07adfa50-4c8f | 4265429f-2707 |
| Presenter's copy | https://claude.ai/artifact/2ci3He47jjV7sLUrZcJZ2y | 0d157649-5893-4332-82d7-cd10f2d8cb8a | 885ca033-678f | 87acdb8b-c8cf |

Diagram widgets in the handout: agitation algorithm bb5af3b7-488a, sedation algorithm f8ade5ef-0f0b.
`agitation-sedation-handout.md` is a markdown snapshot taken after the review fixes. The presenter's copy holds speaking notes keyed to the handout sections and does not repeat the charts (a change from the shock format, to keep one copy of every number).

## What was done

- Five research tracks, notes in `research_notes/ER agitation and procedural sedation/` with every fact tagged verified, secondary or recalled.
- Reference list (1 to 122) checked against PubMed by DOI: all 94 journal DOIs resolve to the right article. Paraphrased titles and missing volumes were corrected.
- One adversarial review against the notes: 13 major and about 20 minor issues. All majors applied except where noted below.

## Review decisions

| Issue | Decision |
| --- | --- |
| Pediatric naloxone printed as mg/kg (label is mg increments) | Fixed |
| Ketamine duration taken from anesthetic dose, Taylor 2017 comparator, "slowest antipsychotic", Martel respiratory depression arms | Fixed |
| Ketofol 0.5 mg/kg start, ASA vs ACEP disagreement, benztropine units, hyperactive delirium description | Dagger added or reworded |
| ICP statement overstated, eye data not in reference list | Reworded, eye data daggered (Halstead 2012, Drayna 2012, Wadia 2014 not added) |
| Numbers cited to the wrong source (older-adult droperidol dose, prehospital intubation range, egg and soy series, cardioversion recovery) | Daggered. Calver 2013, Cole 2018, Olives 2016, Bagley 2021, Bauer 2022 were not added to the reference list |
| Olanzapine plus benzodiazepine inconsistency, ketamine and schizophrenia | Cross-notes added |
| Omissions: olanzapine repeat interval, midazolam after opioid, dissent on combinations, physostigmine cautions, succinylcholine discontinuation | Added |
| Ketamine label phrase "must be diluted" not verbatim | Not changed. Label reads "Do not administer the 100 mg/mL concentration intravenously without proper dilution" |
| Lorazepam 6 to 8 h (Ativan label) and ketamine sedation doses cited to the unread 2011 guideline | Not changed |
| Diagrams | Agitation diagram checked as a rendered image. Sedation diagram uses the same template and was not viewed |

## Open verification items

1. ACEP severe agitation policy (Ann Emerg Med 2024;83(1):e1-e30): Level B and C wording is from the lead author's ACEP Now summary. Check against the PDF.
2. ACEP 2014 sedation policy wording is from the ABEM digest.
3. ACEP 2021 hyperactive delirium task force report was not read.
4. Rescue doses, onset and duration columns, and oral agitation doses are standard values without a primary source.
5. Pediatric agitation doses omitted (Gerson 2019 table unread).
6. Igalmi at-home decision (FDA date November 14, 2026) and ASHP shortage status were not confirmed.
7. Site-specific checklist is at the end of the presenter's copy.
8. The exported PDF pages were not inspected.

## Notes for next time

- Launch research tracks two or three at a time. Five at once hit the account rate limit and three had to be resumed.
- Ask each researcher to write its notes file early and append.
- Docs find-and-replace is all or nothing per call, so keep each batch to verified strings.
