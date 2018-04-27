#include-once
;TODO:
;Rename image variables and make them as arrays of 3 values (file,width,height)
;so they can be used for the buttons and clickable images (see _GDIPlus_ImageGetWidth)
Local $images_dir = @ScriptDir & "\images\"

;####	WEB		####
Local $web_dir = $images_dir & "\web\"
Local $tweetdeck_dir = $web_dir & "\tweetdeck\"
Local $raidfinder_dir = $web_dir & "\raidfinder\"
Local $gbfraider_dir = $web_dir & "\gbfraider\"

$now_raidfinder = $raidfinder_dir & "now_raidfinder.bmp" 	;raidfinder
$now_raidfinder2 = $raidfinder_dir & "now_raidfinder2.bmp"
$now_raidfinder3 = $raidfinder_dir & "now_raidfinder3.bmp"
$now_raidfinder4 = $raidfinder_dir & "now_raidfinder4.bmp"

$gbf_raiderID = $gbfraider_dir & "copyID.bmp"		;gbfraider
$gbf_raiderID75 = $gbfraider_dir & "copyID_75%.bmp"		;gbfraider 75%zoom

$tweet_extension = $tweetdeck_dir & "extension.bmp"	;UNUSED as the app doesn't work anymore
$now_tweet = $tweetdeck_dir & "now.bmp"				;looking only into seconds
$now_tweet2 = $tweetdeck_dir & "now2.bmp"
$recent_tweet = $tweetdeck_dir & "sec.bmp"			;looking only into seconds
$recent_tweet2 = $tweetdeck_dir & "sec2.bmp"
$tweet_id = $tweetdeck_dir & "tweet_id.bmp"			;locate the ID inside the tweet
$tweet_id2 = $tweetdeck_dir & "tweet_id2.bmp"
$tweet_back = $tweetdeck_dir & "back.bmp"				;back to tweet list
$check_web = $tweetdeck_dir & "checkWeb.bmp"			;back to tweet list
$check_web2 = $tweetdeck_dir & "checkWeb2.bmp"			;back to tweet list

;####	GLOBAL	####
Local $other_dir = $images_dir & "\other\"
$neterror = $other_dir & "networkerror.bmp"
$verification = $other_dir & "accessVerification.bmp"
$verification2 = $other_dir & "accessVerification2.bmp"
$verification3 = $other_dir & "accessVerification3.bmp"
$sendverification = $other_dir & "sendVerification.bmp"
$sendverification2 = $other_dir & "sendVerification2.bmp"

;####	CO-OP	####
Local $coop_dir = $images_dir & "\coop\"
Local $coop_home_dir = $coop_dir & "\home\"
Local $joinaButtonAmount = 3
Global $joinaButtons[$joinaButtonAmount]
   $joinaButtons[0] = $coop_home_dir & "joinaRoom.bmp"
   $joinaButtons[1] = $coop_home_dir & "joinaRoom_hermit.bmp"
   $joinaButtons[2] = $coop_home_dir & "joinaRoom_enhancer.bmp"

$allrooms = $coop_dir & "allRooms.bmp"
$allrooms2 = $coop_dir & "allRooms2.bmp"
$allrooms3 = $coop_dir & "allRooms3.bmp"
$allrooms4 = $coop_dir & "allRooms4.bmp"
$anyonecorrect = $coop_dir & "anyoneCorrect.bmp"
$anyone = $coop_dir & "anyone.bmp"
$pandemonium = $coop_dir & "pandemonium.bmp"
$pandemoniumcorrect = $coop_dir & "pandemoniumCorrect.bmp"
$anyone2 = $coop_dir & "anyoneHover.bmp"
$pandemonium2 = $coop_dir & "pandemoniumHover.bmp"
$roomnorank = $coop_dir & "anyoneNoRank.bmp"
$pandemoniumnorank = $coop_dir & "pandemoniumNoRank.bmp"
$joinroom = $coop_dir & "joinRoom.bmp"
$refreshrooms = $coop_dir & "refreshRooms.bmp"
$notmet = $coop_dir & "noreqmet.bmp"
$notmetcancel = $coop_dir & "noreqmetCancel.bmp"

