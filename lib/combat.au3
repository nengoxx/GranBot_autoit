#include-once

Local $attacked = False
Local $attackTimes = 0
Local $usedSkills = False
Local $skillTimes = 0
Local $totalSkillTimes = 0
Local $skippedChars = 0
Local $autoed = False

Local $askForBackup = 0		;ask for backup in nm90 after x turns
Local $backupRequested = 0
Local $minSkills = 12 ;minimum skills to use in total before attacking(ideally for OTK and stuff like that)
Local $minSkillsMC = 4 ;minimu skill to use from the MC
Local $charSkills[4]	;x coors where the skills are
Local $alreadyFoundSkills[4]	; $i counter of the skill in the array to skip it if its already found
Local $genericY = 0

Local $combatTime = 60000;180000
Local $haloCombatTime = 180000

;~ Waits 2 seconds to make sure the ok button appears if we couldn't join. If not then waits till the attack button appears and clicks it.
Func prepareCombat($bot_instance)
   $attacked = False	;prepare for the combat!
   Sleep(5000)
   If clickOk($bot_instance) Then
	  _ConsoleWrite('Combat Failed!' & @CRLF)
	  Return 0
   EndIf
   While _onTime_bi($combatTime,$bot_instance)
	  If simpleCombat($bot_instance) Then
		 _resetTime_bi($bot_instance)
		 Return 1
	  EndIf
   WEnd
   Return 0
EndFunc

Func prepareHaloCombat($bot_instance)
   resetAttack()	;prepare for the combat!
   Sleep(5000)
   If not checkForImage($itemspickedup,$bot_instance) Then
	  If clickOk($bot_instance) Then
		 _ConsoleWrite('Combat Failed!' & @CRLF)
		 Return 0
	  EndIf
   Else
	  _ConsoleWrite('Picked Some Items Up' & @CRLF)
	  If not clickOk($bot_instance) Then
		 _ConsoleWrite('Not clicked ok after items pickup!' & @CRLF)
		 checkForImageT($itemspickedup,$wtl,$bot_instance)
		 clickOk($bot_instance)
	  EndIf
   EndIf
   _ConsoleWrite('Prepare for Combat...' & @CRLF)
   While _onTime_bi($haloCombatTime,$bot_instance)
	  If haloCombat($bot_instance) Then
		 _resetTime_bi($bot_instance)
		 Return 1
	  EndIf
   WEnd
   Return 0
EndFunc

Func prepareBetterCombat($bot_instance, $reset = True)
   If $reset Then
	  resetAttack()	;prepare for the combat!
   EndIf
   If checkForImageT($attack,7500,$bot_instance) Then
	  ;just wait until attack starts or 7 sec have passed
   EndIf
   ;Sleep(5000)
   If clickOk($bot_instance) or checkForImage($sharechestraid,$bot_instance) Then
	  _ConsoleWrite('Combat Failed!' & @CRLF)
	  Return 0
   EndIf
   _ConsoleWrite('Prepare for Combat...' & @CRLF)
   While _onTime_bi($combatTime,$bot_instance)
	  If not $leech and $bot_instance = 1 Then	;TODO temp fix to not use skills when leeching
		 If betterCombatSkillsFirst($bot_instance) Then
			_resetTime_bi($bot_instance)
			Return 1
		 EndIf
	  Else
		 If betterCombat($bot_instance) Then
			_resetTime_bi($bot_instance)
			Return 1
		 EndIf
	  EndIf
   WEnd
   Return 0
EndFunc

;~ Handles a very simple combat, just clicks the attack button once and waits
Func simpleCombat($bot_instance)
   If Not $attacked Or $usedSkills Then
	  attack($bot_instance)
   EndIf
   If $attacked Then
	  clickMainChar($bot_instance)
	  findSkills($bot_instance)
	  If $usedSkills Then
		 If $totalSkillTimes > 2 Or $skippedChars < 8 Then
			nextChar($bot_instance)
		 EndIf
	  Else
		 attack($bot_instance)
	  EndIf
	  $skillTimes = 0
   EndIf
   If checkForImage($finishedcombat,$bot_instance) or checkForImage($finishedcombat2,$bot_instance) _
	  or checkForImage($finishedcombat3,$bot_instance) or checkForImage($finishedcombat4,$bot_instance) or checkForImage($finishedcombat5,$bot_instance) Then	;check if combat has finished(actually it checks the gold chest and if the attack button has faded)
	  _ConsoleWrite('Combat Finished' & @CRLF)
	  _ConsoleWrite('Combat Finished' & @CRLF)		;TODO CHECK WHEN IT ENDS BEFORE YOU GET TO ATTACK
	  resetAttack()
	  Return 1
   EndIf
   waitTurntobeProcessed($bot_instance)
   Return 0
