script_author("impachi")
script_name("Law Assist")
script_version('1.0 Stable')

local imgui = require("imgui")
local window = imgui.ImBool(false)
local windowSus = imgui.ImBool(false)
local requests = require 'requests'
local windowTick = imgui.ImBool(false)
local memenu = imgui.ImBool(true)
local calcWindow = imgui.ImBool(false)
local fast = imgui.ImBool(false)
local carCombo = imgui.ImInt(0)
local carComboCode = imgui.ImInt(0)
local carMenu = imgui.ImBool(false)
local notifWindow = imgui.ImBool(true)
local imAddon = require 'imgui_addons'
local sampev = require ("lib.samp.events")
require "lib.moonloader"
local notifications = {}
local search = imgui.ImBuffer(256)
local sw, sh = getScreenResolution()
local inicfg = require "inicfg"
local config_name = "law_assist"
local config = {
    settings = {
		enableRpGuns = true,
		accent = false,
		accenttext = "",
		slider = 0.5,
		showAd = true,
		fastMenu = false,
		fastMenuP = false,
		memenu = true,
		enable = true,
		sounds = true,
		seprate = true,
		enableCalc = true,
		camHack = false,
		showFps = true,
		showPing = true,
		showTime = true,
		showId = true,
		showDate = true,
		showDialogID = false,
		theme = 1,
		enableHpHud = true,
		hpHudColored = false,
		patrolMenu = true,
		sendDate = true,
		tag = false,
		tagText = "",
    },
	fastMenuPuncts = {
		megaphone = true,
		twoMegaphone = true,
		krik = true,
		prava = true,
		udo = false,
		wanted = false
	}
}
local cfg = inicfg.load(config, config_name)
local rpgun = imgui.ImBool(config.settings.enableRpGuns)
local ad = imgui.ImBool(config.settings.showAd)
local slider = imgui.ImFloat(config.settings.slider)
local fastMenu = imgui.ImBool(config.settings.fastMenu)
local fastMenuP = imgui.ImBool(config.settings.fastMenuP)
local enableHpHud = imgui.ImBool(config.settings.enableHpHud)
local hpHudColored = imgui.ImBool(config.settings.hpHudColored)
local showDialogID = imgui.ImBool(config.settings.showDialogID)
local camHack = imgui.ImBool(config.settings.camHack)
local enableCalc = imgui.ImBool(config.settings.enableCalc)
local showFps = imgui.ImBool(config.settings.showFps)
local showTime = imgui.ImBool(config.settings.showTime)
local showPing = imgui.ImBool(config.settings.showPing)
local showId = imgui.ImBool(config.settings.showId)
local showDate = imgui.ImBool(config.settings.showDate)
local seprate = imgui.ImBool(config.settings.seprate)
local patrolMenu = imgui.ImBool(config.settings.patrolMenu)
local takeSu = false
local togglerTakeSu = imgui.ImBool(takeSu)
local autoDoklad = true
local togglerAutoDoklad = imgui.ImBool(autoDoklad)
local sounds = imgui.ImBool(config.settings.sounds)
local sendDate = imgui.ImBool(config.settings.sendDate)
local enable = imgui.ImBool(config.settings.enable)
local memenu = imgui.ImBool(config.settings.memenu)
local accent = imgui.ImBool(config.settings.accent)
local megaphone = imgui.ImBool(config.fastMenuPuncts.megaphone)
local twoMegaphone = imgui.ImBool(config.fastMenuPuncts.twoMegaphone)
local krik = imgui.ImBool(config.fastMenuPuncts.krik)
local prava = imgui.ImBool(config.fastMenuPuncts.prava)
local udo = imgui.ImBool(config.fastMenuPuncts.udo)
local wanted = imgui.ImBool(config.fastMenuPuncts.wanted)
local accenttext = imgui.ImBuffer(tostring(config.settings.accenttext), 256)
local tag = imgui.ImBool(config.settings.tag)
local tagText = imgui.ImBuffer(tostring(config.settings.tagText), 256)
local encoding = require "encoding"
local fa = require 'faIcons'
local VK = require "vkeys"
local memory = require("memory")
local lower, sub, char, upper = string.lower, string.sub, string.char, string.upper
local lastgun = -1
local lastSendTime = 0
local soundMenu = nil
local result = ""
local show = false
local logs = {}
local soundMenuEnd = nil
local soundButton = nil
function addLog(text)
	table.insert(logs, 1, os.date("[%H:%M] ") ..text)
	if #logs > 7 then
		table.remove(logs)
	end
end
local soundSave = nil
local soundInclude = nil
local organization = "Не получено"
local department = "Не получено"
local rank = "Не получено"
local sent = false
local carName = "Unknown"
local resX, resY = getScreenResolution()
local soundEnd = nil
local pricedown = nil
local concat = table.concat
local UI = {
	Spacing			= (16),
	Font			= (28),
}
local config_file = getWorkingDirectory().."/config/law_assist.ini"
if not doesFileExist(getWorkingDirectory().."\\config\\"..config_name..".ini") then
    inicfg.save(cfg, config_name)
	addLog("Создание нового файла настроек")
end
imgui.Process = true
encoding.default = "CP1251"  
u8 = encoding.UTF8
ToggleButton_Font = nil
fa_size = nil
fa_font = nil
fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })

local webhook = "https://discord.com/api/webhooks/1514204095924146227/Jcbd-IBc9crd2lQscPiO8fyC6YTVJ8qlad23XSOSA-cNqVU5JQPmdLm8EK35fDEJR2de"

local function urlencode(str)
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w %-%_%.%~])",
        function(c) return string.format("%%%02X", string.byte(c)) end)
    str = string.gsub(str, " ", "+")
    return str
end

local function sendLog()
    local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local nick = sampGetPlayerNickname(id)
	local clean_nick = nick:gsub("_", " ")
    local time = os.date("%H:%M:%S")
	local server = sampGetCurrentServerName()

    local text = u8("========================================\n" ..clean_nick.. " запустил Law Assist!\nСервер: " ..server.. "\nОрганизация: " ..organization.. "\nРанг: " ..rank.. "\nДата: " ..os.date("%d.%m.%y").. "\nВремя: " ..time.. "\n========================================")

    requests.post(webhook, {
        data = "content=" .. urlencode(text),
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded"
        }
    })
end

function notif(text)
	notifications = {}
	
    table.insert(notifications, {
        text = text,
        time = os.clock(),
        alpha = 0.0,
        offset = 25
    })

    if config.settings.sounds then
        setAudioStreamState(soundMenuEnd, 0)
        setAudioStreamState(soundMenuEnd, 1)
    end
end

local lu_rus, ul_rus = {}, {}
for i = 192, 223 do
    local A, a = char(i), char(i + 32)
    ul_rus[A] = a
    lu_rus[a] = A
end
local E, e = char(168), char(184)
ul_rus[E] = e
lu_rus[e] = E

commands = {'n', 's', 'a', 'f', 'fn', 'jn', 'j', 'r', 'rn'};
bi = false

local function isExpression(expr)
    if not expr then return false end

    expr = expr:gsub("%s+", "")

    if expr:match("^%-?%d+%.?%d*$") then
        return false
    end

    return expr:find("[%+%-%*/]") ~= nil
end

local function calc(expr)
    if not expr or expr == "" then return nil end

    expr = expr:gsub("[^0-9%+%-%*/%(%). ]", "")

    local fn = load("return " .. expr)
    if not fn then return nil end

    local ok, res = pcall(fn)
    if not ok then return nil end

    return res
end

function sampev.onSendCommand(msg)
	if bi then bi = false; return end
	local cmd, msg = msg:match("/(%S*) (.*)")
	if msg == nil then return end

	for i, v in ipairs(commands) do if cmd == v then
		local length = msg:len()
		if msg:sub(1, 2) == "((" then
			msg = string.gsub(msg:sub(4), "%)%)", "")
			if length > 80 then divide(msg, "/" .. cmd .. " (( ", " ))"); return false end
		else
			if length > 80 then divide(msg, "/" .. cmd .. " ", ""); return false end
		end
	end end

	if cmd == "me" or cmd == "do" then
		local length = msg:len()
		if length > 75 then divide(msg, "/" .. cmd .. " ", "", "ext"); return false end
	end
end

function sampev.onSendCommand(cmd)
    local text = cmd:match("^/r%s+(.+)$")
	local fText = cmd:match("^/f%s+(.+)$")

    if text and config.settings.tag then
        sampSendChat(string.format("/r [%s] %s", u8:decode(config.settings.tagText), text))
        return false
    end
	
	if fText and config.settings.tag then
        sampSendChat(string.format("/f [%s] %s", u8:decode(config.settings.tagText), fText))
        return false
    end
end

function sampev.onServerMessage(color, text)
	if color == -65281 and text:find(" %| Получатель: ") then
		return {bit.tobit(0xFFCC00FF), text}
	end
end

function sampev.onSendChat(msg)
	if bi then bi = false; return end
	local length = msg:len()
	if length > 90 then
		divide(msg, "", "")
		return false
	end
end

function divide(msg, beginning, ending, doing)
	limit = 72

	local one, two = string.match(msg:sub(1, limit), "(.*) (.*)")
	if two == nil then two = "" end 
	local one, two = one .. "...", "..." .. two .. msg:sub(limit + 1, msg:len())

	bi = true; if config.settings.seprate then sampSendChat(beginning .. one .. ending) end
	if doing == "ext" then
		beginning = "/do "
		if two:sub(-1) ~= "." then two = two .. "." end
	end
	bi = true; if config.settings.seprate then sampSendChat(beginning .. two .. ending) end
end

local function su(stars, reason)
    lua_thread.create(function()
	    windowSus.v = false
        imgui.ShowCursor = false
        sampSendChat("/me ввёл имя и фамилию нарушителя, изменил данные.")
        wait(slider.v * 1000)

        sampSendChat("/do Данные успешно изменены.")
        wait(slider.v * 1000)

        sampSendChat("/su " .. current_id .. " " .. stars .. " " .. reason)
    end)
end