$closedroom = $coop_dir & "closedroom.bmp"

;####	CO-OP ROOM	####
Local $coop_room_dir = $coop_dir & "\room\"
$inroom = $coop_room_dir & "inroom.bmp"
$inroom2 = $coop_room_dir & "inroom2.bmp"
$disabledready = $coop_room_dir & "disabledready.bmp"
$selsummbanner = $coop_room_dir & "selSummbanner.bmp"
$skipparty = $coop_room_dir & "skipparty.bmp"
$alreadyready = $coop_room_dir & "alreadyready.bmp"
$clickready = $coop_room_dir & "clickready.bmp"
$clickready2 = $coop_room_dir & "clickready2.bmp"

$leaveroomb = $coop_room_dir & "leaveroom.bmp"
$confirmleaveroomb = $coop_room_dir & "confirmleaveroom.bmp"

;####	NAVIGATION-HOME	####
Local $navigation_dir = $images_dir & "\navigation\"
Local $home_dir = $navigation_dir & "\home\"
Local $coopButtonAmount = 7
Global $coopButtons[$coopButtonAmount]
   $coopButtons[0] = $home_dir & "coop_danua_zinkenstill.bmp"
   $coopButtons[1] = $home_dir & "coop_danua_zinkenstill2.bmp"
   $coopButtons[2] = $home_dir & "coop_danua_zinkenstill3.bmp"
   $coopButtons[3] = $home_dir & "coop_danua_zinkenstill_old.bmp"
   $coopButtons[4] = $home_dir & "coop_danua_zinkenstill_halfap.bmp"
   $coopButtons[5] = $home_dir & "coop_danua_zinkenstill_halfap1.bmp"
   $coopButtons[6] = $home_dir & "coop_danua_zinkenstill_halfap2.bmp"
   ;$coopButtons[3] = $home_dir & "coop_enhancer_zinkenstill.bmp"
   ;$coopButtons[4] = $home_dir & "coop_enhancer_zinkenstill_halfap.bmp"
   ;$coopButtons[5] = $home_dir & "coop_hermit_zinkenstill.bmp"
   ;$coopButtons[6] = $home_dir & "coop_hermit_zinkenstill_halfap.bmp"
   ;$coopButtons[4] = $home_dir & "coop_samurai_zinkenstill.bmp"

Local $questButtonAmount = 6
Global $questButtons[$questButtonAmount]
   $questButtons[0] = $home_dir & "quest1_danua_zinkenstill.bmp"
   $questButtons[1] = $home_dir & "quest1_danua_zinkenstill1.bmp"
   $questButtons[2] = $home_dir & "quest1_danua_zinkenstill2.bmp"
   $questButtons[3] = $home_dir & "quest1_danua_zinkenstill3.bmp"
   ;$questButtons[2] = $home_dir & "quest1_enhancer_zinkenstill.bmp"
   ;$questButtons[3] = $home_dir & "quest1_hermit_zinkenstill.bmp"
   $questButtons[4] = $home_dir & "quest22.bmp"
   $questButtons[5] = $home_dir & "quest23.bmp"
   #cs
   $questButtons[3] = $navigation_dir & "quest1_bishop_zinkenstill.bmp"
   $questButtons[4] = $navigation_dir & "quest1_samurai_zinkenstill.bmp"
   $questButtons[5] = $navigation_dir & "quest1_swordm_zinkenstill.bmp"
   $questButtons[6] = $navigation_dir & "quest1_alchemist_zinkenstill.bmp"
   #ce
$quest2 = $home_dir & "quest2.bmp"

;####	NAVIGATION	####
$homeref = $navigation_dir & "home_referencepoint.bmp"
$reload = $navigation_dir & "reload.bmp"
$reload2 = $navigation_dir & "reload2.bmp"
$mypage = $navigation_dir & "mypage.bmp"
$mypage2 = $navigation_dir & "mypage2.bmp"
$upperMenu = $navigation_dir & "upperMenu.bmp"
$upperClose = $navigation_dir & "upperCloseMenu.bmp"
$back = $navigation_dir & "back.bmp"


