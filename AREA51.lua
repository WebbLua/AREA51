script_name("Special script for AREA 51")
script_author("Leonid_Brezhnev")
script_version_number(5)

function try(f, catch_f)
    local status, exception = pcall(f)
    if not status then catch_f(exception) end
end

try(function()
    sampev = require 'samp.events'
    imgui = require 'imgui'
    imgui.ToggleButton = require('imgui_addons').ToggleButton
    vkeys = require 'vkeys'
    rkeys = require 'rkeys'
    inicfg = require 'inicfg'
    dlstatus = require'moonloader'.download_status
    ffi = require 'ffi'
    encoding = require 'encoding'
    encoding.default = 'CP1251'
    u8 = encoding.UTF8
end, function(e)
    msg("An error occurred while loading libraries", true)
    print(e)
    thisScript():unload()
end)

function msg(text, error)
    if not error then
        sampAddChatMessage("{FFFF00}[AREA 51] {FFFAFA}" .. text, 0xFFFF00)
    else
        sampAddChatMessage("{FF0000}[AREA 51 ERROR] " .. text, 0xFF0000)
    end
end

local variables = {
    checkedUpdates = false,
    ip = nil,
    port = nil,
    logined = false,
    loaded = false,
    request = {complete = true, free = true},
    synchronization = {},
    points = {},
    reload = false,
    unload = false,
    update = false,
    nick = nil,
    id = nil,
    url = nil,
    need = {reload = false, clist = false, stats = false, sethotkeys = 2},
    warehouse = {
        taken = false,
        parachuteTimer = 0,
        isArmorTaken = false,
        isDeagleTaken = false,
        isShotgunTaken = false,
        isSMGTaken = false,
        isM4A1Taken = false,
        isRifleTaken = false,
        isParachuteTaken = false
    },
    ranks = {
        "Рядовой", "Ефрейтор", "Младший сержант",
        "Сержант", "Старший сержант", "Старшина",
        "Прапорщик", "Младший лейтенант",
        "Лейтенант", "Старший лейтенант",
        "Капитан", "Майор", "Подполковник",
        "Полковник", "Генерал"
    },
    checkfood = {
        fish = true,
        mushroom = true,
        nofood = false,
        satiety = 0,
        eat = false
    },
    clists = {
        [16777215] = 0,
        [2852758528] = 1,
        [2857893711] = 2,
        [2857434774] = 3,
        [2855182459] = 4,
        [2863589376] = 5,
        [2854722334] = 6,
        [2858002005] = 7,
        [2868839942] = 8,
        [2868810859] = 9,
        [2868137984] = 10,
        [2864613889] = 11,
        [2863857664] = 12,
        [2862896983] = 13,
        [2868880928] = 14,
        [2868784214] = 15,
        [2868878774] = 16,
        [2853375487] = 17,
        [2853039615] = 18,
        [2853411820] = 19,
        [2855313575] = 20,
        [2853260657] = 21,
        [2861962751] = 22,
        [2865042943] = 23,
        [2860620717] = 24,
        [2868895268] = 25,
        [2868899466] = 26,
        [2868167680] = 27,
        [2868164608] = 28,
        [2864298240] = 29,
        [2863640495] = 30,
        [2864232118] = 31,
        [2855811128] = 32,
        [2866272215] = 33,

        [-256] = 0,
        [161743018] = 1,
        [1476349866] = 2,
        [1358861994] = 3,
        [782269354] = 4,
        [-1360527190] = 5,
        [664477354] = 6,
        [1504073130] = 7,
        [-16382294] = 8,
        [-23827542] = 9,
        [-196083542] = 10,
        [-1098251862] = 11,
        [-1291845462] = 12,
        [-1537779798] = 13,
        [-5889878] = 14,
        [-30648662] = 15,
        [-6441302] = 16,
        [319684522] = 17,
        [233701290] = 18,
        [328985770] = 19,
        [815835050] = 20,
        [290288042] = 21,
        [-1776943190] = 22,
        [-988414038] = 23,
        [-2120503894] = 24,
        [-2218838] = 25,
        [-1144150] = 26,
        [-188481366] = 27,
        [-189267798] = 28,
        [-1179058006] = 29,
        [-1347440726] = 30,
        [-1195985238] = 31,
        [943208618] = 32,
        [-673720406] = 33
    },
    clistnames = {
        "[0] Без цвета", "[1] Зелёный",
        "[2] Светло-зелёный", "[3] Ярко-зелёный",
        "[4] Бирюзовый", "[5] Жёлто-зелёный",
        "[6] Тёмно-зелёный", "[7] Серо-зелёный",
        "[8] Красный", "[9] Ярко-красный",
        "[10] Оранжевый", "[11] Коричневый",
        "[12] Тёмно-красный", "[13] Серо-красный",
        "[14] Жёлто-оранжевый", "[15] Малиновый",
        "[16] Розовый", "[17] Синий", "[18] Голубой",
        "[19] Синяя сталь", "[20] Cине-зелёный",
        "[21] Тёмно-синий", "[22] Фиолетовый",
        "[23] Индиго", "[24] Серо-синий", "[25] Жёлтый",
        "[26] Кукурузный", "[27] Золотой",
        "[28] Старое золото", "[29] Оливковый",
        "[30] Серый", "[31] Серебро", "[32] Чёрный",
        "[33] Белый"
    },
    cmds = {
        {"area", "открыть главное меню скрипта", false},
        {"ud", "показать удостоверение", true},
        {"port", "доложить о выезде в порт", false},
        {"area login", "авторизоваться/зарег.", true},
        {"area reload", "перезагрузить скрипт", false},
        {"area site", "открыть веб-сайт скрипт", false},
        {"area github", "открыть гит-хаб скрипта", false}
    },
    responses = {
        ["Error parsing JSON data"] = "Произошла ошибка при декодировании JSON информации сервером",
        ["Error, nick must be in roleplay format"] = "Ваш ник не соответствует roleplay формату",
        ["Incorrect request"] = "Запрос не валидный",
        ['Successfully registered'] = "Успешная регистрация",
        ['Error registering user'] = "Произошла ошибка при регистрации",
        ['Password is invalid'] = "Пароль не валидный. Попробуйте /area login [password]",
        ['Successfully logged in'] = "Успешная авторизация",
        ['Error logging in'] = "Произошла ошибка при авторизации",
        ['Wrong password'] = "Пароль неверный. Попробуйте /area login [password]"
    }
}

function request(url) -- запрос по URL
    while not variables.request.free do wait(0) end
    variables.request.free = false
    local filePath = os.tmpname()
    while true do
        variables.request.complete = false
        download_id = downloadUrlToFile(url, filePath, download_handler)
        while not variables.request.complete do wait(0) end
        local file = io.open(filePath, "r")
        if file ~= nil then
            local text = file:read("*a")
            io.close(file)
            os.remove(filePath)
            variables.request.free = true
            return text
        end
        os.remove(filePath)
    end
    return ""
end

function download_handler(id, status, p1, p2)
    if stop_downloading then
        stop_downloading = false
        download_id = nil
        return false -- прервать загрузку
    end

    if status == dlstatus.STATUS_ENDDOWNLOADDATA then
        variables.request.complete = true
    end
end

