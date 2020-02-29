#!/bin/bash
echo "全自动安装编译环境【仅用于R2S编译】"
echo "全自动安装编译环境【仅用于R2S编译】"
echo "全自动安装编译环境【仅用于R2S编译】"
echo "全自动安装编译环境【仅用于R2S编译】"
echo "即将开始执行"
echo "即将开始执行"
echo "即将开始执行"

# Root
[[ $(id -u) = 0 ]] && echo -e "\n 哎呀……请不要使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1
	
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

	cp -r ./lede/package/lean /home/test/friendlywrt-rk3328/friendlywrt/package

	#-----------------------------------------------------------------------
	rm -rf ./friendlywrt-rk3328/friendlywrt/package/feeds.conf.default

	cp -r ./lede/feeds.conf.default /home/test/friendlywrt-rk3328/friendlywrt/

	#-----------------------------------------------------------------------
	rm -rf ./friendlywrt-rk3328/friendlywrt/package/lean/v2ray

	rm -rf ./friendlywrt-rk3328/friendlywrt/package/lean/v2ray-plugin

	cp -r ./openwrt-package/package/v2ray /home/test/friendlywrt-rk3328/friendlywrt/package/lean 

	cp -r ./openwrt-package/package/v2ray-plugin /home/test/friendlywrt-rk3328/friendlywrt/package/lean

	#-----------------------------------------------------------------------

	cd ./friendlywrt-rk3328/friendlywrt/

	./scripts/feeds update -a && ./scripts/feeds install -a

	sed -i '/Load Average/i\<tr><td width="33%"><%:CPU Temperature%></td><td><%=luci.sys.exec("cut -c1-2 /sys/class/thermal/thermal_zone0/temp")%></td></tr>' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

	sed -i 's/pcdata(boardinfo.system or "?")/"ARMv8"/' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

	make menuconfig

	../

	./build.sh nanopi_r2s.mk

	rm -rf ./artifact/

	mkdir -p ./artifact/

	find ./out/ -name "FriendlyWrt_*img*" | xargs -i zip -r {}.zip {}

	find ./out/ -name "FriendlyWrt_*img.zip*" | xargs -i mv -f {} ./artifact/

    echo -e "\t---编译完成啦！请到/artifact目录查看哟~~~---"   


