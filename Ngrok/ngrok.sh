#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 6+
#	Description: Install the Ngrok server
#	Version: 1.0.0
#	Author: Yudi
#	Blog:https://blog.51cto.com/4507878
#=================================================

sh_ver="1.0.0"
filepath=$(cd "$(dirname "$0")" || exit; pwd)
ngrok_folder="/root/ngrok"
ngrok_log_file="/var/log/messages"
ngrok_cfg_file="${filepath}/ngrok.cfg"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
Separator_1="——————————————————————————————"

check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}
check_pid(){
	PID=$(pgrep ngrok)
}
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif grep -q -E -i "debian" /etc/issue ; then
		release="debian"
	elif grep -q -E -i "ubuntu" /etc/issue; then
		release="ubuntu"
	elif grep -q -E -i "centos|red hat|redhat" /etc/issue ; then
		release="centos"
	elif grep -q -E -i "debian" /proc/version ; then
		release="debian"
	elif grep -q -E -i "ubuntu" /proc/version ; then
		release="ubuntu"
	elif grep -q -E -i "centos|red hat|redhat" /proc/version ; then
		release="centos"
    fi
}
Ngrok_installation_status(){
	[[ ! -e ${ngrok_folder} ]] && echo -e "${Error} 没有发现 Ngrok 文件目录，请检查 !" && exit 1
}

# 设置配置信息
Set_config_domain(){
	echo -e "请输入要设置的 Ngrok 的域名"
	stty erase '^H' && read -r -p "(默认: my.theyudi.top):" NGROK_DOMAIN
	[[ -z "${NGROK_DOMAIN}" ]] && NGROK_DOMAIN="my.theyudi.top"
	echo && echo ${Separator_1} && echo -e "	域名 : ${Green_font_prefix}${NGROK_DOMAIN}${Font_color_suffix}" && echo ${Separator_1} && echo

}
Set_config_tunnelPort(){
	while true
	do
	echo -e "请输入要设置的ngrok.bat 脚本客户端与服务器 server 交互的端口"
	stty erase '^H' && read -r -p "(默认: 4443):" tunnelPort
	[[ -z "$tunnelPort" ]] && tunnelPort="4443"
	if (( tunnelPort + 0 ))  &>/dev/null; then
		if [[ ${tunnelPort} -ge 1 ]] && [[ ${tunnelPort} -le 65535 ]]; then
			echo && echo ${Separator_1} && echo -e "	端口 : ${Green_font_prefix}${tunnelPort}${Font_color_suffix}" && echo ${Separator_1} && echo
			break
		else
			echo -e "${Error} 请输入正确的数字(1-65535)"
		fi
	else
		echo -e "${Error} 请输入正确的数字(1-65535)"
	fi
	done
}