function isUpdate()
    lua_thread.create(function()
        local response = request(
                             "https://raw.githubusercontent.com/WebbLua/AREA51/main/version.json")
        local info = decodeJson(response)
        if info['ip'] ~= nil and info['port'] ~= nil then
            variables.ip, variables.port = info['ip'], info['port']
        end
        if info['version_num'] ~= nil then
            if info['version_num'] > thisScript()['version_num'] then
                variables.url = info['url']
                update()
            end
        end
        variables.checkedUpdates = true
    end)
end

function update()
    if variables.url == nil then
        msg(
            "При обновлении произошла ошибка, нет ссылки на файл!")
        return
    end
    variables.update = true
    downloadUrlToFile(variables.url, thisScript().path,
                      function(_, status, _, _)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            msg("Скрипт был обновлён!")
            if script.find("ML-AutoReboot") == nil then
                thisScript():reload()
            end
        end
    end)
end

function onScriptTerminate(s, bool)
    if s == thisScript() and not bool then
        imgui.Process = false
        if variables.reload then
            msg("Перезагрузка...")
            return
        end
        if not variables.update and not variables.unload then
            msg(
                "Скрипт крашнулся, подробная информация в консоли (~)",
                true)
        end
    end
end

chatManager = {}
chatManager.messagesQueue = {}
chatManager.messagesQueueSize = 1000
chatManager.antifloodClock = os.clock()
chatManager.lastMessage = ""
chatManager.antifloodDelay = 0.8

function chatManager.initQueue()
    for messageIndex = 1, chatManager.messagesQueueSize do
        chatManager.messagesQueue[messageIndex] = {message = ""}
    end
end

function chatManager.addMessageToQueue(string, _nonRepeat)
    local isRepeat = false
    local nonRepeat = _nonRepeat or false

    if nonRepeat then
        for messageIndex = 1, chatManager.messagesQueueSize do
            if string == chatManager.messagesQueue[messageIndex].message then
                isRepeat = true
            end
        end
    end

    if not isRepeat then
        for messageIndex = 1, chatManager.messagesQueueSize - 1 do
            chatManager.messagesQueue[messageIndex].message =
                chatManager.messagesQueue[messageIndex + 1].message
        end
        chatManager.messagesQueue[chatManager.messagesQueueSize].message =
            string
    end
end

function chatManager.checkMessagesQueueThread()
    while true do
        wait(0)
        for messageIndex = 1, chatManager.messagesQueueSize do
            local message = chatManager.messagesQueue[messageIndex]
            if message.message ~= "" then
                if string.sub(chatManager.lastMessage, 1, 1) ~= "/" and
                    string.sub(message.message, 1, 1) ~= "/" then
                    chatManager.antifloodDelay =
                        chatManager.antifloodDelay + 0.5
                end
                if os.clock() - chatManager.antifloodClock >
                    chatManager.antifloodDelay then

                    local sendMessage = true

                    local command = string.match(message.message, "^(/[^ ]*).*")

                    if sendMessage then
                        chatManager.lastMessage = message.message
                        sampSendChat(message.message)
                    end

                    message.message = ""
                end
                chatManager.antifloodDelay = 0.8
            end
        end
    end
end

function chatManager.updateAntifloodClock()
    chatManager.antifloodClock = os.clock()
    if string.sub(chatManager.lastMessage, 1, 5) == "/sms " or
        string.sub(chatManager.lastMessage, 1, 3) == "/t " then
        chatManager.antifloodClock = chatManager.antifloodClock + 0.5
    end
end

function get_crosshair_position()
    local vec_out = ffi.new("float[3]")
    local tmp_vec = ffi.new("float[3]")
    ffi.cast(
        "void (__thiscall*)(void*, float, float, float, float, float*, float*)",
        0x514970)(ffi.cast("void*", 0xB6F028), 15.0, tmp_vec[0], tmp_vec[1],
                  tmp_vec[2], tmp_vec, vec_out)
    return vec_out[0], vec_out[1], vec_out[2]
end

function getAllPickups() -- https://www.blast.hk/threads/13380/page-8#post-361600
    local pu = {}
    pPu = sampGetPickupPoolPtr() + 16388
    for i = 0, 4095 do
        local id = readMemory(pPu + 4 * i, 4)
        if id ~= -1 then table.insert(pu, sampGetPickupHandleBySampId(i)) end
    end
    return pu
end

function string.split(str, delim, plain) -- bh FYP
    local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end

function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) ==
            tostring(nick) then return i end
    end
end

function makeHotKey(numkey)
    local rett = {}
    for _, v in ipairs(string.split(config.hotkey[numkey], ", ")) do
        if tonumber(v) ~= 0 then table.insert(rett, tonumber(v)) end
    end
    return rett
end

imgui.main = imgui.ImBool(false)
local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec2 = imgui.ImVec2
local ImVec4 = imgui.ImVec4

function toScreenY(gY)
    local x, y = convertGameScreenCoordsToWindowScreenCoords(0, gY)
    return y
end

function toScreenX(gX)
    local x, y = convertGameScreenCoordsToWindowScreenCoords(gX, 0)
    return x
end

function toScreen(gX, gY)
    local s = {}
    s.x, s.y = convertGameScreenCoordsToWindowScreenCoords(gX, gY)
    return s
end

function vec(gX, gY)
    local x, y = convertGameScreenCoordsToWindowScreenCoords(gX, gY)
    return imgui.ImVec2(x, y)
end

function imgui.ApplyCustomStyle()
    imgui.SwitchContext()
    style.WindowRounding = 4.0
    style.WindowTitleAlign = vec(0.5 / 3, 0.5 / 2.4107143878937)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = vec(10 / 3, 5 / 2.4107143878937)
    style.ScrollbarSize = 15
    style.ScrollbarRounding = 0
    style.GrabMinSize = 9.6
    style.GrabRounding = 1.0
    style.WindowPadding = vec(10 / 3, 10 / 2.4107143878937)
    style.AntiAliasedLines = true
    style.AntiAliasedShapes = true
    style.FramePadding = vec(5 / 3, 4 / 2.4107143878937)
    style.DisplayWindowPadding = vec(27 / 3, 27 / 2.4107143878937)
    style.DisplaySafeAreaPadding = vec(5 / 3, 5 / 2.4107143878937)
    style.ButtonTextAlign = vec(0.5 / 3, 0.5 / 2.4107143878937)

    colors[clr.Text] = ImVec4(0.92, 0.92, 0.92, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.44, 0.44, 0.44, 1.00)
    colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 1.00)
    colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border] = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg] = ImVec4(0.11, 0.11, 0.11, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.TitleBg] = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.TitleBgActive] = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg] = ImVec4(0.11, 0.11, 0.11, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.06, 0.06, 0.06, 0.53)
    colors[clr.ScrollbarGrab] = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.47, 0.47, 0.47, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.81, 0.83, 0.81, 1.00)
    colors[clr.CheckMark] = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.SliderGrab] = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SliderGrabActive] = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.Button] = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.Header] = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.HeaderHovered] = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.HeaderActive] = ImVec4(0.93, 0.65, 0.14, 1.00)
    colors[clr.Separator] = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.SeparatorHovered] = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SeparatorActive] = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ResizeGripHovered] = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ResizeGripActive] = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.CloseButton] = ImVec4(0.47, 0.47, 0.47, 1.00)
    colors[clr.CloseButtonHovered] = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive] = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end
