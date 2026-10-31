---
name: anki-vocab-mnemonics
description: Write or revise Japanese vocabulary mnemonics for Anki decks or supplied word lists, connecting whole-word meaning, ordered RTK kanji keywords, and reusable pop-culture sound characters. Use for examples, Story-field rewrites, or small recall pilots.
---

# Japanese vocabulary mnemonics

Create a short visual memory aid connecting the word's actual meaning to its kanji and reading. Inspect the target deck; do not assume a particular deck, note model, or field layout.

For new stories, use the stable sound-character roster: read [references/character-cues.md](references/character-cues.md) and look up actors in [assets/sound-characters.csv](assets/sound-characters.csv). The user chose `あ → Anpanman` and `ま → Mario`. The other entries are proposed defaults that can be personalized. Ordinary sound cues must use actual spoken name openings. Japanese names require an exact matching initial mora, including contracted sounds; non-Japanese names may approximate it when differences are recorded honestly; do not manufacture them through props, moves, titles, or consonant-plus-word combinations. Leave unmatched sounds explicitly unresolved in the CSV. Keep story prose in English; recognizable character names, including anime/game names, replace the former generic English cue objects. Use the CSV display name in prose: a surname cue appears as Newton or Bueller, with the full identity retained in the registry notes.

## Establish the inputs

- Identify the words/deck, scope, and whether the task is examples, a pilot, or an authorized update. Examples do not authorize deck edits.
- For Anki access, load the available `anki-connect` skill. Inspect actual fields before mapping them. Common names are `VocabKanji`, `VocabFurigana`, `VocabDef`, sentence fields, and `Story`. Ask only when inspection leaves an important mapping ambiguous.
- Use the definition and sentence to establish the intended sense. A mnemonic bridge is a memory aid, not historical etymology. Do not switch senses to make an easier story.
- Resolve conflicting definitions, spellings, or readings using context and reliable dictionary evidence. Preserve attested alternative readings. Propose source corrections separately unless already authorized; when authorized, record evidence and before/after values.
- Prefer the user's RTK source. Otherwise use [assets/rtk-keywords.csv](assets/rtk-keywords.csv), the bundled kanji/keyword-only lookup. Some characters have alternatives: preserve the user's existing choice or choose a verified candidate consistently. Do not invent a missing RTK keyword; flag it and continue other words.

## Story-only output

Render only the visual story in the Anki Story field. Omit the word/reading header, labeled meaning bridge, sound breakdown, and repeated pronunciation or written-kana disclaimer. For multiple examples in chat, a short vocabulary label may identify each example outside its story.

- Open with the English whole-word meaning, woven naturally into the scene rather than presented as a standalone label. Render the meaning in bold and underline: `<b><u>travel</u></b>` in Anki HTML. Mark the whole meaningful phrase when needed.
- Follow this narrative order: **whole-word meaning → first RTK keyword + its sound characters → next RTK keyword + its sound characters**. Put each keyword before its corresponding sound characters, in the same short clause where practical. Bold RTK keywords only. Italicize sound-character names, using `<i>Mario</i>` in Anki HTML or `*Mario*` in Markdown previews; use the roster display name consistently. Italicize named nasal/closure markers such as Nemo and Thwomp when they appear, too. In explicitly requested legacy English-object mode, capitalize cue sounds such as `CAt` or `CHOsen`.
- For words containing only one written kanji, omit the separate RTK keyword from the displayed story. Use the whole-word meaning and the kanji's sound characters to create the visual event. Still verify the kanji and its reading internally. Written kana do not count as additional kanji; `々` represents a repeated kanji and retains its repeated keyword image.
- Keep grouped readings intact; do not invent per-character assignments for irregular compounds. For those, open with the meaning, then keep the ordered keyword images and grouped sound characters together in one compact episode, preserving both orders even when strict keyword/actor alternation is impossible.
- Make the action demonstrate the opening meaning. A meaning label followed by unrelated props is insufficient. Do not require the meaning to recur at the end or append a scripted definition such as “that's technology.” The story may use multiple sentences when needed.
- Keep exact keyword mappings, full reading, kanji-only segments, cue alignment, and the meaning rationale in drafting/review data. These checks remain required even though they are not displayed on the card. Give special cue explanations only when requested or needed, rather than routinely appending them.
- Escape story text for Anki, then insert the intended bold/underline markup; do not escape the formatting tags into visible text. Retain only useful emphasis and line breaks.

Read the character examples in [references/character-cues.md](references/character-cues.md) when composing new stories. [references/examples.md](references/examples.md) contains legacy English-object examples, shared failure checks, and the research note. The examples establish quality, not wording to copy onto unrelated words.

## Build the meaning image first

