#! /bin/bash
###
 # @Description  :
 # @Author       : jsmjsm
 # @Github       : https://github.com/jsmjsm
 # @Date         : 2021-07-13 13:43:36
 # @LastEditors  : jsmjsm
 # @LastEditTime : 2021-07-13 19:32:59
 # @FilePath     : /BrewMyMac/install_backup.sh
###
# 全局变量
WD=`pwd`
# > 安装自动备份脚本到 contab
install_to_crontab() {
    script="bash $WD/backup.sh"
    # echo $script
    crontab -l > /tmp/crontab_conf
    if grep -q "no crontab" /tmp/crontab_conf ; then
        # echo /tmp/crontab_conf
        # manual
        echo "自动添加失败，请尝试手动添加: "
        echo
        echo SHELL=$SHELL > crontab_conf
        echo PATH=$PATH >> crontab_conf
        echo "00 12 * * * $script > /tmp/BrewMyMac_Backup.log && osascript -e 'display notification \"$WD/backup\" with title \"程序列表备份成功, 已上传至 GitHub\" '" >> crontab_conf
        echo "运行 \$ crontab -e"

        echo "插入以下内容: "
        cat crontab_conf
        exit 1
    else
        # echo "hav crontab"
        # auto
        crontab -l > crontab_conf
        echo SHELL=$SHELL >> crontab_conf
        echo PATH=$PATH >> crontab_conf
        echo "00 12 * * * $script > /tmp/BrewMyMac_Backup.log && osascript -e 'display notification \"$WD/backup\" with title \"程序列表备份成功, 已上传至 GitHub\" '" >> crontab_conf
        crontab crontab_conf && rm -f crontab_conf

        echo "🎉 自动化备份脚本安装完成"
        echo
        echo "目前的 crontab 配置"
        echo
        crontab -l
        exit 0
    fi
}

install_to_crontab
