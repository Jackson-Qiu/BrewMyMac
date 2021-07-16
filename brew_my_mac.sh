#! /bin/bash

cat << -EOF
#######################################################################
# 🍻 BrewMyMac -- 自动化安装 & 备份 macOS 应用程序
#
# 使用说明&项目地址:
# https://github.com/jsmjsm/BrewMyMac
#
# 原理:
# 利用 Homebrew 作为 macOS 的包管理器
# brew install 安装命令行与 GUI 程序
#
# 注意事项:
# 1. macOS 尽量保持较新版本，否则可能满足不了 Homebrew 的依赖要求
# 2. 中途若遇见安装非常慢的情况，可用 Ctrl+C 打断，直接进行下一项的安装
#######################################################################
-EOF

# Global Variable
type=0
WD=`pwd`/backup

# > Install Homebrew
install_homebrew (){
    if `command -v brew > /dev/null 2>&1`; then
        echo '👌 Homebrew 已安装'
    else
        echo '🍺 正在安装 Homebrew...  (link to Homebrew: https://brew.sh/)'
        # install script:
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        if [ $? -ne 0 ]; then
            echo '🍻 Homebrew 安装成功'
        else
            echo '🚫 安装失败，请检查你的网络环境，或尝试其他安装方式'
        fi
    fi
}

# > Change to diffrent Homebrew source
select_homebrew_mirror (){
    flag=0;
    while [ "$flag" != 1 ]
    do
        echo
        echo "      请选择 Homebrew 镜像: "
        echo "      默认选项:[1] Homebrew 官方源"
        echo
        echo "      0: 跳过切换镜像"
        echo "      1: Homebrew Default Mirror 官方源"
        echo "      2: 清华大学 Tuna 源"
        echo "      3: USTC 中科大源"
        echo
        read input

    case $input in
        1)
            # echo "select_homebrew_mirror -> Debug: 1"
            _change_homebrew_default
            flag=1
            ;;
        2)
            # echo "select_homebrew_mirror -> Debug: 2"
            _change_homebrew_tuna
            flag=1
            ;;
        3)
            # echo "select_homebrew_mirror -> Debug: 3"
            _change_homebrew_ustc
            flag=1
            ;;
        0)
            return 0
            ;;
        *)
            _change_homebrew_default
            # echo "select_homebrew_mirror -> Debug: default"
            flag=1
            ;;
    esac
    done
    return 0
}

_change_homebrew_default (){
    echo "Changing the homebrew mirror to: Deafult ..."

    git -C "$(brew --repo)" remote set-url origin https://github.com/Homebrew/brew.git

    git -C "$(brew --repo homebrew/core)" remote set-url origin https://github.com/Homebrew/homebrew-core.git

    echo "Change Finifh! Run 'brew update' now... "
    brew update
}

_change_homebrew_tuna (){
    echo "Changing the homebrew mirror to: Tuna (清华大学 Tuna 源)  ..."
    echo "Reference from  (参考): https://mirror.tuna.tsinghua.edu.cn/help/homebrew/ "

    git -C "$(brew --repo)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git

    git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git

    echo "Change Finifh! Run 'brew update' now... "
    brew update
}

_change_homebrew_ustc (){
    echo "Changing the homebrew mirror to: USTC (USTC 中科大源)  ..."
    echo "Reference from  (参考): https://lug.ustc.edu.cn/wiki/mirrors/help/brew.git "

    git -C "$(brew --repo)" remote set-url origin https://mirrors.ustc.edu.cn/brew.git

    git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git

    echo "Change Finifh! Run 'brew update' now... "
    brew update
}

# > Install List

list_install (){
    # echo "Debug: list install Begin"
    for app in `cat $1`
    do
        install $app
    done
    # echo "Debug: list install End"
}

