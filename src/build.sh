echo "\033[32m 执行hugo命令 \033[0m"
hugo
echo "\033[32m hugo编译完毕 \033[0m"
echo "\033[32m 正在复制public中的文件到最外层目录... \033[0m"
cp -rf public/* ../
echo "\033[32m 复制完毕 \033[0m"
echo "\033[32m 输入git commit log(输入\并enter换行) \033[0m" 
read log
echo "\033[32m commit log : $log  输入y推送到github \033[0m" 
read confirm
if [ "$confirm" = "Y" -o "$confirm" = "y" ]
  then
    git add -A
    git commit -m "$log"
    git push
else 
  exit
fi
echo "\033[32m 推送成功 \033[0m"
