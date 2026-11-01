# Writing with sound characters

Use [assets/sound-characters.csv](../assets/sound-characters.csv) as the shared sound-to-character registry; [sound-characters.md](sound-characters.md) explains pronunciation, aliases, and exceptional markers. This is the default for new stories requested with the updated skill. The former generic English sound objects remain a legacy mode for explicit requests or existing examples; do not mix the two systems unnoticed within a new batch.

## Select the actors

- The learner is Australian, grew up as an '80s kid, has played many retro video games, and enjoys movies. Prioritize recognizable retro-game characters, classic film characters, and Australian childhood television or public figures. Use these as search directions, not proof that a particular character is familiar. Prefer recognizable English names and record any Japanese alias or other cue association explicitly. Do not loosen the sound match merely to fit a famous name.
- The learner has not watched Naruto and recognizes only Naruto himself; do not use other Naruto characters.
- The learner is unfamiliar with Korean pop culture; avoid Korean pop stars, actors, television characters, and related references when proposing replacements.
- The learner is unfamiliar with Gundam and King of Fighters; avoid proposing characters from those franchises.
- The learner knows only the very popular Pokemon. Do not propose lesser-known Pokemon or Pokemon trainers; preserve individual reviewed choices and avoid recycling rejected names.
- Preserve the user's fixed choices in the CSV, including `あ → Anpanman`, `ま → Mario`, and `きゃ → Kyary Pamyu Pamyu`. Explicit selections supersede earlier unfamiliarity marks for the same actor. `みゅ → Myuutuu` is the user's chosen display spelling for Mewtwo. The user explicitly reaffirmed `りょ → Rio` after its `りお` mismatch was explained; retain this specific exception without relaxing the exact-match rule for other Japanese names. Other roster entries are proposed defaults. Prefer actors the learner already recognizes. Offer a replacement when a rare or unfamiliar actor would otherwise become extra homework; no need to reconfirm familiar choices for every word.
- Use the same actor for the same sound throughout a run and across decks. One actor should not stand for two distinct sounds. Homophone aliases in the roster are deliberate exceptions, not alternative pronunciations to invent.
- Most names encode only their listed initial mora: Mario supplies `ま`, not `まりお`; Anpanman supplies `あ`, not `あん`. Never accidentally encode the rest of a character's name.
- The roster records a pronunciation cue alongside the English identity. Some use the Japanese name or a surname: Newton (Isaac Newton; Japanese NYUuton) for `にゅ`, Huey (Japanese HYUui) for `ひゅ`. Make that association clear during roster setup. Do not assume English spelling guarantees the sound; Kirby's ordinary English name does not supply `き`.
- Use the actual spoken opening of the selected name or explicitly recorded name component. **Japanese names must match the target initial mora exactly.** Preserve contracted sounds: `みお` cannot supply `みょ`, and `りお` cannot supply `りょ`. Do not change a Japanese name's vowels, merge its separate morae, or insert a glide to force a match. Determine this from the name/pronunciation being used, not the character's franchise, nationality, or the script used to display it.
- **Non-Japanese names may use similar-sounding openings.** Record the real pronunciation and specific difference in `selection_note`; prefer small differences and distinguish neighboring kana. Do not present loose English approximations as exact Japanese readings. A familiar character does not automatically make a poor sound association useful.
- Do not manufacture cues through props, moves, weapons, titles, band/film names, animal noises, or consonant-plus-word combinations. King Kong cannot encode `きょ`; Thor cannot encode `みょ` by holding Mjolnir. A named object may itself be the actor when its own name supplies the cue. Check uncertain spoken-name mappings before story use. If a new rule conflicts with a previously explicit user choice, retain that choice and flag the conflict rather than silently replacing it or treating it as an approved exception.
- If no accurate candidate is found, leave `character`, `franchise`, and `visual_anchor` blank, retain the target kana in `cue_reading`, and start `selection_note` with `UNRESOLVED`. An unresolved row is not a usable actor; flag the missing cue when composing stories rather than silently filling it. Nasal/closure/length markers remain explicit operations, not ordinary name-prefix mappings.
- Keep `character` to one word: the name actually spoken in the story and used for its opening sound. Retain the full identity in `selection_note`. If the cue uses a surname or another name component, put that component first as the main display name: `Newton`, `Bueller`, `Tsung`. Keep the full identity in `selection_note`; do not prepend an uncued first name in story prose.
- Keep canonical names readable in the story, such as Mario and Anpanman. The registry and review data hold the exact sound mapping; routine stories need no kana label or repeated cue explanation.