EndFunc

Func haloCombat($bot_instance)
   ;TODO improve performance
;~    If Not $attacked Then
;~ 	  attack()
;~    EndIf
   If attack($bot_instance) and not $autoed Then
	  autoattack($bot_instance)
   EndIf
   If waitTurntobeProcessed($bot_instance) Then
	  resetAttack()
   EndIf
   If checkForImage($resumequest,$bot_instance) Then
	  If checkForImage($acceptresumequest,$bot_instance) Then
		 _ConsoleWrite('Resuming Quest...' & @CRLF)
		 $xReal = $x
		 $yReal = $y
		 $Xaux = 141
		 $Yaux = 24
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
	  EndIf
   EndIf
   If checkForImage($expgained,$bot_instance) or checkForImage($expgained2,$bot_instance) Then
	  _ConsoleWrite('Combat Finished' & @CRLF)		;TODO CHECK WHEN IT ENDS BEFORE YOU GET TO ATTACK
	  resetAttack()
	  Return 1
   EndIf
   If checkForImage($finishedcombat,$bot_instance) or checkForImage($finishedcombat2,$bot_instance) or checkForImage($finishedcombat3,$bot_instance) or checkForImage($finishedcombat4,$bot_instance) or checkForImage($finishedcombat5,$bot_instance) Then
	  Sleep(5000) ;let it time to check if its just a transition or it's actually finished
	  If checkForImage($finishedcombat,$bot_instance) or checkForImage($finishedcombat2,$bot_instance) or checkForImage($finishedcombat3,$bot_instance) or checkForImage($finishedcombat4,$bot_instance) or checkForImage($finishedcombat5,$bot_instance) and $autoed Then	;check if combat has finished(actually it checks the gold chest and if the attack button has faded)
		 _ConsoleWrite('Combat Finished' & @CRLF)		;TODO CHECK WHEN IT ENDS BEFORE YOU GET TO ATTACK
		 resetAttack()
		 ;;fix for when autoattack fails(not return at this point)
		 reloadGame($bot_instance)
		 ;Return 1
		 ;;fi for when autoattack fails(not return at this point)
	  EndIf
   EndIf
   Return 0
EndFunc

Func betterCombat($bot_instance)
   If Not $attacked Or $usedSkills Then
	  attack($bot_instance)
   EndIf
   If $attacked Then
	  clickMainChar($bot_instance)
	  findSkills($bot_instance)
	  If $usedSkills Then
		 If $skillTimes < 1 Or $skippedChars < 8 Then
			nextChar($bot_instance)
		 EndIf
	  EndIf
	  $skillTimes = 0
   EndIf
   If checkForImage($finishedcombat,$bot_instance) or checkForImage($finishedcombat2,$bot_instance) or checkForImage($finishedcombat3,$bot_instance) or checkForImage($finishedcombat4,$bot_instance) or checkForImage($finishedcombat5,$bot_instance) Then	;check if combat has finished(actually it checks the gold chest and if the attack button has faded)
	  _ConsoleWrite('Combat Finished' & @CRLF)		;TODO CHECK WHEN IT ENDS BEFORE YOU GET TO ATTACK
	  resetAttack()
	  Return 1
   EndIf
   waitTurntobeProcessed($bot_instance)
   Return 0
EndFunc

