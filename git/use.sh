# 保存密码
git config --global credential.helper store
# 查看远程仓库
git remote -v 
# 更改远程仓库地址
git remote set-url origin $URL 
# 查看分支
git branch -a
# 切换分支
git checkout $BRANCH
# 拉取远程分支
git pull origin $BRANCH
# 推送到远程分支
git push origin $BRANCH
# 删除本地分支
git branch -d $BRANCH
# 删除远程分支
git push origin --delete $BRANCH
# 查看提交记录
git log
# 查看提交记录
git log --oneline
# 查看提交记录
git log --oneline --graph
# 查看提交记录
git log --oneline --graph --all
# 查看提交记录
git log --oneline --graph --all --decorate
# 合并分支
git merge $BRANCH
# 将主分支合并到当前分支
git merge master
# 将当前分支合并到主分支
git checkout master
git merge $BRANCH
# 重置到上一个版本
git reset --hard HEAD^
# 重置到上上一个版本
git reset --hard HEAD^^
# 重置到上上上一个版本
git reset --hard HEAD^^^
# 重置到指定版本
git reset --hard $COMMIT

