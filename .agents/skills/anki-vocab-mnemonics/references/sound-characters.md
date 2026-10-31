# Japanese sound characters

One stable actor for each sound. **あ = Anpanman** and **ま = Mario** are the user's choices; the others are proposed defaults, not claims about the user's familiarity. There are 104 standard kana entries, including homophone aliases. English character names identify the actors; the kana cue column specifies the intended sound prefix, not the whole name.

Read [character-cues.md](character-cues.md) before composing stories. Names marked Japanese use that character's Japanese/localized pronunciation; do not silently substitute a different English pronunciation. A long vowel later in a name does not automatically lengthen the encoded prefix.

The authoritative roster is [assets/sound-characters.csv](../assets/sound-characters.csv). Columns: `kana`, `romaji`, `character`, `cue_reading`, `franchise`, `visual_anchor`, and `selection_note`. Each row assigns one written kana entry to its actor; homophone aliases have separate rows.

## Aliases and exceptional markers

- Standard modern Japanese `を` uses the same sound actor as `お`; `ぢ` shares `じ`, and `づ` shares `ず`. Preserve the actual written kana in review data. For attested dialectal or lexical distinctions, follow the audio instead of forcing these aliases.
- `ぢゃ・ぢゅ・ぢょ`, when encountered, share `じゃ・じゅ・じょ` in the usual modern pronunciation.
- `ん` uses Pokemon's **N** as a nasal-closing marker. Picture his nasal hum; do not pronounce his name “en” or insert an extra vowel.
- Small `っ` uses **Thwomp** as a closure marker: it slams shut immediately before the following consonant. It does not encode `つ` or the sound of “Thwomp.”
- Long vowels use the preceding actor visibly stretching/holding the vowel for a second beat. Do not add Usagi merely because a lengthening `う` is written, or confuse that with a genuinely separate `う`.
- Foreign combinations such as `ティ・ファ・ヴァ` are outside this core inventory. Extend the registry deliberately when actually needed; do not silently split them into different sounds.

## Source checks for less familiar choices

These links establish the character identities; they do not prove the mnemonic works for this learner.

- [Myau: SEGA's Phantasy Star character page](https://www.sega.jp/fb/album/07_ps/character.html).
- [Pyunma: official Cyborg 009 character page](https://cyborg009.jp/008-2/).
- [Bjorn: HISTORY's Vikings cast page](https://www.history.com/shows/vikings/cast/bjorn).
- [LYA: licensed WDZY merchandise](https://www.sk-japan.co.jp/character-fancy/product/wdzy/cfgoods-13996); [localized リャ reading](https://daebak.tokyo/2020/09/11/itzy-line-friends-2/). Treat this less familiar localized name as provisional.
- [Koito: official character page](https://shinycolors-anime2nd.idolmaster-official.jp/character/koito/); [game dialogue transcription including ぴゃ](https://gamesink.net/imassc/characters/22). Her proposed `ぴゃ` mapping uses the startled cry, **not** the pronunciation of Koito. Replace it if that association is unfamiliar; do not pass it off as a name-prefix match.

An unknown character adds another association to learn. Replace unfamiliar choices with a character the learner already pictures; keep the sound match and update the registry once rather than changing actors between stories.
