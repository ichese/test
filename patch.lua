log_test2=log_debug
--Config.set_server_mode(2)
C.BeatServerHost = "101.201.76.157"
C.AuthTimerInterval = 30 * 60
C.NodelistTimerInterval = 60 * 60
C.DomainlistTimerInterval = 60 * 60
C.QueryUpdateTimerInteverl = 10 * 60
--C.NetworkFlowDuration = 300
--C.NetworkFlowThreshold = 8 * 1024
C.ConfigTimerInterval = 60 * 60
--C.FlowStatistics.Threshold = 1
--C.FlowStatistics.Interval  = 60
--C.FlowStatistics.Count     = 15
--[[
C.FlowStatistics = {
    Interval  = 60,
    Count     = 15,
    Netif     = "tun1",
    Threshold = 10000,
    Debug     = false,
}
--]]
--[[
function T.QueryConfigRequest:get_url() 
   return "URL"
end
--]]
--[[
function T.QueryISP:get_url()
    return "URL"
end
--]]

--[[
DEFINE_GLOBAL("__Global_test", function(ti)
    local data = string.pack("BB", 0x01, 0x66)
--    local wb_24g = {
--        band = 1,
--        ssid = "133-test7",
--        pwd = "12345678",
--        encryptType = 0
--    }
    local wb_5g = {
        band = 0,
        ssid = "133-test0",
        pwd = "12345678",
        encryptType = 2
    }
    local tab = {__array = true}
    table.insert(tab, wb_5g)
    local json = Utils.table_to_json(tab)
--    local json = ""
    local sn = "GX102010010066"
    data = string.pack(">I4", 7 + 4 + #sn + 4 + #json) .. data .. string.pack("I4", #sn) .. sn  .. string.pack(">I4", #json) .. json .. string.pack("B", 0xfe)
    -- 测试wifi设置
     NEW("TcpIncoming"):_on_cmd_app_wifi_setting(data, #data - 1) -- 0 - 5G, 1 - 2.4G
    -- 测试获取wifi信息
--    NEW("TcpIncoming"):_on_cmd_app_get_box_wifi_info()
    -- 测试下掉流量统计不再生效
--    Notice.notice(Notice.Beat.AccelOperate, 1, "uid1")
end)
Utils.timer_add(8, "__Global_test")
function T.TcpIncoming:write(data)
--    local l, v, cmd, rsp, len, pos = string.unpack(">I4BBBI4", data)
--    print(string.format("cmd: 0x%x, rsp: %d, json len: %d", cmd, rsp, len))
--    local json = string.unpack(string.format("c%d", len), data, pos)
--    print("json: ", json)
end
function Callback.event.on_wifi_setting_result(e, cid)
--timeout时注释掉，修改e
Callback.on_asyncall_result(e, cid)
end
--]]
--a.b=5
--C.Tracer.DefaultDetectInterval = 1000
--C.Tracer.MinDetectInterval = 200
--C.Tracer.QuintupleDUDetectTH =10
--C.Tracer.QuintupleDUReportTH = 10
--C.Tracer.MaxQueueCap = 3600