Set_config_httpPort(){
	while true
	do
	echo -e "请输入要设置的Ngrok的 http 的转发口"
	stty erase '^H' && read -r -p "(默认: 80):" httpPort
	[[ -z "$httpPort" ]] && httpPort="80"
	if (( httpPort + 0 ))  &>/dev/null; then
		if [[ ${httpPort} -ge 1 ]] && [[ ${httpPort} -le 65535 ]]; then
			echo && echo ${Separator_1} && echo -e "	端口 : ${Green_font_prefix}${httpPort}${Font_color_suffix}" && echo ${Separator_1} && echo
			break
		else
			echo -e "${Error} 请输入正确的数字(1-65535)"
		fi
	else
		echo -e "${Error} 请输入正确的数字(1-65535)"
	fi
	done
}
Set_config_httpsPort(){
	while true
	do
	echo -e "请输入要设置的Ngrok的 https 的转发口"
	stty erase '^H' && read -r -p "(默认: 443):" httpsPort
	[[ -z "$httpsPort" ]] && httpsPort="443"
	if (( httpsPort + 0 )) &>/dev/null; then
		if [[ ${httpsPort} -ge 1 ]] && [[ ${httpsPort} -le 65535 ]]; then
			echo && echo ${Separator_1} && echo -e "	端口 : ${Green_font_prefix}${httpsPort}${Font_color_suffix}" && echo ${Separator_1} && echo
			break
		else
			echo -e "${Error} 请输入正确的数字(1-65535)"
		fi
	else
		echo -e "${Error} 请输入正确的数字(1-65535)"
	fi
	done
}
Set_config_mstscPort(){
	while true
	do
	echo -e "请输入要设置的Ngrok的 mstsc 远程桌面的转发口"
	stty erase '^H' && read -r -p "(默认: 3389):" mstscPort
	[[ -z "$mstscPort" ]] && mstscPort="3389"
	if (( mstscPort + 0 )) &>/dev/null; then
		if [[ ${mstscPort} -ge 1 ]] && [[ ${mstscPort} -le 65535 ]]; then
			echo && echo ${Separator_1} && echo -e "	端口 : ${Green_font_prefix}${mstscPort}${Font_color_suffix}" && echo ${Separator_1} && echo
			break
		else
			echo -e "${Error} 请输入正确的数字(1-65535)"
		fi
	else
		echo -e "${Error} 请输入正确的数字(1-65535)"
	fi

	done
}
Create_config_file(){
	echo -e "NGROK_DOMAIN : ${NGROK_DOMAIN}" > "${ngrok_cfg_file}"
    echo -e "tunnelPort : ${tunnelPort}"    >> "${ngrok_cfg_file}"
    echo -e "httpPort   : ${httpPort}"      >> "${ngrok_cfg_file}"
    echo -e "httpsPort  : ${httpsPort}"     >> "${ngrok_cfg_file}"
    echo -e "mstscPort  : ${mstscPort}"     >> "${ngrok_cfg_file}"
}
Show_config_all(){
    echo && echo ${Separator_1} &&  cat "${ngrok_cfg_file}" && echo ${Separator_1} && echo
}
Get_config_all(){
    NGROK_DOMAIN=$(grep "NGROK_DOMAIN" "${ngrok_cfg_file}" | awk -F ':'  '{print $2}')
    tunnelPort=$(grep "tunnelPort" "${ngrok_cfg_file}" | awk -F ':'  '{print $2}')
    httpPort=$(grep "httpPort" "${ngrok_cfg_file}" | awk -F ':'  '{print $2}')
    httpsPort=$(grep "httpsPort" "${ngrok_cfg_file}" | awk -F ':'  '{print $2}')
    mstscPort=$(grep "mstscPort" "${ngrok_cfg_file}" | awk -F ':'  '{print $2}')
}
Set_config_all(){
	Set_config_domain
	Set_config_tunnelPort
	Set_config_httpPort
	Set_config_httpsPort
	Set_config_mstscPort
	Create_config_file
}

Check_go(){
	python_ver=$(go version)
	if [[ -z ${python_ver} ]]; then
		echo -e "${Info} 没有安装Go，开始安装..."
		if [[ ${release} == "centos" ]]; then
			yum install -y golang golang-pkg-windows-amd64 golang-pkg-windows-386
		else
			apt-get install -y golang golang-pkg-windows-amd64 golang-pkg-windows-386
		fi
	fi
}