imgui.ApplyCustomStyle()
function imgui.initBuffers()
    buffer = {
        clistmsg = {},
        tag = imgui.ImBuffer(config.personal.tag, 256),
        division = imgui.ImBuffer(config.personal.division, 256),
        clist = imgui.ImInt(config.personal.clist)
    }
    for index, msg in ipairs(config.clistmsg) do
        buffer.clistmsg[index] = imgui.ImBuffer(msg, 256)
    end
end

function imgui.SameText(...)
    imgui.SameLine()
    imgui.Text(...)
end

function imgui.Hotkey(name, numkey, width)
    imgui.BeginChild(name, vec(width, 13.25), true)
    imgui.PushItemWidth(toScreenX(width))

    local hstr = ""
    for _, v in ipairs(string.split(config.hotkey[numkey], ", ")) do
        if v ~= "0" then
            hstr =
                hstr == "" and tostring(vkeys.id_to_name(tonumber(v))) or "" ..
                    hstr .. " + " .. tostring(vkeys.id_to_name(tonumber(v))) ..
                    ""
        end
    end
    hstr = (hstr == "" or hstr == "nil") and "Нет клавиши" or hstr

    imgui.Text(hstr)
    imgui.PopItemWidth()
    imgui.EndChild()
    if imgui.IsItemClicked() then
        lua_thread.create(function()
            local curkeys = ""
            local tbool = false
            while true do
                wait(0)
                if not tbool then
                    for k, v in pairs(vkeys) do
                        sv = tostring(v)
                        if isKeyDown(v) and
                            (v == vkeys.VK_MENU or v == vkeys.VK_CONTROL or v ==
                                vkeys.VK_SHIFT or v == vkeys.VK_LMENU or v ==
                                vkeys.VK_RMENU or v == vkeys.VK_RCONTROL or v ==
                                vkeys.VK_LCONTROL or v == vkeys.VK_LSHIFT or v ==
                                vkeys.VK_RSHIFT) then
                            if v ~= vkeys.VK_MENU and v ~= vkeys.VK_CONTROL and
                                v ~= vkeys.VK_SHIFT then
                                if not curkeys:find(sv) then
                                    curkeys =
                                        tostring(curkeys):len() == 0 and sv or
                                            curkeys .. " " .. sv
                                end
                            end
                        end
                    end

                    for k, v in pairs(vkeys) do
                        sv = tostring(v)
                        if isKeyDown(v) and
                            (v ~= vkeys.VK_MENU and v ~= vkeys.VK_CONTROL and v ~=
                                vkeys.VK_SHIFT and v ~= vkeys.VK_LMENU and v ~=
                                vkeys.VK_RMENU and v ~= vkeys.VK_RCONTROL and v ~=
                                vkeys.VK_LCONTROL and v ~= vkeys.VK_LSHIFT and v ~=
                                vkeys.VK_RSHIFT) then
                            if not curkeys:find(sv) then
                                curkeys =
                                    tostring(curkeys):len() == 0 and sv or
                                        curkeys .. " " .. sv
                                tbool = true
                            end
                        end
                    end
                else
                    tbool2 = false
                    for k, v in pairs(vkeys) do
                        sv = tostring(v)
                        if isKeyDown(v) and
                            (v ~= vkeys.VK_MENU and v ~= vkeys.VK_CONTROL and v ~=
                                vkeys.VK_SHIFT and v ~= vkeys.VK_LMENU and v ~=
                                vkeys.VK_RMENU and v ~= vkeys.VK_RCONTROL and v ~=
                                vkeys.VK_LCONTROL and v ~= vkeys.VK_LSHIFT and v ~=
                                vkeys.VK_RSHIFT) then
                            tbool2 = true
                            if not curkeys:find(sv) then
                                curkeys =
                                    tostring(curkeys):len() == 0 and sv or
                                        curkeys .. " " .. sv
                            end
                        end
                    end

                    if not tbool2 then break end
                end
            end

            local keys = "0"
            if tonumber(curkeys) == vkeys.VK_BACK then
                config.hotkey[numkey] = "0"
            else
                local tNames = string.split(curkeys, " ")
                for _, v in ipairs(tNames) do
                    local val = (tonumber(v) == 162 or tonumber(v) == 163) and
                                    17 or
                                    (tonumber(v) == 160 or tonumber(v) == 161) and
                                    16 or
                                    (tonumber(v) == 164 or tonumber(v) == 165) and
                                    18 or tonumber(v)
                    keys = keys == "0" and val or "" .. keys .. ", " .. val ..
                               ""
                end
            end

            config.hotkey[numkey] = keys
            inicfg.save(config, settings)
        end)
    end
end

function area(param)
    if param == "reload" then
        variables.reload = true
        thisScript():reload()
    elseif param == "site" then
        os.execute("explorer http://" .. variables.ip .. ":" .. variables.port)
        return
    elseif param == "github" then
        os.execute("explorer https://raw.githubusercontent.com/WebbLua/AREA51")
        return
    else
        local params = {}
        for v in string.gmatch(param, "[^%s]+") do
            table.insert(params, v)
        end
        if params[1] == "login" then
            if params[2] == nil or params[2] == "" then
                msg(
                    "Неверный пароль. Введите /area login [password]")
                return
            end
            local password = params[2]
            login(password)
            return
        end
    end
    for k, v in pairs(config.hotkey) do
        local hk = makeHotKey(k)
        if tonumber(hk[1]) ~= 0 then rkeys.unRegisterHotKey(hk) end
    end
    variables.need.sethotkeys = 1
    imgui.main.v = not imgui.main.v
end

function login(password)
    lua_thread.create(function()
        if variables.ip ~= nil and variables.port ~= nil then
            local table = {
                type = "login",
                nick = variables.nick,
                password = tostring(password),
                query = tostring(os.clock()):gsub('%.', '')
            }
            local data = encodeJson(table)

            local url = string.format("http://%s:%d/%s", variables.ip,
                                      variables.port, data)
            -- setClipboardText(url)
            local response = request(url)
            local antwort = variables.responses[response]
            if response == 'Successfully logged in' then
                config.personal.password = password
                variables.logined = true
            elseif response == 'Wrong password' then
                config.personal.password = ""
            elseif response == 'Successfully registered' then
                config.personal.password = password
                variables.logined = true
            elseif response == 'Password is invalid' then
                config.personal.password = ""
            elseif response == 'No access' then
                msg("Доступ к скрипту отсутствует")
                variables.unload = true
                thisScript():unload()
            end
            inicfg.save(config, settings)
            if antwort ~= nil then
                msg(antwort)
                return
            end
        end
    end)
end

function sendpoint()
    lua_thread.create(function()
        if sampIsChatInputActive() or sampIsDialogActive(-1) or
            isSampfuncsConsoleActive() then return end
        local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if result then
            local nick = sampGetPlayerNickname(id)
            local sx, sy = convert3DCoordsToScreen(get_crosshair_position())
            local sw, sh = getScreenResolution()
            local x, y, z
            if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
                local posX, posY, posZ =
                    convertScreenCoordsToWorld3D(sx, sy, 700.0)
                local camX, camY, camZ = getActiveCameraCoordinates()
                local result, colpoint =
                    processLineOfSight(camX, camY, camZ, posX, posY, posZ, true,
                                       true, true, true, true, true, true, true)
                if not result then
                    msg(
                        "Не удалось определить точку фокуса",
                        error)
                    return
                end
                x, y, z = colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]
            end
            local table = {
                type = "points",
                nick = nick,
                id = id,
                password = tostring(config.personal.password),
                coordinates = {x = x, y = y, z = z},
                query = tostring(os.clock()):gsub('%.', '')
            }
            local data = encodeJson(table)
            local url = string.format("http://%s:%d/%s", variables.ip,
                                      variables.port, data)
            -- setClipboardText(url)
            local response = request(url)
            if response ~= nil then
                -- print(response)
                local error = variables.responses[response]
                if error ~= nil then msg(error, true) end
            end
        end
    end)
