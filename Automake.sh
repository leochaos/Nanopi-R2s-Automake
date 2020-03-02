#!/bin/bash
#fonts color
Green="\033[32m"
Red="\033[31m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

# Info="${Green}[信息]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[错误]${Font}"

# 版本
shell_version="V1.0-测试版"
shell_mode="None"
github_branch="master"



judge() {
    if [[ 0 -eq $? ]]; then
        echo -e "${OK} ${GreenBG} $1 完成 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${RedBG} $1 失败${Font}"
        exit 1
    fi
}

install_auto(){
	# Root
	[[ $(id -u) = 0 ]] && echo -e "\n 哎呀……请不要使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1
	git config --local user.email "action@github.com" && git config --local user.name "GitHub Action"
	#sudo rm -rf /etc/apt/sources.list.d
	#更新源
	sudo apt-get update
	#安装依赖
	sudo apt-get -y install bc build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler

	#安装编译环境
	wget -O - https://raw.githubusercontent.com/friendlyarm/build-env-on-ubuntu-bionic/master/install.sh | bash
	#
	sudo rm -rf /usr/share/dotnet /usr/local/lib/android/sdk
	#安装repo
	git clone https://github.com/friendlyarm/repo
	sudo cp repo/repo /usr/bin/

	#新建文件夹
	mkdir friendlywrt-rk3328
	#打开文件夹
	cd friendlywrt-rk3328
	#repo源代码
	git config --local user.email "automake@github.com" && git config --local user.name "Automake shell"

	repo init -u https://github.com/friendlyarm/friendlywrt_manifests -b master-v19.07.1 -m rk3328.xml --repo-url=https://github.com/friendlyarm/repo --no-clone-bundle
	repo sync -c --no-clone-bundle -j8
	#回到根目录
	cd ../
	git clone https://github.com/coolsnowwolf/lede

	git clone https://github.com/Lienol/openwrt-package.git

	#git remote add upstream https://github.com/coolsnowwolf/lede && git fetch upstream

	cp -r ./lede/package/lean ${HOME}/friendlywrt-rk3328/friendlywrt/package

	#-----------------------------------------------------------------------
	rm -rf ./friendlywrt-rk3328/friendlywrt/package/feeds.conf.default

	cp -r ./lede/feeds.conf.default ${HOME}/friendlywrt-rk3328/friendlywrt/

	#-----------------------------------------------------------------------
	rm -rf ./friendlywrt-rk3328/friendlywrt/package/lean/v2ray

	rm -rf ./friendlywrt-rk3328/friendlywrt/package/lean/v2ray-plugin

	cp -r ./openwrt-package/package/v2ray ${HOME}/friendlywrt-rk3328/friendlywrt/package/lean 

	cp -r ./openwrt-package/package/v2ray-plugin ${HOME}/friendlywrt-rk3328/friendlywrt/package/lean

	#-----------------------------------------------------------------------

	cd ./friendlywrt-rk3328/friendlywrt/

	./scripts/feeds update -a && ./scripts/feeds install -a

	sed -i '/Load Average/i\<tr><td width="33%"><%:CPU Temperature%></td><td><%=luci.sys.exec("cut -c1-2 /sys/class/thermal/thermal_zone0/temp")%></td></tr>' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

	sed -i 's/pcdata(boardinfo.system or "?")/"ARMv8"/' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

	make menuconfig

	cd ../../
	
	menu
}
start_make(){
	cd ./friendlywrt-rk3328 

	./build.sh nanopi_r2s.mk

	rm -rf ./artifact/

	mkdir -p ./artifact/

	find ./out/ -name "FriendlyWrt_*img*" | xargs -i zip -r {}.zip {}

	find ./out/ -name "FriendlyWrt_*img.zip*" | xargs -i mv -f {} ./artifact/

	echo -e "\t---编译完成啦！请到/artifact目录查看哟~~~---"   

}

