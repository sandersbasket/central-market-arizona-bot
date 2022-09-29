script_name('central market notf')
script_author('sanders')
local sW, sH = getScreenResolution()
local imgui = require "imgui"
local inicfg = require 'inicfg'
local encoding = require ("encoding")
encoding.default = "CP1251"
u8 = encoding.UTF8
-- imgui
local window = imgui.ImBool(false)
-- config 
local act = false
local mainIni = inicfg.load({ -- CFG
    config = {
        user = '',
        token = '', 
        tgchat = '',
        tgtoken = '', 
        vknotf = false,
        tgnotf = false,
        enable = false
    }
}, "cmarket")
local user = imgui.ImBuffer(u8(mainIni.config.user), 256)
local token = imgui.ImBuffer(u8(mainIni.config.token), 256)
local tguser = imgui.ImBuffer(u8(mainIni.config.tgchat), 256)
local tgtoken = imgui.ImBuffer(u8(mainIni.config.tgtoken), 256)
local vknotf = imgui.ImBool(mainIni.config.vknotf)
local tgnotf = imgui.ImBool(mainIni.config.tgnotf)
local enable = imgui.ImBool(mainIni.config.enable)

local status = inicfg.load(mainIni, 'cmarket.ini')
if not doesFileExist('moonloader/config/cmarket.ini') then inicfg.save(mainIni, 'cmarket.ini') end

function main()
    while not isSampAvailable() do wait(0) end
    print('cmarket loaded [sanders] vk.com/sanders_scripts')
    sampRegisterChatCommand('cmarket', function()
        window.v = not window.v
    end)
    while true do 
        wait(0)
        if enable.v then  
            act = true 
        else 
            act = false 
        end
        imgui.Process = window.v
        style()
    end
end