local collapsing = {

	[1] = {
		name = "Глава 1. Причинение вреда здоровью",
		body = function()

			if imgui.Selectable(u8'1.1 УК - Вред средней степени тяжести (20-50% HP) - 3*') then
				su("3", "1.1 УК")
			end

			if imgui.Selectable(u8'1.2 УК - Тяжкий вред здоровью (Более 50% HP) - 4*') then
				su("4", "1.2 УК")
			end

		end
	},

	[2] = {
		name = "Глава 2. Вооружённое нападение",
		body = function()

			if imgui.Selectable(u8'2.1 УК - Вооружённое нападение с использованием огнестрельного оружия - 6*') then
				su("6", "2.1 УК")
			end

			if imgui.Selectable(u8'2.2 УК - Нападение с использованием холодного оружия - 5*') then
				su("5", "2.2 УК")
			end

		end
	},

	[3] = {
		name = "Глава 3. Транспортные преступления",
		body = function()

			if imgui.Selectable(u8'3.1 УК - Попытка угона транспортного либо служебного средства - 1*') then su("1", "3.1 УК") end
			if imgui.Selectable(u8'3.2 УК - Угон транспортного либо служебного средства - 2*') then su("2", "3.2 УК") end
			if imgui.Selectable(u8'3.3 УК - Причинение физического вреда гражданскому лицу транспортным средством - 4*') then su("4", "3.3 УК") end
			if imgui.Selectable(u8'3.4 УК - Скрытие с места ДТП, причинившее ущерб физическому лицу - 2*') then su("2", "3.4 УК") end

		end
	},

	[4] = {
		name = "Глава 4. Намеренное введение в заблуждение",
		body = function()

			if imgui.Selectable(u8'4.1 УК - Использование формы и знаков отличия представителей гос. Структур - 2*') then su("2", "4.1 УК") end
			if imgui.Selectable(u8'4.2 УК - Использование транспортного средства, оборудованного проблесковыми маячками СГУ - 2*') then su("2", "4.2 УК") end
			if imgui.Selectable(u8'4.3 УК - Выдача себя за другое лицо, не явшяющееся представителем органов власти - 1*') then su("1", "4.3 УК") end

		end
	},

	[5] = {
		name = "Глава 5. Взятка",
		body = function()

			if imgui.Selectable(u8'5.1 УК - Попытка или дача взятки - 3*') then su("3", "5.1 УК") end
			if imgui.Selectable(u8'5.2 УК - Получение взятки должностным лицом - 3*') then su("3", "5.2 УК") end
			if imgui.Selectable(u8'5.3 УК - Вымогательство взятки должностным лицом - 4*') then su("4", "5.3 УК") end

		end
	},

	[6] = {
		name = "Глава 6. Подделка документов",
		body = function()

			if imgui.Selectable(u8'6.1 УК - Подделка документов удостоверяющих личность - 2*') then su("2", "6.1 УК") end
			if imgui.Selectable(u8'6.2 УК - Подделка медецинских справок, выписок, или других документов - 1*') then su("1", "6.2 УК") end

		end
	},

	[7] = {
		name = "Глава 7. Оружие",
		body = function()

			if imgui.Selectable(u8'7.1 УК - Открытое ношение огнестрельного, пневматического, и другого оружия без цели самообороны - 2*') then su("2", "7.1 УК") end
			if imgui.Selectable(u8'7.2 УК - Приминение огнестрельного оружия без цели самообороны - 4*') then su("4", "7.2 УК") end
			if imgui.Selectable(u8'7.3 УК - Незаконное владение огнестрельным оружием (Без лицензии) - 4*') then su("4", "7.3 УК") end
			if imgui.Selectable(u8'7.4 УК - Продажа, покупка, хранение нелегального оружия - 5*') then su("5", "7.4 УК") end
			if imgui.Selectable(u8'7.5 УК - Изготовление оружия/патронов, не имея на то специальной лицензии - 5*') then su("5", "7.5 УК") end
			if imgui.Selectable(u8'7.6 УК - Угроза приминения огнестрельного оружия нацеливаясь на сотрудника МВД - 3*') then su("3", "7.6 УК") end

		end
	},

	[8] = {
		name = "Глава 8. Похищение людей, удержание в заложниках, незаконное лишение свободы",
		body = function()

			if imgui.Selectable(u8'8.1 УК - Похищение, взятие в заложники гражданского лица - 6*') then su("6", "8.1 УК") end
			if imgui.Selectable(u8'8.2 УК - Похищение, взятие в заложники лица, облечённого гос. Властью (9 ранги) - 6*') then su("6", "8.2 УК") end
			if imgui.Selectable(u8'8.3 УК - Похищение, взятие в заложники Президента Синей Федерации - 6*') then su("6", "8.3 УК") end
			if imgui.Selectable(u8'8.4 УК - Незаконное лишение свободы - 3*') then su("3", "8.4 УК") end
			if imgui.Selectable(u8'8.5 УК - Незаконное лишение свободы лица, облечённого гос. Властью (9 ранги) - 6*') then su("6", "8.5 УК") end

		end
	},

	[9] = {
		name = "Глава 9. Неподчинение",
		body = function()

			if imgui.Selectable(u8'9.1 УК - Неподчинение сотруднику ПО или представителем генеральной инспекции - 3*') then su("3", "9.1 УК") end
			if imgui.Selectable(u8'9.2 УК - Неподчинение сотруднику ПО, подавшему законный приказ при обстановке ЧС в Федерации - 4*') then su("4", "9.2 УК") end
			if imgui.Selectable(u8'9.3 УК - Отказ от выплаты штрафа или при его несвоевременной выплате - 3*') then su("3", "9.3 УК") end

		end
	},

	[10] = {
		name = "Глава 10. Проникновение",
		body = function()

			if imgui.Selectable(u8'10.1 УК - Отказ покинуть охраняемую ПО территорию - 2*') then su("2", "10.1 УК") end
			if imgui.Selectable(u8'10.2 УК - Незаконное проникновение на территорию закрытой военной базы либо обьекта - 3*') then su("3", "10.2 УК") end
			if imgui.Selectable(u8'10.3 УК - Проникновение и последующий отказ покинуть территорию часиерй собственности - 1*') then su("1", "10.3 УК") end
			if imgui.Selectable(u8'10.4 УК - Проникновение в здания гос. учреждений с вооружением - 2*') then su("2", "10.4 УК") end
			if imgui.Selectable(u8'10.5 УК - Проникновение в здания гос. учреждений в маске - 1*') then su("1", "10.5 УК") end
			if imgui.Selectable(u8'10.6 УК - Незаконное проникновение на территорию Федерального Бюро Расследований - 5*') then su("5", "10.6 УК") end

		end
	},

	[11] = {
		name = "Глава 11. Наркотические вещества",
		body = function()

			if imgui.Selectable(u8'11.1 УК - Незаконное хранение наркотических средств в больших количествах (5+ грамм или 10+ в доме) - 3*') then su("3", "11.1 УК") end
			if imgui.Selectable(u8'11.2 УК - Незаконный оборот, продажу, покупку наркотических средств - 6*') then su("6", "11.2 УК") end
			if imgui.Selectable(u8'11.3 УК - Производство любых наркотических, психологических средств, припаратов - 5*') then su("5", "11.3 УК") end

		end
	},

	[12] = {
		name = "Глава 12. Терроризм и экстремизм",
		body = function()

			if imgui.Selectable(u8'12.1 УК - Планирование или исполнение терракта - 6*') then su("6", "12.1 УК") end
			if imgui.Selectable(u8'12.2 УК - Помощь в исполнении терракта - 6*') then su("6", "12.2 УК") end
			if imgui.Selectable(u8'12.3 УК - Организация терракта - 6* (Руководителю+)') then su("6", "12.3 УК") end

		end
	},

	[13] = {
		name = "Глава 13. Хулиганство",
		body = function()

			if imgui.Selectable(u8'13.1 УК - Ложный вызов сотрудников ПО - 2*') then su("2", "13.1 УК") end
			if imgui.Selectable(u8'13.2 УК - Хулиганство с приминением либо с угрозой приминения насилия в отношений к гражданам - 3*') then su("3", "13.2 УК") end
			if imgui.Selectable(u8'13.3 УК - Хулиганство в публичном или общественном месте выражаемое в грубом неуважении к обществу - 2*') then su("2", "13.3 УК") end
			if imgui.Selectable(u8'13.4 УК - Организация незаконной уличной гонки на дорогах общего пользования - 3*') then su("3", "13.4 УК") end

		end
	},

	[14] = {
		name = "Глава 14. Публичные мероприятия",
		body = function()

			if imgui.Selectable(u8'14.1 УК - Срыв согласованного собрания, митинга, демонстрации, шествия или пикета - 2*') then su("2", "14.1 УК") end
			if imgui.Selectable(u8'14.2 УК - Организация несанкционированного собрания, митинга, демонстрации, шествия или пикета - 4*') then su("4", "14.2 УК") end
			if imgui.Selectable(u8'14.3 УК - Участие в несанкционированном собрании, митинге, демонстрации, шествии или пикете - 3*') then su("3", "14.3 УК") end

		end
	},

	[15] = {
		name = "Глава 15. Соучастие и содействие",
		body = function()

			if imgui.Selectable(u8'15.1 УК - Соучастие в преступлении любой главы УК - 6*') then su("6", "15.1 УК") end

		end
	},

	[16] = {
		name = "Глава 16. Преступная организация",
		body = function()

			if imgui.Selectable(u8'16.1 УК - Создание, организацию, управление преступной организации которая совершила преступления - 6*') then su("6", "16.1 УК") end
			if imgui.Selectable(u8'16.2 УК - Участие в преступной организации, совершение преступных деяний в соучастии - 6*') then su("6", "16.2 УК") end

		end
	},

	[17] = {
		name = "Глава 17. Таможенный и постовой контроль",
		body = function()

			if imgui.Selectable(u8'17.1 УК - Проезд пункта таможенного поста без предьявления пасспорта - 3*') then su("3", "17.1 УК") end
			if imgui.Selectable(u8'17.2 УК - Уклонение от обыска транспортного средства на таможенном посту - 3*') then su("3", "17.2 УК") end

		end
	},

	[18] = {
		name = "Глава 18. Оскорбление",
		body = function()

			if imgui.Selectable(u8'18.1 УК - Публичное оскорбление представителя(ей) власти, какие-либо унижения - 2*') then su("2", "18.1 УК") end
			if imgui.Selectable(u8'18.2 УК - Неоднократные или повторные оскорбления представителя(ей) власти, какие-либо унижения - 3*') then su("3", "18.2 УК") end

		end
	},

	[19] = {
		name = "Глава 19. Домогательство и изнасилование",
		body = function()

			if imgui.Selectable(u8'19.1 УК - Домогательство сексуального характера - 2*') then su("2", "19.1 УК") end
			if imgui.Selectable(u8'19.2 УК - Совершение изнасилования, насильственных действий сексуального характера - 4*') then su("4", "19.2 УК") end

		end
	},

	[20] = {
		name = "Глава 20. Побег и уклонение от законных мер",
		body = function()

			if imgui.Selectable(u8'20.1 УК - Побег и уклонение от законных мер, предпринимательных органов - 6*') then su("6", "20.1 УК") end

		end
	},

	[21] = {
		name = "Глава 21. Грабёж и кража",
		body = function()

			if imgui.Selectable(u8'21.1 УК - Причинение имущественного ущерба высокой степени тяжести - 4*') then su("4", "21.1 УК") end
			if imgui.Selectable(u8'21.2 УК - Осуществление грабежа, ограбления с приминением огнестрельного, холодного оружия - 5*') then su("5", "21.2 УК") end
			if imgui.Selectable(u8'21.3 УК - Осуществление грабежа на военных обьектах - 6*') then su("6", "21.3 УК") end

		end
	},

	[22] = {
		name = "Глава 22. Незаконное предпринимательство",
		body = function()

			if imgui.Selectable(u8'22.1 УК - Повторное осуществление незаконной предпринимательской деятельности - 5*') then su("5", "22.1 УК") end

		end
	},

	[23] = {
		name = "Глава 23. Кража налоговых данных",
		body = function()

			if imgui.Selectable(u8'23.1 УК - Кража налоговых данных и ограбление/налёт на инкассаторский фургон - 4*') then su("4", "23.1 УК") end
			if imgui.Selectable(u8'23.2 УК - Преднамеренное оказание помощи в ограблении от сотрудника правительства - 3*') then su("3", "23.2 УК") end
			if imgui.Selectable(u8'23.3 УК - Сговор сотрудников правительства с целью передачи налоговых данных - 2*') then su("2", "23.3 УК") end

		end
	},

	[24] = {
		name = "Глава 24. Сбор информации",
		body = function()

			if imgui.Selectable(u8'24.1 УК - Любой незаконный сбор информации или же попытка сбора информации с особо охраняемых обьектов - 6*') then su("6", "24.1 УК") end
			if imgui.Selectable(u8'24.2 УК - Незаконное раскрытие государственной или служебной тайны - 6*') then su("6", "24.2 УК") end
			if imgui.Selectable(u8'24.3 УК - Попытка добычи государственной или служебной тайны незаконным путём - 5*') then su("5", "24.3 УК") end

		end
	},

	[25] = {
		name = "Глава 25. Убийство",
		body = function()

			if imgui.Selectable(u8'25.1 УК - Умышленное убийство гражданина Синей Федерации - 6*') then su("6", "25.1 УК") end
			if imgui.Selectable(u8'25.2 УК - Нанесение тяжких телесных повреждений повлекшее за собой убийство гражданина Синей Федерации - 6*') then su("6", "25.2 УК") end
			if imgui.Selectable(u8'25.3 УК - Исполнение заказанного убийства - 6*') then su("6", "25.3 УК") end
			if imgui.Selectable(u8'25.4 УК - Проведение массовых и серийных убийств (От 2 человек) на территории Синей Федерации - 6*') then su("6", "25.4 УК") end
			if imgui.Selectable(u8'25.5 УК - Убийство высокопоставленных лиц (9 ранги) - 6*') then su("6", "25.5 УК") end

		end
	},

	[26] = {
		name = "Глава 26. Должностные преступления",
		body = function()

			if imgui.Selectable(u8'26.1 УК - Превышение, неисполнение, присвоение либо неналоедашее исполнение должностных обязанностей - 3*') then su("3", "26.1 УК") end
			if imgui.Selectable(u8'26.1.2 УК - Те же деяния предосмотренные в 26.1 УК повлекшие за собой негативные последствия - 6*') then su("6", "26.1.2 УК") end
			if imgui.Selectable(u8'26.2 УК - Внесение должностным лицом заведомо ложных сведений в официальные документы - 5*') then su("5", "26.2 УК") end

		end
	},

	[27] = {
		name = "Глава 27. Предоставление заведомо ложных данных",
		body = function()

			if imgui.Selectable(u8'27.1 УК - Дача заведомо ложных показаний - 2*') then su("2", "27.1 УК") end
			if imgui.Selectable(u8'27.2 УК - Дача заведомо ложных показаний на судебном заседании - 4*') then su("4", "27.2 УК") end

		end
	},

	[28] = {
		name = "Глава 28. Неисполнение судебных постановлений, неуважение к суду",
		body = function()

			if imgui.Selectable(u8'28.1 УК - Любое игнорирование, невыполнение, умышленное нарушение решений, постановлений суда - 6*') then su("6", "28.1 УК") end
			if imgui.Selectable(u8'28.2 УК - Повторная неявка в суд - 6*') then su("6", "28.2 УК") end
			if imgui.Selectable(u8'28.3 УК - Попытка оказать давление на ход судебного процесса путём подкупа, шантажа, угроз - 6*') then su("6", "28.3 УК") end
			if imgui.Selectable(u8'28.4 УК - Грубое неуважение к суду, выражающееся в агрессивных действиях - 5*') then su("5", "28.4 УК") end

		end
	},

	[29] = {
		name = "Глава 29. Укрывательство преступников находящихся в розыске",
		body = function()

			if imgui.Selectable(u8'29.1 УК - Отказ в выдаче сотрудника в организации, находящемся в федеральном розыске - 3*') then su("3", "29.1 УК") end
			if imgui.Selectable(u8'29.2 УК - Оказание противодействия, препядствия, реализации запроса ФБР на выдачу - 3*') then su("3", "29.2 УК") end
			if imgui.Selectable(u8'29.3 УК - Повторный инцедент с отказом в выдаче преступника - 6* (Руководителю организации)') then su("6", "29.3 УК") end

		end
	},

	[30] = {
		name = "Глава 30. Злоупотребление полномочиями и фабрикация уголовных дел",
		body = function()

			if imgui.Selectable(u8'30.1 УК - Умышленное исполнение полномочий с целью личной выгоды - 6* (Сотрудникам МВД)') then su("6", "30.1 УК") end
			if imgui.Selectable(u8'30.2 УК - Фабрикация уголовных дел, фальсификация доказательств и результатов по уголовному делу - 4*') then su("4", "30.2 УК") end
		end
	},

	[31] = {
		name = "Глава 31. Истязание",
		body = function()

			if imgui.Selectable(u8'31.1 УК - Причинение физических, психологических и иных страданий - 5*') then su("5", "31.1 УК") end
			if imgui.Selectable(u8'31.2 УК - Причинение физических, психологических и иных страданий, повлекшее за собой смерть - 6*') then su("6", "31.2 УК") end
			if imgui.Selectable(u8'31.3 УК - Причинение физических, психологических и иных страданий, совершённое гос. Лицом - 6*') then su("6", "31.3 УК") end
		end
	},
}

local function ticket(price, article)
    lua_thread.create(function()
        sampSendChat("/do В кармане лежит ручка и пустой бланк для штрафа.")
        wait(slider.v * 1000)

        sampSendChat("/me достал бланк и ручку, заполнил бланк, передал его нарушителю.")
        wait(slider.v * 1000)

        sampSendChat("/ticket " .. current_id .. " " .. price .. " " .. article)
    end)
end