start_makes(){
	#二次编译
	#-----------------------------------------------------------------------
	#更新L大源码
	#cd ./lede
	#git remote add upstream https://github.com/coolsnowwolf/lede && git fetch upstream #更新源码
	#./scripts/feeds update -a && ./scripts/feeds install -a #更新FEEDS
	#rm -rf ./friendlywrt-rk3328/friendlywrt/package/feeds.conf.default  #删除原有feeds
	#rm -rf ./friendlywrt-rk3328/friendlywrt/package/lean  #删除原有插件
	#cp -r ./lede/lean ${HOME}/friendlywrt-rk3328/friendlywrt/lean  #复制新的插件到改目录
	#cp -r ./lede/feeds.conf.default ${HOME}/friendlywrt-rk3328/friendlywrt/ #将新得feeds复制到friendlywrt
	#cd ../ #回到根目录
	#-----------------------------------------------------------------------
	#更新package
	#cd ./openwrt-package
	#git remote add upstream https://github.com/Lienol/openwrt-package.git && git fetch upstream #更新源码
	#cd ../ #回到根目录
	#-----------------------------------------------------------------------
	cd ./friendlywrt-rk3328/
	#rm -rf ./tmp #清除缓存
	cd ./friendlywrt
	#rm -rf ./tmp #清除缓存
	./scripts/feeds update -a && ./scripts/feeds install -a #更新FEEDS
	sed -i '/Load Average/i\<tr><td width="33%"><%:CPU Temperature%></td><td><%=luci.sys.exec("cut -c1-2 /sys/class/thermal/thermal_zone0/temp")%></td></tr>' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

	sed -i 's/pcdata(boardinfo.system or "?")/"ARMv8"/' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

	#----------------------------------------------------------------------
	#rm -rf .config #清除编译配置和缓存
	#----------------------------------------------------------------------
	make menuconfig #进入编译配置菜单
	
	cd ../
	
	cd ./friendlywrt-rk3328
	
	./build.sh nanopi_r2s.mk
	
	rm -rf ./artifact/

	mkdir -p ./artifact/

	find ./out/ -name "FriendlyWrt_*img*" | xargs -i zip -r {}.zip {}

	find ./out/ -name "FriendlyWrt_*img.zip*" | xargs -i mv -f {} ./artifact/

	echo -e "\t---编译完成啦！请到/artifact目录查看哟~~~---"   
}

list() {
    case $1 in
    *)
        menu
        ;;
    esac
}
menu() {

    update_sh
    clear
    echo
	echo "#############################################################"
	echo "# 全自动安装编译环境【仅用于R2S编译】 管理脚本                  #"
	echo "# Author: Chikage <Poplar>                                  #"
	echo "# Github: https://github.com/yangzifan89                    #"
        echo "#请注意不要使用root用户登录执行此脚本                          #"
        echo "#请确保当前用户目录下空文件,系统推荐 Ubuntu18.0.4TSL           #"
        echo "#当前已安装版本:${shell_mode}                                #"
	echo "#############################################################"
	echo "                                                             "
	echo "                                                             "
	echo "                                                             "	    
 	echo -e "—————————————— 【安装向导】 ——————————————"
	echo -e "1.        全自动安装编译环境"
	echo -e "2.        开始编译         "	
	echo -e "—————————————— 【配置变更】 ——————————————"
	echo -e "3.        变更 config      "
	echo "                                                             "
	echo -e "4.        自动拉取最新更新(二次编译)                        "    
	echo -e "——————————————   【退出】   ——————————————"   
	echo -e "0.        退出 \n                                         "

    read -rp "请输入数字：" menu_num
    case $menu_num in
    #0)
        #update_sh
        #;;
    1)
        shell_mode="autoinstall"
        install_auto
        ;;
    2)
    	shell_mode="start_make"
	start_make
	;;
    3)
        shell_mode="h2"
        chang_config
        ;;
    4)
        shell_mode="start_makes"
	start_makes
        ;;
    0)
        exit 0
        ;;
    *)
        echo -e "${RedBG}请输入正确的数字${Font}"
        ;;
    esac
}
list "$1"



#配置默认ip：vi ./friendlywrt-rk3328/friendlywrt/package/base-files/files/bin/config_generate
#配置默认主题：222