# 安装 依赖
Installation_dependency(){
	if [[ ${release} == "centos" ]]; then
			yum update
            if grep "7\..*" /etc/redhat-release | grep -i centos>/dev/null ; then
                yum install -y openssl-devel curl curl-devel wget gcc gcc-c++ git mercurial unzip
                #yum install -y subversion bzr hg cpio expat-devel gettext-devel zlib-devel
            else
                yum install -y openssl-devel curl curl-devel wget gcc gcc-c++ git mercurial unzip
            fi
	else
		exit 1
	fi
	[[ ! -e "/usr/bin/unzip" ]] && echo -e "${Error} 依赖 unzip(解压压缩包) 安装失败，多半是软件包源的问题，请检查 !" && exit 1
	Check_go
	#echo "nameserver 8.8.8.8" > /etc/resolv.conf
	#echo "nameserver 8.8.4.4" >> /etc/resolv.conf
	cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

Download_Ngrok(){
	cd "/root/" || exit
	git clone https://github.com/tutumcloud/ngrok.git ngrok
	#git config --global http.sslVerify false
	#env GIT_SSL_NO_VERIFY=true git clone -b manyuser https://github.com/ToyoDAdoubi/Ngrok.git
	[[ ! -e ${ngrok_folder} ]] && echo -e "${Error} Ngrok服务端 下载失败 !" && exit 1
	cd ${ngrok_folder} || exit
	echo -e "${Info} Ngrok服务端 下载完成 !"
}

openssl_ngrok_ca () {
    #如果域名配置错误就会被拒绝连接
    cd ${ngrok_folder} || exit
    openssl genrsa -out rootCA.key 2048
    openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
    openssl genrsa -out device.key 2048
    openssl req -new -key device.key -subj "/CN=$NGROK_DOMAIN" -out device.csr
    openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000
    echo -e "${Info} 覆盖 ngrok 原本证书"
    cp --force rootCA.pem /root/ngrok/assets/client/tls/ngrokroot.crt
    cp --force device.crt /root/ngrok/assets/server/tls/snakeoil.crt
    cp --force device.key /root/ngrok/assets/server/tls/snakeoil.key
}

make_ngrok (){
    cd ${ngrok_folder} || exit
    echo -e "${Info} 开始编译 ngrok 的服务端..."
    GOOS=linux GOARCH=amd64 make release-server
    echo -e "${Info} 开始编译 ngrok 的客户端..."
    GOOS=windows GOARCH=amd64 make release-client
}

# 设置 防火墙规则
Status_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables status
	else
		iptables-status > /etc/iptables.up.rules
	fi
}
Show_iptables(){
    service iptables status
}
Add_iptables(){
	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport "${tunnelPort}" -j ACCEPT
	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport "${mstscPort}"  -j ACCEPT
	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport "${httpPort}"   -j ACCEPT
	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport "${httpsPort}"  -j ACCEPT
}
Del_iptables(){
	iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport "${tunnelPort}" -j ACCEPT
	iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport "${mstscPort}"  -j ACCEPT
	iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport "${httpPort}"   -j ACCEPT
	iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport "${httpsPort}"  -j ACCEPT
}
Save_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
        Status_iptables
	else
		iptables-save > /etc/iptables.up.rules
	fi
}
Set_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
		service ip6tables save
		chkconfig --level 2345 iptables on
		chkconfig --level 2345 ip6tables on
	else
		iptables-save > /etc/iptables.up.rules
		ip6tables-save > /etc/ip6tables.up.rules
		echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules\n/sbin/ip6tables-restore < /etc/ip6tables.up.rules' > /etc/network/if-pre-up.d/iptables
		chmod +x /etc/network/if-pre-up.d/iptables
	fi
}