local collapsing2 = {
    [1] = {
        name = "Статья 1. Нанесение вреда здоровью",
        body = function()

            if imgui.Selectable(u8'1.1 АК - Нанесение вреда здоровью лёгкой степени (До 25% HP) - 150.000$') then
                ticket("150000", "1.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    },

    [2] = {
        name = "Статья 2. Общественные правонарушения",
        body = function()

            if imgui.Selectable(u8'2.1 АК - Курение в общественном месте - 15.000$') then
                ticket("15000", "2.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'2.2 АК - Употребление спиртных напитков в общественном месте - 10.000$') then
                ticket("10000", "2.2 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    },

    [3] = {
        name = "Статья 3. Кража",
        body = function()

            if imgui.Selectable(u8'3.1 АК - Причинение имущественного вреда лёгкой степени тяжести - 50.000$') then
                ticket("50000", "3.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'3.2 АК - Причинение имущественного вреда средней степени тяжести - 100.000$') then
                ticket("100000", "3.2 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    },

    [4] = {
        name = "Статья 4. Незаконное предпринимательство",
        body = function()

            if imgui.Selectable(u8'4.1 АК - Совершение предпринимательской деятельности без наличия гос. Регистрации (Лицензии) - 1.500.000$') then
                ticket("1500000", "4.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'4.2 АК - Предоставление рабочих мест без наличия государственной лицензии - 75.000$ (Руководителю)') then
                ticket("75000", "4.2 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    },

    [5] = {
        name = "Статья 5. Причинение ущерба",
        body = function()

            if imgui.Selectable(u8'5.1 АК - Причинение незначительного ущерба частной либо гос. Собственности - 25.000$') then
                ticket("25000", "5.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'5.2 АК - Причинение ущерба средней степени тяжести частной либо гос. Собственности - 50.000$') then
                ticket("50000", "5.2 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    },

    [6] = {
        name = "Статья 6. Оскорбление",
        body = function()

            if imgui.Selectable(u8'6.1 АК - Оскорбление гражданина - 10.000$') then
                ticket("10000", "6.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'6.2 АК - Оскорбление сотрудника ПО - 20.000$') then
                ticket("20000", "6.2 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    },

    [7] = {
        name = "Статья 7. Клевета",
        body = function()

            if imgui.Selectable(u8'7.1 АК - Распостранение заведомо ложной информации - 50.000$') then
                ticket("50000", "7.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    },

    [8] = {
        name = "Статья 8. Административные нарушения в области правосудия",
        body = function()

            if imgui.Selectable(u8'8.1 АК - Неявка в суд - 200.000$') then
                ticket("200000", "8.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'8.2 АК - Неуважение к суду, выражающееся в игнорировании, обсуждении решений, замечаний судьи - 125.000$') then
                ticket("125000", "8.2 АК")
								windowTick = false
				imgui.ShowCursor = false
            end

        end
    },

    [9] = {
        name = "Статья 9. Злонамеренное преследование со стороны сотрудников МВД",
        body = function()

            if imgui.Selectable(u8'9.1 АК - Главе деп-та, сотрудники которого нео-но (3+) используют полномочия с целью злонамерения - 1.250.000$') then
                ticket("1250000", "9.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'9.2 АК - Директору ФБР, сотрудники которого нео-но (3+) используют полномочия с целью злонамерения - 2.500.000$') then
                ticket("2500000", "9.2 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'9.3 АК - Министру МВД, сотрудники которого нео-но (3+) используют пол-ия с целью злонамерения - 5.000.000$') then
                ticket("5000000", "9.3 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    },

    [10] = {
        name = "Статья 10. Незаконные уличные гонки",
        body = function()

            if imgui.Selectable(u8'10.1 АК - Участие в уличной гонке или соревновании - 20.000$') then
                ticket("20000", "10.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'10.2 АК - Реклама или продвижение незаконных уличных гонок - 10.000$') then
                ticket("10000", "10.2 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    },

    [11] = {
        name = "Статья 11. Нарушения в рамках адвокатского запроса",
        body = function()

            if imgui.Selectable(u8'11.1 АК - Несвоевременная передача или неправомерный отказ от предоставления сведений - 100.000$') then
                ticket("100000", "11.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    },

    [12] = {
        name = "Статья 12. Нарушение юрисдикции",
        body = function()

            if imgui.Selectable(u8'12.1 АК - Нарушение юрисдикции без служебной необходимости - 10.000$') then
                ticket("10000", "12.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    },

    [13] = {
        name = "Глава 2. Дорожное движение",
        body = function()

            if imgui.Selectable(u8'1 АК - Движение на автомобиле без номерных знаков - 20.000$') then
                ticket("20000", "2.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'2 АК - Отсутствие у водителя пасспорта или документов - 25.000$') then
                ticket("25000", "2.2 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'3 АК - Управление неисправным автомобиле (С чёрным дымом, 400-300 DL) - 17.500$') then
                ticket("17500", "2.3 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'4 АК - Управление транспортным средством в состоянии алкогольного опьянения - 25.000$ + Лишение прав') then
                ticket("25000", "2.4 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'5 АК - Опасное вождение - 22.500$') then
                ticket("22500", "2.5 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'6 АК - Несоблюдение требований знаков дорожного движения - 12.500$') then
                ticket("12500", "2.6 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'7 АК - Движение автомобиля по встречной полосе - 25.000$') then
                ticket("25000", "2.7 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'7.1 АК - Повторное нарушение 2.7 АК - 25.000$ + Лишение прав') then
                ticket("25000", "2.7.1 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'8 АК - Движение, парковка на газонах, тротуарах - 17.500$') then
                ticket("17500", "2.8 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'9 АК - Движение автомобиля по железнодорожным путям - 20.000$') then
                ticket("20000", "2.9 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'10 АК - Езда без включённых внешних световых приборов (Фар) - 15.000$') then
                ticket("15000", "2.10 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'11 АК - Управление пикапом или грузовиком с пассажирами перевозимыми в кузове (Мясовозка) - 25.000$') then
                ticket("25000", "2.11 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'12 АК - Многочисленные нарушения (3+) - 50.000$') then
                ticket("50000", "2.12 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

            if imgui.Selectable(u8'13 АК - Управление автомобилем с мод-ями, препядствующим пропусканию света менее 70% (Тонировка) - 15.000$') then
                ticket("15000", "2.13 АК")
								windowTick.v = false
				imgui.ShowCursor = false
            end

        end
    }
}

function checkWeapon()
    while true do
        wait(100)

        if not isSampAvailable() then goto continue end
        if not config.settings.enableRpGuns then goto continue end

        local gun = getCurrentCharWeapon(PLAYER_PED)

        if gun ~= lastgun then
            local time = os.clock()

            if time - lastSendTime > 0.7 then
                sendRpGun(gun)
                lastSendTime = time
            end

            lastgun = gun
        end

        ::continue::
    end
end

function sendRpGun(gun)
    if gun == 0 then
			sampSendChat("/me убрал оружие.")

		elseif gun == 3 then
			sampSendChat("/me снял дубинку с поясного держателя.")
		elseif gun == 24 then
			sampSendChat("/me взял в руки пистолет марки Desert Eagle.")
		elseif gun == 25 then
			sampSendChat("/me взял в руки дробовик Shotgun, перезарядил его.")
		elseif gun == 29 then
			sampSendChat("/me взял в две руки пистолет-пулемёт MP5")
		elseif gun == 30 then
			sampSendChat("/me взял в правую руку автомат AK-47, перезарядил его.")
		elseif gun == 31 then
			sampSendChat("/me взял в правую руку автомат M4, перезарядил его.")
		elseif gun == 33 then
			sampSendChat("/me взял в две руки оружие марки Rifle.")
		elseif gun == 34 then
			sampSendChat("/me взял в две руки снайперскую винтовку.")
		end
end

function string.nlower(s)
    s = lower(s)
    local len, res = #s, {}
    for i = 1, len do
        local ch = sub(s, i, i)
        res[i] = ul_rus[ch] or ch
    end
    return concat(res)
end

function main()
    repeat wait(0) until isSampAvailable()
	local path = getWorkingDirectory() .. "\\resource\\LawAssist\\sounds\\"
	local last = -1
    soundMenu = loadAudioStream(path .. "menu.mp3")
	soundButton = loadAudioStream(path .. "button.mp3")
	soundMenuEnd = loadAudioStream(path .. "menu_end.mp3")
	soundSave = loadAudioStream(path .. "save.mp3")
	soundEnd = loadAudioStream(path .. "end.mp3")
	soundInclude = loadAudioStream(path .. "include.mp3")
	
	imgui.ShowCursor = false
	
	lua_thread.create(checkWeapon)
	addLog("Загрузка скрипта")
	notif("Law Assist загружен!")
	
	if config.settings.sounds then
		setAudioStreamState(soundInclude, 0)
		setAudioStreamState(soundInclude, 1)
	end
	
	sampRegisterChatCommand("law", function()
		window.v = not window.v
		imgui.ShowCursor = window.v
		if config.settings.sounds then
		setAudioStreamState(soundMenu, 0)
		setAudioStreamState(soundMenu, 1)
		end
	end)
	
	sampRegisterChatCommand("sus", function(id_str)
		local id = tonumber(id_str)
		if id then
		current_id = id
		windowSus.v = not windowSus.v
		imgui.ShowCursor = windowSus.v
		if config.settings.sounds then
		setAudioStreamState(soundMenu, 0)
		setAudioStreamState(soundMenu, 1)
		end
		else
			notif("Использование: /sus [ID]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		end
	end)
	
	sampRegisterChatCommand("tick", function(id_str)
		local id = tonumber(id_str)
		if id then
		current_id = id
		windowTick.v = not windowTick.v
		imgui.ShowCursor = windowTick.v
		if config.settings.sounds then
		setAudioStreamState(soundMenu, 0)
		setAudioStreamState(soundMenu, 1)
		end
		else
			notif("Использование: /tick [ID]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		end
	end)
	
	flymode = 0  
	speed = 1.0
	radarHud = 0
	time = 0
	keyPressed = 0
	
		sampRegisterChatCommand('prava', cmd_prava)
		sampRegisterChatCommand('cuff', cmd_cuff)
		sampRegisterChatCommand('uncuff', cmd_uncuff)
		sampRegisterChatCommand('hold', cmd_hold)
		sampRegisterChatCommand('arrest', cmd_arrest)
		sampRegisterChatCommand('m1', cmd_m1)
		sampRegisterChatCommand('m2', cmd_m2)
		sampRegisterChatCommand('search', cmd_search)
		sampRegisterChatCommand('su', cmd_su)
		sampRegisterChatCommand('udo', cmd_udo)
		sampRegisterChatCommand('clear', cmd_clear)
		sampRegisterChatCommand('pull', cmd_pull)
		sampRegisterChatCommand('putpl', cmd_putpl)
		sampRegisterChatCommand('histid', cmd_histid)
		sampRegisterChatCommand('krik', cmd_krik)
		sampRegisterChatCommand('ticket', cmd_ticket)
		sampRegisterChatCommand('eject', cmd_eject)
		sampRegisterChatCommand('wanted', cmd_wanted)
		sampRegisterChatCommand('setmark', cmd_setmark)
		sampRegisterChatCommand('sm', cmd_setmark)
	
    while true do
        wait(0)
		
		checkCamHack()
		checkHpHud()
		checkTheme()
		checkFrac()
		checkDialog()
		checkCalc()
		checkOther()

		if isKeyJustPressed(0x32) and not sampIsChatInputActive() and not sampIsDialogActive() and carMenu.v then
			imgui.ShowCursor = not imgui.ShowCursor
		end

        if isCharInAnyCar(PLAYER_PED) and config.settings.patrolMenu then
            carMenu.v = true

            local car = storeCarCharIsInNoSave(PLAYER_PED)
            local model = getCarModel(car)

            carName = getNameOfVehicleModel(model) or "Unknown"
        else
            carMenu.v = false
            carName = "Not in vehicle"
        end

		if config.settings.enable == false then
			sampUnregisterChatCommand("cuff")
			sampUnregisterChatCommand("uncuff")
			sampUnregisterChatCommand("hold")
			sampUnregisterChatCommand("pull")
			sampUnregisterChatCommand("putpl")
			sampUnregisterChatCommand("krik")
			sampUnregisterChatCommand("histid")
			sampUnregisterChatCommand("clear")
			sampUnregisterChatCommand("udo")
			sampUnregisterChatCommand("su")
			sampUnregisterChatCommand("search")
			sampUnregisterChatCommand("m1")
			sampUnregisterChatCommand("m2")
			sampUnregisterChatCommand("arrest")
			sampUnregisterChatCommand("prava")
			sampUnregisterChatCommand("ticket")
			sampUnregisterChatCommand("eject")
			sampUnregisterChatCommand("wanted")
			sampUnregisterChatCommand("sm")
			sampUnregisterChatCommand("setmark")
		end
end
end

function sampev.onPlayerChatBubble(id, col, dist, dur, msg)
	if flymode == 1 then
		return {id, col, 1488, dur, msg}
	end
end

function getMyId()
    if not isSampAvailable() then return nil end
    if not doesCharExist(PLAYER_PED) then return nil end

    local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if result then return id end

    return nil
end

local cachedFps = 0
local lastFpsUpdate = 0

local function getNearestVehicle(radius)
    local px, py, pz = getCharCoordinates(PLAYER_PED)
    local myCar = storeCarCharIsInNoSave(PLAYER_PED)

    local nearestCar = -1
    local nearestDist = radius or 9999.0

    for _, veh in ipairs(getAllVehicles()) do
        if doesVehicleExist(veh) then

            if veh ~= myCar then
                local vx, vy, vz = getCarCoordinates(veh)

                local dist = getDistanceBetweenCoords3d(
                    px, py, pz,
                    vx, vy, vz
                )

                if dist < nearestDist then
                    nearestDist = dist
                    nearestCar = veh
                end
            end
        end
    end

    return nearestCar, nearestDist
end

function updateFps()
    local now = os.clock()
    if now - lastFpsUpdate >= 0.5 then
        cachedFps = math.floor(memory.getfloat(0xB7CB50, true) + 0.5)
        lastFpsUpdate = now
    end
end

function imgui.BeforeDrawFrame()
    if fa_font == nil then
        font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
		if doesFileExist(getWorkingDirectory().."/lib/fontawesome-webfont.ttf") then
			fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory().."/lib/fontawesome-webfont.ttf", 14.0, font_config, fa_glyph_ranges)
		else
			fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 14.0, font_config, fa_glyph_ranges)
		end
	end
	if fa_size == nil then
		if doesFileExist(getWorkingDirectory().."/lib/fontawesome-webfont.ttf") then
			fa_size = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory().."/lib/fontawesome-webfont.ttf", UI.Font, nil, fa_glyph_ranges)
		end
	end
	if ToggleButton_Font == nil then
        ToggleButton_Font = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 15.5, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	
	if pricedown == nil then
        pricedown = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader//resource//LawAssist//fonts//pricedown.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
end

function imgui.CenterText(text)
	imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(u8(text)).x/2)
	imgui.Text(u8(text))
end

local logoImage = imgui.CreateTextureFromFile("moonloader/resource/LawAssist/images/samplogo.png")
local manImage = imgui.CreateTextureFromFile("moonloader/resource/LawAssist/images/man.png")

function imgui.Center1Text(text)
	imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(u8(text)).x/2)
	imgui.Text(text)
end

local function cleanText(text)
    text = text:gsub("{%x%x%x%x%x%x}", "")
    text = text:gsub("[{}]", "")
    text = text:gsub("%s+", " ")
    return text:match("^%s*(.-)%s*$")
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if not text then return end
	
	if dialogId == 0 then
		if text:find("Организация:") then
			for line in text:gmatch("[^\r\n]+") do
				local org = line:match("Организация:%s*(.+)")
				if org then
					organization = cleanText(org)
				end
			end
		end
		
		if text:find("Подразделение:") then
			for line in text:gmatch("[^\r\n]+") do
				local org = line:match("Подразделение:%s*(.+)")
				if org then
					department = cleanText(org)
				end
			end
		end
		
		if text:find("Должность:") then
			for line in text:gmatch("[^\r\n]+") do
				local org = line:match("Должность:%s*(.+)")
				if org then
					org = cleanText(org)

					org = org:gsub("^%[[^%]]+%]%s*", "")

					rank = org
				end
			end
		end
	end
end

local comboSelect = "ADAM"
local comboSelectCode = "CODE-4"

function renderWindow()
	if window.v then
			imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.06, 0.06, 0.06, 1.0))
			imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(900, 600), imgui.Cond.Always)
			imgui.Begin(u8("Law Assist"), window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)
			
			if not selected then 
				selected = 1 
			end
			
			imgui.Image(logoImage, imgui.ImVec2(64, 64))
			if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8("Почему именно Law Assist?\n- Скорость и непрерывная работа.\n- Функционал\n- Многие другие функции которых нет в других helper'ах."))
						imgui.EndTooltip()
			end
			imgui.SameLine()
			imgui.PushFont(pricedown)
			imgui.Text(u8("LAW ASSIST\nVersion 1.0 Stable"))
			imgui.PopFont()
			local oldPos = imgui.GetCursorPos()
				
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.06, 0.06, 0.06, 1.0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.60, 0.60, 0.60, 1.0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.50, 0.50, 0.50, 1.0))
			imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowSize().x - 32 - 10, 10))
			if imgui.Button(fa.ICON_TIMES, imgui.ImVec2(32, 32)) then  window.v = false imgui.ShowCursor = false end
			imgui.PopStyleColor(3)
			
			
			imgui.SetCursorPos(oldPos)
			
			imgui.BeginChild("Left", imgui.ImVec2(250, 515), true)
			
			if imgui.Button(fa.ICON_HOME.. u8(" Основное"), imgui.ImVec2(230, 40)) then
			selected = 1
			if config.settings.sounds then
				setAudioStreamState(soundButton, 0)
				setAudioStreamState(soundButton, 1)
			end
			end
			if imgui.Button(fa.ICON_LIST.. u8(" Комманды"), imgui.ImVec2(230, 40)) then
			selected = 2
			if config.settings.sounds then
				setAudioStreamState(soundButton, 0)
				setAudioStreamState(soundButton, 1)
			end
			end
			if imgui.Button(fa.ICON_WRENCH.. u8(" Настройки"), imgui.ImVec2(230, 40)) then
			selected = 3
			if config.settings.sounds then
				setAudioStreamState(soundButton, 0)
				setAudioStreamState(soundButton, 1)
			end
			end
			
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()
			imgui.NewLine()

			
			imgui.BeginChild("Left Status", imgui.ImVec2(230, 165), true)
			
			local myNick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
			local serverName = sampGetCurrentServerName()
			local connected = isSampAvailable()
			
			if connected then 
				imgui.Text(u8("Статус:"))
				imgui.Text(u8("     Подключён"))
			else
				imgui.Text(u8("Статус:"))
				imgui.Text(u8("     Не подключён"))
			end
			imgui.Dummy(imgui.ImVec2(0, 5))
			imgui.Separator()
			imgui.Text(u8("Ник:"))
			imgui.Text("     " ..myNick)
			imgui.Dummy(imgui.ImVec2(0, 5))
			imgui.Separator()
			imgui.Text(u8("Сервер:"))
			imgui.Text("     " ..serverName)
			imgui.Dummy(imgui.ImVec2(0, 5))
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 5))
			imgui.Text(u8("Время: " ..os.date("%H:%M").. " | "))
			imgui.SameLine()
			imgui.Text(u8("Дата: " ..os.date("%d.%m")))
			
			imgui.EndChild()
			
			imgui.EndChild()
			imgui.SameLine()
			
			local pos = imgui.GetCursorScreenPos()
			local rightX = pos.x
			local rightY = pos.y
			imgui.BeginChild("Centered", imgui.ImVec2(620, 485), true)
			
				if selected == 1 then
				imgui.BeginChild("Hello", imgui.ImVec2(400, 150), true)
				imgui.Image(manImage, imgui.ImVec2(130, 130))
				imgui.SameLine()
				imgui.Text(u8("Добро пожаловать!\nLaw Assist - Маленький но удобный\nИ настраиваемый хелпер.\nСлева вы можете перейти\nВ нужный раздел."))
				imgui.EndChild()
				
				imgui.SameLine()
				imgui.BeginChild("Info", imgui.ImVec2(193, 150), true)
				
				imgui.Text(u8("Информация"))
				imgui.Dummy(imgui.ImVec2(0, 5))
				imgui.Separator()
				imgui.Dummy(imgui.ImVec2(0, 5))
				
				local health = getCharHealth(PLAYER_PED)
				local armor = getCharArmour(PLAYER_PED)

				health = tonumber(health) or 0
				armor = tonumber(armor) or 0

				local hpBar = math.max(0.0, math.min(health / 100.0, 1.0))
				local arBar = math.max(0.0, math.min(armor / 100.0, 1.0))
				
				imgui.Text(u8("Здоровье		"))
				imgui.SameLine()
				imgui.Text(u8("      "))
				imgui.SameLine()
				imgui.Text(u8("		" ..health.. "%"))
				imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(0.0, 0.0, 1.0, 0.5))
				imgui.ProgressBar(hpBar, imgui.ImVec2(175, 10), "##health")
				imgui.PopStyleColor()
				imgui.Dummy(imgui.ImVec2(0, 5))
				imgui.Separator()
				imgui.Dummy(imgui.ImVec2(0, 5))
				
				imgui.Text(u8("Бронежилет  "))
				imgui.SameLine()
				imgui.Text(u8("      "))
				imgui.SameLine()
				imgui.Text(u8("		" ..armor.. "%"))
				imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(0.0, 0.0, 1.0, 0.5))
				imgui.ProgressBar(arBar, imgui.ImVec2(175, 10), "##armor")
				imgui.PopStyleColor()
				
				imgui.EndChild()
				
				imgui.Dummy(imgui.ImVec2(0, 5))
				
				imgui.BeginChild("Two info", imgui.ImVec2(200, 300), true)
				
				imgui.Text(u8("Действия:"))
				imgui.Dummy(imgui.ImVec2(0, 5))
				imgui.Separator()
				imgui.Dummy(imgui.ImVec2(0, 5))
				
				if imgui.Button(u8("Форум"), imgui.ImVec2(85, 120)) then os.execute('start "" "' .. "https://forum.adv-rp.com" .. '"') end
				imgui.SameLine()
				if imgui.Button(u8("УК"), imgui.ImVec2(85, 120)) then os.execute('start "" "' .. "https://forum.adv-rp.com/threads/ugolovnyi-administrativnyi-i-protsessual-nyi-kodeksy.2425077/" .. '"')end
				
				if imgui.Button(u8("АК"), imgui.ImVec2(85, 120)) then os.execute('start "" "' .. "https://forum.adv-rp.com/threads/ugolovnyi-administrativnyi-i-protsessual-nyi-kodeksy.2425077/" .. '"')end
				imgui.SameLine()
				if imgui.Button(u8("ПК"), imgui.ImVec2(85, 120)) then os.execute('start "" "' .. "https://forum.adv-rp.com/threads/ugolovnyi-administrativnyi-i-protsessual-nyi-kodeksy.2425077/post-29874220" .. '"')end
				
				imgui.EndChild()
				
				imgui.SameLine()
				
				imgui.BeginChild("Log", imgui.ImVec2(393, 300), true)
				
				imgui.Text(u8("Последние действия: "))
				
				for i, log in ipairs(logs) do
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Separator()
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(u8(log))
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8(log))
						imgui.EndTooltip()
					end
					imgui.Dummy(imgui.ImVec2(0, 5))
				end
				
				imgui.EndChild()
				
				end
				
				if selected == 2 then
				imgui.BeginChild("Commands", imgui.ImVec2(600, 465), true)
				
				imgui.Columns(3)
				imgui.Text(u8("Комманда"))
				imgui.NextColumn()
				imgui.Text(u8("Описание"))
				imgui.NextColumn()
				imgui.Text(u8("Пример"))
				imgui.NextColumn()
				
				imgui.Text(u8("/cuff [ID]"))
				imgui.NextColumn()
				imgui.Text(u8("Надеть наручники"))
				imgui.NextColumn()
				imgui.Text(u8("/cuff 69"))
				imgui.NextColumn()
				
				imgui.Text(u8("/uncuff [ID]"))
				imgui.NextColumn()
				imgui.Text(u8("Снять наручники"))
				imgui.NextColumn()
				imgui.Text(u8("/uncuff 69"))
				imgui.NextColumn()
				
				imgui.Text(u8("/hold [ID]"))
				imgui.NextColumn()
				imgui.Text(u8("Вести за собой"))
				imgui.NextColumn()
				imgui.Text(u8("/hold 69"))
				imgui.NextColumn()
				
				imgui.Text(u8("/arrest [ID] [Причина]"))
				imgui.NextColumn()
				imgui.Text(u8("Посадить в КПЗ"))
				imgui.NextColumn()
				imgui.Text(u8("/arrest 69 nil"))
				imgui.NextColumn()
				
				imgui.Text(u8("/prava"))
				imgui.NextColumn()
				imgui.Text(u8("Зачитать миранду"))
				imgui.NextColumn()
				imgui.Text(u8("/prava"))
				imgui.NextColumn()
				
				imgui.Text(u8("/m1"))
				imgui.NextColumn()
				imgui.Text(u8("Мегафон для 10-55"))
				imgui.NextColumn()
				imgui.Text(u8("/m1"))
				imgui.NextColumn()
				
				imgui.Text(u8("/m2"))
				imgui.NextColumn()
				imgui.Text(u8("Мегафон для 10-66"))
				imgui.NextColumn()
				imgui.Text(u8("/m2"))
				imgui.NextColumn()
				
				imgui.Text(u8("/search [ID] [Причина]"))
				imgui.NextColumn()
				imgui.Text(u8("Произвести обыск"))
				imgui.NextColumn()
				imgui.Text(u8("/search 69 Полный"))
				imgui.NextColumn()
				
				imgui.Text(u8("/su"))
				imgui.NextColumn()
				imgui.Text(u8("Обьявить в розыск"))
				imgui.NextColumn()
				imgui.Text(u8("/su 69 6 2.1 УК"))
				imgui.NextColumn()
				
				imgui.Text(u8("/udo"))
				imgui.NextColumn()
				imgui.Text(u8("Показать удостоверение"))
				imgui.NextColumn()
				imgui.Text(u8("/udo"))
				imgui.NextColumn()
				
				imgui.Text(u8("/clear [ID] [Причина]"))
				imgui.NextColumn()
				imgui.Text(u8("Снять розыск"))
				imgui.NextColumn()
				imgui.Text(u8("/clear 69 Ошибка КПК"))
				imgui.NextColumn()
				
				imgui.Text(u8("/pull [ID]"))
				imgui.NextColumn()
				imgui.Text(u8("Вытащить из машины"))
				imgui.NextColumn()
				imgui.Text(u8("/pull 69"))
				imgui.NextColumn()
				
				imgui.Text(u8("/putpl [ID]"))
				imgui.NextColumn()
				imgui.Text(u8("Посадить в машину"))
				imgui.NextColumn()
				imgui.Text(u8("/putpl 69"))
				imgui.NextColumn()
				
				imgui.Text(u8("/histid [ID]"))
				imgui.NextColumn()
				imgui.Text(u8("Быстрая проверка /history"))
				imgui.NextColumn()
				imgui.Text(u8("/histid 69"))
				imgui.NextColumn()
				
				imgui.Text(u8("/krik"))
				imgui.NextColumn()
				imgui.Text(u8("'Всем оставаться на своих местах'"))
				imgui.NextColumn()
				imgui.Text(u8("/krik"))
				imgui.NextColumn()
				
				imgui.Text(u8("/law"))
				imgui.NextColumn()
				imgui.Text(u8("Главное меню"))
				imgui.NextColumn()
				imgui.Text(u8("/law"))
				imgui.NextColumn()
				
				imgui.Text(u8("/sus [ID]"))
				imgui.NextColumn()
				imgui.Text(u8("Умный розыск"))
				imgui.NextColumn()
				imgui.Text(u8("/sus 69"))
				imgui.NextColumn()
				
				imgui.Text(u8("/tick [ID]"))
				imgui.NextColumn()
				imgui.Text(u8("Умный штраф"))
				imgui.NextColumn()
				imgui.Text(u8("/tick 69"))
				imgui.NextColumn()
				
				imgui.Text(u8("/ticket [ID] [Сумма] [Причина]"))
				imgui.NextColumn()
				imgui.Text(u8("Выписать штраф"))
				imgui.NextColumn()
				imgui.Text(u8("/ticket 69 25000 2.7 АК"))
				imgui.NextColumn()
				
				imgui.Text(u8("/eject [ID]"))
				imgui.NextColumn()
				imgui.Text(u8("Вытащить из машины"))
				imgui.NextColumn()
				imgui.Text(u8("/eject 69"))
				imgui.NextColumn()
				
				imgui.Text(u8("/setmark [ID]"))
				imgui.NextColumn()
				imgui.Text(u8("Поставить метку на игрока"))
				imgui.NextColumn()
				imgui.Text(u8("/setmark 69"))
				imgui.NextColumn()
				
				imgui.Text(u8("/sm [ID]"))
				imgui.NextColumn()
				imgui.Text(u8("Аналог /setmark"))
				imgui.NextColumn()
				imgui.Text(u8("/sm 69"))
				imgui.NextColumn()
				
				imgui.Text(u8("/wanted"))
				imgui.NextColumn()
				imgui.Text(u8("Список розыскиваемых"))
				imgui.NextColumn()
				imgui.Text(u8("/wanted"))
				imgui.NextColumn()
				
				imgui.Columns(1)

				
				imgui.EndChild()
				end
				
				if selected == 3 then
				imgui.BeginChild("Settings", imgui.ImVec2(600, 465), true)
				
				imgui.Text(u8("Настройки"))
				imgui.BeginChild("Settingsbutn", imgui.ImVec2(580, 45), true)
				
				if not selectedS then selectedS = 1 end
				
				if imgui.Button(u8("Основное"), imgui.ImVec2(133, 25)) then selectedS = 1 if config.settings.sounds then setAudioStreamState(soundButton, 0) setAudioStreamState(soundButton, 1) end end
				imgui.SameLine()
				if imgui.Button(u8("Отыгровки"), imgui.ImVec2(133, 25)) then selectedS = 2 if config.settings.sounds then setAudioStreamState(soundButton, 0) setAudioStreamState(soundButton, 1) end end
				imgui.SameLine()
				if imgui.Button(u8("Разное"), imgui.ImVec2(133, 25)) then selectedS = 3 if config.settings.sounds then setAudioStreamState(soundButton, 0) setAudioStreamState(soundButton, 1) end end
				imgui.SameLine()
				if imgui.Button(u8("Другие"), imgui.ImVec2(133, 25)) then selectedS = 4 if config.settings.sounds then setAudioStreamState(soundButton, 0) setAudioStreamState(soundButton, 1) end end
				imgui.EndChild()
				
				if selectedS == 1 then
				
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Separator()
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(u8("Основные"))
				
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(u8("ID диалогов: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##showDialogID", showDialogID) then
						config.settings.showDialogID = showDialogID.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Выводить ли ID показанных диалогов")
						imgui.EndTooltip()
					end
					
					imgui.Text(u8("Звуки: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##sounds", sounds) then
						config.settings.sounds = sounds.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Проигрывать ли звуки (Нажания на кнопки, сохранения, меню)")
						imgui.EndTooltip()
					end
					
					imgui.Text(u8("Акцент: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##accent", accent) then
						config.settings.accent = accent.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					
					if config.settings.accent then
						imgui.SameLine()
						imgui.PushItemWidth(207)
						imgui.InputText(u8'##accenttext', accenttext)
						imgui.PopItemWidth()
		
							if imgui.Button(u8'Сохранить', imgui.ImVec2(297, 35)) then
							if accenttext.v == "" then notif("Введите акцент перед сохранением!")
							else
							config.settings.accenttext = accenttext.v
							inicfg.save(cfg, config_name)
							printStringNow('~b~Saved!', 1100)
							if config.settings.sounds then
							setAudioStreamState(soundSave, 0) 
							setAudioStreamState(soundSave, 1)
							end
							end
							end
					end
					
					imgui.Text(u8("Тег (/r, /f): "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##tag", tag) then
						config.settings.tag = tag.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					
					if config.settings.tag then
						imgui.SameLine()
						imgui.PushItemWidth(190)
						imgui.InputText(u8'##tagText', tagText)
						imgui.PopItemWidth()
		
							if imgui.Button(u8'Сохранить тег', imgui.ImVec2(297, 35)) then
							if tagText.v == "" then notif("Введите тег перед сохранением!")
							else
							config.settings.tagText = tagText.v
							inicfg.save(cfg, config_name)
							printStringNow('~b~Saved!', 1100)
							if config.settings.sounds then
							setAudioStreamState(soundSave, 0) 
							setAudioStreamState(soundSave, 1)
							end
							end
							end
					end
					
					imgui.PushItemWidth(165)
					imgui.Text(u8'Интервал отыгровок:')
					imgui.SameLine()
					if imgui.SliderFloat('##slider', slider, 0, 5, '%.1f') then 
						config.settings.slider = slider.v
						inicfg.save(cfg, config_name)
					end
					imgui.PopItemWidth()
					
					
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Separator()
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(u8("Организация:"))
					imgui.Text(u8("     " ..organization))
					
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Separator()
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(u8("Отдел:"))
					imgui.Text(u8("     " ..department))
					
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Separator()
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(u8("Занимаемая должность:"))
					imgui.Text(u8("     " ..rank))
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Separator()
					
					imgui.Dummy(imgui.ImVec2(0, 5))
					if imgui.CollapsingHeader(u8"Темы", false) then
						if imgui.Selectable(u8("Стандарт")) then
							config.settings.theme = 1
							
							inicfg.save(cfg, config_name)
						end
						if imgui.Selectable(u8("Хром")) then
							config.settings.theme = 2
							
							inicfg.save(cfg, config_name)
						end
						if imgui.Selectable(u8("Салатная")) then
							config.settings.theme = 3
							
							inicfg.save(cfg, config_name)
						end
						if imgui.Selectable(u8("Зелёная")) then
							config.settings.theme = 4
							
							inicfg.save(cfg, config_name)
						end
						if imgui.Selectable(u8("Оранжевая")) then
							config.settings.theme = 5
							
							inicfg.save(cfg, config_name)
						end
						if imgui.Selectable(u8("Dead Inside")) then
							config.settings.theme = 8
							
							inicfg.save(cfg, config_name)
						end
						if imgui.Selectable(u8("Красная")) then
							config.settings.theme = 6
							
							inicfg.save(cfg, config_name)
						end
						if imgui.Selectable(u8("FBI")) then
							config.settings.theme = 7
							
							inicfg.save(cfg, config_name)
						end
					end
					
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Separator()
					imgui.Dummy(imgui.ImVec2(0, 5))
					
					if imgui.Button(u8("Перезагрузить скрипт"), imgui.ImVec2(297, 35)) then lua_thread.create(function() if config.settings.sounds then setAudioStreamState(soundEnd, 0) setAudioStreamState(soundEnd, 1) end wait(500) thisScript():reload() end) end
					if imgui.Button(u8("Сбросить настройки"), imgui.ImVec2(297, 35)) then lua_thread.create(function() if config.settings.sounds then setAudioStreamState(soundEnd, 0) setAudioStreamState(soundEnd, 1) end wait(500) os.remove(config_file) thisScript():reload() end) end
				end
				
				if selectedS == 2 then
				
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Separator()
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(u8("Отыгровки"))
				
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(u8("Отыгровки оружий: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"", rpgun) then
						config.settings.enableRpGuns = rpgun.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"RP отыгровки оружий\nНапример, если у вас в руках появился Desert Eagle, скрипт напишет:\n/me достал из кобуры пистолет марки Desert Eagle")
						imgui.EndTooltip()
					end
					
					imgui.Text(u8("Работа комманд: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##enable", enable) then
						config.settings.enable = enable.v
						thisScript():reload()
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Будут ли работать все комманды скрипта кроме /law, /sus, /tick")
						imgui.EndTooltip()
					end
				end
				
				if selectedS == 3 then
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Separator()
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(u8("Разное"))
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(u8("Быстрое меню: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##fastMenu", fastMenu) then
						config.settings.fastMenu = fastMenu.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Включить ли быстрое меню (Клавиша 1)")
						imgui.EndTooltip()
					end
										
					imgui.Text(u8("Быстрое меню игрока: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##fastMenuP", fastMenuP) then
						config.settings.fastMenuP = fastMenuP.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Включить ли быстрое меню для взаимодействия с игроком (ПКМ по игроку + Q)")
						imgui.EndTooltip()
					end
					
					imgui.Text(u8("Patrol меню: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##patrolMenu", patrolMenu) then
						config.settings.patrolMenu = patrolMenu.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Если вы в машине будет показываться меню с выбором кода, маркировки, и предлогать доклад.\nПоказать курсор - клавиша 2")
						imgui.EndTooltip()
					end
					if config.settings.fastMenu then
						imgui.Dummy(imgui.ImVec2(0, 5))
						imgui.Text(u8("Пункты быстрого меню: "))
						imgui.Text(u8("Мегафон 10-55"))
						imgui.SameLine()
						if imAddon.ToggleButton(u8("##megaphone"), megaphone) then
							config.fastMenuPuncts.megaphone = megaphone.v
							inicfg.save(cfg, config_name)

							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end

						imgui.SameLine()
						imgui.Text(u8("Мегафон 10-66"))
						imgui.SameLine()
						if imAddon.ToggleButton(u8("##twoMegaphone"), twoMegaphone) then
							config.fastMenuPuncts.twoMegaphone = twoMegaphone.v
							inicfg.save(cfg, config_name)

							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end

						imgui.SameLine()
						imgui.Text(u8("Крик"))
						imgui.SameLine()
						if imAddon.ToggleButton(u8("##krik"), krik) then
							config.settings.krik = krik.v
							inicfg.save(cfg, config_name)

							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end

						imgui.Text(u8("Миранда"))
						imgui.SameLine()
						if imAddon.ToggleButton(u8("##prava"), prava) then
							config.fastMenuPuncts.prava = prava.v
							inicfg.save(cfg, config_name)

							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end

						imgui.SameLine()
						imgui.Text(u8("Удостоверение"))
						imgui.SameLine()
						if imAddon.ToggleButton(u8("##udo"), udo) then
							config.fastMenuPuncts.udo = udo.v
							inicfg.save(cfg, config_name)

							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end

						imgui.SameLine()
						imgui.Text(u8("Wanted"))
						imgui.SameLine()
						if imAddon.ToggleButton(u8("##wanted"), wanted) then
							config.fastMenuPuncts.wanted = wanted.v
							inicfg.save(cfg, config_name)

							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end
					end
				end
				
				if selectedS == 4 then
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Separator()
					imgui.Dummy(imgui.ImVec2(0, 5))
					imgui.Text(u8("Другие"))
					imgui.Dummy(imgui.ImVec2(0, 5))
					
					imgui.Text(u8("CamHack: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##camHack", camHack) then
						config.settings.camHack = camHack.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Свободный полёт камеры. Активация - C1. Деактивация - C2.\nУправление: WASD, Space, Shift, +, -")
						imgui.EndTooltip()
					end
					
					imgui.Text(u8("Отправлять мои данные (Для статистики скрипта): "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##sendDate", sendDate) then
						config.settings.sendDate = sendDate.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Разработчику отправляется дата запуска скрипта и сервер.\nЭто делается исключительно для статистики скрипта.")
						imgui.EndTooltip()
					end
					
					imgui.Text(u8("Hp HUD: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##enableHpHud", enableHpHud) then
						config.settings.enableHpHud = enableHpHud.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Показывает сколько у Вас брони и HP.")
						imgui.EndTooltip()
					end
					
					if config.settings.enableHpHud then
					imgui.Text(u8("Цвета Hp HUD'a: "))
					imgui.SameLine()
						if imAddon.ToggleButton(u8"##hpHudColored", hpHudColored) then
							config.settings.hpHudColored = hpHudColored.v
							inicfg.save(cfg, config_name)
							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end
						imgui.SameLine()
						imgui.Text(fa.ICON_QUESTION)
						if imgui.IsItemHovered() then
							imgui.BeginTooltip()
							imgui.Text(u8"Цвета Hp HUD'a меняются в зависимости от его значения.\n< 5 - Красный, < 51 - Оранжевый, > 51 - зелёный")
							imgui.EndTooltip()
						end
					end

					
					imgui.Text(u8("Калькулятор в чате: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##enableCalc", enableCalc) then
						config.settings.enableCalc = enableCalc.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Калькулятор в чате.\nПример: Вы написали в строку чата '2+2', и скрипт вывел снизу окно с результатом: 4.")
						imgui.EndTooltip()
					end
					
					imgui.Text(u8("Разделение сообщений: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##seprate", seprate) then
						config.settings.seprate = seprate.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Разделение длинных сообщений для комманд:\n/n, /s, /a, /f, /fn, /r, /rn, /j, /jn.")
						imgui.EndTooltip()
					end

					imgui.Text(u8("Показывать /ad: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##ad", ad) then
						config.settings.showAd = ad.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					imgui.SameLine()
					imgui.Text(fa.ICON_QUESTION)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.Text(u8"Показывать ли серверные /ad")
						imgui.EndTooltip()
					end
					
					imgui.Text(u8("Info-Меню: "))
					imgui.SameLine()
					if imAddon.ToggleButton(u8"##memenu", memenu) then
						config.settings.memenu = memenu.v
						inicfg.save(cfg, config_name)
						if config.settings.sounds then
						setAudioStreamState(soundButton, 0)
						setAudioStreamState(soundButton, 1)
						end
					end
					
					if config.settings.memenu then
						imgui.SameLine()
						imgui.Text(u8("FPS"))
						imgui.SameLine()
						if imAddon.ToggleButton(u8"##showFps", showFps) then
							config.settings.showFps = showFps.v
							inicfg.save(cfg, config_name)
							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end
						imgui.SameLine()
						imgui.Text(u8("Ping"))
						imgui.SameLine()
						if imAddon.ToggleButton(u8"##showPing", showPing) then
							config.settings.showPing = showPing.v
							inicfg.save(cfg, config_name)
							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end
						imgui.SameLine()
						imgui.Text(u8("Time"))
						imgui.SameLine()
						if imAddon.ToggleButton(u8"##showTime", showTime) then
							config.settings.showTime = showTime.v
							inicfg.save(cfg, config_name)
							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end
						imgui.SameLine()
						imgui.Text(u8("ID"))
						imgui.SameLine()
						if imAddon.ToggleButton(u8"##showId", showId) then
							config.settings.showId = showId.v
							inicfg.save(cfg, config_name)
							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end
						imgui.SameLine()
						imgui.Text(u8("Date"))
						imgui.SameLine()
						if imAddon.ToggleButton(u8"##showDate", showDate) then
							config.settings.showDate = showDate.v
							inicfg.save(cfg, config_name)
							if config.settings.sounds then
								setAudioStreamState(soundButton, 0)
								setAudioStreamState(soundButton, 1)
							end
						end
						imgui.SameLine()
						imgui.Text(fa.ICON_QUESTION)
						if imgui.IsItemHovered() then
							imgui.BeginTooltip()
							imgui.Text(u8"Меню с информацией.")
							imgui.EndTooltip()
						end
					end
					
					imgui.TextDisabled(u8("Если у Вас что-либо не работает\nИли хотите предложить идею для обновления - напишите разработчику (telegram - @impachi)!"))
					
				end
				
				
				
				imgui.EndChild()
				end

				
			imgui.EndChild()
			local winWight = 250
			local text = u8("Law Assist from 01.03.26 by impachi")
			local textSize = imgui.CalcTextSize(text)
			imgui.SetCursorScreenPos(imgui.ImVec2(rightX + (winWight - textSize.x) / 2, rightY + 485 + 5))
			imgui.TextDisabled(text)

			

			if not window.v then imgui.ShowCursor = false if config.settings.sounds then setAudioStreamState(soundMenuEnd, 0) setAudioStreamState(soundMenuEnd, 1) end end
			imgui.End()
			imgui.PopStyleColor()
		end
end

function renderNotif()
		if notifWindow.v then
		for i = #notifications, 1, -1 do
			local v = notifications[i]

				local life = os.clock() - v.time

				if life < 0.15 then
					v.alpha = math.min(v.alpha + 0.10, 0.8)
					v.offset = math.max(v.offset - 4, 0)

				elseif life < 2.0 then
					v.alpha = 0.8

				else
					v.alpha = math.max(v.alpha - 0.06, 0.0)
				end

				if life > 2.0 and v.alpha <= 0.01 then
					table.remove(notifications, i)
				end

				imgui.PushStyleVar(imgui.StyleVar.Alpha, v.alpha)

				imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.0, 0.55, 1.0, 1.0))

				imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 8.0)

				imgui.SetNextWindowPos(imgui.ImVec2((170) - (300 / 2), sh - 500 + v.offset), imgui.Cond.Always)

				imgui.SetNextWindowSize(imgui.ImVec2(300, 80))

				imgui.Begin(
					"notif"..i,
					nil,
					imgui.WindowFlags.NoTitleBar +
					imgui.WindowFlags.NoResize +
					imgui.WindowFlags.NoMove +
					imgui.WindowFlags.NoScrollbar +
					imgui.WindowFlags.NoCollapse
				)

				imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 5))
				
				imgui.PushFont(pricedown)
				imgui.Text(u8("Уведомление"))
				imgui.PopFont()
				
				imgui.Text(u8(v.text))
				
				imgui.Dummy(imgui.ImVec2(0, 3.50))
				
				imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(0.0, 0.0, 1.0, 0.5))
				imgui.ProgressBar(life, imgui.ImVec2(280, 5), "##life")
				imgui.PopStyleColor()
				
				imgui.PopStyleVar()
				imgui.End()

				imgui.PopStyleVar(2)
				imgui.PopStyleColor(1)
			end
		end
end

function renderCalc()
	if calcWindow.v then
	    imgui.SetNextWindowSize(imgui.ImVec2(200, 10), imgui.Cond.Always)
		imgui.SetNextWindowPos(imgui.ImVec2(45, 215), imgui.Cond.Always)

		imgui.Begin("Result", window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
		imgui.Text(u8("Результат: " ..result))
		imgui.End()
	end
end

local patrol = false
local function formatTime(sec)
    local hours = math.floor(sec / 3600)
    local minutes = math.floor((sec % 3600) / 60)
    local seconds = math.floor(sec % 60)

    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local timerStart = 0
local timerRunning = false

function renderCar()
	if carMenu.v then
		if not patrol and not isCharInAnyCar(PLAYER_PED) then return end
		
		local myNickName = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		local clean_myNickName = myNickName:gsub("_", " ")
		local myId = getMyId()
		local elapsed = os.clock() - timerStart
		
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh - 10), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 180))
		imgui.Begin(u8("Патруль - " ..carName), nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
		
		if carCombo.v == 0 then 
			comboSelect = "Adam"
		elseif carCombo.v == 1 then
			comboSelect = "Lincoln"
		elseif carCombo.v == 2 then
			comboSelect = "Mary"
		elseif carCombo.v == 3 then
			comboSelect = "Henry"
		elseif carCombo.v == 4 then
			comboSelect = "ASD"
		elseif carCombo.v == 5 then
			comboSelect = "David"
		end
		
		if carComboCode.v == 0 then 
			comboSelectCode = "Code 0"
		elseif carComboCode.v == 1 then
			comboSelectCode = "Code 1"
		elseif carComboCode.v == 2 then
			comboSelectCode = "Code 1-1"
		elseif carComboCode.v == 3 then
			comboSelectCode = "Code 1-4"
		elseif carComboCode.v == 4 then
			comboSelectCode = "Code 4"
		elseif carComboCode.v == 5 then
			comboSelectCode = "Code 5"
		end
		
		imgui.Text(u8("Код:"))
		imgui.PushItemWidth(280)
		imgui.Combo(u8("##carComboCode"), carComboCode, u8("Code 0 - Критическое положение\0Code 1 - Бедственное состояние\0Code 1-1 - Выезд из гаража\0Code 1-4 - Перевозка зад-нного в ПД\0Code 4 - Ситуация под контролем\0Code 5 - Требуется поддержка\0"))
        imgui.PopItemWidth()
		
		imgui.Text(u8("Маркировка: "))
		imgui.PushItemWidth(280)
		imgui.Combo(u8("##carCombo"), carCombo, u8("Adam - Парный (2-3)\0Lincoln - Одиночный\0Mary - Одиночный мото\0Henry - Скоростной (1-2)\0ASD - Воздушный (2)\0David - Platoon D (Wanted)\0"))
        imgui.PopItemWidth()
		
		imgui.Dummy(imgui.ImVec2(0, 5))
		
		if imAddon.ToggleButton(u8"##togglerTakeSu", togglerTakeSu)then
			takeSu = togglerTakeSu.v
			if config.settings.sounds then
				setAudioStreamState(soundButton, 0)
				setAudioStreamState(soundButton, 1)
			end
		end
		imgui.SameLine()
		imgui.Text(fa.ICON_BUG.. u8(" Жучёк"))
		
		if imAddon.ToggleButton(u8"##togglerAutoDoklad", togglerAutoDoklad)then
			autoDoklad = togglerAutoDoklad.v
			if config.settings.sounds then
				setAudioStreamState(soundButton, 0)
				setAudioStreamState(soundButton, 1)
			end
		end
		imgui.SameLine()
		imgui.Text(fa.ICON_PAPER_PLANE.. u8(" Авто доклады"))
		
		imgui.Dummy(imgui.ImVec2(0, 5))
		
		local elapsed = os.clock() - timerStart
		if imgui.Button(u8(patrol and formatTime(elapsed) or "Начать"), imgui.ImVec2(88, 30)) then
			patrol = not patrol

			if patrol then
				timerStart = os.clock()

				sampSendChat("/r Начинаю патруль на " .. carName .. " с маркировкой " .. comboSelect .. ", " .. comboSelectCode .. ", доступен.")
				
				if takeSu then
					local myId = getMyId()
					sampSendChat("/me взял в руки маленький жучёк, активировал его и положил в карман.")
					sampSendChat("/su " .. myId .. " 1 Жучёк")
				end
			else
				local elapsed = os.clock() - timerStart

				sampSendChat("/r Заканчиваю патруль на " .. carName .. " с маркировкой " .. comboSelect .. ", недоступен.")
				sampSendChat("/r Мой патруль длился: " .. formatTime(elapsed))
			end
		end
		
		imgui.SameLine()
		
		if imgui.Button(u8("Доклад"), imgui.ImVec2(88, 30)) then
			sampSendChat("/r Докладывает: " ..clean_myNickName.. ". Патрулирую на " ..carName.. " при маркировке " ..comboSelect.. ", состояние: " ..comboSelectCode)
		end
		
		imgui.SameLine()
		
		if imgui.Button(u8("Промощь"), imgui.ImVec2(88, 30)) then
			sampSendChat("/r Докладывает: " ..clean_myNickName.. ". " ..comboSelectCode.. ", запрашиваю помощь на мой жучёк.")
			if takeSu then
				local myId = getMyId()
				sampSendChat("/me взял в руки маленький жучёк, активировал его и положил в карман.")
				sampSendChat("/su " .. myId .. " 1 Жучёк")
			end
		end
	
		imgui.End()
	end
end

function renderFast()
    if fast.v then
	
			function cmdm1()
			lua_thread.create(function()
				local car = getNearestVehicle(20.0)
				if car ~= -1 then
					local model = getCarModel(car)
					local name = getNameOfVehicleModel(model)

					sampSendChat('/me движением руки включил мегафон.')
					wait(slider.v * 1000)

					if autoDoklad then
						sampSendChat("/r Провожу 10-55, автомобиль " .. name .. ", " .. comboSelectCode .. ", доступен.")
					end

					sampSendChat('/m Внимание! Водитель ' .. name .. "!")
					wait(slider.v * 1000)

					sampSendChat("/m Прижмитесь к обочине, заглушите двигатель.")
					wait(slider.v * 1000)

					sampSendChat("/m В случае неподчинения, вы будете объявлены в Федеральный Розыск!")
				else
					notif("Не найдена ближайшая машина")
				end
			end)
		end


		function cmdm2()
			lua_thread.create(function()
				local car = getNearestVehicle(20.0)
				if car ~= -1 then
					local model = getCarModel(car)
					local name = getNameOfVehicleModel(model)

					sampSendChat('/me движением руки включил мегафон.')
					wait(slider.v * 1000)

					if autoDoklad then
						sampSendChat("/r Провожу 10-66, автомобиль " .. name .. ", " .. comboSelectCode .. ", доступен.")
					end

					sampSendChat('/m Внимание! Водитель ' .. name .. "!")
					wait(slider.v * 1000)

					sampSendChat("/m Прижмитесь к обочине, заглушите двигатель...")
					wait(slider.v * 1000)

					sampSendChat("/m После чего выйдите из транспортного средства с поднятыми руками")
					wait(slider.v * 1000)

					sampSendChat("/m В случае неподчинения, по Вам будет открыт огонь на поражение.")
				else
					notif("Не найдена ближайшая машина")
				end
			end)
		end


		function cmdmr()
			lua_thread.create(function()
				sampSendChat('Вы имеете право хранить молчание.')
				wait(slider.v * 1000)

				sampSendChat('Все, что вы скажете, может быть использовано против вас в суде.')
				wait(slider.v * 1000)

				sampSendChat('Ваш адвокат может присутствовать при допросе.')
				wait(slider.v * 1000)

				sampSendChat('Если вы не можете оплатить услуги адвоката, он будет предоставлен вам государством.')
				wait(slider.v * 1000)

				sampSendChat('Вам ясны ваши права?')
			end)
		end
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.1, 0.1, 0.1, 0))

		imgui.SetNextWindowPos(
			imgui.ImVec2(sw / 2, sh / 2),
			imgui.Cond.FirstUseEver,
			imgui.ImVec2(0.5, 0.5)
		)

		imgui.SetNextWindowSize(imgui.ImVec2(450, 200), imgui.Cond.Always)

		imgui.Begin(
			u8("Быстрое меню"),
			fast,
			imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove
		)

		imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 7)

		local c = config.fastMenuPuncts
		local size = imgui.ImVec2(100, 80)

		local function btn(cond, text, cb)
			if cond then
				if imgui.Button(text, size) then
					cb()
					fast.v = false
					imgui.ShowCursor = false
				end
				return true
			else
				imgui.Dummy(size)
				return false
			end
		end

		btn(c.megaphone, u8("10-55"), cmdm1) imgui.SameLine()
		btn(c.twoMegaphone, u8("10-66"), cmdm2) imgui.SameLine()
		btn(c.krik, u8("Крик"), function()
			sampSendChat("/s Всем оставаться на своих местах, без резких движений!")
		end) imgui.SameLine()
		btn(c.prava, u8("Миранда"), cmdmr)

		btn(false, "", function() end) imgui.SameLine()
		btn(c.wanted, u8("Wanted"), function()
			sampSendChat("/wanted 1")
		end) imgui.SameLine()
		btn(c.udo, u8("Удостоверение"), cmd_udo) imgui.SameLine()
		btn(false, "", function() end)

		imgui.PopStyleVar()
		imgui.End()
		imgui.PopStyleColor()
	end
end

function renderTickAndSusAndOther()
	updateFps()

		if config.settings.memenu and memenu.v then
			imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.7))
			imgui.SetNextWindowPos(imgui.ImVec2(resX - 260, resY - 173), imgui.Cond.Always)
			imgui.SetNextWindowSize(imgui.ImVec2(250, 165), imgui.Cond.FirstUseEver)
			imgui.Begin(u8("Menu"), memenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
			
			local myId = getMyId()
			local ping = myId and sampGetPlayerPing(myId) or 0
			
			imgui.Center1Text(fa.ICON_BELL.. "          Law Mobile          " ..fa.ICON_BELL)
			imgui.Dummy(imgui.ImVec2(0, 5))
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 5))
			
			if myId then
			imgui.PushFont(pricedown)
				if config.settings.showId then
					imgui.CenterText(u8("ID: " ..myId))
				end
				if config.settings.showFps then
					imgui.CenterText(u8("FPS: " ..cachedFps))
				end
				if config.settings.showPing then
					imgui.CenterText(u8("PING: " ..ping))
				end
				if config.settings.showTime then
					imgui.CenterText(u8("TIME: " ..os.date("%H:%M:%S")))
				end
				if config.settings.showDate then
					imgui.CenterText(u8("DATE: " ..os.date("%d.%m.%Y")))
				end
			else
				imgui.Text(u8("Loading..."))
			end
			imgui.PopFont()
			
			imgui.End()
			imgui.PopStyleColor()
		end
		if windowTick.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(730, 500), imgui.Cond.Always)
		imgui.Begin(fa.ICON_LIST.. u8(" Умные штрафы ") ..fa.ICON_LIST, windowTick, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		
        imgui.InputText(u8(" Поиск ") ..fa.ICON_SEARCH, search)
		
		imgui.Dummy(imgui.ImVec2(0, 5))
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 5))
		
		imgui.TextDisabled(u8("Примечание: Выберите нужную статью и после чего нажмите на нужный пункт."))
		
		imgui.Dummy(imgui.ImVec2(0, 5))
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 5))
		
        for k, v in ipairs(collapsing2) do
            if u8:decode(search.v) ~= 0 and string.nlower(v.name):find(string.nlower(u8:decode(search.v))) then
                if imgui.CollapsingHeader(u8(v.name)) then
                    v.body()
                end
            end
        end

		if not windowTick.v then imgui.ShowCursor = false if config.settings.sounds then setAudioStreamState(soundMenuEnd, 0) setAudioStreamState(soundMenuEnd, 1) end end
		imgui.End()
	end
	
	if windowSus.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(730, 500), imgui.Cond.Always)
		imgui.Begin(fa.ICON_STAR.. u8(" Умный розыск ") ..fa.ICON_STAR, windowSus, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		
        imgui.InputText(u8(" Поиск ") ..fa.ICON_SEARCH, search)
		
		imgui.Dummy(imgui.ImVec2(0, 5))
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 5))
		
		imgui.TextDisabled(u8("Примечание: Выберите нужную главу и после чего нажмите на нужную статью."))
		
		imgui.Dummy(imgui.ImVec2(0, 5))
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 5))
		
        for k, v in ipairs(collapsing) do
            if u8:decode(search.v) ~= 0 and string.nlower(v.name):find(string.nlower(u8:decode(search.v))) then
                if imgui.CollapsingHeader(u8(v.name)) then
                    v.body()
                end
            end
        end

		if not windowSus.v then imgui.ShowCursor = false if config.settings.sounds then setAudioStreamState(soundMenuEnd, 0) setAudioStreamState(soundMenuEnd, 1) end end
		imgui.End()
	end
end

function imgui.OnDrawFrame()
	if not isSampAvailable() or not doesCharExist(PLAYER_PED) then return end
	
	renderWindow()
	renderFast()
	renderNotif()
	renderCalc()
	renderCar()
	renderTickAndSusAndOther()
end

function sampev.onServerMessage(color, text)
	if text:find("| Отправил ") and config.settings.showAd == false then
		return false
	end
	
	if text:find("Объявление проверил сотрудник СМИ") and config.settings.showAd == false then
		return false
	end
end

local accentToggle = false

function sampev.onSendChat(message)
    if accent.v then
		if not message:find("^[A-zА-я0-9]") or message == 'xD' or message == 'XD' then return{message} end

        accentToggle = not accentToggle

        local prefix = accentToggle and " " or "-"

        return {
            prefix .. ' [' .. u8:decode(accenttext.v) .. ']: ' .. message
        }
    end
end

function imgui.ButtonHex(lable, rgb, size)
    local r = bit.band(bit.rshift(rgb, 16), 0xFF) / 255
    local g = bit.band(bit.rshift(rgb, 8), 0xFF) / 255
    local b = bit.band(rgb, 0xFF) / 255

    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, 0.6))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, 0.8))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, 1.0))
    local button = imgui.Button(lable, size)
    imgui.PopStyleColor(3) 
    return button
end

function imguiSettings()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
  
    style.WindowPadding = ImVec2(10, 10)
    style.WindowRounding = 8.0
    style.FramePadding = ImVec2(8, 4)
    style.FrameRounding = 8.0
    style.ItemSpacing = ImVec2(8, 2)
    style.ItemInnerSpacing = ImVec2(1, 1)
    style.TouchExtraPadding = ImVec2(0, 0)
    style.IndentSpacing = 10.0
    style.ScrollbarSize = 12.0
    style.ScrollbarRounding = 16.0
    style.GrabMinSize = 20.0
    style.GrabRounding = 20.0
  
    style.WindowTitleAlign = ImVec2(0.5, 0.5)
end

imguiSettings()

function checkOther()
if isKeyJustPressed(0x31) and not sampIsChatInputActive() and not sampIsDialogActive() and config.settings.fastMenu then
			fast.v = not fast.v
			imgui.ShowCursor = fast.v
		end
		
		if isKeyDown(0x02) and isKeyJustPressed(0x51) and config.settings.fastMenuP then
			local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if valid and doesCharExist(ped) then
				local result, id = sampGetPlayerIdByCharHandle(ped)
				if result then
					LAW_TARGET = id
					LAW_DIALOG = true
					local nick = string.gsub(sampGetPlayerNickname(id), '_', ' ')
					sampShowDialog(9999, "{1D5DEC}Law Assist - " ..nick,
                "Надеть наручники\nСнять наручники\nВести за собой\nПосадить в машину\nПровести обыск\nВыдать пропуск в здания МВД",
                "Выбрать", "Закрыть", 2)
				end
			end
		end

		local result, button, list, input = sampHasDialogRespond(9999)
		if result then
			if button == 1 and LAW_TARGET then
				local id = LAW_TARGET
				local nick = string.gsub(sampGetPlayerNickname(id), '_', ' ')
				if list == 0 then
					lua_thread.create(function()
					sampSendChat("/me протянул правую руку к поясу, аккуратно снял наручники, после чего поднес их к рукам " .. nick .. ".")
					wait(slider.v * 1000)
					sampSendChat("/me стянул наручники, тем самым схлопнув их вместе.")
					wait(slider.v * 1000)
					sampSendChat("/cuff " .. id)
					end)

				elseif list == 1 then
					lua_thread.create(function()
					sampSendChat("/me протянул руку вперед, расстегнул наручники.")
					wait(slider.v * 1000)
					sampSendChat("/me снял наручники с рук " .. nick .. ", затем повесил их на поясной держатель.")
					sampSendChat("/uncuff " .. id)
					end)

				elseif list == 2 then
					lua_thread.create(function()
					sampSendChat("/me схватил " .. nick .. " и потащил его перед собой.")
					wait(slider.v * 1000)
					sampSendChat("/hold " .. id)
					end)

				elseif list == 3 then
					lua_thread.create(function()
					sampSendChat("/me открыл дверь полицейского крузера, посадил туда " .. nick .. ".")
					wait(slider.v * 1000)
					sampSendChat("/putpl " .. id)
					wait(slider.v * 1000)
					sampSendChat("/me закрыл дверь")
					end)
					
				elseif list == 4 then
					lua_thread.create(function()
					sampSendChat("/me засунул руки в карман, достал пару резиновых перчаток, натянул их на руки.")
					wait(slider.v * 1000)
					sampSendChat("/me вытянул руку перед собой, начал обшлёпывать человека напротив.")
					wait(slider.v * 1000)
					sampSendChat("/me наклонился, начал обыскивать нижние части тела человека напротив.")
					wait(slider.v * 1000)
					sampSendChat("/search "..id.." Не указана")
					end)

				elseif list == 5 then
					lua_thread.create(function()
					sampSendChat("/me достал пустой пропуск в здания МВД, достал ручку")
					wait(slider.v * 1000)
					sampSendChat("/me заполнил пропуск и отдал его " .. nick .. ".")
					wait(slider.v * 1000)
					sampSendChat("/skip " .. id)
					end)
			end
		end
	end
end

function checkCalc()
		if sampIsChatInputActive() then

            local text = sampGetChatInputText()

            if text and text ~= "" and isExpression(text) then
                local res = calc(text)

                if res ~= nil then
                    result = tostring(res)
                    if config.settings.enableCalc then show = true calcWindow.v = true end
                else
                    show = false
					calcWindow.v = false
                end
            else
                show = false
				calcWindow.v = false
            end
        else
            show = false
            calcWindow.v = false
        end
end

function checkDialog()
		    if sampIsDialogActive() then
            local id = sampGetCurrentDialogId()

            if id ~= last and config.settings.showDialogID then
                last = id
				notif("ID показанного диалога: " ..id)
				if config.settings.sounds then
					setAudioStreamState(soundMenu, 0)
					setAudioStreamState(soundMenu, 1)
				end
            end
        else
            last = -1
        end
end

function checkFrac()
		if not sent and sampIsLocalPlayerSpawned() then
            sent = true
			notif("Получение данных о фракции...")
			addLog("Выполняется получаение данных о Вашей фракции..")
            sampSendChat("/mn 1")
			wait(500)
			setVirtualKeyDown(13, true)
			setVirtualKeyDown(13, false)
			addLog("Данные успешно получены.")
			notif("Данные получены!")
			if config.settings.sendDate then
				sendLog()
			end
        end
end

function checkTheme()
		   imgui.SwitchContext()
			local style = imgui.GetStyle()
			local colors = style.Colors
			local clr = imgui.Col
			local ImVec4 = imgui.ImVec4
			local ImVec2 = imgui.ImVec2

			if config.settings.theme == 1 then
				colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
				colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
				colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
				colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
				colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
				colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
				colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
				colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
				colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
				colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
				colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
				colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
				colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
				colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
				colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
				colors[clr.Separator]              = colors[clr.Border]
				colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
				colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
				colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
				colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
				colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
				colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
				colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
				colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
				colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.98)
				colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
				colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
				colors[clr.ComboBg]                = colors[clr.PopupBg]
				colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
				colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.20)
				colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
				colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
				colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
				colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
				colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
				colors[clr.CloseButton]            = ImVec4(0.16, 0.29, 0.48, 1.0)
				colors[clr.CloseButtonHovered]     = ImVec4(0.16, 0.29, 0.48, 1.0)
				colors[clr.CloseButtonActive]      = ImVec4(0.16, 0.29, 0.48, 1.0)
				colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
				colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
				colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
				colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
				colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
			elseif config.settings.theme == 2 then
				colors[clr.Text] = ImVec4(0.00, 1.00, 1.00, 1.00)
				colors[clr.TextDisabled] = ImVec4(0.00, 0.40, 0.41, 1.00)
				colors[clr.WindowBg] = ImVec4(0.00, 0.00, 0.00, 1.00)
				colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
				colors[clr.Border] = ImVec4(0.00, 1.00, 1.00, 0.65)
				colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
				colors[clr.FrameBg] = ImVec4(0.44, 0.80, 0.80, 0.18)
				colors[clr.FrameBgHovered] = ImVec4(0.44, 0.80, 0.80, 0.27)
				colors[clr.FrameBgActive] = ImVec4(0.44, 0.81, 0.86, 0.66)
				colors[clr.TitleBg] = ImVec4(0.14, 0.18, 0.21, 0.73)
				colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.54)
				colors[clr.TitleBgActive] = ImVec4(0.00, 1.00, 1.00, 0.27)
				colors[clr.MenuBarBg] = ImVec4(0.00, 0.00, 0.00, 0.20)
				colors[clr.ScrollbarBg] = ImVec4(0.22, 0.29, 0.30, 0.71)
				colors[clr.ScrollbarGrab] = ImVec4(0.00, 1.00, 1.00, 0.44)
				colors[clr.ScrollbarGrabHovered] = ImVec4(0.00, 1.00, 1.00, 0.74)
				colors[clr.ScrollbarGrabActive] = ImVec4(0.00, 1.00, 1.00, 1.00)
				colors[clr.ComboBg] = ImVec4(0.16, 0.24, 0.22, 0.60)
				colors[clr.CheckMark] = ImVec4(0.00, 1.00, 1.00, 0.68)
				colors[clr.SliderGrab] = ImVec4(0.00, 1.00, 1.00, 0.36)
				colors[clr.SliderGrabActive] = ImVec4(0.00, 1.00, 1.00, 0.76)
				colors[clr.Button] = ImVec4(0.00, 0.65, 0.65, 0.46)
				colors[clr.ButtonHovered] = ImVec4(0.01, 1.00, 1.00, 0.43)
				colors[clr.ButtonActive] = ImVec4(0.00, 1.00, 1.00, 0.62)
				colors[clr.Header] = ImVec4(0.00, 1.00, 1.00, 0.33)
				colors[clr.HeaderHovered] = ImVec4(0.00, 1.00, 1.00, 0.42)
				colors[clr.HeaderActive] = ImVec4(0.00, 1.00, 1.00, 0.54)
				colors[clr.ResizeGrip] = ImVec4(0.00, 1.00, 1.00, 0.54)
				colors[clr.ResizeGripHovered] = ImVec4(0.00, 1.00, 1.00, 0.74)
				colors[clr.ResizeGripActive] = ImVec4(0.00, 1.00, 1.00, 1.00)
				colors[clr.CloseButton] = ImVec4(0.00, 0.78, 0.78, 0.35)
				colors[clr.CloseButtonHovered] = ImVec4(0.00, 0.78, 0.78, 0.47)
				colors[clr.CloseButtonActive] = ImVec4(0.00, 0.78, 0.78, 1.00)
				colors[clr.PlotLines] = ImVec4(0.00, 1.00, 1.00, 1.00)
				colors[clr.PlotLinesHovered] = ImVec4(0.00, 1.00, 1.00, 1.00)
				colors[clr.PlotHistogram] = ImVec4(0.00, 1.00, 1.00, 1.00)
				colors[clr.PlotHistogramHovered] = ImVec4(0.00, 1.00, 1.00, 1.00)
				colors[clr.TextSelectedBg] = ImVec4(0.00, 1.00, 1.00, 0.22)
				colors[clr.ModalWindowDarkening] = ImVec4(0.04, 0.10, 0.09, 0.51)
			elseif config.settings.theme == 3 then
				colors[clr.FrameBg]                = ImVec4(0.42, 0.48, 0.16, 0.54)
				colors[clr.FrameBgHovered]         = ImVec4(0.85, 0.98, 0.26, 0.40)
				colors[clr.FrameBgActive]          = ImVec4(0.85, 0.98, 0.26, 0.67)
				colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
				colors[clr.TitleBgActive]          = ImVec4(0.42, 0.48, 0.16, 1.00)
				colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
				colors[clr.CheckMark]              = ImVec4(0.85, 0.98, 0.26, 1.00)
				colors[clr.SliderGrab]             = ImVec4(0.77, 0.88, 0.24, 1.00)
				colors[clr.SliderGrabActive]       = ImVec4(0.85, 0.98, 0.26, 1.00)
				colors[clr.Button]                 = ImVec4(0.85, 0.98, 0.26, 0.40)
				colors[clr.ButtonHovered]          = ImVec4(0.85, 0.98, 0.26, 1.00)
				colors[clr.ButtonActive]           = ImVec4(0.82, 0.98, 0.06, 1.00)
				colors[clr.Header]                 = ImVec4(0.85, 0.98, 0.26, 0.31)
				colors[clr.HeaderHovered]          = ImVec4(0.85, 0.98, 0.26, 0.80)
				colors[clr.HeaderActive]           = ImVec4(0.85, 0.98, 0.26, 1.00)
				colors[clr.Separator]              = colors[clr.Border]
				colors[clr.SeparatorHovered]       = ImVec4(0.63, 0.75, 0.10, 0.78)
				colors[clr.SeparatorActive]        = ImVec4(0.63, 0.75, 0.10, 1.00)
				colors[clr.ResizeGrip]             = ImVec4(0.85, 0.98, 0.26, 0.25)
				colors[clr.ResizeGripHovered]      = ImVec4(0.85, 0.98, 0.26, 0.67)
				colors[clr.ResizeGripActive]       = ImVec4(0.85, 0.98, 0.26, 0.95)
				colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
				colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
				colors[clr.TextSelectedBg]         = ImVec4(0.85, 0.98, 0.26, 0.35)
				colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
				colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
				colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
				colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
				colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
				colors[clr.ComboBg]                = colors[clr.PopupBg]
				colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
				colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
				colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
				colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
				colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
				colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
				colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
				colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
				colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
				colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
				colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
				colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
				colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
			elseif config.settings.theme == 4 then
				colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
				colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
				colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
				colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
				colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
				colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
				colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
				colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
				colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
				colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
				colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
				colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
				colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
				colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
				colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
				colors[clr.Separator]              = colors[clr.Border]
				colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
				colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
				colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
				colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
				colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
				colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
				colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
				colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
				colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
				colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
				colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
				colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
				colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
				colors[clr.ComboBg]                = colors[clr.PopupBg]
				colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
				colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
				colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
				colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
				colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
				colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
				colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
				colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
				colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
				colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
				colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
				colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
				colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
			elseif config.settings.theme == 5 then
				colors[clr.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54)
				colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40)
				colors[clr.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67)
				colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
				colors[clr.TitleBgActive]          = ImVec4(0.48, 0.23, 0.16, 1.00)
				colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
				colors[clr.CheckMark]              = ImVec4(0.98, 0.43, 0.26, 1.00)
				colors[clr.SliderGrab]             = ImVec4(0.88, 0.39, 0.24, 1.00)
				colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.43, 0.26, 1.00)
				colors[clr.Button]                 = ImVec4(0.98, 0.43, 0.26, 0.40)
				colors[clr.ButtonHovered]          = ImVec4(0.98, 0.43, 0.26, 1.00)
				colors[clr.ButtonActive]           = ImVec4(0.98, 0.28, 0.06, 1.00)
				colors[clr.Header]                 = ImVec4(0.98, 0.43, 0.26, 0.31)
				colors[clr.HeaderHovered]          = ImVec4(0.98, 0.43, 0.26, 0.80)
				colors[clr.HeaderActive]           = ImVec4(0.98, 0.43, 0.26, 1.00)
				colors[clr.Separator]              = colors[clr.Border]
				colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.25, 0.10, 0.78)
				colors[clr.SeparatorActive]        = ImVec4(0.75, 0.25, 0.10, 1.00)
				colors[clr.ResizeGrip]             = ImVec4(0.98, 0.43, 0.26, 0.25)
				colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.43, 0.26, 0.67)
				colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.43, 0.26, 0.95)
				colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
				colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.50, 0.35, 1.00)
				colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.43, 0.26, 0.35)
				colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
				colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
				colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
				colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
				colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
				colors[clr.ComboBg]                = colors[clr.PopupBg]
				colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
				colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
				colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
				colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
				colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
				colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
				colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
				colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
				colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
				colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
				colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
				colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
				colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
			elseif config.settings.theme == 6 then
				colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
				colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
				colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
				colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
				colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
				colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
				colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
				colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
				colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
				colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
				colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
				colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
				colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
				colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
				colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
				colors[clr.Separator]              = colors[clr.Border]
				colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
				colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
				colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
				colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
				colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
				colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
				colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
				colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
				colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
				colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
				colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
				colors[clr.ComboBg]                = colors[clr.PopupBg]
				colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
				colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
				colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
				colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
				colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
				colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
				colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
				colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
				colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
				colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
				colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
				colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
				colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
				colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
				colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
			elseif config.settings.theme == 7 then
			      colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
				  colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
				  colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
				  colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
				  colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
				  colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
				  colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
				  colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
				  colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
				  colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
				  colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
				  colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
				  colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
				  colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
				  colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
				  colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
				  colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
				  colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
				  colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
				  colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
				  colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
				  colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
				  colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
				  colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
				  colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
				  colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
				  colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
				  colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
				  colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
				  colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
				  colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
				  colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
				  colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
				  colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
				  colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
				  colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
				  colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
				  colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
				  colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
				  colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
			elseif config.settings.theme == 8 then
					colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.07, 1.00)
					colors[clr.ChildWindowBg]         = ImVec4(0.06, 0.06, 0.07, 1.00)
					colors[clr.PopupBg]               = ImVec4(0.08, 0.08, 0.09, 0.98)
					colors[clr.ComboBg]               = colors[clr.PopupBg]
					colors[clr.Text]                  = ImVec4(1.00, 1.00, 1.00, 1.00)
					colors[clr.TextDisabled]          = ImVec4(0.55, 0.55, 0.55, 1.00)
					colors[clr.TextSelectedBg]        = ImVec4(0.20, 0.20, 0.22, 0.60)
					colors[clr.FrameBg]               = ImVec4(0.10, 0.10, 0.11, 1.00)
					colors[clr.FrameBgHovered]        = ImVec4(0.14, 0.14, 0.16, 1.00)
					colors[clr.FrameBgActive]         = ImVec4(0.18, 0.18, 0.20, 1.00)
					colors[clr.Button]                = ImVec4(0.10, 0.10, 0.11, 1.00)
					colors[clr.ButtonHovered]         = ImVec4(0.16, 0.16, 0.18, 1.00)
					colors[clr.ButtonActive]          = ImVec4(0.22, 0.22, 0.24, 1.00)
					colors[clr.CloseButton] = ImVec4(0.10, 0.10, 0.11, 1.00)
				    colors[clr.CloseButtonHovered] = ImVec4(0.16, 0.16, 0.18, 1.00)
				    colors[clr.CloseButtonActive] = ImVec4(0.22, 0.22, 0.24, 1.00)
					colors[clr.TitleBg]               = ImVec4(0.05, 0.05, 0.06, 1.00)
					colors[clr.TitleBgActive]         = ImVec4(0.08, 0.08, 0.10, 1.00)
					colors[clr.TitleBgCollapsed]      = ImVec4(0.03, 0.03, 0.03, 0.80)
					colors[clr.Border]                = ImVec4(0.18, 0.18, 0.20, 0.60) 
					colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00)
					colors[clr.CheckMark]             = ImVec4(0.90, 0.90, 0.90, 1.00)
					colors[clr.SliderGrab]            = ImVec4(0.25, 0.25, 0.27, 1.00)
					colors[clr.SliderGrabActive]      = ImVec4(0.35, 0.35, 0.38, 1.00)
					colors[clr.Header]                = ImVec4(0.10, 0.10, 0.11, 1.00)
					colors[clr.HeaderHovered]         = ImVec4(0.16, 0.16, 0.18, 1.00)
					colors[clr.HeaderActive]          = ImVec4(0.22, 0.22, 0.24, 1.00)
					colors[clr.ScrollbarBg]           = ImVec4(0.05, 0.05, 0.06, 1.00)
					colors[clr.ScrollbarGrab]         = ImVec4(0.20, 0.20, 0.22, 1.00)
					colors[clr.ScrollbarGrabHovered]  = ImVec4(0.28, 0.28, 0.30, 1.00)
					colors[clr.ScrollbarGrabActive]   = ImVec4(0.35, 0.35, 0.38, 1.00)
					colors[clr.Separator]             = ImVec4(0.18, 0.18, 0.20, 1.00)
					colors[clr.SeparatorHovered]      = ImVec4(0.25, 0.25, 0.27, 1.00)
					colors[clr.SeparatorActive]       = ImVec4(0.30, 0.30, 0.33, 1.00)
					colors[clr.ResizeGrip]            = ImVec4(0.18, 0.18, 0.20, 0.50)
					colors[clr.ResizeGripHovered]     = ImVec4(0.25, 0.25, 0.28, 0.80)
					colors[clr.ResizeGripActive]      = ImVec4(0.30, 0.30, 0.33, 1.00)
					colors[clr.PlotLines]             = ImVec4(0.60, 0.60, 0.60, 1.00)
					colors[clr.PlotLinesHovered]      = ImVec4(0.90, 0.90, 0.90, 1.00)
					colors[clr.PlotHistogram]         = ImVec4(0.50, 0.50, 0.52, 1.00)
					colors[clr.PlotHistogramHovered]  = ImVec4(0.70, 0.70, 0.72, 1.00)
					colors[clr.ModalWindowDarkening]  = ImVec4(0.00, 0.00, 0.00, 0.60)
			end
end

function checkHpHud()
	if config.settings.enableHpHud then
				useRenderCommands(true)
				setTextCentre(true)
				setTextScale(0.3, 0.7)
				local hp = getCharHealth(PLAYER_PED)
				if config.settings.hpHudColored then
					if hp < 5 then
						setTextColour(255, 0, 0, 255)
					elseif hp < 51 then
						setTextColour(255, 165, 0, 255)
					else
						setTextColour(0, 255, 0, 255)
					end
				else
					setTextColour(255, 255, 255, 255)
				end
				setTextEdge(1, 0, 0, 0, 255)
				displayTextWithNumber(578.0, 68.0, 'NUMBER', getCharHealth(PLAYER_PED))
				if getCharArmour(PLAYER_PED) > 0 then
					setTextCentre(true)
					setTextScale(0.3, 0.7)
					local armor = getCharArmour(PLAYER_PED)
					if config.settings.hpHudColored then
						if armor < 5 then
							setTextColour(255, 0, 0, 255)
						elseif armor < 51 then
							setTextColour(255, 165, 0, 255)
						else
							setTextColour(0, 255, 0, 255)
						end
					else
						setTextColour(255, 255, 255, 255)
					end
					setTextEdge(1, 0, 0, 0, 255)
					displayTextWithNumber(578.0, 46.0, 'NUMBER', getCharArmour(PLAYER_PED))
				end
			end
end

function checkCamHack()
		time = time + 1
		if isKeyDown(VK_C) and isKeyDown(VK_1) and config.settings.camHack then
			if flymode == 0 then
				displayRadar(false)
				displayHud(false)	    
				posX, posY, posZ = getCharCoordinates(playerPed)
				angZ = getCharHeading(playerPed)
				angZ = angZ * -1.0
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
				angY = 0.0
				lockPlayerControl(true)
				flymode = 1
			end
		end
		if flymode == 1 and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
			offMouX, offMouY = getPcMouseMovement()  
			  
			offMouX = offMouX / 4.0
			offMouY = offMouY / 4.0
			angZ = angZ + offMouX
			angY = angY + offMouY

			if angZ > 360.0 then angZ = angZ - 360.0 end
			if angZ < 0.0 then angZ = angZ + 360.0 end

			if angY > 89.0 then angY = 89.0 end
			if angY < -89.0 then angY = -89.0 end   

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0        
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2)

			curZ = angZ + 180.0
			curY = angY * -1.0      
			radZ = math.rad(curZ) 
			radY = math.rad(curY)                   
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 10.0     
			cosZ = cosZ * 10.0       
			sinY = sinY * 10.0                       
			posPlX = posX + sinZ 
			posPlY = posY + cosZ 
			posPlZ = posZ + sinY              
			angPlZ = angZ * -1.0

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0        
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2)

			if isKeyDown(VK_W) then      
				radZ = math.rad(angZ) 
				radY = math.rad(angY)                   
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * speed      
				cosZ = cosZ * speed       
				sinY = sinY * speed  
				posX = posX + sinZ 
				posY = posY + cosZ 
				posZ = posZ + sinY      
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0         
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2)

			if isKeyDown(VK_S) then  
				curZ = angZ + 180.0
				curY = angY * -1.0      
				radZ = math.rad(curZ) 
				radY = math.rad(curY)                   
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * speed      
				cosZ = cosZ * speed       
				sinY = sinY * speed                       
				posX = posX + sinZ 
				posY = posY + cosZ 
				posZ = posZ + sinY      
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0        
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2)
			  
			if isKeyDown(VK_A) then  
				curZ = angZ - 90.0
				radZ = math.rad(curZ)
				radY = math.rad(angY)
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)
				sinZ = sinZ * speed
				cosZ = cosZ * speed
				posX = posX + sinZ
				posY = posY + cosZ
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0        
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY
			pointCameraAtPoint(poiX, poiY, poiZ, 2)       

			if isKeyDown(VK_D) then  
				curZ = angZ + 90.0
				radZ = math.rad(curZ)
				radY = math.rad(angY)
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)       
				sinZ = sinZ * speed
				cosZ = cosZ * speed
				posX = posX + sinZ
				posY = posY + cosZ      
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0        
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2)   

			if isKeyDown(VK_SPACE) then  
				posZ = posZ + speed
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0       
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2) 

			if isKeyDown(VK_SHIFT) then  
				posZ = posZ - speed
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0       
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2) 

			if keyPressed == 0 and isKeyDown(VK_F10) then
				keyPressed = 1
				if radarHud == 0 then
					displayRadar(true)
					displayHud(true)
					radarHud = 1
				else
					displayRadar(false)
					displayHud(false)
					radarHud = 0
				end
			end

			if wasKeyReleased(VK_F10) and keyPressed == 1 then keyPressed = 0 end

			if isKeyDown(187) then 
				speed = speed + 0.01
				printStringNow(speed, 1000)
			end 
			               
			if isKeyDown(189) then 
				speed = speed - 0.01 
				if speed < 0.01 then speed = 0.01 end
				printStringNow(speed, 1000)
			end   

			if isKeyDown(VK_C) and isKeyDown(VK_2) then
				displayRadar(true)
				displayHud(true)
				radarHud = 0	    
				angPlZ = angZ * -1.0
				lockPlayerControl(false)
				restoreCameraJumpcut()
				setCameraBehindPlayer()
				flymode = 0     
			end
		end
