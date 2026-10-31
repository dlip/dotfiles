# Legacy English-object examples and shared failure checks

New stories default to the character roster in [character-cues.md](character-cues.md). These older English-object examples remain useful for explicit legacy requests and for checking meaning links.

Vocabulary labels identify examples here; only each story goes into the Anki Story field. The English target is bold and underlined near the end; natural wording may follow it. Mapping notes illustrate internal review data and are not rendered on cards. English cues approximate the verified Japanese reading.

## 技術【ぎじゅつ】— technology

A **skill**ful GEEk masters the **art** of powering boots with JUice, then skates up a TSUnami while the stranded surfers beg to borrow his <b><u>technology</u></b>.

Internal check: 技 skill＝ぎ (GEEk); 術 art＝じゅつ (JUice + TSUnami). The invention visibly applies knowledge, and the technology is something the surfers want to use.

## 厳しい【きびしい】— strict

The **stern** librarian locks the KEY away. Even her pet BEE gets evicted for one buzz; its tearful apology cannot persuade her to be less <b><u>strict</u></b>.

Internal check: 厳 stern＝きび (KEY + BEE); written しい is excluded. Both cues belong to the same kanji and its rule-enforcing scene.

## 取り消す【とりけす】— cancel a reservation

I **take** my burning booking slip with my TOE, then **extinguish** it with a KEttle. My name disappears from the hotel board, leaving my reservation <b><u>canceled</u></b>.

Internal check: 取 take＝と (TOE); 消 extinguish＝け (KEttle). Written り and す are excluded. The booking ceases; water does not merely fall on unrelated paper.

## 招待【しょうたい】— invitation

I **beckon** my neighbour and SHOW him a feast, then **wait** with a TIE-shaped napkin beside his empty chair until he accepts my dinner <b><u>invitation</u></b>.

Internal check: 招 beckon＝しょう (SHOW); 待 wait＝たい (TIE). Welcoming gestures and a prepared place demonstrate the invitation before it is named.

## 家具【かぐ】— furniture

A **house**-sized CAt builds a **tool** for scraping GOO off chairs and sofas, licking each seat clean before proudly arranging its enormous <b><u>furniture</u></b>.

Internal check: 家 house＝か (CAt); 具 tool＝ぐ (GOO). House-sized identifies the CAt; tool and GOO share the next action. Chairs and sofa concretely establish furniture.

## Research note: distinctiveness and emotion

Humor improved sentence recall in [Schmidt (1994)](https://pubmed.ncbi.nlm.nih.gov/8064254/). Bizarre imagery's recall advantage depended on context and distinctiveness in [McDaniel and Einstein (1986)](https://doi.org/10.1037/0278-7393.12.1.54); it was not an unconditional advantage for making every item bizarre. [Jay et al. (2008)](https://pubmed.ncbi.nlm.nih.gov/18437803/) found strong recall for taboo words, which does not establish that adding profanity improves memory for an associated foreign word.

Emotional material can also have costs. In [Schmidt (2002)](https://pubmed.ncbi.nlm.nih.gov/11911390/), nude pictures were memorable but impaired recall of background details and subsequent pictures. [Experimental work on negative emotional scenes](https://pmc.ncbi.nlm.nih.gov/articles/PMC3792043/) illustrates that effects on central and peripheral details depend on the task. These studies do not directly validate our combination of ordered RTK keywords, whole-word meaning, and English sound cues, or establish that greater sexual or violent intensity improves it.

The practical inference is to make the target connection itself distinctive. For **厳しい【きびしい】— strict**, with RTK **stern** and cues KEY + BEE:

**Integrated:** The **stern** referee locks the trophy KEY away; even his favourite BEE is disqualified for touching the line, and not even his pleading mother can make him less **strict**.

The absurd competitor and exaggerated enforcement reinforce strictness, while both cues belong to that event. An unrelated dirty joke or explosion beside a referee could be memorable without helping retrieve “strict.” Use the same check for sexual, vulgar, or violent scenes; their intensity cannot replace the semantic connection.

When comparing styles, test delayed meaning and reading recall separately. Remembering or enjoying a story alone does not demonstrate improved vocabulary recall.

## Reading edge cases

- `大人【おとな】`: keep `大人＝おとな` together; do not invent per-character readings.
- `五つ星ホテル【いつつぼしほてる】`: cue `五＝いつ` and `星＝ぼし`; exclude written `つ` and `ホテル`.
- `100円ショップ【ひゃくえんしょっぷ】`: cue `円＝えん` only. Retain the full reading in review data.
- `度々【たびたび】`: show the preceding character's keyword twice, for `度` and `々`.
- `依存【いそん】` and `依存【いぞん】`: cues must match the selected valid reading; familiarity alone is not reason to normalize it.

## Reject these patterns

- A stage labeled with the definition, with no action demonstrating it.
- Ordered keywords pasted before an unrelated ordinary example.
- A parade of English sound props with no meaningful interaction.
- A dictionary explanation appended to a scene depicting the wrong sense.
- Scripted endings such as “that's technology,” or a meaning label appended after the event.
- Keywords distant from their corresponding sound cues without a grouped-reading reason.
- Invented RTK keywords or primitive decomposition replacing whole-character keywords.
- Invented per-kanji readings, encoded written kana, or added syllables for convenience.
- Ungrammatical cues such as “ME and SHE run” or “the clerk put ups a notice.”

## Keyword lookup provenance

`assets/rtk-keywords.csv` contains distinct nonempty `(kanji, keyword)` pairs extracted from the user's `/home/dane/code/yomitan-rtk/rtk.csv`. RTK numbers and existing stories are omitted. This is a portable default; user-supplied sources and explicit keyword choices take precedence. Preserve alternatives rather than assuming the first row is intended.
