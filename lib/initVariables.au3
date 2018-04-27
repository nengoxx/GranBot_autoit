;functions
Global $use_elixirs = getBoolean(IniRead("config.ini", "global", "use_elixirs", "0"))
Global $use_berries = getBoolean(IniRead("config.ini", "global", "use_berries", "0"))
Global $use_Bberries = getBoolean(IniRead("config.ini", "global", "use_Bberries", "0"))
;raid snipers
Global $neededEP = Int(IniRead("config.ini", "raid", "magna_ep", "3"))
;co-op
Global $join_pandemonium = Int(IniRead("config.ini", "coop", "join_pandemonium", "0"))
;combat
Global $leech = getBoolean(IniRead("config.ini", "combat", "leech", "1"))
Global $leechingSummons = Int(IniRead("config.ini", "combat", "leechingSummons", "1"))
;granb
Global $bot_4beast = Int(IniRead("config.ini", "bots", "bot_4beast", "0"))
Global $bot_raidSnipe = Int(IniRead("config.ini", "bots", "bot_raidSnipe", "1"))
Global $bot_tweetdeck = Int(IniRead("config.ini", "bots", "bot_tweetdeck", "0"))
Global $bot_coop = Int(IniRead("config.ini", "bots", "bot_coop", "0"))
Global $bot_angelHalo = Int(IniRead("config.ini", "bots", "bot_angelHalo", "0"))

ConsoleWrite('- Bots ' & @CRLF)
ConsoleWrite('Raid Snipe:'&$bot_raidSnipe&'  TweetDeck:'&$bot_tweetdeck&'  Co-op:'&$bot_coop&'  Angel Halo:'&$bot_angelHalo&@CRLF)

ConsoleWrite('- Global ' & @CRLF)
ConsoleWrite('Use Half Elixir: ' & $use_elixirs & @CRLF)
ConsoleWrite('Use Soul Berry: ' & $use_berries & @CRLF)
ConsoleWrite('Use Soul Balm: ' & $use_Bberries & @CRLF)

ConsoleWrite('- Raid ' & @CRLF)
ConsoleWrite('Minimum EP for Magnas: ' & $neededEP & @CRLF)

ConsoleWrite('- Combat ' & @CRLF)
ConsoleWrite('Leech: ' & $leech & @CRLF)
ConsoleWrite('Use Leeching Summons: ' & $leechingSummons & @CRLF)

ConsoleWrite('- Co-op ' & @CRLF)
ConsoleWrite('Join Pandemonium Rooms: ' & $join_pandemonium & @CRLF)