$pending = $navigation_dir & "pending.bmp"
$pendingdialog = $navigation_dir & "pending_dialog.bmp"
$resumequest = $navigation_dir & "resumeq.bmp"
$acceptresumequest = $navigation_dir & "acceptResumeq.bmp"
$cancelresumequest = $navigation_dir & "cancelResumeq.bmp"
$retreatedraid = $navigation_dir & "retreatedraid.bmp"
$rejoin = $navigation_dir & "joined.bmp"

$questmenu = $navigation_dir & "questMenu.bmp"
#cs
Global $raidButtonAmount = 5
Local $raidButtons[$raidButtonAmount]
$raidButtons[0] = $navigation_dir & "raid.bmp"
$raidButtons[1] = $navigation_dir & "raid1.bmp"
$raidButtons[2] = $navigation_dir & "raid2.bmp"
$raidButtons[3] = $navigation_dir & "raid3.bmp"
$raidButtons[4] = $navigation_dir & "raid4.bmp"
#ce

$destination = $navigation_dir & "raidSnipeDestination.bmp"
$favquestsmenu = $navigation_dir & "favquestsmenu.bmp"
$favquestsmenu2 = $navigation_dir & "favquestsmenu2.bmp"
$favquestsmenu3 = $navigation_dir & "favquestsmenu3.bmp"
$favquestsmenu4 = $navigation_dir & "favquestsmenu_lightflb.bmp"
$specialqmenu = $navigation_dir & "specialQuestsMenu.bmp"
$eventraids = $navigation_dir & "eventRaids.bmp"
$enterid = $navigation_dir & "enterID.bmp"
$raid_join = $navigation_dir & "join.bmp"		;join raid with id
$raid_joinstuck = $navigation_dir & "join_stuck.bmp"

;####	COMBAT	####
Local $combat_dir = $images_dir & "\combat\"
Global $skills_dir = $combat_dir & "\skills\"
Global $classes_dir = $combat_dir & "\classes\"
Global $chars_dir = $combat_dir & "\chars\"

$itemspickedup = $combat_dir & "itemspickedup.bmp"

$attack = $combat_dir & "atk.bmp"
$auto = $combat_dir & "autoattack.bmp"
$waitturn = $combat_dir & "waitturn.bmp"
$finishedcombat = $combat_dir & "finishedcombat.bmp"
$finishedcombat2 = $combat_dir & "finishedcombat2.bmp"
$finishedcombat3 = $combat_dir & "finishedcombat3.bmp"
$finishedcombat4 = $combat_dir & "finishedcombat4.bmp"
$finishedcombat5 = $combat_dir & "finishedcombat5.bmp"
Local $maincharAmount = 1
Global $mainchars[$maincharAmount]
$mainchars[0] = $classes_dir & "mainchar_gao2.bmp"

;$mainchars[0] = $classes_dir & "mainchar_ely.bmp"
;$mainchars[1] = $classes_dir & "mainchar_ely2.bmp"
;$mainchars[3] = $classes_dir & "mainchar_sm.bmp"
;$mainchars[4] = $chars_dir & "sarasa.bmp"


