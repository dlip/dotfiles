# Writing with sound characters

Use [assets/sound-characters.csv](../assets/sound-characters.csv) as the shared sound-to-character registry; [sound-characters.md](sound-characters.md) explains pronunciation, aliases, and exceptional markers. This is the default for new stories requested with the updated skill. The former generic English sound objects remain a legacy mode for explicit requests or existing examples; do not mix the two systems unnoticed within a new batch.

## Select the actors

- Preserve the user's fixed choices: `あ → Anpanman`, `ま → Mario`. Other roster entries are proposed defaults. Prefer actors the learner already recognizes. Offer a replacement when a rare or unfamiliar actor would otherwise become extra homework; no need to reconfirm familiar choices for every word.
- Use the same actor for the same sound throughout a run and across decks. One actor should not stand for two distinct sounds. Homophone aliases in the roster are deliberate exceptions, not alternative pronunciations to invent.
- Most names encode only their listed initial mora: Mario supplies `ま`, not `まりお`; Anpanman supplies `あ`, not `あん`. Never accidentally encode the rest of a character's name.
- The roster records a pronunciation cue alongside the English identity. Some use the Japanese name or a surname: Meowth/Nyarth for `にゃ`, Hinata HYUga for `ひゅ`. Make that association clear during roster setup. Do not assume English spelling guarantees the sound; Kirby's ordinary English name does not supply `き`.
- The provisional Koito `ぴゃ` entry uses her recognizable startled cry, not her name. Keep this exception explicit in setup/review data. Do not invent purported canonical catchphrases to fill other gaps.
- Keep canonical names readable in the story, such as Mario and Anpanman. The registry and review data hold the exact sound mapping; routine stories need no kana label or repeated cue explanation.

## Turn the reading into one event

1. Establish the verified whole-word meaning, kanji-only reading segments and ordered RTK keywords exactly as in the main skill.
2. Within each kanji segment, select the contracted mora as one unit (`しゃ`, not `し + や`). Treat `ん`, small `っ`, and vowel length using the roster's marker rules. A true hiatus remains two vowels; a long vowel holds one vowel for two beats. Native audio governs this distinction.
3. Have the sound actors perform or embody their corresponding RTK images in reading order, with the keyword close to the actor it belongs to. The ordered keyword and sound constraints remain separate checks. For irregular grouped readings, keep all relevant images in one compact episode without inventing per-kanji assignments.
4. Make those actions cause the whole-word meaning. Preserve one setting and a clear result. Introduce actors when their sound occurs; do not let decorative appearances, earlier pronouns, or repeated name mentions scramble the recoverable cue sequence.
5. Place the natural English meaning near the end in bold and underline. The card still contains only the story.

An actor's iconic appearance helps identification. Its action must serve this vocabulary word: Mario need not jump in every story, and Anpanman need not throw the same punch every time. Do not add a character's usual props unless they help the reading or meaning. Repeated sound tokens may use the same actor again; preserve the repeated sound in internal data even when one actor performs two ordered actions.

Do not merge several sounds into a convenient unregistered actor, omit a repeated mora, or drop a length/closure marker just to reduce cast size. If a long word becomes a parade, simplify the event rather than sacrifice the reading. Ordinary reading cues encode only kanji; written kana and okurigana still summon no actors.

## Preserve exact review data

For each story retain the selected complete reading, ordered kanji-only segments and RTK mappings, plus ordered sound tokens with `kana`, `actor`, `cue_basis`, and any nasal/closure/length operation. Reconstruct the supplied kanji reading from those tokens and verify gap boundaries. A visually stretched Mario can encode a genuine long `まあ`; two actions by Mario encode repeated `まま`. They are not interchangeable.

A character identity/name change is a registry change, not a per-word improvisation. Record substitutions and apply the chosen replacement consistently to future work. Skill changes do not authorize rewriting already installed decks, resuming cancelled batches, or changing Anki scheduling.

## Short examples

These examples use verified RTK mappings from the bundled lookup. Character assignments below are proposed roster choices except Mario and Anpanman.

### 今【いま】 — now

Itachi shouts **now** as the starting gate drops; Mario bursts through before it closes, seizing his chance to run <b><u>now</u></b>.

Internal: 今 = now; `い → Itachi`, `ま → Mario`; one grouped kanji reading `いま`. The immediate alarm makes the present moment actionable.

### 赤【あか】 — red

Anpanman spills **red** paint over Kakashi's masked face; every white patch turns the color of a tomato, leaving his entire costume <b><u>red</u></b>.

Internal: 赤 = red; `あ → Anpanman`, `か → Kakashi`; one kanji reading `あか`. Both actors visibly cause the color change.

### 取り消す【とりけす】 — cancel a reservation

Totoro **takes** the booking slip and passes it to Ken, who **extinguishes** its flames in water; the hotel erases the booking, leaving the reservation <b><u>canceled</u></b>.

Internal: 取 = take, `と → Totoro`; 消 = extinguish, `け → Ken`. Written `り` and `す` are excluded. The named cancellation happens in the hotel system as a result of destroying the booking slip.

### 学校【がっこう】 — school (closure and length)

Gaara's **study** desk is crushed by Thwomp; Conan stretches the **exam** corridor into a long hall of classrooms where children attend <b><u>school</u></b>.

Internal: 学校 = `がっこう`; `が → Gaara`, `っ → Thwomp` closes before /k/, `こ → Conan` with the /o/ held for the lengthening `う`. This does not summon Usagi or pronounce “Thwomp.” Keywords `study → exam` retain written order. Prefer a more natural scene if this marker-heavy version is harder to recall; the markers cannot be dropped.
