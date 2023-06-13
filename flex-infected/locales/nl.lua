local Translations = {
    error = {
        alreadyjoined = 'Ge doe al mee',
        alreadystarted = 'Tis al bezig..',
        leavevehicle = 'Snel, stap uit voor die ontploft!!',
        cantdrive = 'Nee, je mag niet rijden..',
        leavegame = 'Aii sad, doe je toch ni mee?',
    },
    success = {
        joined = 'Je doet nu mee!',
    },
    info = {
        notenough = 'Niet genoeg spelers',
        zombiespawned = 'Zombie is los gelaten!',
        startgame = 'LETS GO!',
        airdrop = 'Kijkt na boven!',
        turnedzombie = ' is nu zombie!',
        killedallplayers = 'Alle burgers zijn nu zombie! GG',
    },
    menu = {
        join = 'Doe mee',
        leave = 'Verlaat het spel',
        start = 'Start het spel',
        reset = 'Herstart het spel',
        close = 'Sluit het menu'
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})