$nextchar = $combat_dir & "nextchar.bmp"
Local $skillsAmount = 11
Global $skills[$skillsAmount]
   ;BUFFS 1st
   ;$skills[0] = $skills_dir & "skillSplitSpirit.bmp"
   ;$skills[1] = $skills_dir & "skillSturm3.bmp"
   ;$skills[2] = $skills_dir & "skillYuel4.bmp"
   ;$skills[3] = $skills_dir & "skillYuel2.bmp"
   ;$skills[4] = $skills_dir & "skillYuel1.bmp"
   $skills[0] = $skills_dir & "skillOrchid1.bmp"
   ;$skills[1] = $skills_dir & "skillVira1.bmp"
   $skills[1] = $skills_dir & "skillVira2.bmp"

   ;$skills[0] = $skills_dir & "skillConclu.bmp"
   ;$skills[1] = $skills_dir & "skillAbyss.bmp"
   $skills[2] = $skills_dir & "skillGaoRage.bmp"
   ;$skills[3] = $skills_dir & "skillSizmir1.bmp"
   ;$skills[4] = $skills_dir & "skillSizmir2.bmp"
   ;$skills[5] = $skills_dir & "";"skillAltair1.bmp"
   ;$skills[6] = $skills_dir & "skillAltair3.bmp"
   ;$skills[7] = $skills_dir & "skillKat1.bmp"
   ;$skills[8] = $skills_dir & "";"skillKat2.bmp"
   $skills[3] = $skills_dir & "skillGaoIgn.bmp"

   ;DEBUFFS 2nd
   ;$skills[7] = $skills_dir & "skillUnpredict.bmp"
   $skills[4] = $skills_dir & "skillMist.bmp"
   ;$skills[9] = $skills_dir & "skillDefBr.bmp"
   ;$skills[10] = $skills_dir & "skillAltair2.bmp"
   $skills[5] = $skills_dir & "skillGaoDefBr.bmp"
   ;$skills[13] = $skills_dir & "";"skillArrowRain.bmp"
   ;$skills[14] = $skills_dir & "skillSmAwaken.bmp"
   ;$skills[15] = $skills_dir & "skillSarasa3.bmp"

   ;MISC 3rd
   $skills[6] = $skills_dir & "skillZoi2.bmp"

   ;NUKES 4th
   $skills[7] = $skills_dir & "skillZoi1.bmp"
   $skills[8] = $skills_dir & "skillZoi3.bmp"
   $skills[9] = $skills_dir & "skillOrchid3.bmp"
   $skills[10] = $skills_dir & "skillVira3.bmp"
   ;$skills[13] = $skills_dir & "skillSturm1.bmp"

$requestbackup = $combat_dir & "requestBackup.bmp"
$requestbackup_grey = $combat_dir & "requestBackup_grey.bmp"
$requestbackup_in = $combat_dir & "requestBackup_in.bmp"
$requestbackup_tweet = $combat_dir & "requestBackup_tweet.bmp"
$requestbackup_in_confirm = $combat_dir & "requestBackup_in_confirm.bmp"
$requestbackup_tweet_confirm = $combat_dir & "requestBackup_tweet_confirm.bmp"

$salutecombat = $combat_dir & "salutecombat.bmp"
$acceptsalute = $combat_dir & "saluteaccept.bmp"
$salutedcombat = $combat_dir & "salutedcombat.bmp"
$useelixirscombat = $combat_dir & "useelixirscombat.bmp"
$canceluseelixirs = $combat_dir & "canceluseelixirs.bmp"
$leavecombat = $combat_dir & "leavecombat.bmp"

$menuleavecombat = $combat_dir & "menuleavecombat.bmp"
$retreat = $combat_dir & "retreat.bmp"

;####	REWARDS	####
Local $rewards_dir = $images_dir & "\rewards\"
$returnto_pending = $rewards_dir & "returntoP.bmp"
$returnto_quests = $rewards_dir & "returntoQ.bmp"
$returnto_quests2 = $rewards_dir & "returntoQ2.bmp"
$returnto_quests3 = $rewards_dir & "returntoQ3.bmp"
$backtoroom = $rewards_dir & "backtoroom.bmp"
$friendreq = $rewards_dir & "friendreq.bmp"
$cancelfriend = $rewards_dir & "cancelfriend.bmp"
$expgained = $rewards_dir & "expG.bmp"
$expgained2 = $rewards_dir & "expG2.bmp"
$closequest = $rewards_dir & "questclose.bmp"
$newloot = $rewards_dir & "newloot.bmp"
$skilllearned = $rewards_dir & "skilllearned.bmp"

;####	QUESTS	####
Local $quests_dir = $images_dir & "\quests\"
$ahsel = $quests_dir & "angelHaloSelect.bmp"
$ahsel2 = $quests_dir & "angelHaloSelect2.bmp"	;when there are more quests before(ex. all trials)
$ahplay = $quests_dir & "angelHaloPlay.bmp"
$ahplay2 = $quests_dir & "angelHaloPlay2.bmp"
$ahplay3 = $quests_dir & "angelHaloPlay3.bmp"
$ahplay4 = $quests_dir & "angelHaloPlay4.bmp"


$ahnm = $quests_dir & "angelHaloNM.bmp"
$ahnm2 = $quests_dir & "angelHaloNM2.bmp"	;when there are more quests before(ex. all trials)