end

function ud(sid)
    local id = tonumber(sid)
    if id ~= nil then
        if tonumber(id) < 0 or tonumber(id) > 999 then
            msg("Неверный ID. Введите /ud [id]")
            return
        end
        if not sampIsPlayerConnected(id) then
            msg("Игрок оффлайн. Введите /ud [id]")
            return
        end
        if not sampGetCharHandleBySampPlayerId(id) then
            msg("Игрок не поблизости. Введите /ud [id]")
            return
        end
        chatManager.addMessageToQueue("/showpass " .. id, true)
    end
    chatManager.addMessageToQueue(string.format(
                                      "/me показал%s удостоверение в открытом виде",
                                      config.personal.sex), true)
    chatManager.addMessageToQueue(string.format(
                                      "/do В удостоверении: «ARMY LV | %s | %s | %s»",
                                      variables.nick:gsub("_", " "),
                                      (config.personal.division == "" and
                                          "Без подразделения" or
                                          config.personal.division),
                                      config.personal.rank), true)
end

function port()
    local skin = getCharModel(PLAYER_PED)
    if skin ~= 287 and skin ~= 191 then
        msg("Вы не в военной форме")
        return
    end
    if not isCharInAnyCar(PLAYER_PED) then
        msg("Вы не в транспорте")
        return
    end
    local mycar = storeCarCharIsInNoSave(PLAYER_PED)
    local comrades = ""
    for _, ped in ipairs(getAllChars()) do
        if ped ~= PLAYER_PED then
            if isCharInAnyCar(ped) then
                local pedcar = storeCarCharIsInNoSave(ped)
                if mycar == pedcar then
                    local result, id = sampGetPlayerIdByCharHandle(ped)
                    if result then
                        local pedskin = getCharModel(ped)
                        if pedskin == 287 or skin == 191 then
                            local surname =
                                sampGetPlayerNickname(id):match(".*_(.*)")
                            comrades = comrades ~= "" and comrades .. ", " ..
                                           surname or surname
                        end
                    end
                end
            end
        end
    end
    local one = string.format("Выехал%s в порт", config.personal.sex)
    local more = comrades ~= "" and ". Напарники: " .. comrades or ""
    f(one .. more)
end

function f(...)
    if ... ~= nil and ... ~= "" then
        chatManager.addMessageToQueue(string.format("/f %s %s",
                                                    config.personal.tag, ...))
    end
end