# > Install Package
install () {
    # echo "Debug: install Begin"
    check_installation $1
    if [[ $? -eq 0 ]]; then
        echo "👌 ==> 已安装" $1 ", 尝试安装下一项..."
    else
        echo "🔥 ==> 正在安装: " $1
        # echo "Debug: Running brew install "
        brew install $1
        # echo $? >> /dev/null
    fi

    if [[ $? -eq 0 ]]; then
        echo "🍺 ==> 安装成功 " $1
    else
        echo "🚫 ==> 安装失败" $1
    fi
}

# > Installed Package Checking
check_installation (){
    # if [[ $type == "cli" ]]; then
    brew list -1 | grep $1 > /dev/null

    if [[ $? -eq 0 ]]; then
        # not installed, return 0
        return 0
    fi
    # installed, return 1
    return 1
}

# > show menu
# TODO: update the menu
show_menu () {
    echo
    read -p "✨ 请选择要安装的软件包类型: [0] 命令行 (默认) [1] 图形化 [2]命令行 + 图形化 " ans
    echo

    case $ans in
        0) cd $WD && cat formulae.list && type=0
        ;;
        1) cd $WD && cat cask.list && type=1
        ;;
        2) cd $WD && echo 'formulae: \n' cat formulae.list && echo 'cask.list: \n' && cat cask.list && type=2
        ;;
        *) cd $WD && cat cask.list && type=0
        ;;
    esac
}

# > 对比 Cask 安装的 App 和 Application.list 备份的 App
compare_application() {
    # echo "Debug: compare_application"
    cd $WD
    if [ ! -f application.list ]; then
        echo "application.list doesn't exists"
        return 1
    else
        # echo "application.list exists"
        ls /Applications | sed s'/\.app$//' > /tmp/cask_app.list

        diff application.list /tmp/cask_app.list | grep '<.*' | sed s'/<.// ' > not_install_app.list

        echo "🍃 以下 App 存在于 Application 备份列表，但未通过 brew 安装，可以尝试通过 brew 安装或自行手动安装，列表见 backup/not_install_app.list "
        echo
        cat not_install_app.list
        echo
    fi
}


# > 检测并提醒 Setapp 应用列表
setapp_notify(){
    # echo "Debubg: setapp_notify"
    cd $WD
    if [ ! -f setapp.list ]; then
        echo "setapp.list 不存在"
        return 1
    else
        echo "🔍 检测到有 Setapp 应用列表备份: "
        echo
        cat setapp.list
        echo
        echo "Setapp 应用备份列表存放在 backup/setapp.list ,你可以自行查看"
    fi
}

# 检查AWK是否可用
check_awk () {
  if ! `command -v awk > /dev/null`; then
    echo 未检测到AWK，请先安装AWK再执行本程序...
    exit 127
  fi
}

#! 程序入口
echo
echo "🙏  请花 5 秒时间看一下上述注意事项"
sleep 5s
install_homebrew
echo '🪞 假如你处于中国大陆境内，网络环境不佳，可以尝试使用 Homebrew 国内镜像源 (脚本结束后可以切换回官方源) '
select_homebrew_mirror

while :
do
    show_menu
    # echo "Debug: type: $type"
    echo

    case $type in
        0)  list_install formulae.list
        ;;
        1)  list_install cask.list
        ;;
        2)  list_install formulae.list && list_install cask.list
        ;;
        *)  echo "Debug: error list"
        ;;
    esac

    echo
    read  -p "📕 是否继续查看菜单列表，Y/y继续，N/n退出 : " ans
    case $ans in
        Y|y) :
        ;;
        *) break
        ;;
    esac

done

echo '🪞 brew 使用完毕，你可以再次选取 Homebrew 的镜像源'
select_homebrew_mirror
echo "🤔 查看 package 信息 (用于配置环境变量): 运行 \$brew info [模块名]"
compare_application
sleep 3
setapp_notify
echo
echo '🤖️ 自动化备份安装，请先运行 ./backup.sh 运行正常无误后，再运行 ./install_backup.sh '
echo
echo '🎉 享受你的新 Mac 吧！'
exit 0