$favquest1 = $quests_dir & "favquest1.bmp"
$favquest1_1 = $quests_dir & "favquest1_1.bmp"
$multiplequest = $quests_dir & "multiplequest.bmp"

$dailyshowdown = $quests_dir & "dailyShowdown_other.bmp"
$dailyshowdown2 = $quests_dir & "dailyShowdown_otherfest.bmp"
$dailyshowdown3 = $quests_dir & "dailyShowdown3_top.bmp"
$dailyshowdown4 = $quests_dir & "dailyShowdown4_top.bmp"
$dailyshowdown5 = $quests_dir & "dailyShowdown5_top.bmp"
$dailyshowdown6 = $quests_dir & "dailyShowdown6_top.bmp"
$limitedquestprompt = $quests_dir & "limitedQuestPrompt.bmp"

$GWbanner = $quests_dir & "GWbanner.bmp"
$GWmenu = $quests_dir & "GWmenu.bmp"
$GWquestMenu = $quests_dir & "GWquestMenu.bmp";"GWquestMenu_nm90.bmp";"GWquestMenu.bmp"
$GWquest = $quests_dir & "GWquest.bmp";"GWquest_nm90.bmp";"GWquest.bmp"
$GWquestCurr = $quests_dir & "GWquestCurr.bmp"

;####	DIALOGS	####
Local $dialog_dir = $images_dir & "\dialog\"
$select_summon = $dialog_dir & "selectSumm.bmp"
$select_summon2 = $dialog_dir & "selectSumm2.bmp"
$special_summons = $dialog_dir & "specialSumm.bmp";"specialSumm_dark.bmp";"specialSumm.bmp"		;Quick fix
$special_summons2 = $dialog_dir & "specialSumm2.bmp";"specialSumm_dark.bmp";"specialSumm2.bmp"
$exp_summons1 = $dialog_dir & "expSumm1.bmp";"selectSumm_baha1.bmp";"expSumm1.bmp"
$exp_summons2 = $dialog_dir & "expSumm2.bmp";"selectSumm_baha2.bmp";"expSumm2.bmp"
$exp_summons3 = $dialog_dir & "expSumm3.bmp";"selectSumm_baha3.bmp";"expSumm3.bmp"
$exp_summons4 = $dialog_dir & "expSumm4.bmp";"selectSumm_baha4.bmp";"expSumm4.bmp"

Local $oksAmount = 10
Global $oks[$oksAmount]
   $oks[0] = $dialog_dir & "ok_summon.bmp"
   $oks[1] = $dialog_dir & "ok_battleend.bmp"
   $oks[2] = $dialog_dir & "ok_pending.bmp"
   $oks[3] = $dialog_dir & "ok_itemPickup.bmp"
   $oks[4] = $dialog_dir & "ok_berries.bmp"
   $oks[5] = $dialog_dir & "ok_elixirs.bmp"
   $oks[6] = $dialog_dir & "ok_multipleQuest.bmp"
   $oks[7] = $dialog_dir & "ok6.bmp"
   $oks[8] = $dialog_dir & "ok4.bmp"
   $oks[9] = $dialog_dir & "ok7.bmp"

$sharechestraid = $dialog_dir & "sharechestraid.bmp"

;####	EXTRAS	####
Local $extra_dir = $images_dir & "\extra\"
$halfelixir = $extra_dir & "halfElixirUse.bmp"
$halfelixir2 = $extra_dir & "halfElixirUse2.bmp"
$halfelixir3 = $extra_dir & "halfElixirUse3.bmp"
$halfelixir4 = $extra_dir & "halfElixirUse4.bmp"
$berries = $extra_dir & "berries.bmp"
$useberries = $extra_dir & "useBerry.bmp"
$useberries2 = $extra_dir & "useBerry2.bmp"
$usebberries = $extra_dir & "useBBerry.bmp"
$usebberries2 = $extra_dir & "useBBerry2.bmp"
$used = $extra_dir & "used.bmp"
$minap = $extra_dir & "minap.bmp"
$minap2 = $extra_dir & "minap2.bmp"
$minap3 = $extra_dir & "minap_wheat.bmp"
Local $epsamount = 10
Global $epsRaid[$epsamount]
   $epsRaid[0] = $extra_dir & "1ep_raid.bmp"
   $epsRaid[1] = $extra_dir & "2ep_raid.bmp"
   $epsRaid[2] = $extra_dir & "3ep_raid.bmp"
   $epsRaid[3] = $extra_dir & "4ep_raid.bmp"
   $epsRaid[4] = $extra_dir & "5ep_raid.bmp"
   $epsRaid[5] = $extra_dir & "6ep_raid.bmp"	;overcapping ep
   $epsRaid[6] = $extra_dir & "7ep_raid.bmp"
   $epsRaid[7] = $extra_dir & "8ep_raid.bmp"
   $epsRaid[8] = $extra_dir & "9ep_raid.bmp"
   $epsRaid[9] = $extra_dir & "10ep_raid.bmp"