function imgui.OnDrawFrame()
    if imgui.main.v then
        imgui.ShowCursor = true
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2),
                               imgui.Cond.FirstUseEver, vec(0.17, 0.21))
        imgui.SetNextWindowSize(vec(310, 430), imgui.Cond.FirstUseEver)
        imgui.Begin(thisScript().name, imgui.main,
                    imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize +
                        imgui.WindowFlags.NoScrollbar)
        imgui.BeginChild("Личная информация", vec(150, 60), true)
        imgui.Text("Звание: " ..
                       (config.personal.rank ~= "" and config.personal.rank or
                           "Нет"))
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(
                "Звание обновляется автоматически при открытия диалога /stats после спавна, а также при /giverank")
            imgui.EndTooltip()
        end
        imgui.Text("Основной клист: ")
        imgui.SameLine()
        imgui.PushItemWidth(toScreenX(67))
        if imgui.Combo("##personal_clist", buffer.clist, variables.clistnames) then
            config.personal.clist = tostring(buffer.clist.v)
            inicfg.save(config, settings)
        end
        imgui.Text("Тэг в рацию: ")
        imgui.SameLine()
        imgui.PushItemWidth(toScreenX(90))
        if imgui.InputText("##tag", buffer.tag) then
            config.personal.tag = tostring(buffer.tag.v)
            inicfg.save(config, settings)
        end
        imgui.Text("Подразделение: ")
        imgui.SameLine()
        imgui.PushItemWidth(toScreenX(90))
        if imgui.InputText("##division", buffer.division) then
            config.personal.division = tostring(buffer.division.v)
            inicfg.save(config, settings)
        end
        if imgui.ToggleButton("##sex", imgui.ImBool(
                                  config.personal.sex == "а" and true or false)) then
            config.personal.sex = config.personal.sex == "а" and "" or "а"
            inicfg.save(config, settings)
        end
        imgui.SameText("Женский пол")
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("Сервер", vec(150, 60), true)
        if imgui.ToggleButton(string.format("##server_sendcoordinates",
                                            config.server.sendcoordinates),
                              imgui.ImBool(config.server.sendcoordinates)) then
            config.server.sendcoordinates = not config.server.sendcoordinates
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Отправлять на сервер свои координаты")
        if imgui.ToggleButton(string.format("##server_showcoordinates",
                                            config.server.showcoordinates),
                              imgui.ImBool(config.server.showcoordinates)) then
            config.server.showcoordinates = not config.server.showcoordinates
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Отрисовывать положение пользователей на экране")
        if imgui.ToggleButton(string.format("##server_showpoints",
                                            config.server.showpoints),
                              imgui.ImBool(config.server.showpoints)) then
            config.server.showpoints = not config.server.showpoints
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Отрисовывать метки, которые устанавливают пользователи")
        imgui.Text("Текущие пользователи онлайн:")
        for nick, data in pairs(variables.synchronization) do
            imgui.Text(string.format("%s[%d] [Last request: %d sec]", nick,
                                     data.id, data.delay))
        end
        imgui.EndChild()
        imgui.BeginChild("Работа с клистом", vec(150, 254), true)
        if imgui.ToggleButton("##clist_area", imgui.ImBool(config.clist.area)) then
            config.clist.area = not config.clist.area
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Вводить /clist 7 после заезда на базу")
        if imgui.ToggleButton(string.format("##clist_death",
                                            config.personal.clist),
                              imgui.ImBool(config.clist.death)) then
            config.clist.death = not config.clist.death
            inicfg.save(config, settings)
        end
        imgui.SameText(string.format(
                           "Вводить /clist %d после смерти",
                           config.personal.clist))
        if imgui.ToggleButton("##clist_duty", imgui.ImBool(config.clist.duty)) then
            config.clist.duty = not config.clist.duty
            inicfg.save(config, settings)
        end
        imgui.SameText(string.format(
                           "Вводить /clist %d после начала рабочего дня\nи /clist 7 после окончания",
                           config.personal.clist))
        if imgui.ToggleButton("##clist_synchronization",
                              imgui.ImBool(config.clist.synchronization)) then
            config.clist.synchronization = not config.clist.synchronization
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Синхронизация своего клиста с клистом водителя")
        if imgui.ToggleButton("##clist_me", imgui.ImBool(config.clist.me)) then
            config.clist.me = not config.clist.me
            inicfg.save(config, settings)
        end
        imgui.SameText("Отыгрывать /clist")
        for index, msg in ipairs(buffer.clistmsg) do
            imgui.PushItemWidth(toScreenX(90))
            imgui.PushID(index)
            if imgui.InputText("##message", msg) then
                config.clistmsg[index] = tostring(msg.v)
                inicfg.save(config, settings)
            end
            imgui.PopID()
        end
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("Горячие клавиши", vec(150, 66), true)
        imgui.Hotkey("fraction", "fraction", 40)
        imgui.SameText(string.format(
                           "Написать текст в рацию\n(/f %s)",
                           config.personal.tag))
        imgui.Hotkey("changeclist", "changeclist", 40)
        imgui.SameText(string.format(
                           "Переключить клист\n(/clist %d)",
                           config.personal.clist))
        imgui.Hotkey("gribheal", "gribheal", 40)
        imgui.SameText("Употребить психохил\n(/grib heal)")
        imgui.Hotkey("point", "point", 40)
        imgui.SameText("Установить метку для внимания")
        imgui.EndChild()
        imgui.BeginChild("Взятие оружия со склада",
                         vec(150, 95), true)
        if imgui.ToggleButton("##take_weapon",
                              imgui.ImBool(config.dialogs.weapon)) then
            config.dialogs.weapon = not config.dialogs.weapon
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Реагировать на диалог в оружейке\n(обязательно включите для оружия)")
        if imgui.ToggleButton("##take_deagle", imgui.ImBool(config.take.deagle)) then
            config.take.deagle = not config.take.deagle
            inicfg.save(config, settings)
        end
        imgui.SameText("Брать Desert Eagle")
        if imgui.ToggleButton("##take_shotgun",
                              imgui.ImBool(config.take.shotgun)) then
            config.take.shotgun = not config.take.shotgun
            inicfg.save(config, settings)
        end
        imgui.SameText("Брать Shotgun")
        if imgui.ToggleButton("##take_smg", imgui.ImBool(config.take.smg)) then
            config.take.smg = not config.take.smg
            inicfg.save(config, settings)
        end
        imgui.SameText("Брать SMG")
        if imgui.ToggleButton("##take_m4a1", imgui.ImBool(config.take.m4a1)) then
            config.take.m4a1 = not config.take.m4a1
            inicfg.save(config, settings)
        end
        imgui.SameText("Брать M4A1")
        if imgui.ToggleButton("##take_rifle", imgui.ImBool(config.take.rifle)) then
            config.take.rifle = not config.take.rifle
            inicfg.save(config, settings)
        end
        imgui.SameText("Брать Rifle")
        if imgui.ToggleButton("##take_armor", imgui.ImBool(config.take.armor)) then
            config.take.armor = not config.take.armor
            inicfg.save(config, settings)
        end
        imgui.SameText("Брать Armor")
        if imgui.ToggleButton("##take_parachute",
                              imgui.ImBool(config.take.parachute)) then
            config.take.parachute = not config.take.parachute
            inicfg.save(config, settings)
        end
        imgui.SameText("Брать Parachute")
        if imgui.ToggleButton("##take_me", imgui.ImBool(config.take.me)) then
            config.take.me = not config.take.me
            inicfg.save(config, settings)
        end
        imgui.SameText("Отыгрывать взятие оружия")
        if imgui.ToggleButton("##take_pickup", imgui.ImBool(config.take.pickup)) then
            config.take.pickup = not config.take.pickup
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Автоматически брать pickup выхода")
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("Команды", vec(150, 95), true)
        imgui.Columns(2, "##cmds", true)
        for i = 1, #variables.cmds do
            local cmd = variables.cmds[i]
            if imgui.Selectable("/" .. cmd[1]) then
                if not cmd[3] then
                    sampProcessChatInput(string.format("/%s", cmd[1]))
                else
                    sampSetChatInputEnabled(true)
                    sampSetChatInputText(string.format("/%s ", cmd[1]))
                end
            end
            imgui.NextColumn()
            imgui.Text(cmd[2])
            imgui.Separator()
            imgui.NextColumn()
        end
        imgui.EndChild()
        imgui.SetCursorPos(vec(156.7, 143.2))
        imgui.BeginChild("Прочее", vec(150, 185.9), true)
        if imgui.ToggleButton("##checkfood_satiety",
                              imgui.ImBool(config.checkfood.satiety)) then
            config.checkfood.satiety = not config.checkfood.satiety
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Автоматически пополнять сытость")
        if imgui.ToggleButton("##checkfood_mushroom",
                              imgui.ImBool(config.checkfood.mushroom)) then
            config.checkfood.mushroom = not config.checkfood.mushroom
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Пополнять сытость грибами, а не рыбой")
        if imgui.ToggleButton("##checkfood_sbiv",
                              imgui.ImBool(config.checkfood.sbiv)) then
            config.checkfood.sbiv = not config.checkfood.sbiv
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Сбивать анимацию приёма психохила")
        if imgui.ToggleButton("##fractionseedo",
                              imgui.ImBool(config.personal.fractionseedo)) then
            config.personal.fractionseedo = not config.personal.fractionseedo
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Отыгрывать /seedo при нажатии кнопки рации")
        if imgui.ToggleButton("##elevator",
                              imgui.ImBool(config.dialogs.elevator)) then
            config.dialogs.elevator = not config.dialogs.elevator
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "\"Лифт\" - принимать диалоги в штабе.\nПри зажатии кнопки ALT можно попасть на 3 этаж")
        if imgui.ToggleButton("##duty", imgui.ImBool(config.dialogs.duty)) then
            config.dialogs.duty = not config.dialogs.duty
            inicfg.save(config, settings)
        end
        imgui.SameText(
            "Принимать диалог начала рабочего дня")
        imgui.EndChild()
        imgui.End()
    end
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end
    while sampGetCurrentServerName() == "SA-MP" do wait(0) end
    while sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) <=
        0 and not sampIsLocalPlayerSpawned() do wait(0) end
    local url, status = isUpdate()
    while not variables.checkedUpdates do wait(0) end
    if status then
        update(url)
        return
    end
    if not sampGetCurrentServerName():match("Under") then
        msg("Скрипт работает на Samp-RP Underground", true)
        variables.unload = true
        thisScript():unload()
    end
    local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if not result then
        msg("Не удалось получить ваш игровой ID",
            true)
        variables.unload = true
        thisScript():unload()
    end
    variables.id = id
    variables.nick = sampGetPlayerNickname(id)

    local AdressConfig = string.format("%s\\config", thisScript().directory)
    local AdressFolder = string.format("%s\\config\\AREA 51\\%s",
                                       thisScript().directory, variables.nick)
    if not doesDirectoryExist(AdressConfig) then
        createDirectory(AdressConfig)
    end
    if not doesDirectoryExist(AdressFolder) then
        createDirectory(AdressFolder)
    end

    settings = string.format("AREA 51\\%s\\settings.ini", variables.nick)

    local ini = {
        personal = {
            clist = 0,
            rank = "Гражданский",
            tag = "",
            division = "Без подразделения",
            sex = "",
            fractionseedo = false,
            password = ""
        },
        clist = {
            area = false,
            death = false,
            duty = false,
            stopduty = false,
            synchronization = false,
            me = false
        },
        clistmsg = {
            [1] = "повязку №1",
            [2] = "повязку №2",
            [3] = "повязку №3",
            [4] = "повязку №4",
            [5] = "повязку №5",
            [6] = "повязку №6",
            [7] = "повязку №7",
            [8] = "повязку №8",
            [9] = "повязку №9",
            [10] = "повязку №10",
            [11] = "повязку №11",
            [12] = "повязку №12",
            [13] = "повязку №13",
            [14] = "повязку №14",
            [15] = "повязку №15",
            [16] = "повязку №16",
            [17] = "повязку №17",
            [18] = "повязку №18",
            [19] = "повязку №19",
            [20] = "повязку №20",
            [21] = "повязку №21",
            [22] = "повязку №22",
            [23] = "повязку №23",
            [24] = "повязку №24",
            [25] = "повязку №25",
            [26] = "повязку №26",
            [27] = "повязку №27",
            [28] = "повязку №28",
            [29] = "повязку №29",
            [30] = "повязку №30",
            [31] = "повязку №31",
            [32] = "повязку №32",
            [33] = "повязку №33"
        },
        take = {
            me = false,
            pickup = false,
            deagle = false,
            shotgun = false,
            smg = false,
            m4a1 = false,
            rifle = false,
            armor = false,
            parachute = false
        },
        server = {
            sendcoordinates = true,
            showcoordinates = true,
            showpoints = true
        },
        checkfood = {satiety = false, mushroom = false, sbiv = false},
        dialogs = {weapon = false, elevator = false, duty = false},
        hotkey = {
            fraction = "0",
            changeclist = "0",
            gribheal = "0",
            point = "0"
        }
    }

    if config == nil then
        config = inicfg.load(ini, settings)
        inicfg.save(config, settings)
    end

    imgui.initBuffers()
    renderfont = renderCreateFont("times", toScreenX(9 / 3), 12)

    sampRegisterChatCommand("area", area)
    if config.personal.password ~= "" and config.personal.password ~= nil then
        login(config.personal.password)
    else
        msg("Авторизируйтесь: /area login [password]")
    end
    while not variables.logined do wait(0) end
    sampRegisterChatCommand("ud", ud)
    sampRegisterChatCommand("port", port)
    imgui.Process = true

    chatManager.initQueue()
    lua_thread.create(chatManager.checkMessagesQueueThread)

    msg("Скрипт запущен - /area")

    lua_thread.create(function()
        while true do
            wait(0)
            if variables.ip ~= nil and variables.port ~= nil then
                local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
                if result then
                    local nick = sampGetPlayerNickname(id)
                    local table = {
                        type = "synchronization",
                        nick = nick,
                        id = id,
                        password = tostring(config.personal.password),
                        query = tostring(os.clock()):gsub('%.', '')
                    }
                    if config.server.sendcoordinates and getActiveInterior() ==
                        0 then
                        local x, y, z = getCharCoordinates(PLAYER_PED)
                        table.coordinates = {x = x, y = y, z = z}
                    end
                    local data = encodeJson(table)
                    local url = string.format("http://%s:%d/%s", variables.ip,
                                              variables.port, data)
                    -- setClipboardText(url)
                    local response = request(url)

                    if response ~= nil then
                        -- print(response)
                        local error = variables.responses[response]
                        if error == nil then
                            local serverdata = decodeJson(response)
                            variables.synchronization =
                                serverdata.synchronization
                            variables.points = serverdata.points
                        else
                            print("{FF0000}" .. error)
                        end
                    end
                end
            end
        end
    end)
    lua_thread.create(function()
        while true do
            wait(0)
            if getActiveInterior() == 0 and config.server.showcoordinates then
                for nick, table in pairs(variables.synchronization) do
                    if table.coordinates ~= nil and nick ~= variables.nick then
                        if table.coordinates.x ~= nil and table.coordinates.y ~=
                            nil and table.coordinates.z ~= nil then
                            local result, x, y, z =
                                convert3DCoordsToScreenEx(table.coordinates.x,
                                                          table.coordinates.y,
                                                          table.coordinates.z)
                            if result and z > 0 then
                                local mx, my, mz =
                                    getCharCoordinates(PLAYER_PED)
                                local distance =
                                    getDistanceBetweenCoords3d(mx, my, mz,
                                                               table.coordinates
                                                                   .x,
                                                               table.coordinates
                                                                   .y,
                                                               table.coordinates
                                                                   .z)
                                local text = string.format(
                                                 "%s [%d sec]\n[%d meters]",
                                                 nick, table.delay, distance)
                                renderFontDrawText(renderfont, text, x, y,
                                                   0xFFFFFFFF)
                            end
                        end
                    end
                end
            end
        end
    end)
    lua_thread.create(function()
        while true do
            wait(0)
            if getActiveInterior() == 0 and config.server.showpoints then
                for nick, table in pairs(variables.points) do
                    if table.coordinates ~= nil then
                        if table.coordinates.x ~= nil and table.coordinates.y ~=
                            nil and table.coordinates.z ~= nil then
                            local result, x, y, z =
                                convert3DCoordsToScreenEx(table.coordinates.x,
                                                          table.coordinates.y,
                                                          table.coordinates.z)
                            if result and z > 0 then
                                local mx, my, mz =
                                    getCharCoordinates(PLAYER_PED)
                                local distance =
                                    getDistanceBetweenCoords3d(mx, my, mz,
                                                               table.coordinates
                                                                   .x,
                                                               table.coordinates
                                                                   .y,
                                                               table.coordinates
                                                                   .z)
                                if distance <= 210 then
                                    renderDrawBox(x, y, 25, 25, 0xFFFF0000)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    lua_thread.create(function()
        while not variables.checkfood.nofood do
            wait(0)
            if sampTextdrawIsExists(2048) then
                local satiety = tonumber(
                                    sampTextdrawGetString(2048):match(
                                        "~[ryg]~(%d+)"))
                if satiety ~= nil and config.checkfood.satiety then
                    variables.checkfood.satiety = satiety
                    if satiety == 0 then
                        variables.checkfood.eat = true
                    end
                    if variables.checkfood.eat then
                        local maxsatiety, food
                        if config.checkfood.mushroom then
                            food = "grib"
                            maxsatiety = 45
                        else
                            food = "fish"
                            maxsatiety = 70
                        end
                        if satiety < maxsatiety then
                            wait(300)
                            sampSendChat(string.format("/%s eat", food))
                            wait(300)
                        else
                            variables.checkfood.eat = false
                        end
                    end
                end
            end
        end
    end)

    variables.loaded = true
    variables.need.reload = true
    variables.need.stats = true

    chatManager.addMessageToQueue("/stats", true)
    while true do
        wait(0)
        if not imgui.main.v then
            imgui.ShowCursor = false
            if variables.need.sethotkeys == 1 then
                variables.need.sethotkeys = 2
                sampSetChatDisplayMode(3)
            end
        end
        if variables.need.sethotkeys == 2 then
            rkeys.registerHotKey(makeHotKey("fraction"), true, function()
                sampSetChatInputEnabled(true)
                sampSetChatInputText(
                    string.format("/f %s ", config.personal.tag))
                if config.personal.fractionseedo then
                    chatManager.addMessageToQueue(
                        "/seedo Голосовая связь активирована.",
                        true)
                end
            end)
            rkeys.registerHotKey(makeHotKey("changeclist"), true, function()
                if sampIsChatInputActive() or sampIsDialogActive(-1) or
                    isSampfuncsConsoleActive() then return end
                setPlayerClist()
            end)
            rkeys.registerHotKey(makeHotKey("gribheal"), true, function()
                if sampIsChatInputActive() or sampIsDialogActive(-1) or
                    isSampfuncsConsoleActive() then return end
                chatManager.addMessageToQueue("/grib heal", true)
            end)
            rkeys.registerHotKey(makeHotKey("point"), true, sendpoint)
            variables.need.sethotkeys = 0
        end
        if variables.need.clist and config.clist.area then
            local skin = getCharModel(PLAYER_PED)
            if skin ~= 287 and skin ~= 191 and
                isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) then
                setPlayerClist(7)
                variables.need.clist = false
            end
        end
    end
