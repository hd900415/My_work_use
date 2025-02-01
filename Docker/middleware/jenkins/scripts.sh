#!/usr/bin/env bash
source /etc/profile &>/dev/null
export Deploy_Git="Code_Branch: ${BRANCH} Build_Commit:$(git rev-parse HEAD)"
export Release=$(echo "${BRANCH}" |sed 's@/@_@g')

export Deploy_Workdir=/jenkins_data/plexwww
export Group=plex
export Project=plex-www
export Date=$(date "+%Y%m%d%H%M")


export Release_Dir=/var/lib/jenkins/workspace/release/${Group}/${Project}
test -e ${Release_Dir}|| { echo "${Release_Dir} 不存在 请先执行build Job";exit 1; }
echo "${Deploy_Git}" > ${Release_Dir}/${Release}/Deploy_Version.txt


echo "---------------------------------------------------------------------------------------------------------------------------------------"
echo -e "$(date +"%F %T") \033[32m  Git: \033[36;5m【${Deploy_Git}】\033[32m \033[0m"
echo "============================================å==========================================================================================="

#ssh 同步文件部署服务
export Ssh_Hosts=${Deploy_Hosts:-"8.8.8.8 1.1.1.1"}
export Ssh_Port=${Ssh_Port:-"22"}
export Ssh_User=${Ssh_User:-"root"}
export Ssh_Key=${Ssh_Key:-"/var/lib/jenkins/.ssh/id_rsa"}
export Source_Dir=${Release_Dir}
export Target_Dir=${Deploy_Workdir}
for Ssh_Host in ${Ssh_Hosts}
do

    #初始化目录
    echo -e "    $(date +"%F %T") \033[32m  Sync Files: \033[36;5m【${Source_Dir} to ${Ssh_Host}:${Target_Dir}】\033[32m \033[0m"
    ssh -i ${Ssh_Key} -o "StrictHostKeyChecking no" -p ${Ssh_Port} ${Ssh_User}@${Ssh_Host} "\
        mkdir -p ${Target_Dir} /data/backup/${Group}/${Project}/${Date};\
        " >/dev/null
    
    #同步文件
    rsync -avzrP --delete  -e "ssh -p ${Ssh_Port} -i ${Ssh_Key} -o 'StrictHostKeyChecking no'" \
    ${Source_Dir}  \
    ${Ssh_User}@${Ssh_Host}:${Target_Dir} \
    &>/dev/null &&\
    { echo -e "    $(date +"%F %T") \033[32m  Sync Files: \033[36;5m【${Ssh_Host}】\033[32m succ 。。。。。。 \033[0m";export Exit_Code=${Exit_Code:-"0"}; } ||\
    { echo -e "    $(date +"%F %T") \033[32m  Sync Files: \033[31;5m【${Ssh_Host}】\033[32m fail ！！！！！！ \033[0m";export Exit_Code=${Exit_Code:-"1"}; }
    
    #初始化和启动服务
    ssh -i ${Ssh_Key} -o "StrictHostKeyChecking no" -p ${Ssh_Port} ${Ssh_User}@${Ssh_Host} "\
    	cd /www/wwwroot/ ;\
        tar czf jys-h5.tar.gz ./jys-h5 ;\
        mv jys-h5.tar.gz /data/backup/${Group}/${Project}/${Date}/ ;\
        ls  ${Target_Dir}/${Project}/* ;\
        \cp -rf ${Target_Dir}/${Project}/* /www/wwwroot/jys-h5/ ;\
        chown -R www:www /www/wwwroot/jys-h5/; \
        " >/dev/null
done
exit ${Exit_Code:-"1"}
exit 1