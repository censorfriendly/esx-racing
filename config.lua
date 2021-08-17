-- 
-- Types Sprint/Circuit
-- Laps 1-99
-- Markers consist of x,y,z coords
RacingConfig = {
    kashacters = false,  --Set false to not include character validation
    crypto = false,  --Set false to disable crypto gains
    cryptoMin = 3, --Minimum number of racers per race to earn crypto
    cryptoPayout = 12, -- 12 to first, 6 second, 3 to third. everyone else receives 2. Math = /2 /4  (/4 -1)
    cryptoName = 'MTC'
}

Races = {}