end

function setPlayerClist(clist)
    lua_thread.create(function()
        local needclist
        local res, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if not res then
            msg("Не удалось узнать свой ID")
            return
        end
        local myclist = variables.clists[sampGetPlayerColor(myid)]
        if myclist == nil then
            msg(
                "Не удалось узнать номер своего цвета")
            return
        end
        if clist == nil then
            needclist = myclist == 0 and config.personal.clist or 0
        else
            needclist = clist
        end
        chatManager.addMessageToQueue("/clist " .. needclist, true)
        if config.clist.me then
            wait(1300)
            local newclist = variables.clists[sampGetPlayerColor(myid)]
            if newclist ~= tonumber(needclist) then
                msg("Клист не был надет")
                return
            elseif newclist == 0 then
                chatManager.addMessageToQueue(
                    string.format("/me снял%s %s", config.personal.sex,
                                  config.clistmsg[myclist]))
            else
                chatManager.addMessageToQueue(string.format(
                                                  "/me надел%s %s",
                                                  config.personal.sex,
                                                  config.clistmsg[newclist]))
            end
        end
    end)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if variables.loaded then
        if dialogId == 22 and style == 4 and title ==
            "Статистика персонажа" then
            if not string.find(text, "Организация%s+Army LV") then
                config.personal.rank = "Гражданский"
            end
            local i = tonumber(string.match(text, "Ранг.*%[(%d+)%]"))
            if i ~= nil then
                local rank = variables.ranks[i]
                config.personal.rank = rank ~= nil and rank or
                                           "Гражданский"
            else
                config.personal.rank = "Гражданский"
            end
            inicfg.save(config, settings)
            if variables.need.stats then
                variables.need.stats = false
                return false
            end
        end
        if config.dialogs.elevator and dialogId == 288 and
            string.find(text, "1 Этаж: Холл") then
            local pickups = 0
            local myX, myY, myZ = getCharCoordinates(PLAYER_PED)

            for i, v in ipairs(getAllPickups()) do
                local cX, cY, cZ = getPickupCoordinates(v)
                local distanse = math.ceil(
                                     math.sqrt(((myX - cX) ^ 2) +
                                                   ((myY - cY) ^ 2) +
                                                   ((myZ - cZ) ^ 2)))
                if distanse <= 16 then pickups = pickups + 1 end
            end

            if pickups == 3 then -- 1st floor
                sampSendDialogResponse(dialogId, 1,
                                       isKeyDown(vkeys.VK_MENU) and 2 or 1, "")
                sampCloseCurrentDialogWithButton(0)
                return false
            elseif pickups == 2 or pickups == 1 then -- 2nd and 3rd floors
                sampSendDialogResponse(dialogId, 1,
                                       isKeyDown(vkeys.VK_MENU) and 2 or 0, "")
                sampCloseCurrentDialogWithButton(0)
                return false
            end
        end
        if config.dialogs.duty then
            if dialogId == 184 and style == 0 and title ==
                "Раздевалка" and button1 == "Да" and button2 ==
                "Нет" and
                string.find(text,
                            "Вы хотите начать рабочий день?") then
                sampSendDialogResponse(dialogId, 1, 0, "")
                sampCloseCurrentDialogWithButton(0)
                return false
            end
            if dialogId == 185 and style == 2 and title ==
                "Раздевалка" and button1 == "Далее" and button2 ==
                "Отмена" and
                string.find(text, "Завершить рабочий день") then
                local result, skin = getCharModel(PLAYER_PED)
                local response = (skin == 252 or skin == 140) and 1 or 0
                sampSendDialogResponse(dialogId, 1, response, "")
                sampCloseCurrentDialogWithButton(0)
                return false
            end
        end
        if config.dialogs.weapon and dialogId == 245 and title ==
            "Склад оружия" then
            variables.warehouse.taken = false
            if config.take.deagle then
                local a = getAmmoInCharWeapon(PLAYER_PED, 24)
                if a <= 61 then
                    sampSendDialogResponse(dialogId, 1, 0, "")
                    variables.warehouse.taken = true
                    variables.warehouse.isDeagleTaken = true
                    return false
                end
            end

            if config.take.shotgun then
                local a = getAmmoInCharWeapon(PLAYER_PED, 25)
                if a <= 28 then
                    sampSendDialogResponse(dialogId, 1, 1, "")
                    variables.warehouse.taken = true
                    variables.warehouse.isShotgunTaken = true
                    return false
                end
            end

            if config.take.smg then
                local a = getAmmoInCharWeapon(PLAYER_PED, 29)
                if a <= 178 then
                    sampSendDialogResponse(dialogId, 1, 2, "")
                    variables.warehouse.taken = true
                    variables.warehouse.isSMGTaken = true
                    return false
                end
            end

            if config.take.m4a1 then
                local a = getAmmoInCharWeapon(PLAYER_PED, 31)
                if a <= 290 then
                    sampSendDialogResponse(dialogId, 1, 3, "")
                    variables.warehouse.taken = true
                    variables.warehouse.isM4A1Taken = true
                    return false
                end
            end

            if config.take.rifle then
                local a = getAmmoInCharWeapon(PLAYER_PED, 33)
                if a <= 28 then
                    sampSendDialogResponse(dialogId, 1, 4, "")
                    variables.warehouse.taken = true
                    variables.warehouse.isRifleTaken = true
                    return false
                end
            end

            if config.take.armor and not variables.warehouse.isArmorTaken then
                sampSendDialogResponse(dialogId, 1, 5, "")
                variables.warehouse.taken = true
                variables.warehouse.isArmorTaken = true
                return false
            end

            if config.take.parachute and
                (os.time() > variables.warehouse.parachuteTimer) then
                local a = getAmmoInCharWeapon(PLAYER_PED, 46)
                if a ~= 1 then
                    sampSendDialogResponse(dialogId, 1, 6, "")
                    variables.warehouse.taken = true
                    variables.warehouse.isParachuteTaken = true
                    variables.warehouse.parachuteTimer = os.time() + 60
                    return false
                end
            end

            if not variables.warehouse.taken then
                if config.take.me then
                    local otsrt = ""
                    if variables.warehouse.isArmorTaken then
                        otsrt = "бронежилет"
                    end
                    if variables.warehouse.isDeagleTaken then
                        otsrt = otsrt == "" and "Desert Eagle" or "" .. otsrt ..
                                    ", Desert Eagle"
                    end
                    if variables.warehouse.isShotgunTaken then
                        otsrt = otsrt == "" and "Shotgun" or "" .. otsrt ..
                                    ", Shotgun"
                    end
                    if variables.warehouse.isSMGTaken then
                        otsrt = otsrt == "" and "HK MP-5" or "" .. otsrt ..
                                    ", HK MP-5"
                    end
                    if variables.warehouse.isM4A1Taken then
                        otsrt = otsrt == "" and "M4A1" or "" .. otsrt ..
                                    ", M4A1"
                    end
                    if variables.warehouse.isRifleTaken then
                        otsrt =
                            otsrt == "" and "Country Rifle" or "" .. otsrt ..
                                ", Country Rifle"
                    end
                    if variables.warehouse.isParachuteTaken then
                        otsrt =
                            otsrt == "" and "парашют" or "" .. otsrt ..
                                ", парашют"
                    end
                    if otsrt ~= "" then
                        sampSendChat("/me взял" .. config.personal.sex ..
                                         " со склада " .. otsrt .. "")
                    end
                end
                sampSendDialogResponse(dialogId, 0, 5, "")
                sampCloseCurrentDialogWithButton(0)
                variables.warehouse.isArmorTaken, variables.warehouse
                    .isDeagleTaken, variables.warehouse.isShotgunTaken, variables.warehouse
                    .isSMGTaken, variables.warehouse.isM4A1Taken, variables.warehouse
                    .isRifleTaken, variables.warehouse.isParachuteTaken, variables.warehouse
                    .taken = false, false, false, false, false, false, false,
                             false
                if config.take.pickup then
                    local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
                    for i, v in ipairs(getAllPickups()) do
                        local cX, cY, cZ = getPickupCoordinates(v)
                        local distance = math.ceil(
                                             math.sqrt(((myX - cX) ^ 2) +
                                                           ((myY - cY) ^ 2) +
                                                           ((myZ - cZ) ^ 2)))
                        if distance <= 5 and distance > 1 then
                            sampSendPickedUpPickup(
                                sampGetPickupSampIdByHandle(v))
                        end
                    end
                end
                return false
            end
        end
    end
