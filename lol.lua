local dlstatus = require('moonloader').download_status

local SCRIPT_VERSION = "1.0.0"

local VERSION_URL = "https://raw.githubusercontent.com/USERNAME/MyScript/main/version.json"

local VERSION_FILE =
getWorkingDirectory() .. "\\version.json"

function main()
    repeat wait(0) until isSampAvailable()

    CheckUpdate()

    while true do
        wait(0)
    end
end

local function log(...)
    local msg = table.concat({...}, " ")

    print("[AUTOUPDATE] " .. msg)

    local f = io.open(
        getWorkingDirectory() .. "\\MyScript.log",
        "a"
    )

    if f then
        f:write(
            os.date("[%d.%m.%Y %H:%M:%S] ")
            .. msg .. "\n"
        )
        f:close()
    end
end

function CheckUpdate()

    log("Начинаю проверку обновлений")

    downloadUrlToFile(
        VERSION_URL,
        VERSION_FILE,

        function(id, status)

            log("download callback:", tostring(status))

            if status ~= dlstatus.STATUSEX_ENDDOWNLOAD then
                return
            end

            local f = io.open(VERSION_FILE, "r")

            if not f then
                log("Не удалось открыть version.json")
                return
            end

            local data = f:read("*a")
            f:close()

            os.remove(VERSION_FILE)

            local ok, json = pcall(decodeJson, data)

            if not ok then
                log("JSON ошибка:", tostring(json))
                return
            end

            log("Текущая версия:", SCRIPT_VERSION)
            log("Удалённая версия:", json.version)

            if json.version == SCRIPT_VERSION then
                log("Обновлений нет")
                return
            end

            log("Найдено обновление")

            DownloadUpdate(json.download)
        end
    )
end

function DownloadUpdate(url)

    log("Качаю:", url)

    local scriptPath = thisScript().path
    local backupPath = scriptPath .. ".bak"

    if doesFileExist(scriptPath) then
        os.rename(scriptPath, backupPath)
        log("Создан бэкап")
    end

    downloadUrlToFile(
        url,
        scriptPath,

        function(id, status)

            log("update callback:", tostring(status))

            if status == dlstatus.STATUSEX_ENDDOWNLOAD then

                log("Обновление успешно")

                sampAddChatMessage(
                    "[SCRIPT] Обновление установлено",
                    -1
                )

                thisScript():reload()

            elseif status == dlstatus.STATUSEX_ERROR then

                log("Ошибка загрузки")

                if doesFileExist(backupPath) then
                    os.rename(backupPath, scriptPath)
                    log("Восстановлен бэкап")
                end
            end
        end
    )
end