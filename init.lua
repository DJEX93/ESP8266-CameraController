--Connects to the camera directly, sets Record Mode and takes a photo.
--
--To change focus and other settings:
--  shut off the ESP8266
--    connect to the camera with your phone
--        set the zoom and options as desired
--            disconnect your phone
--                power on the ESP8266

--Params
ssid = "SidPwnt_Camera" --SSID for camera as AP only
pass = "a784b87a382e7" --Password for camera as AP only
interval = 10

--functions
reply = ""
function sendHttp(host,requestString)
    sk=net.createConnection(net.TCP, 0) 
    sk:on("receive", function(sck, c)
        reply = c
    end)
    sk:on("connection", function(sck) 
        sck:send("GET /" .. requestString .." HTTP/1.1\r\nHost: " .. host .. "\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n") 
    end) 
    sk:connect(80,host)
end

--Lumix TZ40 API's
camera = "192.168.54.1"
recMode = "/cam.cgi?mode=camcmd&value=recmode"
takePhoto = "/cam.cgi?mode=camcmd&value=capture"
--powerOff = "/cam.cgi?mode=camcmd&value=poweroff"
getCamState = "/cam.cgi?mode=getstate"

--Connect WiFi
wifi.setmode(wifi.STATION)
wifi.sta.config(ssid, pass)
wifi.sta.connect()

--Intervalometer
function startIntervalometer()
    tmr.alarm(1, (interval * 1000), 1, function() sendHttp(camera, takePhoto) end)
end

--Set camera in to recMode
function setupCamera()
    sendHttp(camera, recMode) 
    startIntervalometer()
end

--Safely wait for the camera and ESP8266 to connect to each other ok first
tmr.alarm(0, 4000, 0, setupCamera)