## Turn the reading into one event

1. Establish the verified whole-word meaning, kanji-only reading segments and ordered RTK keywords exactly as in the main skill.
2. Within each kanji segment, select the contracted mora as one unit (`しゃ`, not `し + や`). Treat `ん`, small `っ`, and vowel length using the roster's marker rules. A true hiatus remains two vowels; a long vowel holds one vowel for two beats. Native audio governs this distinction.
3. Open the scene with the bold-and-underlined whole-word meaning. For multi-kanji words, let each RTK image interact with its corresponding sound actors. Either may come first locally; choose vivid imagery and natural grammar, keeping them in the same short clause where practical. Preserve keyword writing order and actor reading order independently. For single-kanji words, omit the separate RTK keyword and let the sound actors demonstrate the meaning. The ordered keyword and sound constraints remain separate checks. For irregular grouped readings, keep all relevant images in one compact episode without inventing per-kanji assignments.
4. Make those actions cause the whole-word meaning. Preserve one setting and a clear result. Introduce actors when their sound occurs; do not let decorative appearances, earlier pronouns, or repeated name mentions scramble the recoverable cue sequence.
5. Italicize sound-character names (including named nasal/closure markers), using `<i>…</i>` in Anki HTML. Check that the action demonstrates the opening meaning; no closing definition is required. The card still contains only the story.

An actor's iconic appearance helps identification. Its action must serve this vocabulary word: Mario need not jump in every story, and Anpanman need not throw the same punch every time. Do not add a character's usual props unless they help the reading or meaning. Repeated sound tokens may use the same actor again; preserve the repeated sound in internal data even when one actor performs two ordered actions.

Do not merge several sounds into a convenient unregistered actor, omit a repeated mora, or drop a length/closure marker just to reduce cast size. If a long word becomes a parade, simplify the event rather than sacrifice the reading. Ordinary reading cues encode only kanji; written kana and okurigana still summon no actors.

## Preserve exact review data

For each story retain the selected complete reading, ordered kanji-only segments and RTK mappings, plus ordered sound tokens with `kana`, `actor`, `cue_basis`, and any nasal/closure/length operation. Reconstruct the supplied kanji reading from those tokens and verify gap boundaries. A visually stretched Mario can encode a genuine long `まあ`; two actions by Mario encode repeated `まま`. They are not interchangeable.

A character identity/name change is a registry change, not a per-word improvisation. Record substitutions and apply the chosen replacement consistently to future work. Skill changes do not authorize rewriting already installed decks, resuming cancelled batches, or changing Anki scheduling.

## Short examples

### 旅行【りょこう】 — travel

During her <b><u>travel</u></b> adventure, *Rio* films her **trip** aboard a runaway suitcase; **going** across the ocean, *Conan* stretches from deck to deck to investigate its missing ticket.

Internal: 旅 = trip, `りょ → Rio` (user-authorized approximation); 行 = going, `こ → Conan`, stretching holds /o/ for the lengthening `う`. Meaning comes first; the first actor precedes its keyword, while the next keyword precedes its actor. Both keyword writing order and actor reading order remain intact. Both actors participate in the journey.

### 牛【ぎゅう】 — cow

A <b><u>cow</u></b> chews *Gustave*’s mechanical arm, stretching him across the paddock as he desperately tries to pull free.

Internal: one kanji, so omit the separate RTK keyword. `ぎゅ → Gustave` (registered approximation); stretching marks the long /u/. The cow drives the action.

### 取り消す【とりけす】 — cancel a reservation

To <b><u>cancel a reservation</u></b>, **take** the burning booking slip with *Totoro* and **extinguish** it with *Kenny*; its magical hotel entry vanishes in the steam.

Internal: 取 = take, `と → Totoro`; 消 = extinguish, `け → Kenny`. Written `り` and `す` receive no actors. There are two kanji, so both keywords remain.