end

function cmd_cuff(arg)
		if tonumber(arg) == nil then
			notif("Использование: /cuff [ID]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		else
			lua_thread.create(function()
			id = arg
			nick = sampGetPlayerNickname(id)
			clean_nick = nick:gsub("_", " ")
			sampSendChat('/me схватился за руки подозреваемого, затем нащупал на поясе наручники и...')
			wait(slider.v * 1000)
			sampSendChat('/me ...вытащив их из подсумка, нацепил на ' ..clean_nick.. ".")
			wait(slider.v * 1000)
			sampSendChat('/cuff '..id)
			addLog("Надевание наручников на " ..clean_nick)
		end)
	end
end

function cmd_setmark(arg)
		if tonumber(arg) == nil then
			notif("Использование: /setmark (/sm) [ID]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		else
			lua_thread.create(function()
			id = arg
			nick = sampGetPlayerNickname(id)
			clean_nick = nick:gsub("_", " ")
			
			sampSendChat('/do В машине стоит маленький нотбук с открытой базой данных ' ..department.. ".")
			wait(slider.v * 1000)
			sampSendChat("/me потянулся к ноутбуку, вбил запрос: " ..clean_nick.. ".")
			wait(slider.v * 1000)
			sampSendChat('/setmark '..id)
			sampSendChat("/do На экран выведено точное местоположение преступника.")
			wait(slider.v * 1000)
			addLog("Исполнение /setmark (/sm) на " ..clean_nick)
		end)
	end
end

function cmd_uncuff(arg)
		if tonumber(arg) == nil then
			notif("Использование: /uncuff [ID]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		else
			lua_thread.create(function()
			id = arg
			nick = sampGetPlayerNickname(id)
			clean_nick = nick:gsub("_", " ")
			sampSendChat("/me протянул руку вперед, расстегнул наручники.")
			wait(slider.v * 1000)
			sampSendChat("/me снял наручники с рук " .. clean_nick .. ", затем повесил их на поясной держатель.")
			wait(slider.v * 1000)
			sampSendChat('/uncuff '..id)
			addLog("Снятие наручников с " ..clean_nick)
		end)
	end
end

function cmd_hold(arg)
		if tonumber(arg) == nil then
			notif("Использование: /hold [ID]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		else
			lua_thread.create(function()
			id = arg
			nick = sampGetPlayerNickname(id)
			clean_nick = nick:gsub("_", " ")
			sampSendChat('/me схватил ' ..clean_nick.. " за руки и потащил его перед собой.")
			wait(slider.v * 1000)
			sampSendChat('/hold '..id)
			addLog("Ведение " ..clean_nick.. " за собой")
		end)
	end
end

function cmd_arrest(arg)
		if arg == "" then
			notif("Использование: /arrest [ID] [Причина]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
			return
		end

		local id, reason = arg:match("^(%d+)%s+(.+)$")
		id = tonumber(id)

		if not id or not reason then
			notif("Использование: /arrest [ID] [Причина]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
			return
		end

		nick = sampGetPlayerNickname(id)
		clean_nick = nick:gsub("_", " ")

		lua_thread.create(function()
			sampSendChat("/do Нарушитель сидит на пасажирском сидении полицейского крузера.")
			wait(slider.v * 1000)
			sampSendChat("/me взял блакнот и ручку, начал вписывать в блакнот какую-то информацию...")
			wait(slider.v * 1000)
			sampSendChat("/do Информация была успешно заполнена.")
			wait(slider.v * 1000)
			sampSendChat("/me заполнив информацию, вызвал охрану ИК, после чего передал " .. clean_nick .. " охране.")
			wait(slider.v * 1000)
			sampSendChat("/arrest " .. id .. " " .. reason)
			addLog("Передача " ..clean_nick.. " в ИК")
		end)
end

function cmd_m1()
lua_thread.create(function()
	local car = getNearestVehicle(20.0)
	if car ~= -1 then
		local model = getCarModel(car)
		local name = getNameOfVehicleModel(model)
		sampSendChat('/me движением руки включил мегафон.')
		wait(slider.v * 1000)
		if autoDoklad then
			sampSendChat("/r Провожу 10-66, автомобиль " ..name.. ", " ..comboSelectCode.. ", доступен.")
		end
		sampSendChat('/m Внимание! Водитель ' ..name.. "!")
		wait(slider.v * 1000)
		sampSendChat("/m Прижмитесь к обочине, заглушите двигатель.")
		wait(slider.v * 1000)
		sampSendChat("/m В случае неподчинения, вы будете объявлены в Федеральный Розыск!")
		addLog("Использование мегафона (10-55)")
	else notif("Не найдена ближайшая машина")
	end
	end)
end

function cmd_wanted()
	lua_thread.create(function()
		sampSendChat("/me взял в руки мини-планшет, вошёл в базу данных и осмотрел розыскиваемых.")
		sampSendChat("/wanted 1")
	end)
end

function cmd_m2()
lua_thread.create(function()
	local car = getNearestVehicle(20.0)
	if car ~= -1 then
		local model = getCarModel(car)
		local name = getNameOfVehicleModel(model)
		sampSendChat('/me движением руки включил мегафон.')
		wait(slider.v * 1000)
		if autoDoklad then
			sampSendChat("/r Провожу 10-66, автомобиль " ..name.. ", " ..comboSelectCode.. ", доступен.")
		end
		sampSendChat('/m Внимание! Водитель ' ..name.. "!")
		wait(slider.v * 1000)
		sampSendChat("/m Прижмитесь к обочине, заглушите двигатель...")
		wait(slider.v * 1000)
		sampSendChat("/m После чего выйдите из транспортного средства с поднятыми руками")
		wait(slider.v * 1000)
		sampSendChat("/m В случае неподчинения, по Вам будет открыт огонь на поражение.")
		addLog("Использование мегафона (10-66)")
	else notif("Не найдена ближайшая машина")
	end
	end)
end

function cmd_krik()
lua_thread.create(function()
    sampSendChat('/s Всем оставаться на своих местах, без резких движений!')
	addLog("Использование крика")
	end)
end

function cmd_eject(arg)
	local id = tonumber(arg)
	if not id then
		notif("Использование: /eject [ID]")
		return
	end
	if not sampIsPlayerConnected(id) then
		notif("Игрока с таким ID нет или он не подключён")
		return
	end
	local nick = sampGetPlayerNickname(id)
	clean_nick = nick:gsub("_", " ")
	lua_thread.create(function()
	sampSendChat("/me потянулся к двери, открыл её, вытащил " .. clean_nick .. " из автомобиля.")
	wait(slider.v * 1000)
	sampSendChat("/eject " .. id)
	end)
end

function cmd_udo()
lua_thread.create(function()
	local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
	local clean_nick = mynick:gsub("_", " ")
    sampSendChat('Здравия желаю, ' ..clean_nick.. ", " ..rank.. ", " ..department.. ".")
	wait(slider.v * 1000)
	sampSendChat('/me движением руки достал из кармана удостоверение, показал его человеку напротив.')
	wait(slider.v * 1000)
	sampSendChat('/do На документе написано:')
	wait(slider.v * 1000)
	sampSendChat('/do ' ..clean_nick.. " | " ..rank.. " | " ..department)
	wait(slider.v * 1000)
	sampSendChat('/me после показа удостоверения, свернул его и положил обратно в карман.')
	addLog("Показ удостоверения")
	end)
end

function cmd_prava()
lua_thread.create(function()
    sampSendChat('Вы имеете право хранить молчание.')
    wait(slider.v * 1000)
	sampSendChat('Все, что вы скажете, может быть искользовано против вас в суде.')
    wait(slider.v * 1000)
    sampSendChat('Ваш адвокат может присутствовать при допросе.')
	wait(slider.v * 1000)
    sampSendChat('Если вы не можете оплатить услуги адвоката, он будет предоставлен вам государством.')
	wait(slider.v * 1000)
    sampSendChat('Вам ясны ваши права?')
	addLog("Использование миранды")
	end)
end

function cmd_search(params)
	local id, reason = params:match("^(%d+)%s+(.+)$")
	nick = sampGetPlayerNickname(id)
	clean_nick = nick:gsub("_", " ")
	if not id or not reason then
			notif("Использование: /search [ID] [Причина]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		return
	end

	lua_thread.create(function()
		sampSendChat("/me засунул руки в карман, достал пару резиновых перчаток, натянул их на руки.")
		wait(slider.v * 1000)
		sampSendChat("/me вытянул руку перед собой, начал обшлёпывать человека напротив.")
		wait(slider.v * 1000)
		sampSendChat("/me наклонился, начал обыскивать нижние части тела человека напротив.")
		wait(slider.v * 1000)
		sampSendChat("/search "..id.." "..reason)
		addLog("Проведение обыска " ..clean_nick.. " с причиной: " ..reason)
	end)
end

function cmd_clear(arg)
	if arg == "" then
			notif("Использование: /clear [ID] [Причина]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		return
	end
	local id, reason = arg:match("^(%d+)%s+(.+)$")
	id = tonumber(id)
	if not id or not reason then
		notif("Использование: /clear [ID] [Причина]")
		if config.settings.sounds then
			setAudioStreamState(soundMenu, 0)
			setAudioStreamState(soundMenu, 1)
		end
		return
	end
	local nick = sampGetPlayerNickname(id)
	local clean_nick = nick:gsub("_", " ")
	lua_thread.create(function()
	sampSendChat("/me вошёл в базу данных, зашёл в раздел 'Розыскиваемые'")
	wait(slider.v * 1000)
	sampSendChat("/me выбрав " .. clean_nick .. ", нажал кнопку 'Удалить из базы'. Причина: " ..reason)
	wait(slider.v * 1000)
	sampSendChat("/clear " .. id .. " " .. reason)
	addLog("Снятие розыска " ..clean_nick.. " с причиной: " ..reason)
	end)
end

function cmd_histid(arg)
	local id = tonumber(arg)
	if not id then
			notif("Использование: /histid [ID]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		return
	end
	if not sampIsPlayerConnected(id) then
			notif("Игрок с таким ID не найден")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		return
	end
	local nick = sampGetPlayerNickname(id)
	if nick and nick ~= "" then
		sampSendChat("/history " .. nick)
		addLog("Проверка history " ..nick)
	else
			notif("Не удалось получить ник")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
	end
end

function cmd_putpl(arg)
	local id = tonumber(arg)
	if not id then
			notif("Использование: /putpl [ID]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		return
	end
	if not sampIsPlayerConnected(id) then
			notif("Игрок с таким ID не найден")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		return
	end
	local nick = sampGetPlayerNickname(id)
	local clean_nick = nick:gsub("_", " ")
	lua_thread.create(function()
	sampSendChat("/me открыл дверь полицейского крузера, посадил туда " .. clean_nick .. ".")
	wait(slider.v * 1000)
	sampSendChat("/putpl " .. id)
	wait(slider.v * 1000)
	sampSendChat("/me закрыл дверь")
	addLog("Посаживание " ..clean_nick.. " в машину")
	end)
end

function cmd_pull(arg)
	local id = tonumber(arg)
	if not id then
			notif("Использование: /pull [ID]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		return
	end
	if not sampIsPlayerConnected(id) then
			notif("Игрок с таким ID не найден")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		return
	end
	local nick = sampGetPlayerNickname(id)
	local clean_nick = nick:gsub("_", " ")
	lua_thread.create(function()
	sampSendChat("/do " .. clean_nick .. " сидит в машине.")
	wait(slider.v * 1000)
	sampSendChat("/me резким движением открыл дверь, вышвырнул " .. clean_nick .. " из автомобиля.")
	wait(slider.v * 1000)
	sampSendChat("/pull " .. id)
	addLog("Вытаскивание " ..clean_nick.. " из машины")
	end)
end

function cmd_ticket(arg)
	if arg == "" then
		notif("Использование: /ticket [ID] [Сумма] [Причина]")
		return
	end
	local id, stars, reason = arg:match("^(%d+)%s+(%d+)%s+(.+)$")
	local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
	local clean_mynick = mynick:gsub("_", " ")
	id = tonumber(id)
	stars = tonumber(stars)
	if not id or not stars or not reason then
		notif("Использование: /ticket [ID] [Сумма] [Причина]")
		return
	end
	if not sampIsPlayerConnected(id) then
		notif("Игрок с таким ID не найден")
		return
	end
	local nick = sampGetPlayerNickname(id)
	local clean_nick = nick:gsub("_", " ")
	lua_thread.create(function()
			sampSendChat("/me в кармане у " ..clean_mynick.. " лежит ручка и бланк.")
			wait(slider.v * 1000)
			sampSendChat("/me движением руки достал бланк и ручку из кармана, после чего ввёл данные нарушителя.")
			wait(slider.v * 1000)
			sampSendChat("/do На бланке написано:")
			wait(slider.v * 1000)
			sampSendChat("/do --- ШТРАФ ---")
			wait(slider.v * 1000)
			sampSendChat("/do Имя и Фамилия: " .. clean_nick .. ".")
			wait(slider.v * 1000)
			sampSendChat("/do Причина: " .. reason .. ".")
			wait(slider.v * 1000)
			sampSendChat("/do Сумма: " .. stars .. "$.")
			wait(slider.v * 1000)
			sampSendChat("/do -------------")
			wait(slider.v * 1000)
			sampSendChat("/todo Передав выписанный бланк нарушителю*Оплачивайте.")
			wait(slider.v * 1000)
			sampSendChat("/ticket " .. id .. " " .. stars .. " " .. reason)
			addLog("Выписка штрафа " ..clean_nick.. " на сумму " ..stars.. " с причиной " ..reason)
		end)
end

function cmd_su(arg)
	if arg == "" then
			notif("Использование: /su [ID] [Кол-Во] [Причина]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		return
	end

	local id, stars, reason = arg:match("^(%d+)%s+(%d+)%s+(.+)$")
	id = tonumber(id)
	stars = tonumber(stars)

	if not id or not stars or not reason then
			notif("Использование: /su [ID] [Кол-Во] [Причина]")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		return
	end
	
	if stars >6 then 
			notif("Количество выд. Звёзд не может быть более 6")
			if config.settings.sounds then
				setAudioStreamState(soundMenu, 0)
				setAudioStreamState(soundMenu, 1)
			end
		return
	end

	local nick = sampGetPlayerNickname(id)
	clean_nick = nick:gsub("_", " ")

	lua_thread.create(function()
		sampSendChat("/me достал мини-планшет, вошёл в базу данных, ввёл запрос: " .. clean_nick)
		wait(slider.v * 1000)
		sampSendChat("/me после ввода запроса, запросил обявление гражданина в Федеральный розыск с причиной: " .. reason .. ".")
		wait(slider.v * 1000)
		sampSendChat("/do Запрос одобрен, " .. clean_nick .. " получает " .. stars .. " статус розыска.")
		wait(slider.v * 1000)
		sampSendChat("/su " .. id .. " " .. stars .. " " .. reason)
		addLog("Обьявление " ..clean_nick.. " в розыск на " ..stars.. " стадию с причиной " ..reason)
	end)
end

function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function separator(text)
	if text:find("$") then
		for S in string.gmatch(text, "%$%d+") do
			local replace = comma_value(S)
			text = string.gsub(text, S, replace)
		end
		for S in string.gmatch(text, "%d+%$") do
			S = string.sub(S, 0, #S-1)
			local replace = comma_value(S)
			text = string.gsub(text, S, replace)
		end
	end
		return text
end
	
if sampevcheck then
	
	function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
		text = separator(text)
		title = separator(title)
		return {dialogId, style, title, button1, button2, text}
	end

	function sampev.onServerMessage(color, text)
		text = separator(text)
		return {color, text}
	end

	function sampev.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
		text = separator(text)
		return {id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text}
	end
end