Func betterCombatSkillsFirst($bot_instance)
   If $attackTimes = 0 or Mod($attackTimes,5) = 0 Then	;first of all and every 4 turns
	  clickMainChar($bot_instance)
	  findSkills($bot_instance)
   EndIf

   If $usedSkills Then
	  If $totalSkillTimes >= $minSkillsMC and $totalSkillTimes < $minSkills Then;And $skippedChars < 9 Then 	;ALWAYS use next char instead of having max 9 just in case
		 nextChar($bot_instance)
	  EndIf
   EndIf

   If $attackTimes >= 1 and $askForBackup Then	;ask for backup if attacked 2 or more times
	  askForBackup($bot_instance)
   EndIf

   If $usedSkills and $totalSkillTimes >= $minSkills and (not $askForBackup or $backupRequested = 2 or $attackTimes <= 1) Then
	  If $attackTimes > 0 Then	;EXPERIMENTAL, ougi skip and atk skip when all skills are used in turn 1
		 attackReload($bot_instance)
	  Else
		 attack($bot_instance)
	  EndIf
   EndIf
   If checkForImage($finishedcombat,$bot_instance) or checkForImage($finishedcombat2,$bot_instance) or checkForImage($finishedcombat3,$bot_instance) or checkForImage($finishedcombat4,$bot_instance) or checkForImage($finishedcombat5,$bot_instance) Then	;check if combat has finished(actually it checks the gold chest and if the attack button has faded)
	  _ConsoleWrite('Combat Finished' & @CRLF)		;TODO CHECK WHEN IT ENDS BEFORE YOU GET TO ATTACK
	  resetAttack()
	  reloadGame($bot_instance)
	  Return 1
   EndIf
   If checkForImage($expgained,$bot_instance) or checkForImage($expgained2,$bot_instance) Then
	  _ConsoleWrite('Combat Finished' & @CRLF)		;EXPERIMENTAL for ougi skip & atk skip
	  resetAttack()
	  restartGame($bot_instance)
	  Return 1
   EndIf
   waitTurntobeProcessed($bot_instance)
   Return 0
EndFunc

Func slimeCombat($bot_instance)
   $minSkillsMC_slime=1
   $minSkills_slime=2

   If $attackTimes = 0 or Mod($attackTimes,4) = 0 Then	;first of all and every 4 turns
	  clickMainChar($bot_instance)
	  findSkills($bot_instance)
   EndIf
   If $usedSkills Then
	  If $totalSkillTimes >= $minSkillsMC_slime and $totalSkillTimes < $minSkills Then;And $skippedChars < 9 Then 	;ALWAYS use next char instead of having max 9 just in case
		 nextChar($bot_instance)
	  EndIf
   EndIf
   ;resetAttack()
   #cs
   If $usedSkills and $totalSkillTimes >= $minSkills_slime Then
	  If $attackTimes > 0 Then	;EXPERIMENTAL, ougi skip and atk skip when all skills are used in turn 1
		 attackReload($bot_instance)
	  Else
		 attack($bot_instance)
	  EndIf
   EndIf
   #ce
   If checkForImage($finishedcombat,$bot_instance) or checkForImage($finishedcombat2,$bot_instance) or checkForImage($finishedcombat3,$bot_instance) or checkForImage($finishedcombat4,$bot_instance) or checkForImage($finishedcombat5,$bot_instance) Then	;check if combat has finished(actually it checks the gold chest and if the attack button has faded)
	  _ConsoleWrite('Combat Finished' & @CRLF)		;TODO CHECK WHEN IT ENDS BEFORE YOU GET TO ATTACK
	  resetAttack()
	  reloadGame($bot_instance)
	  Return 1
   EndIf
   If checkForImage($expgained,$bot_instance) or checkForImage($expgained2,$bot_instance) Then
	  _ConsoleWrite('Combat Finished' & @CRLF)		;EXPERIMENTAL for ougi skip & atk skip
	  resetAttack()
	  restartGame($bot_instance)
	  Return 1
   EndIf
   waitTurntobeProcessed($bot_instance)
   Return 0

EndFunc

;### FUNCTIONS ###

Func clickMainChar($bot_instance)
   For $i = 0 to Ubound($mainchars) - 1
	  If checkForImage($mainchars[$i],$bot_instance) Then
		 $Xaux = 57
		 $Yaux = 35
		 randomClick($x,$y,$Xaux,$Yaux)
		 _resetTime_bi($bot_instance)
		 _ConsoleWrite('Located Main Character...' & @CRLF)
		 Sleep(1000)
		 Return 1
	  EndIf
   Next
   Return 0
EndFunc

