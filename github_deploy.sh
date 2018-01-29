hexo clean
hexo generate
cp -R public/* /Users/wangjie/work/vcs_projects/self/github_blog

echo '-------- github blog push --------'

cd /Users/wangjie/work/vcs_projects/self/github_blog
git add .
git commit -m "hexo deploy.."
git push origin master

echo '-------- hexo push --------'
cd /Users/wangjie/work/other/hexo_blog/wangjiegulu.github.io
./hexo_push.sh
