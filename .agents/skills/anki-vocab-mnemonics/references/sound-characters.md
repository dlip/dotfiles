# Japanese sound characters

One stable actor for each sound. **あ = Anpanman** and **ま = Mario** are the user's choices; the others are proposed defaults, not claims about the user's familiarity. There are 104 standard kana entries, including homophone aliases. English character names identify the actors; the kana cue column records the actual name pronunciation used for its opening sound. Unmatched sounds have blank actor fields and an UNRESOLVED selection note.

The learner recognizes Naruto himself but has not watched Naruto; all other Naruto characters have been replaced with proposed alternatives. Personalize replacements using the learner’s direct feedback. The learner knows only very popular Pokemon and is unfamiliar with Gundam and King of Fighters. The learner is also unfamiliar with Korean pop culture. Avoid lesser-known Pokemon, Pokemon trainers, Korean pop-culture references, and both unfamiliar franchises.

Read [character-cues.md](character-cues.md) before composing stories. Names marked Japanese use that character's Japanese/localized pronunciation; do not silently substitute a different English pronunciation. A long vowel later in a name does not automatically lengthen the encoded prefix.

The authoritative roster is [assets/sound-characters.csv](../assets/sound-characters.csv). Columns: `kana`, `romaji`, `character`, `cue_reading`, `franchise`, `visual_anchor`, `selection_note`, and `signature_actions`. Each row assigns one written kana entry to its actor; homophone aliases have separate rows.

## Aliases and exceptional markers

- Standard modern Japanese `を` uses the same sound actor as `お`; `ぢ` shares `じ`, and `づ` shares `ず`. Preserve the actual written kana in review data. For attested dialectal or lexical distinctions, follow the audio instead of forcing these aliases.
- `ぢゃ・ぢゅ・ぢょ`, when encountered, share `じゃ・じゅ・じょ` in the usual modern pronunciation.
- `ん` uses **Nemo** as a nasal-closing marker. Imagine him closing his mouth while the learner hums the nasal sound; this is a designed mnemonic gesture, not a canonical character sound. Do not say Nemo or add a vowel.
- Small `っ` uses **Thwomp** as a closure marker: it slams shut immediately before the following consonant. It does not encode `つ` or the sound of “Thwomp.”
- Long vowels use the preceding actor visibly stretching/holding the vowel for a second beat. Do not add Usagi merely because a lengthening `う` is written, or confuse that with a genuinely separate `う`.
- Foreign combinations such as `ティ・ファ・ヴァ` are outside this core inventory. Extend the registry deliberately when actually needed; do not silently split them into different sounds.

## Familiarity review

The learner is Australian and an '80s kid, has played many retro video games, and likes movies. Favor retro games, classic films, and Australian childhood television when proposing actors; individual familiarity still comes from the learner's review.

Use the learner’s direct feedback to replace unfamiliar actors when requested. Prefer familiar actors while preserving sound accuracy. Keep `selection_note` focused on the current cue, pronunciation differences, and explicit exceptions.

## Name cues, English approximations, and unresolved entries

Japanese names require an exact matching initial mora, including contracted sounds. `みお` is not `みょ`, and `りお` is not `りょ`; do not merge separate Japanese morae. Similar-sounding approximations are permitted for non-Japanese names only. The user explicitly reaffirmed one exception: `りょ → Rio` despite the Japanese reading `りお`. Retain that choice; do not extend the exception to other Japanese names. Apply the distinction to the actual name/pronunciation, not the franchise or nationality.

Use actual spoken name openings or an explicitly recorded name component. The user permits similar English names; keep the real pronunciation and describe the mismatch in `selection_note`. For example, Bueller supplies `びゅ` through his surname's BYOO opening. `character` stores the sound-bearing display name; `selection_note` retains Ferris Bueller as the full identity. Likewise, use Newton and Tsung in stories rather than prepending Isaac or Shang. Mia's MEE-ah is a loose resemblance to `みゃ`, not an exact Japanese contracted mora. Do not claim that English names are pronounced as their target kana.

Do not manufacture cues through props, moves, film/band titles, animal noises, or consonant-plus-word combinations. King Kong does not supply `きょ`. Mjolnir can supply `みょ` as the actual named hammer; its owner Thor cannot supply that sound merely by holding it.

A provisional spoken-name mapping must be checked before story use. Gyorg's proposed GY-org reading is unverified and would not work if the learner says GUY-org or GEE-org. Familiarity review does not itself verify pronunciation.

If no suitable proposal exists, leave actor fields blank and mark `selection_note` as `UNRESOLVED`; do not invent a name or pronunciation. Nasal, closure, and vowel-length operations remain separate markers.

`signature_actions` lists optional recognizable actions for the recorded character or explicitly identified role. Use them when they support the word’s meaning; avoid forcing the same move into every story. Real-person entries describe public performance or a named role, not invented personal traits. Nemo’s mouth-closing cue is a designed mnemonic gesture.
