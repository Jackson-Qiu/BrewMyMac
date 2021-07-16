#! /bin/bash
###
 # @Description  :
 # @Author       : jsmjsm
 # @Github       : https://github.com/jsmjsm
 # @Date         : 2021-07-13 15:40:23
 # @LastEditors  : jsmjsm
 # @LastEditTime : 2021-07-16 18:54:10
 # @FilePath     : /BrewMyMac/brew_mirror.sh
###

# > Change to diffrent Homebrew source
select_homebrew_mirror (){
    flag=0;
    while [ "$flag" != 1 ]
    do
        echo
        echo "      请选择 Homebrew 镜像: "
        echo "      默认选项:[1] Homebrew 官方源"
        echo
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
        *)
            _change_homebrew_default
            # echo "select_homebrew_mirror -> Debug: default"
            flag=1
            ;;
    esac
    done

    exit 0
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

select_homebrew_mirror