Func findSkills($bot_instance)
   _ConsoleWrite('Looking for Skills...' & @CRLF)
   $charSkills[0] = 0
   $charSkills[1] = 0
   $charSkills[2] = 0
   $charSkills[3] = 0
   $alreadyFoundSkills[0] = -1
   $alreadyFoundSkills[1] = -1
   $alreadyFoundSkills[2] = -1
   $alreadyFoundSkills[3] = -1
   For $i = 0 to Ubound($skills) - 1
	  If $i <> $alreadyFoundSkills[0] and $i <> $alreadyFoundSkills[1] and $i <> $alreadyFoundSkills[2] and $i <> $alreadyFoundSkills[3] and checkForImage($skills[$i],$bot_instance) Then
		 ;_ConsoleWrite('Found ' & $i & ' Skill!' & @CRLF)
		 If $genericY = 0 Then
			$genericY = $y
		 EndIf
		 For $j = 0 to Ubound($charSkills) -1	;add the skills to both arrays
			If $charSkills[$j] = 0 and $alreadyFoundSkills[$j] = -1 Then
			   $charSkills[$j] = $x
			   $alreadyFoundSkills[$j] = $i
			   $skillTimes +=  1
			   $totalSkillTimes +=  1
			   ExitLoop
			EndIf
		 Next
		 _resetTime_bi($bot_instance)
		 _ConsoleWrite('Found ' & $skillTimes & ' From a Total of ' & $totalSkillTimes & ' Skills...' & @CRLF)
	  EndIf
   Next
   clickSkills($bot_instance)

   If $skillTimes = 0 Then
	  $usedSkills = True
	  ;_ConsoleWrite('Used All Skills From the Char...' & @CRLF)
   EndIf

   $skillTimes = 0
EndFunc

Func clickSkills($bot_instance)
   ;_ConsoleWrite('Clicking Skills...' & @CRLF)
   For $j = 0 to Ubound($charSkills) -1	;add the skills to both arrays
	  If $charSkills[$j] <> 0 and $alreadyFoundSkills[$j] <> -1 Then
		 $Xaux = 35
		 $Yaux = 35
		 randomClick($charSkills[$j],$genericY,$Xaux,$Yaux,1)
		 randomClick($charSkills[$j],$genericY,$Xaux,$Yaux,1)	;not doubleclick in case it seems much like a bot
		 _resetTime_bi($bot_instance)
		 ;Sleep($wt)
	  EndIf
   Next
EndFunc

Func attack($bot_instance)
   If checkForImage($attack,$bot_instance) Then
	  $Xaux = 125
	  $Yaux = 40
	  randomClick($x,$y,$Xaux,$Yaux)
	  $attacked = True
	  $attackTimes = $attackTimes + 1
	  _resetTime_bi($bot_instance)
	  _ConsoleWrite('Attacked ' & $attackTimes & ' Times...' & @CRLF)
	  Sleep(1000)
	  Return 1
   EndIf
   Return 0
EndFunc

Func attackReload($bot_instance)
   If checkForImage($attack,$bot_instance) Then
	  $Xaux = 125
	  $Yaux = 40
	  randomClick($x,$y,$Xaux,$Yaux)
	  $attacked = True
	  $attackTimes = $attackTimes + 1
	  _resetTime_bi($bot_instance)
	  _ConsoleWrite('Attacked ' & $attackTimes & ' Times...' & @CRLF)
	  Sleep(1000)
	  reloadGame($bot_instance)
	  Return 1
   EndIf
   Return 0
EndFunc

Func autoattack($bot_instance)
   _ConsoleWrite('Triggering Auto Mode...' & @CRLF)
   ;Sleep(1000)
   If checkForImage($auto,$bot_instance) Then
	  _ConsoleWrite('Found Auto Mode!' & @CRLF)
	  $xReal = $x
	  $yReal = $y + 361
	  $Xaux = 64
	  $Yaux = 13
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  $autoed = True
	  _resetTime_bi($bot_instance)
	  _ConsoleWrite('Auto Mode Triggered...' & @CRLF)
   EndIf
EndFunc

Func nextChar($bot_instance)
   If checkForImage($nextchar,$bot_instance) Then
	  $Xaux = 10
	  $Yaux = 23
	  randomClick($x,$y,$Xaux,$Yaux,2)
	  $skippedChars = $skippedChars + 1
	  _resetTime_bi($bot_instance)
	  _ConsoleWrite('Next Character...' & @CRLF)
   EndIf
EndFunc

Func waitTurntobeProcessed($bot_instance)
   If checkForImage($waitturn,$bot_instance) Then
	  _ConsoleWrite('Wait for the Turn to be Processed...' & @CRLF)
	  If clickOk($bot_instance) Then
		 ;do nothing
	  EndIf
	  _resetTime_bi($bot_instance)
	  Return 1
   EndIf
   Return 0