;####	RAIDS	####
Local $raids_dir = $images_dir & "\raids\"
Local $specific_raids_dir = $raids_dir & "\specific\"

$1epRaid = $raids_dir & "1epLeft.bmp"		;1 of 2
$2epRaid = $raids_dir & "2epLeft.bmp"		;2 of 2
$3epRaid = $raids_dir & "3epLeft.bmp"		;3 of 3
$3epRaid2 = $raids_dir & "3epLeft2.bmp"		;3 of 3

$1epBraid = $raids_dir & "1epLeftB.bmp"		;1 of 5
$1epBraid2 = $raids_dir & "1epLeftB2.bmp"	;1 of 5
$3epBraid = $raids_dir & "3epLeftB.bmp"		;3 of 5
$5epBraid = $raids_dir & "5epLeftB.bmp"		;5 of 5

$1epBraidHalf = $raids_dir & "1epLeftBHalf.bmp" 	;1 of 3 (half ap)
$1epBraidHalf2 = $raids_dir & "1epLeftBHalf2.bmp" 	;1 of 3 (half ap)
$2epBraidHalf = $raids_dir & "2epLeftBHalf.bmp" 	;2 of 3 (half ap)
$2epBraidHalf2 = $raids_dir & "2epLeftBHalf2.bmp" 	;2 of 3 (half ap)
$3epBraidHalf = $raids_dir & "3epLeftBHalf.bmp" 	;2 of 3 (half ap)

#cs
Local $beastamount = 4
Global $beasts[$beastamount]
   $beasts[0] = $specific_raids_dir & "zuqCardinal.bmp"		;zhuque
   $beasts[1] = $specific_raids_dir & "xuanCardinal.bmp"	;xuawu
   $beasts[2] = $specific_raids_dir & "baiCardinal.bmp"		;baihu
   $beasts[3] = $specific_raids_dir & "quingCardinal.bmp"	;qinglong

Local $bbeastamount = 13
Global $bbeasts[$bbeastamount]
   $bbeasts[0] = $specific_raids_dir & "agniCardinal.bmp"	;agni
   $bbeasts[1] = $specific_raids_dir & "agniCardinal2.bmp"	;agniTODO
   $bbeasts[2] = $specific_raids_dir & "neptCardinal.bmp"	;neptune
   $bbeasts[3] = $specific_raids_dir & "neptCardinal2.bmp"	;neptune
   $bbeasts[4] = $specific_raids_dir & "titanCardinal.bmp"	;titan
   $bbeasts[5] = $specific_raids_dir & "titanCardinal2.bmp"	;titan
   $bbeasts[6] = $specific_raids_dir & "zephCardinal.bmp"	;zephirus
   $bbeasts[7] = $specific_raids_dir & "zephCardinal2.bmp"	;zephirus
   $bbeasts[8] = $specific_raids_dir & "zephCardinal3.bmp"	;zephirus
   $bbeasts[9] = $specific_raids_dir & "zephCardinal4.bmp"	;zephirus
   $bbeasts[10] = $specific_raids_dir & "titanCardinal3.bmp";titan
   $bbeasts[11] = $specific_raids_dir & "zephCardinal5.bmp"	;zephirus
   $bbeasts[12] = $specific_raids_dir & "neptCardinal3.bmp"	;neptune
#ce