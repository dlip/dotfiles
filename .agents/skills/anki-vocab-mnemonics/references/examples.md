# Examples and failure checks

These are illustrative drafts. Follow the target deck's actual meaning and chosen reading. English cues are approximate.

## Distinguishing trait: 特徴

**特徴【とくちょう】— characteristic; distinguishing feature**

**Kanji → meaning:** 特 **special** → 徴 **indications**. Special identifying indications reveal a distinguishing trait.

**Kanji → sounds:** 特 とく → TOE + COO; 徴 ちょう → CHOsen.

**Story:** A **special** spiral feather wraps around a bird's TOE. It gives a COO as the guide examines the CHOsen flock: each bird has that spiral, unlike neighboring species. These **indications** reveal their shared **characteristic—the spiral feather**.

The feature is physically present and distinguishes the flock. “A special feather gives indications” alone leaves the connection abstract. The explicit final phrase reinforces the image rather than supplying its only meaning.

## Excluding written kana: 取り消す

**取り消す【とりけす】— to cancel a reservation**

**Kanji → meaning:** 取 **take** → 消 **extinguish**. Taking a reservation and extinguishing its active booking cancels it.

**Kanji → sounds:** 取 と → TOE; 消 け → KEttle. Written `り` and `す` receive no cues.

**Story:** I **take** my burning reservation slip between my TOE and heel, then **extinguish** its booking flame with a KEttle. My name vanishes from the hotel board, and the room becomes available again: the reservation is **canceled**.

The booking ceases; water does not merely fall on unrelated paper. If furigana is grouped over `取り消`, account for the written `り` rather than encoding the entire furigana string.

## Abstract relation made visible: 矛盾

**矛盾【むじゅん】— contradiction; inconsistency**

**Kanji → meaning:** 矛 **halberd** → 盾 **shield**. Incompatible claims about the weapon and shield expose a contradiction.

**Kanji → sounds:** 矛 む → MOO; 盾 じゅん → JUNE.

**Story:** A MOOing merchant tells JUNE: “This **halberd** pierces everything; this **shield** blocks everything.” She thrusts one against the other and asks which promise will fail. His claims cannot both be true—that's the **contradiction**.

The interaction exposes incompatibility. Holding a weapon and shield alone does not demonstrate contradiction. This scene is a memory aid, not a claim about historical origin.

## Internal state shown through action: 我慢

**我慢【がまん】— endurance; bearing discomfort**

**Kanji → meaning:** 我 **ego** → 慢 **ridicule**. Controlling a wounded ego while bearing ridicule demonstrates endurance.

**Kanji → sounds:** 我 が → GAp; 慢 まん → MAN.

**Story:** My **ego**, a tiny crowned version of me, tries to flee through a GAp as a MAN heaps **ridicule** on my work. I hold it back, steady my trembling hands, and finish the repair despite the insults—**endurance**.

Both discomfort and continued effort are visible. The abstract ego has a concrete representation.

## Reading edge cases

- `大人【おとな】`: keep `大人＝おとな` together; do not invent per-character readings.
- `五つ星ホテル【いつつぼしほてる】`: cue `五＝いつ` and `星＝ぼし`; exclude written `つ` and `ホテル`.
- `100円ショップ【ひゃくえんしょっぷ】`: cue `円＝えん` only. Display the full reading in the header.
- `度々【たびたび】`: show the preceding character's keyword twice, for `度` and `々`.
- `依存【いそん】` and `依存【いぞん】`: cues must match the selected valid reading; familiarity alone is not reason to normalize it.

## Reject these patterns

- A stage labeled with the definition, with no action demonstrating it.
- Ordered keywords pasted before an unrelated ordinary example.
- A parade of English sound props with no meaningful interaction.
- A dictionary explanation appended to a scene depicting the wrong sense.
- Invented RTK keywords or primitive decomposition replacing whole-character keywords.
- Invented per-kanji readings, encoded written kana, or added syllables for convenience.
- Ungrammatical cues such as “ME and SHE run” or “the clerk put ups a notice.”

## Keyword lookup provenance

`assets/rtk-keywords.csv` contains distinct nonempty `(kanji, keyword)` pairs extracted from the user's `/home/dane/code/yomitan-rtk/rtk.csv`. RTK numbers and existing stories are omitted. This is a portable default; user-supplied sources and explicit keyword choices take precedence. Preserve alternatives rather than assuming the first row is intended.