function imgui.OnDrawFrame()
    if window.v then  
        imgui.SetNextWindowPos(imgui.ImVec2(sW / 2, sH / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(350, 255), imgui.Cond.FirstUseEver)
        imgui.Begin('Central market notf | SL TEAM', window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize)
            imgui.Text(u8"В данный момент отправка в VK: ")
            imgui.SameLine()
            if act then
                imgui.TextColored(imgui.ImVec4(0, 143, 0, 1), u8"Включена")
            else
                imgui.TextColored(imgui.ImVec4(58, 81, 194, 1), u8"Выключена")
            end
            if imgui.Checkbox('Enable', enable) then  
                act = not act
            end
            imgui.Checkbox('Notf VK', vknotf)
            if vknotf.v then  
                imgui.PushItemWidth(235)
                imgui.Text('Token')
                imgui.SameLine(60)
                imgui.InputText('##2', token, imgui.InputTextFlags.Password)
                imgui.Text('User ID')
                imgui.SameLine(60)
                imgui.InputText('##3', user)
                imgui.PopItemWidth()
                if imgui.Button('Test Message') then  
                    if token ~= '' and user ~= '' then  
                        sendVK('TestMessage')
                    else
                        printStringNow('~r~Not Found information!', 1500)
                    end
                end
            end
            imgui.Checkbox('Notf TG', tgnotf)
            if tgnotf.v then  
                imgui.PushItemWidth(235)
                imgui.Text('Token')
                imgui.SameLine(60)
                imgui.InputText('##22', tgtoken, imgui.InputTextFlags.Password)
                imgui.Text('User ID')
                imgui.SameLine(60)
                imgui.InputText('##33', tguser)
                imgui.PopItemWidth()
                if imgui.Button('Test Message') then  
                    if tgtoken ~= '' and tguser ~= '' then  
                        sendTG('TestMessage')
                    else
                        printStringNow('~r~Not Found information!', 1500)
                    end
                end
            end
            if imgui.Button("SL TEAM CHAT", imgui.ImVec2(335, 30)) then imgui.OpenPopup(u8"Подтверждение")   end
            if imgui.BeginPopupModal(u8"Подтверждение", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)  then
                if imgui.Button(u8"Перейти", imgui.ImVec2(100, 30)) then
                    os.execute('explorer "https://t.me/joinchat/AAAAAFUTPf7K_-9XlsmIkw"')
                    imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if imgui.Button(u8"Передумал", imgui.ImVec2(100, 30)) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
		    end
            if imgui.Button('SAVE',imgui.ImVec2(335, 25)) then  
                mainIni.config.token = token.v
                mainIni.config.user = user.v
                mainIni.config.tgtoken = tgtoken.v  
                mainIni.config.tguser = tguser.v  
                mainIni.config.vknotf = vknotf.v 
                mainIni.config.tgnotf = tgnotf.v  
                mainIni.config.enable = enable.v 
                inicfg.save(mainIni, 'cmarket.ini')
                printStringNow('~u~ ~p~SAVED~p~ ~u~', 1000)
                addOneOffSound(0.0, 0.0, 0.0, 1138)
                printStringNow('~u~ ~p~SAVED~p~ ~u~', 1000)
            end
        imgui.End()
    end
end

local sampev = require('lib.samp.events')
function sampev.onServerMessage(color, text)
    if enable.v then  
        if text:find("Вы купили") then  
            if vknotf.v and user.v ~= '' and token ~= '' then  
                local info = text:match('Вы купили (.+)')
                local object = text:match('Вы купили (.+) %(')
                local quantity = text:match('(%d+) шт.%)% у')
                local nameped = text:match('%)% у игрока (%a+_%a+) за')
                local money = text:match('за $(.+)')
                local id = sampGetPlayerIdByCharHandle(PLAYER_PED)
                if info ~= nil and object ~= nil and quantity ~= nil and nameped ~= nil and money ~= nil then  
                    sendVK('------СКУПКА------%0ALog: '..info.."%0AВам продали: "..object..'%0AВ количестве: '..quantity..'%0AИгрок: '..nameped..'%0AПотрачено: '..money..'$'..'%0AДенег осталось: '..getPlayerMoney(id))
                end
            end
            if tgnotf.v and tgchat ~= '' and tgtoken ~= '' then  
                local info = text:match('Вы купили (.+) ((%d+) шт.) у игрока (%a+)_(%a+) за $(.+)')
                local object = text:match('Вы купили (.+) (')
                local quantity = text:match('((%d+) шт.) у')
                local nameped = text:match(') у игрока (%a+)_(%a+) за')
                local money = text:match('за $(.+)')
                if info ~= nil and object ~= nil and quantity ~= nil and nameped ~= nil and money ~= nil then  
                    sendTG('------СКУПКА------%0ALog: '..info.."%0AВам продали: "..object..'%0AВ количестве: '..quantity..'%0AИгрок: '..nameped..'%0AПотрачено: '..money..'$'..'%0AДенег осталось: '..getPlayerMoney(id))
                end
            end
        end
        if text:find('купил у вас') then  
            local id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            if vknotf.v and user.v ~= '' and token ~= '' then  
                local buyinfo = text:match('купил у вас (.+)')
                local name = text:match('(%a+_%a+) купил')
                local bobject = text:match('у вас (.+) %(%d+')
                local bquantity = text:match('(%d+) шт.%)')
                local takemoney = text:match('вы получили $(.+) от')
                local commission =  text:match('комиссия (%d+)')
                if buyinfo ~= nil and name ~= nil and bobject ~= nil and bquantity ~= nil and takemoney ~= nil and commission ~= nil then  
                    sendVK('------ПРОДАЖА------%0ALog: '..buyinfo..'%0AУ вас купили: '..bobject..'%0AВ количестве: '..bquantity..'%0AИгрок: '..name..'%0AПолучено: '..takemoney..'$'..'%0AКомиссия: '..commission..'%'..'%0AВаши деньги: '..getPlayerMoney(id))
                end
            end
            if tgnotf.v and tgchat ~= '' and tgtoken ~= '' then 
                local buyinfo = text:match('купил у вас (.+)')
                local name = text:match('(%a+_%a+) купил')
                local bobject = text:match('у вас (.+) %(%d+')
                local bquantity = text:match('(%d+) шт.%)')
                local takemoney = text:match('вы получили $(.+) от')
                local commission =  text:match('комиссия (%d+)')
                if buyinfo ~= nil and name ~= nil and bobject ~= nil and bquantity ~= nil and takemoney ~= nil and commission ~= nil then 
                    sendTG('------ПРОДАЖА------%0ALog: '..buyinfo..'%0AУ вас купили: '..bobject..'%0AВ количестве: '..bquantity..'%0AИгрок: '..name..'%0AПолучено: '..takemoney..'$'..'%0AКомиссия: '..commission..'%'..'%0AВаши деньги: '..getPlayerMoney(id))
                end    
            end
        end
    end
end


function sendVK(text)
    server = sampGetCurrentServerName()
	alert_text = text
    text = u8(alert_text)
    urld = ('https://api.vk.com/method/messages.send?message='..text..'&user_id='..user.v..'&access_token='..token.v..'&v=5.50')
    downloadUrlToFile(urld,nil,nil)
end


function sendTG(text)
	server = sampGetCurrentServerName()
	alert_text = text
    text = u8(alert_text)
    urld = ('https://api.telegram.org/bot'..tgtoken.v..'/sendMessage?chat_id='..tguser.v..'&text='..text)
    downloadUrlToFile(urld,nil,nil)
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function rainbow(speed, alpha, offset)
    local clock = os.clock() + offset
    local r = math.floor(math.sin(clock * speed) * 127 + 128)
    local g = math.floor(math.sin(clock * speed + 2) * 127 + 128)
    local b = math.floor(math.sin(clock * speed + 4) * 127 + 128)
    return r,g,b,alpha
end

function style()
    local r,g,b,a = rainbow(1, 255, 0)
    local argb = join_argb(a, r, g, b)
    local a = a / 255
    local r = r / 255
    local g = g / 255
    local b = b / 255
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    colors[clr.TitleBgActive] = ImVec4(r, g, b, 1.00)
    colors[clr.CheckMark] = ImVec4(r, g, b, 1.00)
    colors[clr.SliderGrab] = ImVec4(r, g, b, 0.53)
    colors[clr.SliderGrabActive] = ImVec4(r, g, b, 1.00)
end
