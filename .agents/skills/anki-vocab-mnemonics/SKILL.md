---
name: anki-vocab-mnemonics
description: Write or revise Japanese vocabulary mnemonics for Anki decks or supplied word lists, connecting whole-word meaning, ordered RTK kanji keywords, and English sound cues. Use for examples, Story-field rewrites, or small recall pilots.
---

# Japanese vocabulary mnemonics

Create a short visual memory aid connecting the word's actual meaning to its kanji and reading. Inspect the target deck; do not assume a particular deck, note model, or field layout.

## Establish the inputs

- Identify the words/deck, scope, and whether the task is examples, a pilot, or an authorized update. Examples do not authorize deck edits.
- For Anki access, load the available `anki-connect` skill. Inspect actual fields before mapping them. Common names are `VocabKanji`, `VocabFurigana`, `VocabDef`, sentence fields, and `Story`. Ask only when inspection leaves an important mapping ambiguous.
- Use the definition and sentence to establish the intended sense. A mnemonic bridge is a memory aid, not historical etymology. Do not switch senses to make an easier story.
- Resolve conflicting definitions, spellings, or readings using context and reliable dictionary evidence. Preserve attested alternative readings. Propose source corrections separately unless already authorized; when authorized, record evidence and before/after values.
- Prefer the user's RTK source. Otherwise use [assets/rtk-keywords.csv](assets/rtk-keywords.csv), the bundled kanji/keyword-only lookup. Some characters have alternatives: preserve the user's existing choice or choose a verified candidate consistently. Do not invent a missing RTK keyword; flag it and continue other words.

## Required four-part format

Use this order for examples and the rendered Story field:

1. **Word【complete reading】— precise contextual meaning**
2. **Kanji → meaning:** each kanji with its exact RTK keyword, in written order, followed by a plain sentence connecting those images to the whole-word meaning.
3. **Kanji → sounds:** each verified kanji reading segment with English cues; capitalize the relevant sounds, as in `CAt`, `CAke`, or `CHOsen`.
4. **Story:** one concrete visual episode joining the ordered keyword images, meaning, and sound cues.

Keep the meaning bridge visible, not solely in hidden review metadata. The story must demonstrate the meaning before its final explanatory phrase; explicitly naming the meaning may reinforce the image.

Compact labeled paragraphs are sufficient. In Anki, escape HTML and use readable line breaks. Keep the characters, full reading, keyword mapping, and sound mapping visible rather than rendering only prose.

Read [references/examples.md](references/examples.md) when composing initial examples or repairing a weak link. These establish quality, not wording to copy onto unrelated words.

## Build the meaning image first

- Decide what visible action, property, or relationship demonstrates the exact meaning. A characteristic is a distinguishing trait; a contradiction involves incompatible claims; endurance means continuing despite discomfort.
- Give every RTK keyword an active or identifying role. Preserve whole-kanji written order, including repetition; `々` repeats the preceding character's keyword. Do not substitute primitive decomposition or stroke order.
- Preserve exact keyword spelling in the mapping and use it naturally in the story, inflecting where necessary. Avoid broken English written merely to retain a marker.
- Add English sound cues to the same episode, attaching them to its actors, objects, or actions. Remove decorative props that help neither meaning nor reading.
- Prefer one setting, one main action, and a clear result. Aim for roughly 20–35 words when practical; allow more for complex compounds. This is an editing target, not a proven memory threshold.
- Abstract keywords can be personified or given visible consequences. An abstract keyword preface followed by an unrelated example is insufficient. The learner should be able to reconstruct one vivid event.
- Compose each story individually. Reuse the output layout, not a sentence skeleton with mechanically substituted keywords.

## Encode only the kanji reading

- Display the complete word and reading in the header. Sound cues encode only reading portions belonging to written kanji.
- Exclude written kana, okurigana, particles, prefixes, and Arabic numerals. For `取り消す`, cue `取＝と` and `消＝け`, not `り` or `す`.
- Align spelling and reliable furigana. Keep irregular whole-word or compound reading groups intact; do not invent per-character readings to fill a table. No cue may cross a written-kana gap.
- Concatenated cue kana must exactly reproduce the selected kanji-only reading segments. Cues occur in that order in the story. Keywords also occur in character order; English cue and keyword boundaries need not coincide.
- Use real English words or familiar English names, not invented syllables or Japanese words presented as English. Reuse familiar cues for recurring sounds when practical.
- Cues approximate Japanese pronunciation. The Japanese reading and available native audio govern pronunciation, vowel length, and pitch accent.
- Judge spoken sound, not spelling: `SHEll` begins “sheh,” not `し`; `DAnish` begins “day,” not `だ`; `JAW` has a different vowel from `じょう`. Prefer `SHE`, `DAd`, and `JOke`. In helpers such as `Cat-YOgurt` for `きょ`, mark the initial consonant rather than the whole `CAt` syllable.

## Review every story

- **Meaning:** Does the event demonstrate the intended definition rather than merely label it? Does the visible meaning bridge explain this particular image?
- **Kanji:** Are source keywords correct, ordered, and involved in the event? Are the actions causally coherent?
- **Reading:** Are cues recognizable English, approximately sound-matched, ordered, and limited to the kanji reading? Does the guide match the actual story?
- **English:** Check pronouns (`ME` as object, `SHE` as subject), agreement, and phrasal verbs. Repair grammar rather than forcing convenient cues.
- **Memory load:** Can the learner picture one event without learning an unrelated prop list?

For bulk work, validate membership, duplicates, keyword mappings, and reading-segment coverage programmatically. Semantic review still requires reading every story. Use independent reviewers when available and authorized, particularly after a format change. Checkpoint drafts and reviewed IDs so interruptions do not trigger regeneration. Do not describe sampled review as full review.

## Updating Anki

- Respect existing user authorization and the AnkiConnect skill's mutation rules. Do not repeatedly ask for the same authorized operation. One deck's approval does not cover another deck or unrelated source corrections.
- Save target note IDs, all field values, tags, model/deck associations, and relevant scheduling metadata before writing. Refresh the snapshot near application after a long drafting run.
- Change only the mapped Story field by default; include source corrections only when authorized. Preserve media references, templates, tags, other fields, and scheduling. Do not sync automatically.
- Compare live values with the snapshot before updating. Preserve and report newly edited notes instead of overwriting them. Deduplicate notes represented by multiple cards.
- With AnkiConnect, use version 6 and check every response's `error`, including each nested `multi` action. Specify version 6 on nested actions too. Checkpoint outcomes and investigate errors instead of blindly retrying.
- Read back every intended field and compare full note state and scheduling with the snapshot. Report actual updated, skipped, and verified counts plus backup/review locations. Do not claim drafts were installed.

## Optional recall pilot

Offer this when the user wants to test effectiveness, not as a prerequisite for ordinary examples. A practical pilot uses about 20 words split between existing and revised mnemonics, balancing prior familiarity and difficulty. Keep exposure comparable and score meaning and reading separately over several days. Treat this as a personal usability check, not proof of general superiority.

For an interactive test, ask for meaning and reading before revealing the explanation, a few words at a time. Do not reveal answers in the baseline prompt or mark a valid alternative reading wrong when no sense was specified. Native audio supports pronunciation; the story supports recall. Do not change scheduling or add card types unless requested.