- Decide what visible action, property, or relationship demonstrates the exact meaning. A characteristic is a distinguishing trait; a contradiction involves incompatible claims; endurance means continuing despite discomfort.
- For multi-kanji words, give every RTK keyword an active or identifying role. Preserve whole-kanji written order, including repetition; `々` repeats the preceding character's keyword. Do not substitute primitive decomposition or stroke order.
- Preserve exact keyword spelling in the internal mapping and, when displayed, use it naturally in the story, inflecting where necessary. Avoid broken English written merely to retain a marker.
- Make the registered sound characters act within that same episode. Their actions must help demonstrate the meaning and incorporate the RTK images. Remove decorative characters or props that help neither meaning nor reading.
- Prefer one setting, one main action, and a clear result. Aim for roughly 20–35 words when practical; allow more for complex compounds. This is an editing target, not a proven memory threshold.
- Abstract keywords can be personified or given visible consequences. An abstract keyword preface followed by an unrelated example is insufficient. The learner should be able to reconstruct one vivid event.
- Compose each story individually. Reuse the output layout, not a sentence skeleton with mechanically substituted keywords.

## Use emotion and distinctiveness selectively

- Use humor, exaggeration, surprise, or absurdity when they strengthen the meaning image. Vary the treatment across words; making every scene equally outrageous can reduce its distinctiveness.
- Make the memorable action carry the target association: the ordered RTK images demonstrate the meaning, and the sound characters participate in that action. A joke or shocking detail beside an otherwise ordinary explanation is insufficient.
- Vulgar, sexual, violent, or frightening imagery is optional, not a requirement or a presumed improvement. Follow the user's stated preferences and the intended audience; do not infer a preference for explicit material from a general request for memorable stories.
- Prefer a short, coherent scene over escalating shock or adding props. If the learner could remember the sensational event while forgetting what the word means or how it sounds, revise the association.
- Treat this as evidence-informed writing guidance, not a proven formula for this RTK-plus-sound format. Read the research note in [references/examples.md](references/examples.md#research-note-distinctiveness-and-emotion) when explaining the rationale or evaluating a style change.

## Encode only the kanji reading

- Verify the complete word and reading in the inputs and review data. Sound cues encode only reading portions belonging to written kanji.
- Exclude written kana, okurigana, particles, prefixes, and Arabic numerals. For `取り消す`, cue `取＝と` and `消＝け`, not `り` or `す`.
- Align spelling and reliable furigana. Keep irregular whole-word or compound reading groups intact; do not invent per-character readings to fill a table. No cue may cross a written-kana gap.
- Concatenated cue kana must exactly reproduce the selected kanji-only reading segments. Cues occur in that order in the story. Keywords also occur in character order; English cue and keyword boundaries need not coincide.
- Use the registered pop-culture characters for recurring sounds. Their English names identify the actor; the registry specifies the intended sound prefix, Japanese-name alias, or exceptional marker. Do not invent characters or misrepresent a spelling as a pronunciation. For an explicitly requested legacy mode, use real English words or familiar names rather than invented syllables.
- Cues approximate Japanese pronunciation. The Japanese reading and available native audio govern pronunciation, vowel length, and pitch accent. In character mode, explicitly encode vowel length, nasal closure and small `っ` using the roster rules; a character name’s unused syllables encode nothing.
- In legacy English-object mode, judge spoken sound, not spelling: `SHEll` begins “sheh,” not `し`; `DAnish` begins “day,” not `だ`; `JAW` has a different vowel from `じょう`. Prefer `SHE`, `DAd`, and `JOke`. In helpers such as `Cat-YOgurt` for `きょ`, mark the initial consonant rather than the whole `CAt` syllable.

## Review every story

- **Meaning:** Does the event demonstrate the intended definition rather than merely label it? Does the internal meaning rationale explain this particular image? Does the story open naturally with the English meaning in bold and underline, with the following action demonstrating it?
- **Kanji:** For multi-kanji words, are source keywords correct, ordered, and placed before their corresponding sound characters? For single-kanji words, is the separate RTK keyword omitted? Are the actions causally coherent?
- **Reading:** Are the registered characters recognizable, correctly sound-matched, ordered, and limited to the kanji reading, with length/closure markers preserved? Does the internal cue mapping match the actual story, with each keyword close to its corresponding cue?
- **English:** Check pronouns (`ME` as object, `SHE` as subject), agreement, and phrasal verbs. Repair grammar rather than forcing convenient cues.
- **Memory load:** Can the learner picture one event without learning an unrelated prop list?
- **Distinctiveness:** Does the funny, emotional, or unusual feature reinforce the target meaning and cues, rather than compete with them? Does it remain distinguishable from neighboring stories?

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
