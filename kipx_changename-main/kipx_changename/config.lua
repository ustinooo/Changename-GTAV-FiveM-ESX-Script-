Config = {}

Config.Framework = 'esx' 		-- or 'qbcore'
Config.Notification = 'oxlib'  	-- or 'esx' or 'qbcore'
Config.ChangeNamePrice = 100000
Config.Society = 'society_gov'
Config.MayorOffice = {
    [1] = {
        pos = vector3(-568.1113, -195.3247, 37.9186), 
        heading = 206.5581,
        people = 0x31430342,
        label = "Mayor's Secretary",
        icon = "fa-solid fa-print",
        anim = "WORLD_HUMAN_SEAT_LEDGE"						---- or "WORLD_HUMAN_CLIPBOARD"
    },
}
Config.NPCEnable = true
Config.Webhook = 'https://discord.com/api/webhooks/1244343476955648050/ri3Esqh-UgqHliTuzYgjhBpPzgr6qchFPmYygr2VesN62NMsq1HNLhu8yYCUAjjsslG9'