Install_Ngrok(){
	check_root
	[[ -e ${ngrok_folder} ]] && echo -e "${Error} Ngrok 文件夹已存在，请检查( 如安装失败或者存在旧版本，请先卸载 ) !" && exit 1
	echo -e "${Info} 开始设置 Ngrok域名配置..."
	Set_config_all
	echo -e "${Info} 开始安装/配置 Ngrok依赖..."
	Installation_dependency
	echo -e "${Info} 开始下载/安装 Ngrok文件..."
	Download_Ngrok
	echo -e "${Info} 开始生成 Ngrok服务证书..."
	openssl_ngrok_ca
	echo -e "${Info} 开始编译 ngrok ..."
	make_ngrok
	echo -e "${Info} 开始设置 iptables防火墙..."
	Set_iptables
	echo -e "${Info} 开始添加 iptables防火墙规则..."
	Add_iptables
	echo -e "${Info} 开始保存 iptables防火墙规则..."
	Save_iptables
	echo -e "${Info} 所有步骤 安装完毕，可以开始启动 Ngrok服务端..."
}
Uninstall_Ngrok(){
	[[ ! -e ${ngrok_folder} ]] && echo -e "${Error} 没有安装 Ngrok，请检查 !" && exit 1
	echo "确定要 卸载Ngrok？[y/N]" && echo
	stty erase '^H' && read -r -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		Ngrok_installation_status
        check_pid
            if [[ -n $PID ]]
            then
                echo -e "${Info} Ngrok 正在运行，现在停止Ngrok !"
                kill -9 "${PID}"
            else
                echo -e "${Info} Ngrok 没有运行,直接卸载Ngrok !"
            fi
		Get_config_all
		echo -e "${Info} 开始删除 iptables防火墙规则..."
        Del_iptables
        echo -e "${Info} 开始保存 iptables防火墙规则..."
        Save_iptables
        echo -e "${Info} 开始删除 ${ngrok_cfg_file} ..."
        rm -rf "${ngrok_cfg_file}"
        echo -e "${Info} 开始删除 ${ngrok_folder} ..."
		rm -rf "${ngrok_folder}"
		echo && echo " Ngrok 卸载完成 !" && echo
	else
		echo && echo " 卸载已取消..." && echo
	fi
}
#Ngrok手工管理
Start_Ngrok(){
	Ngrok_installation_status
    check_pid
    if [[ -n $PID ]]
	then
	    echo -e "${Error} Ngrok 正在运行 !" && exit 1
	else
	    echo -e "${Info} Ngrok 没有运行，现在启动Ngrok !"
	    Set_config_all
	    nohup /root/ngrok/bin/ngrokd -domain="$NGROK_DOMAIN"  -httpAddr=":${httpPort}" -httpsAddr=":${httpsPort}" -tunnelAddr=":${tunnelPort}" &
	    netstat -an | grep -E "$tunnelPort|$httpPort|$httpsPort|$mstscPort"
	fi
}
Stop_Ngrok(){
	Ngrok_installation_status
	check_pid
    if [[ -n $PID ]]
	then
	    echo -e "${Info} Ngrok 正在运行，现在停止Ngrok !"
	    kill -9 "${PID}"
	else
	    echo -e "${Error} Ngrok 没有运行 !" && exit 1
	fi
}
Restart_Ngrok(){
	Ngrok_installation_status
	check_pid
    if [[ -n $PID ]]
	then
	    echo -e "${Info} Ngrok 正在运行，现在停止Ngrok !"
	    kill -9 "${PID}"
	    Start_Ngrok
	else
	    echo -e "${Info} Ngrok 没有运行，直接启动Ngrok !"
	    Start_Ngrok
	fi
}
Status_Ngrok(){
    Ngrok_installation_status
    check_pid
    if [[ -n $PID ]]
    then
	    echo -e "${Info} Ngrok 正在运行!"
	    netstat -an | grep tcp  | grep LISTEN | grep :::
	else
	    echo -e "${Info} Ngrok 没有运行!"
	fi
}
View_Log(){
	Ngrok_installation_status
	[[ ! -e ${ngrok_log_file} ]] && echo -e "${Error} Ngrok日志文件不存在 !" && exit 1
	echo && echo -e "${Tip} 按 ${Red_font_prefix}Ctrl+C${Font_color_suffix} 终止查看日志" && echo
	tail -f ${ngrok_log_file}
}

# 显示 菜单状态
menu_status(){
	if [[ -e ${ngrok_folder} ]]; then
		check_pid
		if [[ -n "${PID}" ]]; then
			echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
		else
			echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
		fi
	else
		echo -e " 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
	fi
}
check_sys
[[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
echo -e "  Ngrok 一键管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  ---- Yudi | yudiatgg@gmail.com ----

 ${Green_font_prefix}1.${Font_color_suffix} 安装 Ngrok
 ${Green_font_prefix}2.${Font_color_suffix} 查看 Ngrok 配置
 ${Green_font_prefix}3.${Font_color_suffix} 卸载 Ngrok
————————————
 ${Green_font_prefix}4.${Font_color_suffix} 启动 Ngrok
 ${Green_font_prefix}5.${Font_color_suffix} 停止 Ngrok
 ${Green_font_prefix}6.${Font_color_suffix} 重启 Ngrok
 ${Green_font_prefix}7.${Font_color_suffix} 检查 Ngrok 状态
 ${Green_font_prefix}8.${Font_color_suffix} 查看 Ngrok 日志
————————————
 ${Green_font_prefix}9.${Font_color_suffix} 查看 iptables 配置

 "
menu_status
echo && stty erase '^H' && read -r -p "请输入数字 [1-9]：" num
case "$num" in
	1)
	Install_Ngrok
	;;
	2)
	Show_config_all
	;;
	3)
	Uninstall_Ngrok
	;;
	4)
	Start_Ngrok
	;;
	5)
	Stop_Ngrok
	;;
	6)
	Restart_Ngrok
	;;
	7)
	Status_Ngrok
	;;
	8)
	View_Log
	;;
	9)
	Show_iptables
	;;
	*)
	echo -e "${Error} 请输入正确的数字 [1-9]"
	;;
esac
