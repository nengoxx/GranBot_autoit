
#cs
   Config file for combat
#ce
Local $classParams = 3

Local $classes[4] = [ $gao, $katalina, $altair, $sizmir]

Local $gao[$classParams]
   $gao[0] = $classes_dir & "mainchar_gao2.bmp"		;outside
   $gao[1] =										;inside
   $gao[2] = [ $gao_def_breach, $gao_ignition, $gao_rage, $sub_arrow_rain ]

Local $altair[$classParams]
   $altair[0] =
   $altair[1] =
   $altair[2] = [ $altair_1, $altair_2, $altair_3 ]

Local $katalina[$classParams]
   $katalina[0] =
   $katalina[1] =
   $katalina[2] = [ $kata_1, $kata_2, $kata_3 ]

Local $sizmir[$classParams]
   $sizmir[0] =
   $sizmir[1] =
   $sizmir[2] = [ $sizmir_1, $sizmir_2 ]