EndFunc

Func askForBackup($bot_instance)

   If $backupRequested = 2 Then
	  Return
   EndIf
   _ConsoleWrite('Asking for Backup...' & @CRLF)
   Sleep(1000)
   checkForImageT($attack,20000,$bot_instance) ;wait till the attack button appears so we are sure the it finished everything
   randomMove($x,$y,125,40)
   MouseWheel($MOUSE_WHEEL_DOWN, 2)
   ;For $i = 0 to 3
   ;	 ControlSend($granblue_windows[$bot_instance][0], "", "", "{DOWN}")
   ;Next
   Sleep(1000)
   If checkForImage($requestbackup,$bot_instance) and $backupRequested = 0 Then
	  _ConsoleWrite('Backup Button Located!' & @CRLF)
	  $Xaux = 140
	  $Yaux = 13
	  randomClick($x,$y,$Xaux,$Yaux)
	  Sleep(2000)
	  If checkForImage($requestbackup_in,$bot_instance) Then
		 $Xaux = 129
		 $Yaux = 21
		 randomClick($x,$y,$Xaux,$Yaux)
		 Sleep(2000)
		 If checkForImage($requestbackup_in_confirm,$bot_instance) Then
			clickOk($bot_instance)
			$backupRequested = 1
			Sleep(1000)
		 EndIf
	  EndIf
   EndIf

   If (checkForImage($requestbackup,$bot_instance) or checkForImage($requestbackup_grey,$bot_instance)) and $backupRequested = 1 Then
	  $Xaux = 140
	  $Yaux = 13
	  randomClick($x,$y,$Xaux,$Yaux)
	  Sleep(2000)
	  If checkForImage($requestbackup_tweet,$bot_instance) Then
		 $Xaux = 86
		 $Yaux = 19
		 randomClick($x,$y,$Xaux,$Yaux)
		 Sleep(2000)
		 If checkForImage($requestbackup_tweet_confirm,$bot_instance) Then
			clickOk($bot_instance)
			Sleep(2000)
			clickOk($bot_instance)
			$backupRequested = 2
		 EndIf
	  EndIf
   EndIf

   For $i = 0 to 10
		 ControlSend($granblue_windows[$bot_instance][0], "", "", "{UP}")
		 MouseWheel($MOUSE_WHEEL_UP, 10)
   Next
EndFunc

Func leaveCombatRoom($bot_instance)
   If checkForImage($salutecombat,$bot_instance) Then
	  If checkForImage($acceptsalute,$bot_instance) Then
	  $Xaux = 140
	  $Yaux = 25
	  randomClick($x,$y,$Xaux,$Yaux)
	  EndIf
   Else
	  leaveCombatRoomMenu($bot_instance)
	  Return
   EndIf

   Sleep(2000)
   If checkForImage($salutedcombat,$bot_instance) Then
	  clickOk($bot_instance)
   EndIf

   Sleep(2000)
   If checkForImage($useelixirscombat,$bot_instance) Then
	  If checkForImage($canceluseelixirs,$bot_instance) Then
	  $Xaux = 140
	  $Yaux = 25
	  randomClick($x,$y,$Xaux,$Yaux)
	  EndIf
   EndIf

   Sleep(2000)
   If checkForImage($leavecombat,$bot_instance) Then
	  $Xaux = 140
	  $Yaux = 25
	  randomClick($x,$y,$Xaux,$Yaux)
   EndIf

EndFunc

Func leaveCombatRoomMenu($bot_instance)
   If checkForImage($menuleavecombat,$bot_instance) Then
	  $Xaux = 52
	  $Yaux = 20
	  randomClick($x,$y,$Xaux,$Yaux)
   Else
	  Return
   EndIf

   Sleep(2000)
   If checkForImage($retreat,$bot_instance) Then
	  $Xaux = 78
	  $Yaux = 23
	  randomClick($x,$y,$Xaux,$Yaux)
   EndIf

   Sleep(2000)
   If checkForImage($leavecombat,$bot_instance) Then
	  $Xaux = 140
	  $Yaux = 25
	  randomClick($x,$y,$Xaux,$Yaux)
   EndIf

EndFunc

Func resetAttack()
   $attacked = False
   $attackTimes = 0
   $usedSkills = False
   $skillTimes = 0
   $totalSkillTimes = 0
   $skippedChars = 0
   $autoed = False

   $backupRequested = 0
EndFunc