end

function sampev.onServerMessage(col, text)
    if variables.loaded then
        if col == -356056833 and string.find(text,
                                             "^ Для восстановления доступа нажмите клавишу %'F6%' и введите %'%/restoreAccess%'") then
            variables.need.clist = true
            if variables.need.reload then
                variables.reload = true
                thisScript():reload()
            end
        end
        if col == -1342193921 and
            string.find(text,
                        "^ У вас недостаточно пачек рыбы$") then
            variables.checkfood.fish = false
            config.checkfood.mushroom = true
            if not variables.checkfood.fish and not variables.checkfood.mushroom then
                variables.checkfood.nofood = true
                return
            end
        end
        if col == -1347440641 and
            string.find(text,
                        "^ Недостаточно готовых грибов$") then
            variables.checkfood.mushroom = false
            config.checkfood.mushrom = false
            if not variables.checkfood.fish and not variables.checkfood.mushroom then
                variables.checkfood.nofood = true
                return
            end
        end
        if col == 1790050303 and config.clist.duty then
            if string.find(text, "^ Рабочий день окончен$") then
                setPlayerClist(7)
            elseif string.find(text, "^ Рабочий день начат$") then
                setPlayerClist(config.personal.clist)
            end
        end
        if col == -1 and (string.find(text,
                                      "^ Здоровье %d+%/%d+%. Сытость %d+%/%d+%. У вас осталось %d+%/%d+% психохила$") or
            string.find(text,
                        "^ Вы истощены%. Здоровье снижено до %d+%/%d+%. У вас осталось %d+%/%d+% психохила$")) and
            config.checkfood.sbiv and not isCharInAnyCar(PLAYER_PED) then
            lua_thread.create(function()
                wait(1)
                sampSendChat(" ")
            end)
        end
    end
