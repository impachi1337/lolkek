local dlstatus = require('moonloader').download_status

local SCRIPT_VERSION = "1.0"

local VERSION_URL = "https://raw.githubusercontent.com/impachi1337/lolkek/refs/heads/main/version.json"

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

    log("Íà÷èíàþ ïðîâåðêó îáíîâëåíèé")

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
                log("Íå óäàëîñü îòêðûòü version.json")
                return
            end

            local data = f:read("*a")
            f:close()

            os.remove(VERSION_FILE)

            local ok, json = pcall(decodeJson, data)

            if not ok then
                log("JSON îøèáêà:", tostring(json))
                return
            end

            log("Òåêóùàÿ âåðñèÿ:", SCRIPT_VERSION)
            log("Óäàë¸ííàÿ âåðñèÿ:", json.version)

            if json.version == SCRIPT_VERSION then
                log("Îáíîâëåíèé íåò")
                return
            end

            log("Íàéäåíî îáíîâëåíèå")

            DownloadUpdate(json.download)
        end
    )
end

function DownloadUpdate(url)

    log("Êà÷àþ:", url)

    local scriptPath = thisScript().path
    local backupPath = scriptPath .. ".bak"

    if doesFileExist(scriptPath) then
        os.rename(scriptPath, backupPath)
        log("Ñîçäàí áýêàï")
    end

    downloadUrlToFile(
        url,
        scriptPath,

        function(id, status)

            log("update callback:", tostring(status))

            if status == dlstatus.STATUSEX_ENDDOWNLOAD then

                log("Îáíîâëåíèå óñïåøíî")

                sampAddChatMessage(
                    "[SCRIPT] Îáíîâëåíèå óñòàíîâëåíî",
                    -1
                )

                thisScript():reload()

            elseif status == dlstatus.STATUSEX_ERROR then

                log("Îøèáêà çàãðóçêè")

                if doesFileExist(backupPath) then
                    os.rename(backupPath, scriptPath)
                    log("Âîññòàíîâëåí áýêàï")
                end
            end
        end
    )
end
