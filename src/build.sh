echo "执行hugo命令"
hugo
echo "hugo编译完毕"
echo "正在复制public中的文件到最外层目录..."
cp -rf public/* ../
echo "复制完毕"
echo "输入git commit log(输入\并enter换行)" 
read log
echo "commit log : $log  输入y推送到github" 
read confirm
if [ "$confirm" = "Y" -o "$confirm" = "y" ]
  then
    git add -A
    git commit -m "$log"
    git push
else 
  exit
fi
echo "推送成功"
