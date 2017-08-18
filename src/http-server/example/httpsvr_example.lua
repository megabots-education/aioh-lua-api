require("httpsvr")

-- Conecta na rede wifi
wifi_sta_config={}
wifi_sta_config.ssid = "MCAF"
wifi_sta_config.pwd = "27111997"

wifi.setmode(wifi.STATION)
wifi.sta.config(wifi_sta_config)
wifi.sta.connect()

timeout = 0

tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip() == nil then
        print("Conectando...")
        timeout = timeout + 1
    elseif timeout >= 60 then
        print("Não foi possível se conectar a rede wifi " .. wifi_sta_config.ssid .. "com a senha " .. wifi_sta_config.pwd)
    else
        tmr.stop(1)
        tmr.wdclr()
        timeout = nil
        print("Conectado com sucesso a rede " .. wifi_sta_config.ssid)
        ip, nm, gt = wifi.sta.getip()
        print("IP: " .. ip)
        print("MAC: " .. wifi.sta.getmac())
        print("Net Mask: " .. nm)
        print("Gateway: " .. gt)
    end
end)

httpsvr.start(80)

httpsvr.attatchEvent("/", "POST", function(conn, request)
  if request.header["action"] == "create-file" then
    fd = file.open(request.header["file-name"], "w")
    if fd then
        fd:write(request.body)
        fd:close()
        httpsvr.sendResponse(conn, 200, "Arquivo criado com sucesso!")
    else
        httpsvr.sendResponse(conn, 500, "Erro ao criar arquivo")
    end
  else
    httpsvr.sendResponse(conn, 400, "Cabeçalho incompleto")
  end
end)

httpsvr.attatchEvent("/", "GET", function(conn, request)
    if request.header["file-name"] then
        fd = file.open(request.header["file-name"], "r")
        httpsvr.sendResponseCode(conn, 200)
        line = fd:readline()
        repeat
            conn:send(line)
            line = fd:readline()
        until line == nil
        fd:close()
    else
        httpsvr.sendResponse(conn, 400, "Cabeçalho incompleto")
    end
end)