end

function sampev.onSendDeathNotification(reason, id)
    if variables.loaded then
        if config.clist.death then
            local skin = getCharModel(PLAYER_PED)
            if skin == 287 or skin == 191 then
                if config.personal.clist ~= nil then
                    lua_thread.create(function()
                        repeat wait(0) until getActiveInterior() ~= 0
                        setPlayerClist(config.personal.clist)
                    end)
                end
            end
        end
    end
end

function sampev.onSetPlayerColor(id, color)
    if variables.loaded then
        if variables.logined and config.clist.synchronization and
            isCharInAnyCar(PLAYER_PED) then
            local result, ped = sampGetCharHandleBySampPlayerId(id)
            if not result or ped == PLAYER_PED then
                return {id, color}
            end

            local car = storeCarCharIsInNoSave(PLAYER_PED)
            local driver = getDriverOfCar(car)
            if ped ~= driver then return {id, color} end
            local cl = variables.clists[color]
            local mycl = variables.clists[sampGetPlayerColor(select(2,
                                                                    sampGetPlayerIdByCharHandle(
                                                                        PLAYER_PED)))]
            if cl == mycl then return end
            setPlayerClist()
        end
    end
end

function sampev.onSendChat(message)
    chatManager.lastMessage = message
    chatManager.updateAntifloodClock()
end

function sampev.onSendCommand(message)
    chatManager.lastMessage = message
    chatManager.updateAntifloodClock()
end

_utf8 = load(
            [=[return function(utf8_func, in_encoding, out_encoding); if encoding == nil then; encoding = require("encoding"); encoding.default = "CP1251"; u8 = encoding.UTF8; end; if type(utf8_func) ~= "table" then; return false; end; if AnsiToUtf8 == nil or Utf8ToAnsi == nil then; AnsiToUtf8 = function(text); return u8(text); end; Utf8ToAnsi = function(text); return u8:decode(text); end; end; if _UTF8_FUNCTION_SAVE == nil then; _UTF8_FUNCTION_SAVE = {}; end; local change_var = "_G"; for s = 1, #utf8_func do; change_var = string.format('%s["%s"]', change_var, utf8_func[s]); end; if _UTF8_FUNCTION_SAVE[change_var] == nil then; _UTF8_FUNCTION = function(...); local pack = table.pack(...); readTable = function(t, enc); for k, v in next, t do; if type(v) == 'table' then; readTable(v, enc); else; if enc ~= nil and (enc == "AnsiToUtf8" or enc == "Utf8ToAnsi") then; if type(k) == "string" then; k = _G[enc](k); end; if type(v) == "string" then; t[k] = _G[enc](v); end; end; end; end; return t; end; return table.unpack(readTable({_UTF8_FUNCTION_SAVE[change_var](table.unpack(readTable(pack, in_encoding)))}, out_encoding)); end; local text = string.format("_UTF8_FUNCTION_SAVE['%s'] = %s; %s = _UTF8_FUNCTION;", change_var, change_var, change_var); load(text)(); _UTF8_FUNCTION = nil; end; return true; end]=])
function utf8(...) pcall(_utf8(), ...) end

utf8({"sampSendChat"}, "Utf8ToAnsi")
utf8({"sampAddChatMessage"}, "Utf8ToAnsi")
utf8({"print"}, "Utf8ToAnsi")
utf8({"sampSetChatInputText"}, "Utf8ToAnsi")
utf8({"sampev", "onShowDialog"}, "AnsiToUtf8", "Utf8ToAnsi")
utf8({"sampev", "onServerMessage"}, "AnsiToUtf8", "Utf8ToAnsi")
utf8({"sampev", "onSendChat"}, "AnsiToUtf8")
utf8({"sampev", "onSendCommand"}, "AnsiToUtf8")
