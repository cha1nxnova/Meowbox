# ER pharmacist role, medication safety, and 2024 to 2026 updates: acute agitation and procedural sedation

Notes compiled 16 Nov 2026 (all web/API sources accessed 2026-11-16). US ER setting.

Evidence tags used on every fact:
- **[verified]** = I read it in the primary document, label text, API record or abstract (abstracts retrieved from PubMed / Europe PMC; attribution: "according to PubMed").
- **[secondary]** = taken from a digest, news item, search-result summary or review; primary not opened.
- **[recalled]** = from memory, NOT confirmed in this session. Check before printing.

Access problems the writer should know about: acep.org, ashp.org, drugs.com and ismp.org pages returned HTTP 403 to automated fetches, so ACEP policy text, the ASHP shortage list and ISMP newsletters could NOT be read directly. FDA shortage data (openFDA API) and DailyMed label text WERE read directly.

---

## 1. Evidence for ER pharmacist involvement (sedation, RSI, agitation, resuscitation)

### Takeaway
The measured benefit of a bedside ER pharmacist is mostly on process outcomes: faster time to post-intubation sedation/analgesia (roughly 9 to 20 min with a pharmacist vs 28 to 49 min without), fewer recorded medication errors in resuscitations, and error interception during verbal orders and consults. I found NO study that isolates pharmacist impact on ER procedural sedation or on adult agitation management; the pharmacist evidence there is indirect (order sets, RSI, resuscitation).

### Cited Findings

