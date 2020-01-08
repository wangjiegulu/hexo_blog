---
title: Huginn 数据自动备份到 Google Drive
subtitle: "Huginn 数据自动备份到 Google Drive"
tags: ["huginn", "automate", "backup", "Google Drive"]
categories: ["huginn", "backup", "Google Drive"]
header-img: "https://images.unsplash.com/photo-1553460017-8917b6b478d5?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80"
centercrop: false
hidden: false
copyright: true
---

# Huginn 数据自动备份到 Google Drive

之前有写过一篇讲 [《Huginn 的 Docker 部署及数据迁移》](https://blog.wangjiegulu.com/2018/11/24/huginn_deployment_with_docker_and_data_migration/)，但是文中的数据备份自己 SSH 到服务器手动进行备份，比较麻烦。那如果能实现自动实时帮我备份到云端，那再也不用担心数据丢失问题了。

那我们要解决的问题是：

- 怎么备份数据？
- 数据备份到哪里？
- 怎么实现自动触发？

**怎么备份数据？**

这个之前在 [《Huginn 的 Docker 部署及数据迁移》](https://blog.wangjiegulu.com/2018/11/24/huginn_deployment_with_docker_and_data_migration/) 中有讲到，所以这里就不再赘述了。

**数据备份到哪里？**

因为一直用的 Google Drive，所以优先考虑，而且也是最优解：

- 容量比较大
- 支持 Restful API，那可以通过脚本去进行上传文件了
- 有版本管理，也就是说你只要打包然后上传数据，下次备份只需替换掉，Google 会进行 diff，可以在占用最小的容量的前提下保存更多的版本；默认会保留 100 个版本，足够多了，超过的会自动删除，所以备份的版本也不会无限制地增加。

> 其它的比如：DropBox，Box 等也可以。

**怎么实现自动触发？**

我的 huginn 是部署在 linux，可以使用 `crontab` 来定时触发备份操作。

## 1. 备份数据

数据的备份还是通过 mysql 的 `mysqldump` 命令：

```shell
#!/bin/bash
sudo docker exec huginn bash -c "mysqldump --single-transaction --opt -u [数据库用户名] -ppassword [数据库密码] > /app/huginn_backupfile_tmp.sql"

docker cp huginn:/app/huginn_backupfile_tmp.sql .

sudo docker exec huginn bash -c "rm /app/huginn_backupfile_tmp.sql"

mv huginn_backupfile_tmp.sql huginn_backupfile.sql
```

执行以上命令，你可以看到在目录下出现了 `huginn_backupfile.sql` 备份文件。

接下去就是怎么把这个文件上传到 Google Drive 了。

## 2. 上传到 Google Drive

先看 [Google Drive API](https://developers.google.com/drive/api/v3/manage-uploads)，阅读文档可知，要上传文件需要一下两步：

- 调用 `POST https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable` 或者 `PUT https://www.googleapis.com/upload/drive/v3/files/[FILE_ID]?uploadType=resumable` 两个接口来请求增加一个文件或者更新某一个文件（注意，这里只是请求，并不是真正上传数据）。
- 上个接口调用成功之后，Response 中会返回一个 `Location` 的 `header`，它指定了断点续传的 session URL，然后我们就可以调用这个 URL 来进行真正的上传操作了。

### OAuth2 认证

在此之前，我们还需要得到认证（请求 header 中的 `access_token`），这样才能 Google 才能知道是谁在上传文件，是不是合法的。

因为 Google 是使用 OAuth2 进行认证的，所以一般情况下在认证时，需要跳出一个界面让用户（如果未登录则登录）点击授权之后，才能进行授权。但是这样的话，自动化的流程就被中断了。

那怎么样才能在不跳出界面授权的情况下进行授权呢？可以使用 [oauthplayground](https://developers.google.com/oauthplayground/)

#### 创建凭据

打开 [console](https://console.developers.google.com) 中点击创建凭据：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/58694368-694d9980-83c5-11e9-9ed2-6984df687679.png" width="600px">
</div>

应用类型选择 `Web 应用`，名称随意，创建完毕之后，复制 `client id` 和 `client secret`。

#### 使用 OAuth Playground

打开 [oauthplayground](https://developers.google.com/oauthplayground/)，点击右上角的设置按钮，如下：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/58694633-12948f80-83c6-11e9-9cd6-b35589b41362.png" width="400px">
</div>

勾选 `Use your own OAuth credentials`，使用自己的 OAuth 证书，然后填写上一步创建的 `Client ID` 和 `Client Secret`。

左边如下勾选：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/58693610-bdf01500-83c3-11e9-80c3-8b25ed37ac30.png" width="400px">
</div>

点击 `Authorize API` 之后，复制 `Refresh token`（注意是 `refresh token`，不是 `access token`）。

拿到 refresh token 之后，我们需要使用 refresh token 通过以下接口来置换一个 `access token`：

```shell
REFRESH_RESPONSE=`curl --silent \
	https://www.googleapis.com/oauth2/v4/token \
	--data-raw "client_secret=[你的client secret]&grant_type=refresh_token&refresh_token=[你的refresh token]&client_id=[你的client id]"`

echo "refresh response: $REFRESH_RESPONSE"

# 获取 token
ACCESS_TOKEN=`grep -o "\"access_token\"\s*:\s*\".*\"" <<<"$REFRESH_RESPONSE" | sed -n -e 's/"//gp' | awk -F': ' '{print $2}'`
echo "Token: $ACCESS_TOKEN"
```

至此就拿到了需要的 `access token`。

#### 执行上传

根据 [Google Drive API 文档](https://developers.google.com/drive/api/v3/manage-uploads)，上传文件有两种方式：

##### 创建文件

> 接口：`POST https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable`

当第一次备份时，Google Drive 上是需要调用这个接口创建的。

这个接口中，接口中需要传入 `parents.id` 参数，表示我上传的备份文件应该上传到哪个目录中。你可以在 Google Drive 的任何位置创建目录，通过 `url` 来获取该目录的 id，如下：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/58695525-3bb61f80-83c8-11e9-855b-a0fff7737548.png" width="600px">
</div>

URL 涂黑的 Path segment 就是 folder 的 id。

##### 修改文件

> 接口：`PUT https://www.googleapis.com/upload/drive/v3/files/[FILE_ID]?uploadType=resumable`

第二次备份开始之后，我们就用这个方法来不断地修改上一次的备份文件。

因为是需要修改文件，所以这个接口中除了父目录的 id 之外还需要通过 `fileId` url 参数 来指定你要修改的某个文件，只要执行第一个备份之后，你就可以在 Google Drive 中拿到对应上传的备份数据的 id，如下选中文件后右键，点击获取共享链接，你就复制了该文件的共享地址，格式类似： `https://drive.google.com/open?id=1-a68Gyxxxxxxxxxx4OgxMNufpB`，最后的 id 就是该文件的 id 了，你可以拿到 id 之后把分享关闭。

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/58696063-5b017c80-83c9-11e9-8f8b-bb6e0e0cb539.png" width="400px">
</div>

#### 完整的上传脚本

**huginn-backup.sh**

```shell
#!/bin/bash
sudo docker exec huginn bash -c "mysqldump --single-transaction --opt -u [数据库用户名] -ppassword [数据库密码] > /app/huginn_backupfile_tmp.sql"

docker cp huginn:/app/huginn_backupfile_tmp.sql .

sudo docker exec huginn bash -c "rm /app/huginn_backupfile_tmp.sql"

mv huginn_backupfile_tmp.sql huginn_backupfile.sql

# upload
CURRENT_PATH=`pwd`
cd ../drive_script
./upload.sh $CURRENT_PATH/$NEW_BACKUP_FILE_NAME [目录 id] [文件 id]
```

**upload.sh**：

```shell
####
#### x.sh [FILE] [FOLDER_ID] [FILE_ID]
####

// client sercret, client id, refresh token 等数据保存在了同目录的文件中
CLIENT_SERCRET=`cat CLIENT_SERCRET`
REFRESH_TOKEN=`cat REFRESH_TOKEN`
CLIENT_ID=`cat CLIENT_ID`

REFRESH_RESPONSE=`curl --silent \
	https://www.googleapis.com/oauth2/v4/token \
	--data-raw "client_secret=$CLIENT_SERCRET&grant_type=refresh_token&refresh_token=$REFRESH_TOKEN&client_id=$CLIENT_ID"`

echo "refresh response: $REFRESH_RESPONSE"

# 获取 token
ACCESS_TOKEN=`grep -o "\"access_token\"\s*:\s*\".*\"" <<<"$REFRESH_RESPONSE" | sed -n -e 's/"//gp' | awk -F': ' '{print $2}'`
echo "Token: $ACCESS_TOKEN"

FILE="$1"

FOLDER_ID="$2"
FILE_ID="$3"
#ACCESS_TOKEN="$3"
MIME_TYPE=`file --brief --mime-type "$FILE"`
SLUG=`basename "$FILE"`
#FILE_SIZE=`stat -c%s "$FILE"`
FILE_SIZE=`wc -c < $FILE | awk '{print $1}'`


postData="{\"mimeType\": \"$MIME_TYPE\",\"title\": \"$SLUG\",\"parents\": [{\"id\": \"$FOLDER_ID\"}]}"
    postDataSize=$(echo $postData | wc -c)

echo "FILE_ID: $FILE_ID"

echo "Generating upload link for file $FILE ..."

if [ "$FILE_ID" = "" ]
then
	uploadlink=`curl --silent \
                -X POST \
                -H "Host: www.googleapis.com" \
                -H "Authorization: Bearer ${ACCESS_TOKEN}" \
                -H "Content-Type: application/json; charset=UTF-8" \
                -H "X-Upload-Content-Type: $MIME_TYPE" \
                -H "X-Upload-Content-Length: $FILE_SIZE" \
                -d "$postData" \
                "https://www.googleapis.com/upload/drive/v2/files?uploadType=resumable" \
                -v -# \
                --dump-header - | sed -ne s/"Location: "//p | tr -d '\r\n'`
else
	echo "FILE_ID not empty: ${FILE_ID}"
	uploadlink=`curl --silent \
                -X PUT \
                -H "Host: www.googleapis.com" \
                -H "Authorization: Bearer ${ACCESS_TOKEN}" \
                -H "Content-Type: application/json; charset=UTF-8" \
                -H "X-Upload-Content-Type: $MIME_TYPE" \
                -H "X-Upload-Content-Length: $FILE_SIZE" \
                -d "$postData" \
                "https://www.googleapis.com/upload/drive/v2/files/${FILE_ID}?uploadType=resumable" \
                -v -# \
                --dump-header - | sed -ne s/"Location: "//p | tr -d '\r\n'`
fi

echo "uploadlink: $uploadlink"

echo "Uploading file $FILE to google drive..."
curl \
    -X PUT \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: $MIME_TYPE" \
    -H "Content-Length: $FILE_SIZE" \
    -H "Slug: $SLUG" \
    --data-binary "@$FILE" \
    --output ./output \
    "$uploadlink" \
    $curl_args \
    -v -#
```

## 3. 设置自动调度

上传脚本搞定了，最后需要通过 `crontab` 来设置自动调度任务。

执行 `crontab -e`，如下编辑：

```shell
# huginn backup 23:30 every day
30 23 * * * cd ~/backup/huginn && /bin/sh huginn-backup.sh >> ~/backup/huginn/cron-huginn.log 2>&1
```

- 启动服务：`/etc/init.d/cron start`
- 停止服务：`/etc/init.d/cron stop`

> 每天晚上11点30分执行备份


<!--<iframe src="https://coda.io/embed/O34oAZyJI2/_suhA0?viewMode=embedplay&hideSections=true" width=900 height=500 style="max-width: 100%;" allow="fullscreen"></iframe>-->

