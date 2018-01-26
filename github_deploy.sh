hexo clean
hexo generate
cp -R public/* /Users/wangjie/work/vcs_projects/self/github_blog
cd /Users/wangjie/work/vcs_projects/self/github_blog
git add .
git commit -m "hexo deploy.."
git push origin master
