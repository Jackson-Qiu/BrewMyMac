#! /bin/bash
###
 # @Description  :
 # @Author       : jsmjsm
 # @Github       : https://github.com/jsmjsm
 # @Date         : 2021-07-13 13:43:11
 # @LastEditors  : jsmjsm
 # @LastEditTime : 2021-07-16 17:49:25
 # @FilePath     : /BrewMyMac/backup.sh
###

# 全局变量，填入项目地址
# HEAD
DIR=$HOME/BrewMyMac
export git=/usr/bin/git

# > Install Homebrew
install_homebrew(){
    if `command -v brew > /dev/null 2>&1`; then
        echo '👌 Homebrew 已安装'
    else
        echo '🍺 正在安装 Homebrew... (link to Homebrew: https://brew.sh/)'
        # install script:
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        if [ $? -ne 0 ]; then
            echo '🍻 Homebrew 安装成功'
        else
            echo '🚫 安装失败，请检查你的网络环境，或尝试其他安装方式'
            exit 127
        fi
    fi
}

# > Backup Cask
backup_cask(){
    echo "backing up cask..."
    cd $DIR && brew list --cask > cask.list
    echo "cask: "
    cat $DIR/cask.list
}
# > Backup formulae
backup_formulae(){
    echo "backing up formulae..."
    cd $DIR && brew list --formulae > formulae.list
    echo "formulae: "
    cat $DIR/formulae.list

}

# > Backup Application List
backup_application(){
    echo "backing up application..."
    cd $DIR && ls /Applications | sed s'/\.app$//' > application.list
    echo "application: "
    cat $DIR/application.list
}

# Backup Setapp List
backup_setapp(){
    if [ ! -d /Applications/Setapp ];then
        #echo "setapp directory doesn't exist"
        return 0
    else
        #echo "setapp directory exists"
        echo "backing up setapp..."
        cd $DIR && ls /Applications/Setapp | sed s'/\.app$//' > setapp.list
        echo "setapp: "
        cat setapp.list
    fi
}

switch_branch(){
    echo "dir: $DIR"

    git checkout -b brew_backup > /tmp/tmplog
    if grep -q "fatal: A branch named" /tmp/tmplog ; then
        echo "create new branch"
    else
        echo "checkout to brew_backup"
        git checkout brew_backup
    fi
}

# > Backup to Github
backup_to_github(){
    msg='Backup on: '`date`
    # echo $msg

    git add $DIR
    git commit -m "$msg"
    git push --set-upstream origin brew_backup
    git push
}

# >>  主程序
cd $DIR
# 检查b ackup 文件夹是否存在
if [ ! -d backup  ];then
  mkdir backup
  DIR=$DIR/backup
else
  DIR=$DIR/backup
fi

# 运行
install_homebrew > /dev/null
switch_branch
# 备份
backup_formulae
backup_cask
backup_application
backup_setapp
# 备份到 github 要最后运行
backup_to_github
exit 0
