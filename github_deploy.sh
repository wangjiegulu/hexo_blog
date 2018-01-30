hexo clean
hexo generate
cp -R public/* ~/work/other/hexo_blog/wangjiegulu.github.com

echo '-------- github blog push --------'

cd ~/work/other/hexo_blog/wangjiegulu.github.com
git add .
git commit -m "hexo deploy.."
git push origin master

echo '-------- hexo push --------'
cd ~/work/other/hexo_blog/wangjiegulu.github.io
./hexo_push.sh
