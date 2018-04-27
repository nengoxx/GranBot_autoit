#cs
   Config file for combat #2 Skills

   Each skill has parameters for the combat bot:
   [ IMAGE, CD, TYPE, DURATION, PRIORITY, DEBUFFS ]
   0-	Image to search for ingame
   1-	Cooldown
   2-	Type 	0: buff | 1: debuff | 2: dmg cut | -1: none
   3-	Duration of the effect, -1 if none or debuff(assume debuffs last for 180 sec)
   4-	Priority from 0 to 5 to pair in order with other skills
		 0: first | 1 to 3: buffs | 4: usual debuffs | 5: special or short debuffs
   5-	Applies or Clears debuffs to/from party		0: applies debuff | 1: clears debuff | -1: none

   WARNING: take in account CD & Duration modifications caused by characters & other
#ce
Local $skillParams = 7

;### 	GAO
Local $gao_def_breach[$skillParams]
   $gao_def_breach[0] = $skills_dir & "skillGaoDefBr.bmp"
   $gao_def_breach[1] = 5	;5 turn CD
   $gao_def_breach[2] = 1	;Debuff
   $gao_def_breach[3] = -1	;No duration tracking for debuffs
   $gao_def_breach[4] = 4	;Priority as a simple debuff
   $gao_def_breach[5] = -1	;Doesn't apply/clear debuffs to/from party
   $gao_def_breach[6] = 0		;Doesn't heal

Local $gao_ignition[$skillParams]
   $gao_ignition[0] = $skills_dir & "skillGaoIgn.bmp"
   $gao_ignition[1] = 5
   $gao_ignition[2] = 0
   $gao_ignition[3] = 1
   $gao_ignition[4] = 3	;Use this as one of last buffs as u're supposed to drain the charge bar 1st
   $gao_ignition[5] = -1
   $gao_ignition[6] = 0

Local $gao_rage[$skillParams]
   $gao_rage[0] = $skills_dir & "skillGaoRage.bmp"
   $gao_rage[1] = 5		;CD
   $gao_rage[2] = 0		;Type 0: buff | 1: debuff | 2: dmg cut | -1: none
   $gao_rage[3] = 3		;Duration
   $gao_rage[4] = 1		;Priority
   $gao_rage[5] = -1	;Debuffs party 0: applies | 1: clears | -1: none
   $gao_rage[6] = 0		;Heal

;### 	Katalina
Local $kata_2[$skillParams]
   $kata_2[0] = $skills_dir & "skillKat2.bmp"
   $kata_2[1] = 8		;CD
   $kata_2[2] = 0		;Type 0: buff | 1: debuff | 2: dmg cut | -1: none
   $kata_2[3] = 4		;Duration
   $kata_2[4] = 1		;Priority
   $kata_2[5] = 1		;Debuffs party 0: applies | 1: clears | -1: none
   $kata_2[6] = 1		;Heal

Local $kata_1[$skillParams]
   $kata_1[0] = $skills_dir & "skillKat1.bmp"
   $kata_1[1] = 6		;CD
   $kata_1[2] = 0		;Type 0: buff | 1: debuff | 2: dmg cut | -1: none
   $kata_1[3] = 1		;Duration
   $kata_1[4] = 3		;Priority
   $kata_1[5] = -1		;Debuffs party 0: applies | 1: clears | -1: none
   $kata_1[6] = 0		;Heal

Local $kata_3[$skillParams]
   $kata_3[0] = $skills_dir & "skillKat3.bmp"
   $kata_3[1] = 3		;CD
   $kata_3[2] = 2		;Type 0: buff | 1: debuff | 2: dmg cut | -1: none
   $kata_3[3] = 1		;Duration
   $kata_3[4] = 0		;Priority
   $kata_3[5] = -1	;Debuffs party 0: applies | 1: clears | -1: none
   $kata_3[6] = 0		;Heal

;###	Altair
Local $altair_1[$skillParams]
   $altair_1[0] = $skills_dir & "skillAltair1.bmp"
   $altair_1[1] = 7		;CD
   $altair_1[2] = 0		;Type 0: buff | 1: debuff | 2: dmg cut | -1: none
   $altair_1[3] = 3		;Duration
   $altair_1[4] = 2		;Priority
   $altair_1[5] = -1	;Debuffs party 0: applies | 1: clears | -1: none
   $altair_1[6] = 0		;Heal

Local $altair_2[$skillParams]
   $altair_2[0] = $skills_dir & "skillAltair2.bmp"
   $altair_2[1] = 7		;CD
   $altair_2[2] = 1		;Type 0: buff | 1: debuff | 2: dmg cut | -1: none
   $altair_2[3] = -1		;Duration
   $altair_2[4] = 4		;Priority
   $altair_2[5] = -1		;Debuffs party 0: applies | 1: clears | -1: none
   $altair_2[6] = 0		;Heal

Local $altair_3[$skillParams]
   $altair_3[0] = $skills_dir & "skillAltair3.bmp"
   $altair_3[1] = 7		;CD
   $altair_3[2] = 0		;Type 0: buff | 1: debuff | 2: dmg cut | -1: none
   $altair_3[3] = -1		;Duration
   $altair_3[4] = 1		;Priority
   $altair_3[5] = -1		;Debuffs party 0: applies | 1: clears | -1: none
   $altair_3[6] = 0		;Heal

;### 	S.Izmir
Local $sizmir_1[$skillParams]
   $sizmir_1[0] = $skills_dir & "skillSizmir1.bmp"
   $sizmir_1[1] = 2		;CD
   $sizmir_1[2] = 0		;Type 0: buff | 1: debuff | 2: dmg cut | -1: none
   $sizmir_1[3] = -1		;Duration
   $sizmir_1[4] = 1		;Priority
   $sizmir_1[5] = -1		;Debuffs party 0: applies | 1: clears | -1: none
   $sizmir_1[6] = 0		;Heal

Local $sizmir_2[$skillParams]
   $sizmir_2[0] = $skills_dir & "skillSizmir2.bmp"
   $sizmir_2[1] = 15		;CD
   $sizmir_2[2] = 0		;Type 0: buff | 1: debuff | 2: dmg cut | -1: none
   $sizmir_2[3] = -1		;Duration
   $sizmir_2[4] = 1		;Priority
   $sizmir_2[5] = -1		;Debuffs party 0: applies | 1: clears | -1: none
   $sizmir_2[6] = 0		;Heal


;###	Sub Skills
Local $sub_arrow_rain[$skillParams]
   $sub_arrow_rain[0] = $skills_dir & "skillArrowRain.bmp"
   $sub_arrow_rain[1] = 5		;CD
   $sub_arrow_rain[2] = 1		;Type 0: buff | 1: debuff | 2: dmg cut | -1: none
   $sub_arrow_rain[3] = -1		;Duration
   $sub_arrow_rain[4] = 4		;Priority
   $sub_arrow_rain[5] = -1		;Debuffs party 0: applies | 1: clears | -1: none
   $sub_arrow_rain[6] = 0		;Heal