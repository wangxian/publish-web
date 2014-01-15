###
  publish web resource
  --- color and style
  bold italic underline inverse yellow cyan white magenta
  green red grey blue rainbow zebra random
###

fs        = require 'fs'
commander = require 'commander'
colors    = require 'colors'
shelljs   = require 'shelljs/global'
config    = require './config.coffee'

# The command list
list      = ['CDN', 'Project', 'Files', 'Directory', 'Rollback', 'RevertAll', 'MobileClient', 'PreviewWWW', 'Help', 'Exit']
startTime = (new Date()).getTime();

exit = ->
  console.log '--------------------------------------------'
  console.log '完成，用时：%ss, 内存使用：%sM'.cyan,
              ((new Date()).getTime() - startTime)/1000,
              (process.memoryUsage().heapUsed/1048576).toFixed(2)
  console.log '完成时间：%s'.cyan, new Date()
  process.exit(1)


replaceFile = (filename)->
  data = fs.readFileSync filename, {encoding: "utf-8"}
  newData = data.replace(/\/assets\//g, 'http://img.xxx.cn/web/')
  fs.writeFileSync filename, newData, {encoding: "utf-8"}

cdn = ->
  console.log '------------------'
  console.log 'Revert svn repository...'.yellow
  exec "svn revert -R #{config.cdnRepo}"

  console.log '------------------'
  console.log 'Update svn repository...'.yellow
  exec "svn up #{config.cdnRepo}"

  console.log '------------------'
  console.log 'Replace cdn resource if it contains {/assets/}'.yellow
  files = find(config.cdnRepo).filter (file)->
    ext = file.slice file.lastIndexOf('.')
    ext is '.css' or ext is '.js'

  # 替换文件内容
  files.forEach (v)->
    console.log ('Replace file: '+ v).grey
    replaceFile v

  do exit

publishProject = ->
  commander.prompt 'Project name(eg: buy): ', (name)->
    paths = switch name
      when 'www' then ['index.php', '_app/']
      when 'buy' then ['index-buy.php', '_buy/']
      when 'qq'  then ['index-qq.php', '_qq/']
      else
        console.log "无此项目：#{name}"
        do exit
    exec "svn up #{config.webRoot}#{paths[0]} #{config.webRoot}#{paths[1]}"
    do exit

publishFiles = ->
  console.log '[说明]：\n-----------------'.red
  console.log '1. 发布文件过程中，不替换文件内容。'.blue
  console.log '2. 多个文件请以空格分割。'.blue
  console.log '3. 文件相对于config.WebRoot目录。'.blue

  commander.prompt 'File list: ', (name)->
    if name.length
      exec "svn up #{config.webRoot}#{name}"
    do exit

publishDir = ->
  console.log '[说明]：\n-----------------'.red
  console.log '1. 发布目录过程中，不替换文件内容。'.blue
  console.log '2. 多个目录请以空格分割。'.blue
  console.log '3. 文件相对于config.WebRoot目录。'.blue

  commander.prompt 'Directory list: ', (name)->
    if name.length
      exec "svn up #{config.webRoot}#{name}"
    do exit

rollback = ->
  console.log 'Error: 暂未实现。'.blue
  do exit

revertAll = ->
  exec "svn revert -R #{config.webRoot}"
  do exit

mobileClient = ->
  exec "svn up #{config.webRoot}/lastest-version.php #{config.cdnRepo}package/"
  do exit
previewWWW = ->
  exec "svn up #{config.preRoot}/"
  do exit

help = ->
  console.log 'Usage: 此处省略500字。'.blue
  do exit

# 等待输入
main = ->
  console.log '请选择您要发布的内容：'.red
  console.log '--------------------------------------------'

  commander.choose list, (i)->
    switch list[i]
      when 'CDN' then do cdn
      when 'Files' then do publishFiles
      when 'Project' then do publishProject
      when 'Directory' then do publishDir
      when 'Help' then do help
      when 'Rollback' then do rollback
      when 'RevertAll' then do revertAll
      when 'MobileClient' then do mobileClient
      when 'PreviewWWW' then do previewWWW
      when 'Exit' then do exit

do main