**Guidelines and position documents**
- ASHP guideline exists and is the anchor citation: Ortmann MJ, Johnson EG, Jarrell DH, et al. ASHP Guidelines on Emergency Medicine Pharmacist Services. Am J Health Syst Pharm 2021;78(3):261-275. doi:10.1093/ajhp/zxaa378. PMID 33480409. **[verified: citation only; no abstract, full text not read]** — [DOI](https://doi.org/10.1093/ajhp/zxaa378)
- The ASHP guideline lists direct patient care roles including participation in resuscitation, RSI and procedural sedation, medication preparation at the bedside, and high-risk medication oversight. **[recalled]** (content not read this session)
- ACEP policy statement "Clinical Pharmacist Services in the Emergency Department": originally approved June 2015, revised January 2021. **[secondary: search-result summary of the ACEP PDF; page blocked]** — [ACEP](https://acep.org/patient-care/policy-statements/clinical-pharmacist-services-in-the-emergency-department)
- Morgan SR, Acquisto NM, Coralic Z, et al. Clinical pharmacy services in the emergency department. Am J Emerg Med 2018;36(10):1727-1732. PMID 29475633. Narrative review; says ER pharmacists "work alongside emergency physicians and nurses at the bedside to optimize pharmacotherapy, improve patient safety, increase efficiency and cost-effectiveness". **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.ajem.2018.01.056)
- Hampton JP, Hommer K, Musselman M, Bilhimer M. Rapid sequence intubation and the role of the emergency medicine pharmacist: 2022 update. Am J Health Syst Pharm 2023;80(4):182-195. PMID 36306474. Review; "The EMP is a key member of the bedside care team". **[verified: abstract]** — [DOI](https://doi.org/10.1093/ajhp/zxac326)
- 2026 ACCP EMED PRN opinion (endorsed by SAEM AEMP and SEMP): Gilbert BW, Zimmerman DE, Robertson A, et al. Role of the Emergency Medicine Pharmacist in the Management of Boarding Patients. J Am Coll Clin Pharm 2026 (June). PMID 42161376. Position: ER pharmacists "should ideally be resourced to remain focused on time-sensitive, high-risk medication management" and "not be used as default providers for all pharmacotherapy needs during ED boarding". **[verified: abstract]** — [DOI](https://doi.org/10.1002/jac5.70227)
- Pharmacist medication administration: Guidos J, Singh R, Smith A, Feldman R. From policy to practice: implementation of emergency medicine pharmacist medication administration. Am J Health Syst Pharm 2025 (Dec 16). PMID 40452555. Framework and checklist; notes state scope-of-practice variability as the main barrier. **[verified: abstract]** — [DOI](https://doi.org/10.1093/ajhp/zxaf130)

**Time to drug after intubation (closest evidence to "sedation" work)**
- Amini A, et al. Am J Health Syst Pharm 2013;70(17):1513-1517. PMID 23943183. Retrospective cohort, level 1 trauma centre, rocuronium RSI. Pharmacist present vs absent: mean time to post-intubation sedation 9 min vs 28 min (p = 0.007); analgesia 21 vs 44 min (p = 0.057). Sedated by 5/10/15 min: 33%/53%/63% vs 11%/26%/41%. **[verified: abstract]** — [DOI](https://doi.org/10.2146/ajhp120673)
- Johnson EG, et al. J Emerg Med 2015. PMID 25797938. n = 106 (76 rocuronium, 30 succinylcholine). Time to sedation/analgesia 34 ± 36 min (rocuronium) vs 16 ± 21 min (succinylcholine), p = 0.002. With an ER pharmacist present: 20 ± 21 min vs 49 ± 45 min without (p < 0.001). **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.jemermed.2014.12.028)
- Robey-Gavin E, Abuakar L. J Emerg Med 2016;50(2). PMID 26433427. Before/after, 41 patients per group. Post-intubation analgesia rose from 20% to 49% (p = 0.005); during pharmacist hours 50% to 85%. Sedation without analgesia fell 73% to 51% (p = 0.04). Time to analgesia fell from 98 to 45 min. **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.jemermed.2015.07.029)
- Context for the "sedation gap": Barnden C, et al. Emerg Med Australas 2026. PMID 41766465. n = 158 Australian ER RSIs; median time from paralysis to post-intubation sedation/analgesia 7.5 min (IQR 4.0-14.0); ketamine was the induction agent in 75.9%, rocuronium in 95.6%. (No pharmacist arm.) **[verified: abstract]** — [DOI](https://doi.org/10.1111/1742-6723.70238)

**Error interception**
- Patanwala AE, et al. Ann Emerg Med 2012;59(5):369-373. PMID 22226174. Prospective, 4 US ERs, 1,000 pharmacist-hours, 16,446 patients: 364 confirmed error interceptions. Source of interception: consultative activities 51.4% (n = 187), order review 34.9% (n = 127), other 13.7%. Order type: written/computerised 54.4%, VERBAL orders 32.7% (n = 119). Phase: prescribing 82.4%. Most common type: wrong dose 44.2% (n = 161). **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.annemergmed.2011.11.013)
- Patanwala AE, et al. Int J Pharm Pract 2011. PMID 21899616. Single ER, 7 months, 237 interceptions: severity minor 18%, significant 67%, serious 15%; probability of harm medium 17%, high 1%. **[verified: abstract]** — [DOI](https://doi.org/10.1111/j.2042-7174.2011.00122.x)
- Ernst AA, et al. Am J Emerg Med 2012;30(5):717-725. PMID 21665406. Level 1 trauma centre, resuscitations and traumas, 694 patients (242 pharmacist-present, 452 absent). Patients with recorded errors: 3% (6) vs 30% (137); adjusted OR 13.5 (95% CI 5.7-31.9) for errors when pharmacist absent. Design caveat: prospective (present) vs retrospective (absent) data collection. **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.ajem.2011.05.002)
- Bakhsh HT, et al. Int J Risk Saf Med 2014. PMID 25420761. Psychiatric patients BOARDING in a community ER: 288 medication errors in 100 patients; 65 patients had at least one; 89% were errors of omission; 152 "significant", 3 "serious". **[verified: abstract]** — [DOI](https://doi.org/10.3233/JRS-140634)
- Accomando M, et al. Ment Health Clin 2022;12(3):187-192. PMID 35801158. Pharmacist medication reconciliation for behavioural health boarders: 298 discrepancies among 484 medications in 54 patients; no change in time to home-medication administration (median 11.5 vs 10.8 h, P = .179). **[verified: abstract]** — [DOI](https://doi.org/10.9740/mhc.2022.06.187)

**Resuscitation and trauma "code" response**
- Roman C, et al. Pharmacists in Trauma RCT. Emerg Med J 2024. PMID 38749667. Australian level 1 trauma centre, 82 analysed (39 control, 43 pharmacist). First-dose analgesia within 30 min: 64.1% vs 83.7% (RR 1.31, 95% CI 1.0-1.71; p = 0.042). Median time to analgesia 28 (22-35) vs 20 (15-26) min, p = 0.025. Pharmacist prescribed the first analgesic in 88.4%. Note: pharmacist prescribing model, not US scope. **[verified: abstract]** — [DOI](https://doi.org/10.1136/emermed-2022-212934)
- Currey EM, et al. Am J Emerg Med 2023. PMID 37939522. Systematic review, 30 studies (29 cohort, 1 RCT): time to medication administration was the most frequent outcome, with significant benefit in 23 studies; few showed mortality differences; only 8/30 low risk of bias. **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.ajem.2023.10.020)
- Patel H, et al. Pharmacy (Basel) 2025;13(4):89. PMID 40700260. Scoping review, 26 records, cardiac arrest and trauma: ACLS compliance and medication errors most commonly reported; quantitative pooling not feasible. **[verified: abstract]** — [DOI](https://doi.org/10.3390/pharmacy13040089)

**Cost avoidance**
- PHARM-EM: Rech MA, et al. Crit Care Explor 2021;3(4):e0406. PMID 33912836. 88 ER pharmacists, 49 US centres, 917 shifts: 13,984 interventions on 8,602 patients; $7,531,862 cost avoidance; $538.61 per intervention; $8,213.59 per shift; annualised $1,971,262 per pharmacist; benefit-to-salary ratio $1.4:1 to $10.6:1. "Hands-on care" was the largest category (3,533 interventions; $2,836,811). **[verified: abstract]** — [DOI](https://doi.org/10.1097/cce.0000000000000406)

**Agitation-specific pharmacy interventions (order sets)**
- Mills KP, et al. Am J Health Syst Pharm 2026;83(11):e390-e399. PMID 40576965. Paediatric ER (St. Louis Children's), 3,756 encounters (1,742 pre, 2,014 post) around a medication-focused agitation order set (olanzapine PO/IM first line, diphenhydramine second line). After: olanzapine and chlorpromazine use up, haloperidol and lorazepam down; FEWER ADC overrides, less combination therapy, shorter physical restraint duration; no increase in proportion medicated. Abstract gives no percentages. **[verified: abstract]** — [DOI](https://doi.org/10.1093/ajhp/zxaf117)
- Sedation team with a pharmacist (outpatient paediatric, not ER): Pero-Cleveland E, et al. Paediatr Anaesth 2025. PMID 41118132. n = 35 (17 pre, 18 post). Sedation time 40 min (IQR 30-54) vs 75 min (45-100), p = 0.02; 15 pharmacist interventions in 6 patients (interactions, premedication choice, dose). **[verified: abstract]** — [DOI](https://doi.org/10.1111/pan.70069)

### Inferences
- The most defensible handout claim: pharmacist presence roughly halves time to post-intubation sedation in three small single-centre retrospective studies; all predate 2017 and none are randomised.
- One-third of intercepted errors arose from verbal orders (Patanwala 2012). Agitation and procedural sedation are both verbal-order, ADC-override situations, so this is the best numerical argument for bedside presence.
- Paediatric order-set data (Mills 2026) is the only 2024 to 2026 study linking a pharmacy-built agitation tool to fewer ADC overrides.

### Gaps
- No study found of ER pharmacist presence at procedural sedation (dosing accuracy, adverse events). PubMed and Europe PMC title searches returned none.
- No adult study found isolating pharmacist impact on time to sedation or rescue dosing in agitation.
- ASHP 2021 guideline and ACEP pharmacist policy text not read (no abstract; sites blocked).

---

## 2. Medication-error literature and drug preparation facts

### Takeaway
Label-verified preparation facts are solid (below). The brief's "6 hours for drawn-up propofol syringes" is NOT in the current Diprivan label or the three generic labels I read: all say 12 hours. I could not open any ISMP document, so ISMP-attributed items are secondary or recalled.

### Cited Findings

**Ketamine**
- Ketalar label (Par, DailyMed, published 26 Mar 2026): supplied as 200 mg/20 mL (10 mg/mL), 500 mg/10 mL (50 mg/mL) and 500 mg/5 mL (100 mg/mL) multiple-dose vials. **[verified: label]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063)
- Same label: "Do not administer the 100 mg/mL concentration of KETALAR intravenously without proper dilution"; dilute with an equal volume of SWFI, NS or D5W and use immediately. "The 10 mg/mL and 50 mg/mL concentrations ... may be administered intravenously ... without dilution. The 100 mg/mL concentration ... may be administered intramuscularly ... without dilution." **[verified: label]** — same link
- Label anaesthetic IM dose: 6.5 to 13 mg/kg (9 to 13 mg/kg gives surgical anaesthesia in 3 to 4 min lasting 12 to 25 min). This is the anaesthesia dose, higher than agitation doses used in practice. **[verified: label]** — same link
- Tenfold error, published case: 950 mg IV given instead of 95 mg when a 100 mg/mL vial was taken in place of 10 mg/mL; only effect was prolonged emergence. Warner LL, Smischney N. Am J Case Rep 2018;19:10-12. PMID 29295971. **[verified: abstract]** — [DOI](https://doi.org/10.12659/ajcr.906205). AHRQ PSNet WebM&M discusses the same type of event (Jan 2021) and recommends concentrated vials be differentiated/segregated. **[secondary]** — [PSNet](https://psnet.ahrq.gov/web-mm/unintentional-ketamine-overdose-operating-room-mixing-ampules)
- Paediatric iatrogenic IM overdose of 20 mg/kg with minimal toxicity: Bowman CF, et al. Pediatr Emerg Care 2021;37(12):e1711-e1713. PMID 30829847. **[verified: abstract]** — [DOI](https://doi.org/10.1097/pec.0000000000001783)
- Paediatric case: 1 mg/kg ordered, 10 mg/kg given through use of 100 mg/mL instead of 10 mg/mL (EMSC Pediatric Readiness toolkit). **[secondary]** — [EMSC](https://emscimprovement.center/domains/pediatric-readiness-project/readiness-toolkit-checklist/section-4-improve/patient-and-medication-safety/key-points-on-medication-errors/)
- ISMP has recommended that labels state total drug per total volume as the primary expression after a ketamine labelling error. **[secondary: search summary of ISMP Nurse AdviseERR Dec 2018; not opened]** — [ISMP PDF](https://www.ismp.org/sites/default/files/attachments/2018-12/NurseAdviseERR201812.pdf)

**Propofol**
- Diprivan label (Fresenius Kabi, DailyMed, published 22 Sep 2025): contains 0.005% disodium edetate "to inhibit the rate of growth of microorganisms, for up to 12 hours, in the event of accidental extrinsic contamination". "Administration should commence promptly and be completed within 12 hours after the vial has been opened." Tubing and unused drug discarded at end of procedure or at 12 hours. Single-patient use. Use a sterile vent spike; label the syringe with date and time the vial was opened. **[verified: label]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e3105799-a4b6-f3f4-e6e2-b2b29bbdb538)
- Syringe limit: Diprivan label says if transferred to a syringe, draw up immediately after opening and complete administration "within 12 hours after the vial has been opened". The string "6 hours" does not appear in the Diprivan label, nor in generic labels from Dr. Reddy's (benzyl alcohol), Hospira (benzyl alcohol/sodium benzoate) or Sagent (metabisulfite); all say "discarded and administration lines changed after 12 hours". **[verified: label text search]** — [Hospira](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=28d7ba00-f824-4e55-139a-03f509c099db); [Sagent](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fa93f173-7858-4d88-860e-76ab97e65c2f)
- A 6-hour limit for propofol transferred out of the original container appeared in older labelling and is still widely taught. **[recalled; not found in any current label read]**
- Contains soybean oil and egg phospholipid; "contraindicated in patients with a history of anaphylaxis to egg" (label wording fragment). **[verified: label]** — Diprivan link above
- Look-alike: propofol and clevidipine (Cleviprex) are both milky white IV emulsions; a VA National PBM communication (2009, reprinted by APSF) advised separate storage and ordering alerts. Clevidipine given for propofol means no sedation plus hypotension; the reverse risks apnoea without airway protection. **[secondary]** — [APSF](https://www.apsf.org/article/propofol-diprivan-and-clevidipine-cleviprex-and-potential-look-alike-concern/)
- Liposomal bupivacaine (Exparel) is also a milky suspension that looks identical to propofol in a syringe (NCC MERP alert, 2012). **[secondary]** — [NCC MERP](https://www.nccmerp.org/sites/default/files/aANAlertMar2012.pdf)

**Olanzapine IM**
- Zyprexa IntraMuscular label: dissolve the 10 mg vial with 2.1 mL Sterile Water for Injection to give about 5 mg/mL; solution clear and yellow; "used immediately (within 1 hour) after reconstitution"; discard unused portion. Volumes: 10 mg = withdraw total contents; 7.5 mg = 1.5 mL; 5 mg = 1 mL; 2.5 mg = 0.5 mL. **[verified: label, DailyMed copy published 2016]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=85688d8f-f2de-408a-8ae2-0976c266c961)
- Same label: reconstitute only with SWFI. Do not combine in a syringe with diazepam (wording continues; diazepam precipitates **[recalled for the reason]**). "Lorazepam injection should not be used to reconstitute ... as this combination results in a delayed reconstitution time." Do not combine in a syringe with haloperidol "because the resulting low pH has been shown to degrade olanzapine over time." **[verified: label]** — same link
- Same label: dose 10 mg IM (5 or 7.5 mg when warranted); assess for orthostatic hypotension before repeat doses; max 3 doses 2 to 4 h apart; safety of total daily dose above 30 mg not evaluated. "Concomitant administration of intramuscular olanzapine and parenteral benzodiazepine is not recommended due to the potential for excessive sedation and cardiorespiratory depression." **[verified: label]** — same link
- Counterpoint to the benzodiazepine warning: Bradley K, et al. Am J Emerg Med 2025;87:51-56. PMID 39489026. Retrospective, 48 vs 48: parenteral olanzapine + benzodiazepine vs haloperidol/droperidol + benzodiazepine within 1 h; SBP fell in both (olanzapine group 132 to 117 mmHg median); no difference in hypotension, oxygen requirement or intubation. **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.ajem.2024.10.044)

**Ziprasidone IM**
- Geodon IM label: IM only, not IV. Add 1.2 mL SWFI, shake vigorously; each mL contains 20 mg. 10 mg = 0.5 mL; 20 mg = 1.0 mL. No preservative; discard unused portion. Dose 10 mg every 2 h or 20 mg every 4 h, max 40 mg/day. **[verified: label, DailyMed copy published 2014]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=136aeec3-b918-4157-b2a7-dd615e36183f)

**Droperidol**
- American Regent label (DailyMed, published 21 Mar 2023): 2.5 mg/mL; 5 mg/2 mL single-dose vial; IV or IM. Boxed warning for QT prolongation/torsade "at doses at or below recommended doses". Label says all patients should have a 12-lead ECG before administration and droperidol should not be given if QTc is above 440 ms (males) or 450 ms (females). Label maximum initial dose 2.5 mg with 1.25 mg increments. **[verified: label]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=147e033d-d997-4ef6-8bb5-a9ba372590b2)
- The agitation doses in the literature (5 to 10 mg IM) therefore exceed the labelled dose and are off-label. **[verified: label dose vs Cole 2025 cohort below]**

**Haloperidol**
- Haloperidol lactate label (Fresenius Kabi, DailyMed, published 1 Oct 2026): 5 mg/mL for IM injection. "HALOPERIDOL INJECTION IS NOT APPROVED FOR INTRAVENOUS ADMINISTRATION. If ... administered intravenously, the ECG should be monitored for QTc prolongation and arrhythmias." QTc above 500 ms flagged as higher torsade risk. **[verified: label]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b1ad2abd-a9d6-44e3-957b-36a73260f4f5)
- Haloperidol decanoate is supplied at 50 mg/mL (and 100 mg/mL **[recalled]**) as an oil depot; 50 mg/mL presentation confirmed in FDA shortage records. **[verified: openFDA record for the 50 mg/mL NDCs]** — [openFDA](https://api.fda.gov/drug/shortages.json?search=generic_name:haloperidol)
- Pennsylvania Patient Safety Authority (Aug 2024): over 200 wrong-route haloperidol events reported to PA-PSRS; most involved lactate given IV; accidental IV decanoate also reported; harms included ventricular tachycardia, apnoea needing intubation, NMS and seizure. **[secondary: search summary; newsletter not opened]** — [PA PSA](https://patientsafety.pa.gov/newsletter/pages/newsletter-aug-2024.aspx)
- Lactate vs decanoate selection mix-ups (5 mg/mL vs 50 mg/mL, tenfold dose and wrong formulation) are a known ISMP topic. **[recalled; no ISMP document read]**

**Midazolam**
- Marketed injection concentrations are 1 mg/mL and 5 mg/mL (FDA shortage records list both for multiple manufacturers, e.g. Hospira 10 mg/10 mL at 1 mg/mL and 10 mg/2 mL at 5 mg/mL). **[verified: openFDA records]** — [openFDA](https://api.fda.gov/drug/shortages.json?search=generic_name:midazolam)
- AHRQ PSNet case: nurse overrode the ADC on a verbal order and removed midazolam 10 mg instead of haloperidol. **[secondary]** — [PSNet](https://psnet.ahrq.gov/web-mm/verbal-orders-and-medication-overrides-dangerous-combination)

**Remimazolam (Byfavo)**
- Label (Acacia, DailyMed, published 28 Feb 2025): Schedule IV. Indicated for induction and maintenance of procedural sedation in adults for procedures lasting 30 minutes or less. 20 mg vial + 8.2 mL 0.9% NaCl = 2.5 mg/mL; swirl, do not shake; reconstituted vial stable up to 8 hours at room temperature. Induction 5 mg IV over 1 min (2.5 to 5 mg for ASA III-IV); maintenance 2.5 mg over 15 s. **[verified: label]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4e1838f2-b999-41a7-a761-d94f09aa531f)

**ISMP high-alert list**
- Current edition is the 2024 ISMP List of High-Alert Medications in Acute Care Settings. **[verified: ECRI/ISMP landing page citation]** — [ECRI/ISMP](https://home.ecri.org/blogs/ismp-resources/high-alert-medications-in-acute-care-settings)
- The 2024 revision followed a 2023 practitioner survey; headline addition was tranexamic acid injection. **[secondary]** — [ECRI/ISMP news](https://home.ecri.org/blogs/ismp-news/ismp-updates-high-alert-medication-list)
- Relevant classes on the list: "moderate sedation agents, IV (e.g., dexmedetomidine, midazolam, lorazepam)" **[secondary: 2025 CE slide deck quoting ISMP]**; "moderate and minimal sedation agents, oral, for children (e.g., chloral hydrate, midazolam, ketamine using the parenteral form)", "anesthetic agents, general, inhaled and IV (e.g., propofol, ketamine)", neuromuscular blockers, opioids **[recalled]**. — [slide deck](https://ce.advocatehealth.org/sites/default/files/course/2025-09/Ensuring%20Safety%20-%20The%20Impact%20of%20ISMP%20Guidelines%20on%20Pharmacy%20Technician%20Practices_Final%20Slides.pdf)

**USP <797> immediate use (bedside ketofol and syringe drawing)**
- Revised <797> published 1 Nov 2022, official 1 Nov 2023. **[secondary]** — [AANA](https://aana.com/practice/clinical-practice/clinical-practice-resources/usp-general-chapter)
- Immediate-use provision: administration must begin within 4 hours of starting preparation; no more than 3 different sterile products; the old 1-hour, emergency-only limit no longer applies. **[secondary: Wolters Kluwer and a BCSCP study guide; USP text not read]** — [Wolters Kluwer](https://wolterskluwer.com/en/expert-insights/what-is-usp-797-and-how-to-stay-compliant)
- Unless given immediately by the preparer (or witnessed), an immediate-use preparation needs a label with ingredient names and amounts, preparer and the 4-hour limit. **[recalled]**

### Inferences
- Ketofol in one syringe is two sterile products, so it fits immediate use. The binding limit for a mixed syringe is the USP 4-hour clock, not the 12-hour propofol label limit; institutional policy is often stricter.
- Ketamine arithmetic the pharmacist can prompt (my calculation from label concentrations): 4 mg/kg IM in an 80 kg adult = 320 mg = 3.2 mL at 100 mg/mL, 6.4 mL at 50 mg/mL, 32 mL at 10 mg/mL. Only the 100 mg/mL vial is practical for IM; the same vial pushed IV undiluted is the tenfold-error scenario.
- Volumes for common IM regimens (from label concentrations): olanzapine 10 mg = about 2 mL; ziprasidone 20 mg = 1 mL; droperidol 5 mg = 2 mL; haloperidol 5 mg = 1 mL.
- Droperidol's label ECG requirement cannot be met in a combative patient; the handout should present it as "label says, practice differs" and cite the observational safety data in section 6.

### Gaps
- No ISMP newsletter could be opened. Specific ISMP reports on ketamine concentration mix-ups, IM vs IV ketamine dose confusion, midazolam 1 vs 5 mg/mL, and haloperidol lactate/decanoate were not confirmed.
- Smart-pump and ADC override literature specific to sedation agents: only the PSNet case and Mills 2026 found.
- Current generic olanzapine IM and ziprasidone IM labels not individually read (DailyMed name search did not return them); brand label text is from older DailyMed copies.
- ISMP Targeted Medication Safety Best Practices 2026-2027: nothing found.

---

## 3. IM injection practicalities

### Takeaway
Physical compatibility of haloperidol + lorazepam + diphenhydramine in one syringe is supported by one bench study (visual plus particle count, 4 hours). Olanzapine must go in its own syringe. Injection-site volume limits were not verified.

### Cited Findings
- Djerroud L, et al. Eur J Hosp Pharm 2023;30(e1):e97-e100. PMID 36002244. Tested 12 IM psychotropics in syringes, inspected to 4 hours: 35 combinations visually compatible, 35 incompatible. Of 8 combinations tested to USP <788>, 6 were physically compatible, "including the triple combinations of lorazepam and haloperidol with either benztropine or diphenhydramine". Physical compatibility only; no chemical stability data. **[verified: abstract]** — [DOI](https://doi.org/10.1136/ejhpharm-2022-003378)
- Olanzapine IM: not in a syringe with diazepam, lorazepam (as diluent) or haloperidol. **[verified: Zyprexa IM label, section 2]**
- "B52" = diphenhydramine 50 mg + haloperidol 5 mg + lorazepam 2 mg; a 2021 review found no RCTs of the IM triple combination. **[secondary]** — [Prim Care Companion CNS Disord](https://www.psychiatrist.com/pcc/intramuscular-b52)
- B52 vs ketamine: Sunshine N, et al. Open Access Emerg Med 2025;17:113-120. PMID 39981414. Retrospective, 51 vs 51 (B52 here used diphenhydramine 25 mg). Time to next sedative (RMST) 2.1 h ketamine vs 4 h B52 (p = 0.032); median additional doses 3 vs 0. **[verified: abstract]** — [DOI](https://doi.org/10.2147/oaem.s486208)
- Typical maximum IM volumes in adults: deltoid about 1 mL (up to 2 mL), vastus lateralis and ventrogluteal about 3 mL (up to 5 mL in some references). **[recalled; no source opened]**
- Droperidol + midazolam in one syringe: no compatibility source found this session. **[gap]**

### Inferences
- B52 at standard concentrations is 3 mL (1 mL each of haloperidol 5 mg/mL, lorazepam 2 mg/mL, diphenhydramine 50 mg/mL **[concentrations for lorazepam and diphenhydramine recalled; lorazepam 2 mg/mL confirmed in FDA records]**), at the upper limit for a single large-muscle site.

### Gaps
- Needle-safety and restraint-injection injury data not searched.
- No primary nursing reference opened for site volumes.

---

## 4. Regulatory and supply status, 2024 to November 2026

### Takeaway
As of the FDA shortage database dated 13 Nov 2026, lorazepam, midazolam, etomidate and dexmedetomidine injections are in current shortage; ketamine, droperidol, propofol, olanzapine, physostigmine and diphenhydramine have no FDA entry. ASHP (which uses a broader definition) reportedly still lists ketamine, propofol and physostigmine, but I could not open the ASHP pages. The Igalmi at-home decision was due 14 Nov 2026 and I found no report of the outcome.

### Cited Findings

**FDA Drug Shortages database (openFDA API, database last updated 2026-11-13)** — [openFDA shortages endpoint](https://api.fda.gov/drug/shortages.json?search=generic_name:lorazepam)

| Drug | FDA status 13 Nov 2026 | Dates in record | Tag |
|---|---|---|---|
| Lorazepam injection | Current shortage (Amphastar, Fresenius, Hikma, Hospira) | First posted 05/03/2018; records updated Oct to Nov 2026 | [verified] |
| Midazolam injection | Current shortage (Avet, Fresenius, Gland, Hikma, Hospira, WG Critical Care); both 1 mg/mL and 5 mg/mL | First posted 04/02/2020; updated Oct to Nov 2026 | [verified] |
| Etomidate injection | Current shortage (Caplin, Eugia, Gland, Hikma, Hospira, Mylan) | First posted 10/05/2022; updated Jun to Nov 2026 | [verified] |
| Dexmedetomidine injection | Current shortage (many manufacturers) | First posted 04/10/2020; updated Aug to Nov 2026 | [verified] |
| Fentanyl citrate injection | Current shortage | First posted 01/01/2012 (Hikma 12/20/2023) | [verified] |
| Rocuronium injection | Current shortage | First posted 02/15/2023 | [verified] |
| Succinylcholine | Fresenius Kabi presentation "To Be Discontinued" | 07/23/2026 | [verified] |
| Haloperidol decanoate 50 mg/mL | Fresenius Kabi "To Be Discontinued" (2 NDCs); no shortage entry for haloperidol lactate | 01/09/2026 | [verified] |
| Benztropine injection 1 mg/mL | Fresenius Kabi "To Be Discontinued" | 01/27/2026 | [verified] |
| Ketamine, droperidol, propofol, olanzapine, ziprasidone, physostigmine, diphenhydramine, chlorpromazine, flumazenil, naloxone, remimazolam | NO record returned (searched by generic name and free text) | n/a | [verified: absence of record] |

- Caveat: one search summary stated FDA lists ketamine as currently in shortage; the API returned no ketamine record on 16 Nov 2026. Treat ketamine FDA status as "not listed per API, conflicting secondary report". **[verified API vs secondary conflict]** — [Medfinder](https://www.medfinder.com/blog/ketamine-shortage-what-providers-prescribers-need-to-know-2026)

**ASHP shortage list (could not open; search-result summaries only)** — [ASHP list](https://www.ashp.org/drug-shortages/current-shortages/drug-shortages-list)
- Ketamine injection: on ASHP list, created Feb 2018, revised 9 Nov 2026 (another view showed 9 Oct 2026); Hikma reported to have supply. **[secondary]** — [ASHP detail](https://www.ashp.org/drug-shortages/current-shortages/drug-shortage-detail.aspx?id=391)
- Propofol emulsion: ASHP current shortage, revised 3 Jun 2026; Amneal has supply; Dr. Reddy's discontinued propofol in early 2026. **[secondary]** — [ASHP detail](https://www.ashp.org/drug-shortages/current-shortages/drug-shortage-detail.aspx?id=651&loginreturnUrl=SSOCheckOnly)
- Physostigmine salicylate injection: ASHP current shortage, revised 13 Aug 2026. **[secondary]**
- Droperidol injection: most recent ASHP bulletin revised 9 Jul 2025; appears not to be a current shortage. **[secondary; status unconfirmed]**
- Lorazepam injection: a Drugs.com shortage entry dated 21 Oct 2026. **[secondary]**
- ASHP/Utah counted 227 active national shortages in Q2 2026 (third consecutive quarterly rise). **[secondary: Becker's]** — [Becker's](https://www.beckershospitalreview.com/pharmacy/cancer-drug-shortages-worsen-7-notes-from-ashps-q3-report/)

**Physostigmine**
- The only physostigmine product with a recent DailyMed listing is imported Anticholium (physostigmine salicylate 2 mg/5 mL, Dr. Franz Köhler Chemie, distributed by Provepharm), "not FDA-approved", under temporary importation announced in a September 2023 Dear Healthcare Provider letter; DailyMed listing published 17 Nov 2025. The Akorn listing dates from Dec 2022. **[verified: DailyMed listing text]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b90b50e8-c8f1-4f2d-be6e-4d269b8c362c)
- Akorn ceased operations in February 2023, which removed the US physostigmine supplier. **[recalled]**

**Igalmi (dexmedetomidine sublingual film; BXCL501)**
- Current label (DailyMed, published 26 Nov 2025): indicated for acute treatment of agitation associated with schizophrenia or bipolar I or II disorder in adults; limitation: safety and effectiveness not established beyond 24 hours from first dose; "should be administered under the supervision of a healthcare provider", who should monitor vital signs and alertness to prevent falls and syncope; "prolongs the QT interval". 60/90 mcg doses are made by cutting a film in half. **[verified: label]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=99476e8c-2527-4cb0-9d67-9f9cd91343c6)
- At-home sNDA: submitted 14 Jan 2026; FDA accepted with PDUFA target date 14 Nov 2026; supported by the Phase 3 SERENITY At-Home trial (a tolerability/safety trial, primary endpoint met). **[secondary: company press releases via BioSpace/Psychiatric Times]** — [BioSpace](https://www.biospace.com/press-releases/bioxcel-therapeutics-announces-food-drug-administration-acceptance-of-supplemental-new-drug-application-for-use-of-igalmi-in-the-at-home-setting); [Psychiatric Times](https://www.psychiatrictimes.com/view/snda-submission-igalmi-for-acute-treatment-of-agitation-associated-with-bipolar-disorders-or-schizophrenia-in-outpatient-setting)
- OUTCOME UNKNOWN: two searches on 16 Nov 2026 found no approval, complete response or delay notice. The handout must check BioXcel/FDA before stating the label. **[verified: absence of report]** — [BioXcel IR](https://ir.bioxceltherapeutics.com/news-releases/news-release-details/bioxcel-therapeutics-announces-food-drug-administration)
- Dementia: TRANQUILITY In-Care (planned Phase 3, about 150 care-facility residents with Alzheimer's dementia, 60 mcg vs placebo, plus a 20-patient home feasibility cohort) was still described as planned in March and May 2026 company updates; no enrolment or results found. Not approved for dementia agitation. **[secondary]** — [company Q1 2026 update](https://www.biospace.com/press-releases/bioxcel-therapeutics-provides-business-update-and-reports-first-quarter-2026-financial-results)
- Safety signal: case report of severe hypotension after sublingual dexmedetomidine in an elderly patient (PMID 41351540). **[verified: title only]**
- Small pragmatic RCT: Faden J, et al. J Clin Psychopharmacol 2026. PMID 42572939. n = 24 inpatients; PANSS-EC change at 2 h median -13.0 (SL dexmedetomidine 120/180 mcg) vs -14.0 (oral lorazepam 2 mg); not powered for differences. **[verified: abstract]** — [DOI](https://doi.org/10.1097/jcp.0000000000002232)

**Ketamine regulatory**
- FDA public warning on compounded ketamine (including home use for psychiatric disorders) dated 10 Oct 2023, following a Feb 2022 alert on compounded intranasal ketamine. **[secondary]** — [FDA](https://www.fda.gov/drugs/human-drug-compounding/fda-warns-patients-and-health-care-providers-about-potential-risks-associated-compounded-ketamine)
- An FDA-approved Ketalar label revision exists from 2025 (NDA 016812 supplement 056, approved 29 Oct 2025), with two more labeling supplements in March 2026 (see Drugs@FDA records below). Content of the changes not reviewed. **[verified: document exists in Drugs@FDA; content not read]** — [FDA label PDF](https://www.accessdata.fda.gov/drugsatfda_docs/label/2025/016812s056lbl.pdf)
- No 2024 to 2026 FDA Drug Safety Communication specific to ketamine injection was found. **[verified: absence in search]**
- Ketamine remains Schedule III; remimazolam Schedule IV (label). No DEA scheduling change for any drug in this handout was found for 2024 to 2026. **[remimazolam verified: label; remainder recalled/absence]**

**Droperidol**
- ACEP policy statement "Use of Droperidol in the Emergency Department" (2021) supports use for agitation among other indications. **[secondary: search result; PDF blocked]** — [ACEP PDF](https://www.acep.org/siteassets/new-pdfs/policy-statements/use-of-droperidol-in-the-emergency-department.pdf)
- EMS uptake: droperidol administrations in the ESO national EMS dataset rose from 1 dose in 2018 to 22,372 in 2023 (0.18 to 1,603 per million cases; 56,232,761 cases). Schuler RLU, et al. Open Access Emerg Med 2026;18:548610. PMID 41777419. **[verified: abstract]** — [DOI](https://doi.org/10.2147/oaem.s548610)

**Drugs@FDA application records (openFDA drugsfda API, database last updated 2026-11-13)** — [openFDA drugsfda](https://api.fda.gov/drug/drugsfda.json?search=application_number:NDA215390)
- Igalmi NDA 215390 (BioXcel): original approval 5 Apr 2022; SUPPL-1 labeling approved 24 Oct 2022; SUPPL-2, class "Efficacy", approved 19 Nov 2025 (new label posted). No supplement approved in November 2026 appears as of the 13 Nov 2026 data, so the at-home sNDA (PDUFA 14 Nov 2026) is not shown as approved in this record. What SUPPL-2 changed was not determined; the current label still requires healthcare-provider supervision. **[verified: API record]**
- Ketalar NDA 016812: labeling supplements approved 29 Oct 2025 (S-56), 20 Mar 2026 (S-59) and 23 Mar 2026 (S-57). So the ketamine label was revised three times in 2025 to 2026; content of the changes not read. **[verified: API record]**
- Zyprexa NDA 021253 (now held by Cheplapharm; includes Zyprexa IntraMuscular): labeling supplements approved 22 Jan 2025 (S-66) and 30 Jan 2026 (S-67); content not read. **[verified: API record]**
- Generic IM olanzapine (powder for injection) ANDAs listed as prescription-marketed: American Regent (ANDA 201741), Sandoz (201588), Eugia (210968), UBI (211072), Aspiro (217466), Qilu (218116), Omnivium (219048), Anthea (220323). Approval dates not pulled. **[verified: API record]** — [openFDA query](https://api.fda.gov/drug/drugsfda.json?search=products.active_ingredients.name:olanzapine+AND+products.route:intramuscular&limit=50)

### Inferences
- Benzodiazepine supply is the practical constraint in late 2026: both lorazepam and midazolam injections are in FDA-listed shortage, which strengthens the case for antipsychotic-first agitation protocols and for pharmacy-managed allocation.
- Etomidate and dexmedetomidine shortages matter for procedural sedation back-up plans; ketamine and propofol are not FDA-listed but ASHP reportedly still lists both, so local availability may vary by presentation.
- Fresenius Kabi's exit from haloperidol decanoate and benztropine injection (Jan 2026) changes which vials sit in ADCs; a lactate/decanoate look-alike review is timely.

### Gaps
- ASHP list not read directly; ASHP status and dates above are second-hand.
- Igalmi at-home decision (due 14 Nov 2026) not found.
- Content of the 2025 to 2026 Ketalar and Zyprexa label supplements and of Igalmi SUPPL-2 (Nov 2025, "Efficacy") not read; diphenhydramine injection ASHP status not determined.

---

## 5. Guidelines, position statements, standards and laws, 2024 to 2026

(Per coordinator: ACEP 2024 severe agitation policy, the 2026 ACEP unscheduled sedation Delphi guideline, CMS restraint rules and RCEM 2025 are covered by other researchers; only pharmacist-relevant points are noted.)

### Takeaway
New since 2024: the two-part 2026 unscheduled procedural sedation consensus guideline (Annals, Sept 2026), Joint Commission's move to National Performance Goals in January 2026, Colorado's 2024 "excited delirium" ban, a 2025 Geriatric ED Guidelines 2.0 review and a 2026 Lancet Psychiatry network meta-analysis. No new AAP/ACEP/ENA joint paediatric agitation statement was found.

### Cited Findings
- 2026 unscheduled procedural sedation guideline, Part 2 (Green SM, Roback MG, et al. Ann Emerg Med 2026;88:346-361; approved by ACEP Board 29 Apr 2026): "Drug doses and concentrations should be confirmed before administration, with pediatric doses calculated using appropriate, weight-based methods"; for obese patients most doses should use ideal body weight. Lists remimazolam among agents in use. Calls ketofol "an equally safe and effective alternative" to opioid pre-treatment before propofol. States that essentially all modern procedural sedation drug use is off-label and labelling "should not supersede" the sedation literature. Co-administered anticholinergics "no longer recommended". Extra vigilance when sedation is within about 30 minutes of opioid dosing. **[verified: guideline PDF text]** — [Part 2 PDF](https://www.acmt.net/wp-content/uploads/2026/08/Part-2-Unscheduled-Procedural-Sedation.pdf); [DOI](https://doi.org/10.1016/j.annemergmed.2026.06.039)
- Part 1 (Ann Emerg Med 2026;88:332-345): principles, privileging, quality monitoring. A text search found no mention of pharmacists in either part. **[verified: PDF text search]** — [Part 1 PDF](https://www.acmt.net/wp-content/uploads/2026/08/Part-1-Unscheduled-Procedural-Sedation.pdf); [DOI](https://doi.org/10.1016/j.annemergmed.2026.06.038)
- ACEP/ENA policy statement "Procedural Sedation in the Emergency Department": approved/reaffirmed February 2023. **[secondary]** — [ACEP PDF](https://www.acep.org/siteassets/new-pdfs/policy-statements/procedural-sedation-in-the-emergency-department.pdf)
- ACEP "Use of Patient Restraints": latest revision found February 2020. **[secondary]** — [ACEP](https://acep.org/patient-care/policy-statements/use-of-patient-restraints)
- ACEP Task Force Report on Hyperactive Delirium with Severe Agitation in Emergency Settings: approved 23 June 2021. ACEP/ASA joint statement (26 Aug 2020) opposes ketamine or any sedative "to chemically incapacitate someone solely for a law enforcement purpose". No 2024 to 2026 revision of either was found. **[secondary]** — [ASA/ACEP statement](https://asahq.org/about-asa/newsroom/news-releases/2020/08/american-college-of-emergency-physicians-and-american-society-of-anesthesiologists-issue-joint-statement-on-ketamine-use)
- ACMT position statement to end use of the term "excited delirium". **[secondary]** — [ACMT](https://www.acmt.net/?p=15602)
- Geriatric ED Guidelines 2.0 systematic review: Casey MF, et al. J Am Geriatr Soc 2025. PMID 40275439. 9 studies; 838 older adults in observational studies; any adverse event 16.8% (141/838); midazolam 53% (36/68), OR 5.25 (95% CI 2.64-10.45) vs haloperidol; quetiapine OR 0.27 (0.08-0.97). **[verified: abstract]** — [DOI](https://doi.org/10.1111/jgs.19485)
- EMS protocols: Yang DH, et al. Prehosp Emerg Care 2026. PMID 41489336. Statewide protocols 2018 (n = 29) vs 2025 (n = 31): "do not restrain solely by law enforcement request" 0% to 16%; verbal de-escalation 66% to 100%; patient monitoring 55% to 71%; standardised agitation score 10% to 29%; only 3 states had all 11 NAEMSP elements. **[verified: abstract]** — [DOI](https://doi.org/10.1080/10903127.2025.2608105)
- Paediatric: ACEP Pediatric Emergency Medicine Committee review "Strategies for optimal management of pediatric acute agitation in emergency settings", JACEP Open, Aug 2024 (PMID 39183940). A PECARN research agenda for paediatric mental and behavioural health emergencies appeared in Annals in July 2026. AAEP paediatric BETA consensus dates from 2019. No 2025 to 2026 AAP/ACEP/ENA joint agitation statement found. **[secondary; titles verified in Europe PMC for 39183940]** — [ACEP Now](https://acepnow.com/article/how-to-manage-acute-agitation-in-children)
- Joint Commission: workplace violence prevention standards for hospitals took effect 1 Jan 2022 **[recalled]**; new/revised WPV requirements for other programmes were announced in July 2024 (home care) and January 2025 (ambulatory, laboratory, assisted living, nursing care, office-based surgery) **[secondary]**; from January 2026 the National Patient Safety Goals were replaced by 14 National Performance Goals, with WPV prevention folded into the culture-of-safety goal and described by TJC as adding no new accreditation requirements **[secondary]**. — [TJC Jan 2025](https://www.jointcommission.org/resources/news-and-multimedia/newsletters/newsletters/joint-commission-online/jan-15-2025/new-and-revised-workplace-violence-prevention-requirements-for-three-accreditation-programs)
- State law, ketamine: Colorado HB21-1251 (signed 2021) bars peace officers from directing or unduly influencing paramedics to give ketamine, with penalties, and states "excited delirium" is not a justifying emergency. **[secondary]** — [EMS World](https://hmpgloballearningnetwork.com/site/emsworld/news/colorado-adds-ketamine-restrictions-statewide)
- State law, terminology: California AB 360 signed October 2023 (first state; bars the term as a diagnosis/cause of death and in police reports). Colorado HB24-1103 signed 2024 (second state; applies to law enforcement, first responders, coroners). Minnesota reported as having restricted the term. Hawaii SB228 (2025) and a New York bill (2025) were pending, enactment not confirmed. **[secondary]** — [PHR](https://phr.org/news/colorado-becomes-second-u-s-state-to-ban-excited-delirium-following-groundbreaking-phr-research-media-investigations/); [KFF Health News](https://kffhealthnews.org/public-health/excited-delirium-police-deaths-state-legislation-bans/)

### Inferences
- "Hyperactive delirium with severe agitation" is the term to use in the handout; "excited delirium" is legally restricted in at least California and Colorado.
- The 2026 sedation guideline's "confirm dose and concentration before administration" line is the cleanest hook for a pharmacist double-check step, even though the guideline does not name pharmacists.

### Gaps
- SAEM GRACE guideline on agitation: none found. ASA 2024 to 2026 statements: none found. AAP: none found.
- ACEP policy pages could not be opened; reaffirmation dates after 2023 unknown.
- Minnesota, Hawaii and New York enactment status unverified.

---

## 6. New trials and large observational studies, 2024 to 2026

### Takeaway
No practice-changing ER agitation RCT appeared in 2024 to 2026. The most useful new items are a Lancet Psychiatry individual-patient network meta-analysis favouring antipsychotic + benzodiazepine combinations, an 11,568-patient droperidol dose cohort, and first ER remimazolam cohorts.

### Cited Findings

**Agitation**
- Siafis S, et al. Lancet Psychiatry 2026 (8 Jun). PMID 42259329. IPD network meta-analysis, 18 RCTs, 3,411 participants (13 trials, 2,705 with IPD), search to 14 Nov 2025; outcome sedation within 15 to 30 min. Versus haloperidol alone, moderate agitation: combination OR 12.93 (95% CrI 3.00-50.91), benzodiazepines 5.52 (1.37-21.02), other antipsychotics 4.54 (1.35-14.45). Severe agitation: combination 4.86 (1.28-17.54); benzodiazepines 2.09 (0.58-6.99) and other antipsychotics 1.70 (0.62-4.59) uncertain. Confidence very low. Haloperidol alone had more EPS; benzodiazepines (alone or combined) more hypotension. **[verified: abstract]** — [DOI](https://doi.org/10.1016/S2215-0366(26)00097-0)
- Cole JB, et al. J Emerg Med 2025;68:73-83. PMID 39643509. Single-centre retrospective, 2010 to 2023, n = 11,568 given droperidol first (74% IM): 10,293 got 5 mg, 1,275 got 10 mg. Rescue within 1 h: 9.6% vs 14.8% (difference 5.2%, 95% CI 3.2-7.3). Any additional sedation 17.3% vs 24.9%. Confounded by indication. **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.jemermed.2024.07.005)
- Cole JB, et al. Am J Emerg Med 2026. PMID 41740194. Secondary analysis, n = 122 methamphetamine-associated agitation, IM drugs. Median time to adequate sedation: droperidol 5 mg 16 min (n = 37), olanzapine 10 mg 16 min (n = 44), midazolam 5 mg 13 min (n = 15), lorazepam 2 mg 29 min (n = 26). Rescue: 16%, 20%, 13%, 46%. Lorazepam slower (p < 0.001). **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.ajem.2026.02.027)
- Choudhary Y, et al. J Emerg Med 2024 (epub 29 Nov). PMID 40320314. Open-label RCT (India), n = 94: IM olanzapine 10 mg vs haloperidol 5 mg. Sedated at 15 min 31.9% vs 25.5% (RR 1.25, 95% CI 0.65-2.37); 30 min 61.7% vs 48.9%; rescue 12.7% vs 25.5%; adverse events 4.2% vs 10.6%; none significant. **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.jemermed.2024.11.014)
- DiGuglielmo F, et al. Ment Health Clin 2025;15(5). PMID 41079523. Retrospective, 6 ERs, IM droperidol vs haloperidol: mean additional doses within 4 h 0.75 vs 1.1 (p = 0.0048); no documented EPS or QTc prolongation. Sample size not in abstract. **[verified: abstract]** — [DOI](https://doi.org/10.9740/mhc.2025.10.232)
- Droperidol safety cohorts: VA Los Angeles ER, n = 207 (88.4% for agitation; 18.4% aged 65 or older): no deaths at 24 h, rescue 7.3%, EPS 1.0%, no arrhythmia or clinically relevant QTc prolongation (Minoda E, et al. Fed Pract 2026;43(5):180-185. PMID 42719802). **[verified: abstract]** — [DOI](https://doi.org/10.12788/fp.0699). Trauma activations, US level I centre, n = 66 (73% got 2.5 mg, 91% IV): rescue within 60 min 39.4%; new oxygen requirement 21%, 2 intubated (Dobson AR, Billups KL. J Trauma Nurs 2026. PMID 41533956). **[verified: abstract]** — [DOI](https://doi.org/10.1097/JTN.0000000000000910). Australian trauma cohort n = 87: hypoxia 10% (Williamson F, et al. Emerg Med Australas 2026. PMID 42267846). **[verified: abstract, truncated]** — [DOI](https://doi.org/10.1111/1742-6723.70293)
- A 2026 Am J Emerg Med paper on QTc change after low-dose droperidol exists (Bartoe A, et al. PMID 42731911); no abstract available. **[verified: citation only]** — [DOI](https://doi.org/10.1016/j.ajem.2026.09.013)
- Ketamine: systematic review, 29 studies, 1,516 patients: 86.5% IM at mean 3.83 mg/kg; mean sedation time 6.1 min; 24.5% needed rescue or repeat dosing; 19.1% intubated (not attributable to ketamine alone); cardiac arrest 0.2% (Peter C, et al. Asian J Psychiatr 2025;103:104344. PMID 39724793). **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.ajp.2024.104344)
- Prehospital ketamine, Ontario, n = 313: mean IM dose 4.2 mg/kg; no vital signs documented before dosing in 34%; adverse events 30.3% (hypoxia 15.4%, airway compromise 14.8%); bag-mask ventilation 5.5%; 6 advanced airways; 3 cardiac arrests (Kwong JL, et al. CJEM 2025;27(8):653-660. PMID 40715991). **[verified: abstract]** — [DOI](https://doi.org/10.1007/s43678-025-00963-w)
- Paediatric: PEAChY-O RCT, 9 Australian ERs, n = 348 aged 9 to 17: oral olanzapine vs oral diazepam; sedation at 1 h without extra sedatives 61% (103/168) vs 57% (90/158); adjusted risk difference 3.6% (95% CI -6.7 to 14.0); no serious adverse events; about 40% not sedated in either arm (Bourke EM, et al. Ann Emerg Med 2025. PMID 39955661). **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.annemergmed.2025.01.007)
- Paediatric practice pattern: 109 encounters; benzodiazepine alone 43%, antipsychotic alone 21%, antipsychotic + benzodiazepine + diphenhydramine 15%; repeat dose within 5 to 120 min in 11% (Brasel K, et al. Pediatr Emerg Care 2025;41(4):267-272. PMID 39841042). **[verified: abstract]** — [DOI](https://doi.org/10.1097/pec.0000000000003320)

**Procedural sedation**
- Ketamine dose RCT: 0.5 vs 1 mg/kg IV in adults, n = 108: recovery agitation difference 1.9% (95% CI -14.8 to 18.4); 7.4% of the low-dose group needed a top-up vs 0 (Türkücü Ç, et al. Acad Emerg Med 2025. PMID 39878430). **[verified: abstract]** — [DOI](https://doi.org/10.1111/acem.15116)
- Adult RCT meta-analysis: 50 RCTs, 5,398 patients; per 1,000 sedations: hypoxia 136, agitation 143, apnoea 51, hypotension 23, GI 45, bradycardia/dysrhythmia 30; procedural success 921 (Qu Z, et al. Adv Clin Exp Med 2026. PMID 41698174). **[verified: abstract]** — [DOI](https://doi.org/10.17219/acem/205615)
- Paediatric RCT meta-analysis: 17 RCTs, 2,302 sedations; per 1,000: vomiting 104.9, agitation 37.5, hypoxia 38.3, apnoea 8.6, bag-valve-mask 13.5; no intubations, one laryngospasm (Khan MT, et al. CJEM 2025;27(3):178-190. PMID 39522109). **[verified: abstract]** — [DOI](https://doi.org/10.1007/s43678-024-00809-x)
- Propofol recall: prospective multicentre, n = 248 adults: 16% (95% CI 12-20) reported recall at 2 h; 18.9% at 24 h (Muller B, et al. J Emerg Med 2025;79:457-462. PMID 41205307). **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.jemermed.2025.09.013)
- Italian SEED registry: 10 ERs, n = 1,349; propofol 67%, midazolam 24.2%; procedural failure 4.6%; adverse events 10% overall (Lison D, et al. Eur J Emerg Med 2025;32(3):194-201. PMID 39715053). **[verified: abstract, truncated]** — [DOI](https://doi.org/10.1097/mej.0000000000001210)
- Paediatric propofol roll-out (QI, 4 US paediatric ERs): 2,368 sedations (2,251 ketamine, 117 propofol); sedation length 18 to 24 min vs 33 to 52 min (P < 0.001); propofol serious adverse events 2.6% (Wiersma A, et al. Pediatr Emerg Care 2026. PMID 42400418). **[verified: abstract]** — [DOI](https://doi.org/10.1097/PEC.0000000000003650)
- Remimazolam in the ER (all Danish single-centre or case-level): n = 68, median dose 7.5 mg, 97% none/mild respiratory problems, 2 transient severe events after large prior opioid doses, 89% of joint reductions successful (Andreassen S, et al. Dan Med J 2025;72(12):A08240562. PMID 41312710) **[verified: abstract]** — [DOI](https://doi.org/10.61409/a08240562); nurse-administered, n = 183: 89% no respiratory adverse effect, 7.5% mild/moderate, 2.2% severe; procedure start at median 3 min; 94% amnesia (Krarup AL, et al. Int Emerg Nurs 2026;89:101898. PMID 42727215) **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.ienj.2026.101898); first US ER cardioversion case report, 5 mg bolus (Bradshaw JC, et al. JACEP Open 2026;7(6):100506. PMID 42959249) **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.acepjo.2026.100506)
- Ketofol: small RCT, n = 64, ketamine + propofol vs ketamine + midazolam for shoulder reduction; authors favour ketamine-propofol (Pehlivan M, et al. Turk J Emerg Med 2026;26(1):62-70. PMID 41567482; abstract numbers garbled). **[verified: abstract, partial]** — [DOI](https://doi.org/10.4103/tjem.tjem_211_25). A secondary analysis of critical adverse events with paediatric ER ketamine-propofol was published 6 Nov 2026 (Cohen N, et al. Eur J Anaesthesiol. PMID 42989963; no abstract). **[verified: citation only]** — [DOI](https://doi.org/10.1097/eja.0000000000002530)

### Inferences
- Remimazolam has no US ER trial data yet; ER use is off-label by setting only (label covers adult procedures of 30 min or less) and current evidence is uncontrolled.
- The lorazepam IM signal (slowest, 46% rescue) plus the lorazepam shortage both point away from IM lorazepam as a first-line agitation drug.

### Gaps
- No 2024 to 2026 US multicentre ER agitation RCT found. Etomidate and dexmedetomidine procedural sedation updates not reviewed in detail.

---

## 7. Workplace violence, response teams, and equity

### Takeaway
Black patients have consistently higher adjusted odds of physical restraint (about 1.1 to 1.5 times) and of IM chemical sedation (about 1.3 to 1.4 times) across large US datasets. Structured agitation code teams and QI bundles have reduced restraint rates and, in one 2026 paediatric project, narrowed the IM sedation gap.

### Cited Findings

**Epidemiology**
- ACEP/Marketing General poll, fielded 25 Jul to 1 Aug 2022, 2,712 emergency physicians: 66% assaulted in the past year; about 80% said violence was increasing (45% "greatly increased" over 5 years); 85% reported emotional trauma/anxiety; 87% loss of productivity; 89% said violence harmed patient care. The 2018 poll: 47% ever physically assaulted. **[secondary: press release via EurekAlert; ACEP page blocked]** — [EurekAlert](https://www.eurekalert.org/news-releases/965643); [ACEP poll page](https://www.acep.org/administration/violence-in-the-emergency-department-resources-for-a-safer-workplace/poll---ed-violence)
- ENA "pulse check" survey (11 Feb to 11 Mar 2024, released 4 Apr 2024; nearly 500 respondents, self-selected): 56% physically or verbally assaulted or threatened in the prior 30 days; about 1 in 10 considering leaving nursing. **[secondary: ENA press release summary]** — [ENA](https://www.ena.org/press-room/articles/detail/2024/04/04/ena-survey--56-percent-of-ed-nurses-assaulted-in-the-past-month)
- BLS 2021 to 2022: healthcare workers (about 10% of the workforce) had about 73% of nonfatal workplace violence injuries requiring days away, restriction or transfer. Other sites quote different shares; BLS table not opened. **[secondary; conflicting figures]** — [CDC stacks](https://stacks.cdc.gov/view/cdc/257854/cdc_257854_DS1.pdf)
- US paediatric emergency physicians (national survey, 207 respondents, 45% response): 96% exposed to workplace violence; 10% injured needing care or time off; half never reported (Huang CJ, et al. Pediatr Emerg Care 2024;40(4):249-254. PMID 38563972). **[verified: abstract]** — [DOI](https://doi.org/10.1097/pec.0000000000002944)
- Agitation is cited as affecting up to 2.6% of ER encounters (Rudisell E, et al. BMJ Ment Health 2025. PMID 40032552). **[verified: abstract; secondary for the original figure]** — [DOI](https://doi.org/10.1136/bmjment-2024-301189)

**Response teams and bundles**
- Wong AH, et al. Ann Emerg Med 2021. PMID 34863528. Agitation code team QI, 634,578 ER visits over 5 years: restraint rate 1.1% to 0.9% to 0.8% across phases, a 27.3% proportionate fall. **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.annemergmed.2021.10.013)
- Mendelsohn L, et al. J Hosp Med 2026. PMID 41854083. Scoping review of behavioural emergency response teams, 28 studies (search to May 2024): associated with less violence, restraint use and security calls; 22 teams included security; only 8 studies tracked race, some showing disproportionate activations and restraint for Black patients. **[verified: abstract]** — [DOI](https://doi.org/10.1002/jhm.70307)
- Adu MR, et al. Pediatrics 2026 (Oct). PMID 42716528. Paediatric ER QI. Baseline IM chemical restraint 6.0% non-Hispanic Black, 3.7% Hispanic, 2.6% non-Hispanic White; physical restraint 2.7% Black and Hispanic vs 1.1% White. After pathway, 24/7 behavioural health counsellors, care plans, de-escalation and disparity education: IM rates fell to 1.4% (Black) and 1.2% (Hispanic), White unchanged at 2.6%; physical restraint unchanged for Black patients; staff injuries did not rise. **[verified: abstract]** — [DOI](https://doi.org/10.1542/peds.2025-073158)
- Project BETA implementation summary: Roppolo LP, et al. JACEP Open 2020. PMID 33145538 (narrative; no numbers in abstract). **[verified: abstract]** — [DOI](https://doi.org/10.1002/emp2.12138)

**Equity: physical restraint**
- Wong AH, et al. JAMA Netw Open 2021;4(1):e2035241. PMID 33492372. 726,417 ER visits; 7,090 (1%) with restraint orders. Black vs White AOR 1.13 (95% CI 1.08-1.21 in text; 1.07-1.21 in table). Hispanic AOR 0.78 (0.70-0.88). Female 0.75 (0.71-0.79). Medicaid 1.55 (1.45-1.67); Medicare 1.67 (1.54-1.82). Homeless 1.35 (CI printed as 1.14-1.16 in the article, an apparent typographical error). **[verified: full text]** — [DOI](https://doi.org/10.1001/jamanetworkopen.2020.35241)
- Schnitzer K, et al. Acad Emerg Med 2020;27(10):943-950. PMID 32691509. Massachusetts General, 195,092 visits; 2,658 (1.4%) restrained. Black vs White RR 1.22 (95% CI 1.05-1.40, p = 0.007); Asian vs White RR 0.71 (0.55-0.92). **[verified: abstract]** — [DOI](https://doi.org/10.1111/acem.14092)
- Carreras Tartak JA, et al. Acad Emerg Med 2021;28(9). PMID 34533261. 11 hospitals, 32,054 involuntary-hold encounters; 7.7% restrained. Black AOR 1.22 (1.01-1.48); Hispanic AOR 1.45 (1.22-1.73); male 1.44; Medicaid 1.21; in-network primary care 0.81 (0.72-0.92). **[verified: abstract]** — [DOI](https://doi.org/10.1111/acem.14327)
- Chang-Sing E, et al. JAMA Netw Open 2024;7(2):e240098. PMID 38381433. 4,263,437 visits, 13 hospitals, 2015 to 2022. Black vs White restraint AOR 1.33 (1.28-1.37). Police transport raised restraint odds, AOR 5.51 (5.21-5.82); Black patients more often police-transported, AOR 1.38 (1.34-1.42); police transport mediated 10.70% (9.26-12.53%) of the association. **[verified: abstract]** — [DOI](https://doi.org/10.1001/jamanetworkopen.2024.0098)
- Johnson D, et al. Health Equity 2026. PMID 42973977. Two San Francisco ERs, 6,631 mental health encounters, 15.8% restrained; Black aOR 1.54 (1.16-2.05). **[verified: abstract]** — [DOI](https://doi.org/10.1177/24731242251394114)

**Equity: chemical sedation**
- Smith CM, et al. Psychiatr Serv 2021/2022. PMID 34932385. Duke, 12,977 emergency psychiatric evaluations: physical restraint 7.4%, chemical restraint 15.8%. Black vs White: physical AOR 1.35 (1.07-1.72); chemical AOR 1.33 (1.15-1.55). **[verified: abstract]** — [DOI](https://doi.org/10.1176/appi.ps.202100474)
- Lippert SC, et al. Ann Emerg Med 2026. PMID 41854577. Kaiser Northern California, 2017 to 2021, 94,204 visits with mental health consult, age 18 to 64: 11.7% (11,048) got IM chemical sedation. Black race aOR 1.38 (1.27-1.50); EMS/law enforcement arrival 1.51 (1.43-1.60); involuntary hold 1.66 (1.56-1.77); concurrent physical restraint 33.05 (30.28-36.08). Supplemental oxygen in 2.8% (most common adverse event). **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.annemergmed.2026.01.021)
- Jivalagian P, et al. Am J Geriatr Psychiatry 2024. PMID 39054237. Age 65 or older, 872,587 visits: chemical sedation 1.4%, physical restraint 3.7%. Chemical sedation AOR: Black non-Hispanic 1.26 (1.18-1.35), Hispanic 1.22 (1.15-1.29); age 95+ vs 65-74 AOR 2.35 (2.15-2.57). **[verified: abstract]** — [DOI](https://doi.org/10.1016/j.jagp.2024.07.004)
- Robinson L, et al. PLoS One 2025. PMID 40080507. Unhoused patients: restraint orders in 5.7% of visits vs 1.5% housed; restraint/sedation aOR 1.45 (1.36-1.54). **[verified: abstract]** — [DOI](https://doi.org/10.1371/journal.pone.0319286)
- Kumar A, et al. Acad Emerg Med 2025. PMID 39948714. 3,406,474 visits: Spanish speakers had LOWER odds of restraint (aOR 0.70, 0.65-0.76) and IM sedation (0.82, 0.79-0.87) than English speakers. **[verified: abstract]** — [DOI](https://doi.org/10.1111/acem.70004)
- Also exists, numbers not extracted (no abstract): Robinson L, et al. Racial and ethnic disparities in use of chemical restraint in the ED. Acad Emerg Med 2022. PMID 35934988 [DOI](https://doi.org/10.1111/acem.14579); Nash KA, et al. JAMA Pediatr 2021. PMID 34515764 [DOI](https://doi.org/10.1001/jamapediatrics.2021.3348). **[verified: citation only]**

### Inferences
- Effect sizes are modest but consistent in direction across at least seven independent datasets; police/EMS arrival and involuntary holds are the strongest co-factors.
- A pharmacist-run audit of IM sedation by race, arrival mode and drug choice would use data the pharmacy already holds (ADC and MAR records).

### Gaps
- ACEP 2022 poll and BLS primary tables not opened; BLS figures conflict between secondary sources.
- No 2024 ACEP poll found.

---

## 8. Post-sedation monitoring and documentation the pharmacist can prompt

### Takeaway
I found no dedicated guideline or study on monitoring after chemical sedation for agitation. Support comes from drug labels (ECG for droperidol and IV haloperidol; orthostatic checks for olanzapine; vital signs and alertness for Igalmi) and from adverse event rates showing hypoxia is the commonest complication.

### Cited Findings
- Droperidol label: "Vital signs and ECG should be monitored routinely"; 12-lead ECG before dosing; QTc cut-offs 440 ms (men) / 450 ms (women). **[verified: label]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=147e033d-d997-4ef6-8bb5-a9ba372590b2)
- Haloperidol lactate label: if given IV, monitor ECG for QTc prolongation and arrhythmias. **[verified: label]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b1ad2abd-a9d6-44e3-957b-36a73260f4f5)
- Olanzapine IM label: assess for orthostatic hypotension before subsequent doses; IM olanzapine with parenteral benzodiazepine "not recommended". **[verified: label]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=85688d8f-f2de-408a-8ae2-0976c266c961)
- Igalmi label: monitor vital signs and alertness; ensure no orthostatic or symptomatic hypotension before ambulation. **[verified: label]** — [DailyMed](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=99476e8c-2527-4cb0-9d67-9f9cd91343c6)
- How often things go wrong: supplemental oxygen in 2.8% of 94,204 mental health ER visits with IM sedation data (Lippert 2026); adverse events in 16.8% of older adults, 53% with midazolam (Casey 2025); prehospital ketamine hypoxia 15.4% with no pre-dose vital signs in 34% (Kwong 2025); droperidol in trauma, new oxygen requirement 21% (Dobson 2026). **[verified: abstracts cited in sections 5 to 7]**
- EMS protocols including patient monitoring after sedation rose from 55% to 71% of states, 2018 to 2025 (Yang 2026). **[verified: abstract]** — [DOI](https://doi.org/10.1080/10903127.2025.2608105)
- Standard expectations (continuous pulse oximetry, capnography where available after ketamine or benzodiazepine combinations, vital signs every 5 to 15 min until rousable, lateral or head-up positioning, avoidance of prone restraint, ECG once safe, glucose and temperature check). **[recalled; not sourced this session]**

### Inferences
- Documentation prompts a pharmacist can own, derived from the items above: drug, dose, concentration and route actually given (and lot/vial strength for ketamine); time given and time of adequate sedation; total benzodiazepine + antipsychotic exposure in the prior hour before any repeat dose; SpO2 and vital signs after dosing; ECG/QTc once feasible when droperidol or IV haloperidol was used; orthostatic check before repeat olanzapine; ADC override reconciliation with a retrospective order; restraint order linkage.

### Gaps
- No primary guideline text on post-sedation monitoring intervals was read (ACEP 2024 agitation policy is covered by another researcher).
