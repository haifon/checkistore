module("luci.controller.check_istore", package.seeall)

function index()
    entry({"admin", "checkistore"}, template("check_istore"), _("iStore检测"), 90).dependent=false
    entry({"admin", "checkistore", "install"}, call("action_install"), nil).dependent=false
    entry({"admin", "checkistore", "upload_ipk"}, call("action_upload_ipk"), nil).dependent=false
    entry({"admin", "checkistore", "viewlog"}, call("action_viewlog"), nil).dependent=false
end

-- 自动判断包管理器 apk / opkg
local function get_pkg_mgr()
    local f = io.popen("command -v apk 2>/dev/null")
    local apk_exist = f:read("*a")
    f:close()
    if #apk_exist > 0 then
        return "apk"
    else
        return "opkg"
    end
end

-- 检测 luci-app-store 是否已安装
local function istore_installed()
    local mgr = get_pkg_mgr()
    local cmd
    if mgr == "apk" then
        cmd = "apk info 2>/dev/null | grep luci-app-store"
    else
        cmd = "opkg list-installed | grep luci-app-store"
    end
    local f = io.popen(cmd)
    local res = f:read("*a")
    f:close()
    return #res > 0
end

-- 一键安装iStore后台任务
function action_install()
    luci.http.prepare_content("text/plain")
    local cmd = [[
cd /tmp
wget --no-check-certificate https://gitee.com/wukongdaily/commonscript/raw/master/common/reinstall_istore.sh
chmod +x reinstall_istore.sh
./reinstall_istore.sh > /tmp/istore_install.log 2>&1 &
]]
    os.execute(cmd)
    luci.http.write("✅iStore安装任务后台启动！\n日志路径：/tmp/istore_install.log\n点击【查看日志】按钮实时查看")
end

-- 上传IPK并安装（apk使用 apk add --allow-untrusted；opkg使用opkg install）
function action_upload_ipk()
    local fp
    luci.http.setfilehandler(
        function(meta, chunk, eof)
            if not fp then
                fp = io.open("/tmp/upload.ipk", "wb")
            end
            if chunk then
                fp:write(chunk)
            end
            if eof and fp then
                fp:close()
            end
        end
    )
    local file = luci.http.formvalue("ipkfile")
    if file then
        local mgr = get_pkg_mgr()
        local install_cmd
        if mgr == "apk" then
            install_cmd = "apk add --allow-untrusted /tmp/upload.ipk > /tmp/ipk_install.log 2>&1"
        else
            install_cmd = "opkg install /tmp/upload.ipk > /tmp/ipk_install.log 2>&1"
        end
        os.execute(install_cmd)
        luci.http.prepare_content("text/plain")
        luci.http.write("✅IPK上传完成，开始安装！\n日志：/tmp/ipk_install.log")
    end
end

-- 读取日志
function action_viewlog()
    luci.http.prepare_content("text/plain")
    local logname = luci.http.formvalue("logname") or "istore_install.log"
    local path = "/tmp/"..logname
    local f = io.open(path,"r")
    if f then
        local data = f:read("*a")
        f:close()
        luci.http.write(data)
    else
        luci.http.write("日志文件不存在！")
    end
end
