cdirs
==========================
cdirs 用于在目录间快速切换,对庞大的项目工程效果显著。

- 支持标记目录,并快速切换到标记目录
- 支持模糊搜索[标记目录(-f)](#模糊搜索标记目录)/[当前目录(-F)](#模糊搜索当前目录)以切换目录
- 支持搜索目录/标记目录自动补全

******

### 　　　　　　　　　　　　Author: 广漠飘羽
### 　　　　　　　　　 E-mail: gmpy_tiger@163.com

==========================

## 目录
- [简介](#简介)
- [特点](#特点)
- [快速安装](#快速安装)
    - [安装演示](#安装演示)
    - [安装步骤](#安装步骤)
        - [获取cdirs](#获取cdirs)
        - [安装](#安装)
        - [安装-不覆盖cd](#安装-不覆盖cd)
    - [卸载步骤](#卸载步骤)
- [快速开始](#快速开始)
    - [标记目录](#标记目录)
    - [切换目录](#切换目录)
    - [模糊搜索标记目录](#模糊搜索标记目录)
    - [模糊搜索当前目录](#模糊搜索当前目录)
- [个性配置](#个性配置)
    - [配置简介](#配置简介)
    - [系统配置](#系统配置)
        - [gmpy_cdirs_default](#gmpy_cdirs_default)
        - [gmpy_cdirs_mark_symbol](#gmpy_cdirs_mark_symbol)
        - [gmpy_cdirs_label_symbol](#gmpy_cdirs_label_symbol)
        - [gmpy_cdirs_find_max_depth](#gmpy_cdirs_find_max_depth)
        - [gmpy_cdirs_default_key](#gmpy_cdirs_default_key)
        - [gmpy_cdirs_key](#gmpy_cdirs_key)
- [全局标签](#全局标签)
    - [全局标签简介](#全局标签简介)
    - [全局标签配置格式](#全局标签配置格式)
- [快速标记当前目录](#快速标记当前目录)
    - [快速标记当前目录简介](快速标记当前目录简介)
    - [快速标记当前目录使用指南](快速标记当前目录使用指南)
- [cdir/setdir/lsdir/cldir命令说明](#cdir/setdir/lsdir/cldir命令说明)
    - [cdir命令](#cdir命令)
        - [cdir参数列表](#cdir参数列表)
        - [cdir使用指南](#cdir使用指南)
        - [效果演示](#效果演示)
    - [setdir命令](#setdir命令)
        - [setdir参数列表](#setdir参数列表)
        - [setdir使用指南](#setdir使用指南)
        - [效果演示](#效果演示)
    - [lsdir命令](#lsdir命令)
        - [lsdir参数列表](#lsdir参数列表)
        - [lsdir使用指南](#lsdir使用指南)
        - [lsdir嵌入到其他命令](#lsdir嵌入到其他命令)
        - [效果演示](#效果演示)
    - [cldir命令](#cldir命令)
        - [cldir参数列表](#cldir参数列表)
        - [cldir使用指南](#cldir使用指南)
        - [效果演示](#效果演示)
- [FAQ](#faq)

---

## 简介
cdirs 的存在是为了解决linux命令行切换目录时层层输入的繁琐,
通过标记目录以及模糊搜索的方式快速切换到任意目录。

cdirs 包含四个命令:
[`cdir`](#cdir命令) [`setdir`](#setdir命令) [`lsdir`](#lsdir命令) [`cldir`](#lsdir命令),
且可通过`alias cd="cdir"`的方式无缝覆盖cd命令以实现最低的学习成本。

cdirs 标记的目录默认**只在当次BASH有效**,也可通过[全局标签](#全局标签)永久保存标记的目录,实现开机(或者新BASH)即可**直接使用**标签切换到任意目录。

cdirs 通过集合find命令,实现从[标记目录](#模糊搜索标记目录)/
[当前目录](#模糊搜索当前目录)模糊搜索, 并快速切换到搜索到的目录。

cdirs 使用`shell script`语言编写,在BASH环境下测试。

|命令|全称|功能|参数|
|:---:|:---:|:---:|:---:|
|[`cdir`](#cdir命令)|change directory|切换目录|[cdir参数](#cdir参数列表)|
|[`setdir`](#setdir命令)|set directory|绑定标签与路径(标记目录)|[setdir参数](#setdir参数列表)|
|[`lsdir`](#lsdir命令)|list direcotry|列出标签|[lsdir参数](#lsdir参数列表)|
|[`cldir`](#lsdir命令)|clear directory|清除标签|[cldir参数](#cldir参数列表)|

> 强烈建议用cdir取代shell内置的cd命令（安装默认）
```Bash
alias cd="cdir"
```

## 特点
- `cdir`命令是`cd`的超集,用`cdir`取代`cd`,无需改变`cd`的使用习惯,实现**最小学习成本**。
- 支持**模糊搜索**切换目录(-F|-f)。
- 支持标签标记目录,并通过标签快速切换目录。
- 各种人性化配置：
    - 标签/模糊搜索都**支持tab补全**
    - 彩色显示各种提示。
    - 对不同选项提供不同的选项参数补全
    - 参数`-h|--help`可获得使用帮助
- 支持设定[全局标签](#全局标签),实现开机(或者新BASH)即可**直接使用**标签。
- 多个BASH间setdir(无-g参数)设定的标签相互独立,支持服务器上多用户的环境。
- 所有命令支持绝对路径/相对路径参数,也支持特殊符号 `.`  `..` `~`和`-`。
- lsdir命令支持[内嵌到其他命令](#lsdir嵌入到其他命令)

## 快速安装
### 安装演示
### 安装步骤
#### 获取cdirs

```Bash
git clone https://github.com/gmpy/cdirs.git ~/cdirs
```

#### 安装

* 自动安装  

执行安装脚本:
```Bash
~/cdirs/install.sh
```

* 手动安装

在`~/.bashrc`中添加:`source ~/cdirs.sh`

#### 安装-不覆盖cd

* 自动安装  

执行安装脚本:
```Bash
~/cdirs/install.sh --unalias-cd
```

* 手动安装  

在`~/.bashrc`中添加:`source ~/cdirs.sh --unalias-cd`

### 卸载步骤

* 自动卸载

自动卸载只适用于自动安装的应用，执行卸载脚本:
```Bash
~/cdirs/install.sh --uninstall
```

* 手动卸载

在`~/.bashrc`中删除: `source ~/cdirs.sh`

## 快速开始

快速开始只适用于第一次体验cdirs,若要使用得更加便捷舒服,
需要[个性化配置](#配置)告知cdirs你的习惯,以及通过-h|--help参数了解系列命令的使用说明。

### 标记目录

`setdir`命令用于绑定标签与目录路径(标记目录)。***标签以***`,`(***逗号***)***开头,支持字母/数字和字符***`-`。

`setdir ,`:快速临时标记**当前路径**,更多说明参考[快速标记当前目录](快速标记当前目录)。

`setdir ,<标签> <目录路径>`:标记指定目录为<,标签>,当前BASH有效,更多说明参考[setdir命令](setdir命令)。

`setdir -g ,<标签> <目录路径>`:标记[全局标签](#全局标签),实现开机(或新BASH)即可**直接使用**。

### 切换目录

默认用cdirs覆盖cd(`alias cd=cdir`),因此若非覆盖安装用户把下面说明中的cd替换为cdir即可。

`cd ,`:任意目录下切换到快速标记的目录(由`setdir ,`标记),更多说明参考[快速标记当前目录](快速标记当前目录)。

`cd ,<标签>`:任意目录下切换到`,<标签>`标记的目录(由`setdir [-g] ,<标签>标记),更多说明参考[cdir命令](cdir命令)。

### 模糊搜索标记目录

`cd [-t <标记目录键名>] -f <目录名>`:在标记目录下搜索并切换到<目录名>,其中<目录名>**支持tab补全**,标记目录参考[配置说明](#个性配置)。

### 模糊搜索当前目录

`cd -F <目录名>`:在当前目录下搜索并切换到<目录名>,其中<目录名>**支持tab补全**。

## 个性配置
### 配置简介
配置文件为`~/.cdirsrc`,以`shell script`语言组织,在初始化cdirs(加载全局标签)前会先加载此配置文件,因此除了[系统配置](#系统配置)指定的变量外,可在配置文件中自行设定任何私人变量,函数等。

例如：  

> 在`~/.cdirsrc`中定义变量
```Bash
WORKSPACE="/home/user/projects"
```

> 在全局标签文件`~/cdirs_default`中使用此变量
```Bash
,work  = ${WORKSPACE}/cdirs/subdir
```

> 使用`cd ,work`切换目录
```Bash
cd ,work  ==> 等效于 cd /home/user/projects/cdirs/subdir
```

### 系统配置

|变量|含义|默认|
|:---:|:---:|:---:|
| gmpy_cdirs_default        | 全局标签文件路径 | ~/.cdirs_default |
| gmpy_cdirs_mark_symbol    | 标签标识符号     | ,                |
| gmpy_cdirs_label_symbol   | 标签名符号       | -                |
| gmpy_cdirs_find_max_depth | 最大搜索深度     | 2                |
| gmpy_cdirs_default_key    | 默认标记目录     | 无               |
| gmpy_cdirs_key            | 标记目录列表     | 无               |

#### gmpy_cdirs_default

此变量标记了全局标签文件保存路径,默认为`~/.cdirs_default`
> 格式: gmpy_cdirs_default="<文件路径名>"

#### gmpy_cdirs_mark_symbol

此变量设定标签标识符号,即标签名开头符号,值默认为`,`,标签名默认格式为
***以***`,`(***逗号***)***开头,支持字母/数字和字符***`-`,例如: `,cdirs-test`
> 格式: gmpy_cdirs_mark_symbol='<符号>'

> **不建议修改此变量**,因为一般情况下文件名开头不会为`,`，因此通过此符号区分正常目录与标签,在tab补全显示中会清晰得多。

> 同时此符号关联[快速标记当前目录](#快速标记当前目录)的符号。

#### gmpy_cdirs_label_symbol

此变量设定标签名支持符号,值默认为`-`,标签名默认格式为
***以***`,`(***逗号***)***开头,支持字母/数字和字符***`-`,例如: `,cdirs-test`
> 格式: gmpy_cdirs_label_symbol='<符号>'

> 例如: `gmpy_cdirs_label_symbol='_'`

#### gmpy_cdirs_find_max_depth

此变量设定模糊搜索的深度,值越大,模糊搜索/tab补全速度越慢,但能搜索的范围越大。
默认为2,不建议设置值过大。
> 格式: gmpy_cdirs_find_max_depth=<数值>

#### gmpy_cdirs_default_key

此变量用于个性化设定[模糊搜索(-f)的标记目录](#模糊搜索标记目录)的默认标记目录。
执行`cd -f <目录名>`则默认在此标记目录下搜索并切换目录
> 格式: gmpy_cdirs_default_key=<标记目录键名>

> 变量值为键名,此键名指定的目录路径由[gmpy_cdirs_key](#gmpy_cdirs_key)指定

#### gmpy_cdirs_key

此变量用于个性化设定[模糊搜索(-f)的标记目录](#模糊搜索标记目录)
> gmpy_cdirs_key为数组变量

> 一行为一个标记目录

> 格式: "标记目录键名 = 标记目录"

> **除最后一行**,每一行以`;`标识结尾

> 例如:
```Bash
gmpy_cdirs_key=(
"project    = ${PROJECTS}/lichee;"
"android    = ${PROJECTS}/android;"
"bugs       = ${HOME}/bugs"
)
```

## 全局标签

### 全局标签简介

setdir标记的目录**默认当前BASH有效**,关闭BASH则标记丢失,因此提供全局标签,
用于在启动shell后自动设定标签路径,实现开机(或者新BASH)即可**直接使用**标签快速切换目录。

默认全局标签文件为`~/.cdirs_default`,可在[~/.cdirsrc中修改](#gmpy_cdirs_default)。

可通过setdir的`-g`参数设定全局变量,也可以手动修改全局标签文件,
修改后通过`cd --reload`或`cd --reset`重新加载全局标签文件。

### 全局标签配置格式

- 基本格式: `标签名 = 路径名`
- [路径支持使用变量](#配置简介)
- 若路径不存在或不为目录,则此项标签配置无效 
- 一行一个全局标签,加载顺序由上往下,标签编号递增
- 若全局标签重名时，最后一此定义的同名全局标签路径有效

## 快速标记当前目录
### 快速标记当前目录简介

此功能用于快速标记当前目录后,切换到其他目录临时工作,临时工作结束后返回标记目录。
BASH默认支持`cd -`返回上次目录,但是当切换目录大于2次时,无法再通过`cd -`返回,此时可用`cd ,`。

### 快速标记当前目录使用指南

|命令|作用|
|:---:|:---:|
|`setdir  ,`| 标记当前目录 |
|`cd  ,` | 切换到标记目录 |
|`lsdir  ,` | 显示标记目录 |
|`cldir  ,` | 清除标记目录 |

## cdir/setdir/lsdir/cldir命令说明
### cdir命令
#### cdir参数列表

| 选项 | 含义 |
|:---:|:---|
| `-h|--help`         | 显示使用帮助 |
| `-l|--label`        | 指定后面的参数为标签 |
| `-p|--path`         | 指定后面的参数为路径 |
| `-n|--num`          | 指定后面的参数为编号 |
| `-t|-k|--tag|--key` | 指定模糊搜索的标记目录键名 |
| `-f|--find`         | 模糊搜索标记目录 |
| `-F|--Find`         | 模糊搜索当前目录 |
| `--reset`           | 复位cdirs（删除当前所有标签，重新计数，加载全局标签+配置） |
| `--reload`          | 重新加载所有全局标签和配置文件 |

#### cdir使用指南

#### 效果演示

### setdir命令
#### setdir参数列表

| 选项 | 含义 |
|:---:|:---|
| `-h|--help`   | 显示使用帮助 |
| `-g|--global` | 设置为全局标签 |

#### setdir使用指南

#### 效果演示

### lsdir命令
#### lsdir参数列表

| 选项 | 含义 |
|:---:|:---|
| `-h|--help`   | 显示使用帮助 |
| `-p|--print`  | 只显示路径,用于[嵌入到其他命令](#lsdir嵌入到其他命令) |

#### lsdir使用指南

#### lsdir嵌入到其他命令

例如:
```Bash
$ lsdir cdirs
num     label    path
---     -----    ----
1 )     cdirs    /home/user/cdirs #存在cdirs的标记路径

$ lsdir -p tina
/home/user/tina  #-p参数只显示路径

#嵌入到其他命令中举例:
$ ll `lsdir -p cdirs`/gif  #等效于 ll /home/user/cdirs/gif
```

#### 效果演示

### cldir命令
#### cldir参数列表

| 选项 | 含义 |
|:---:|:---|
| `-h|--help`   | 显示使用帮助 |
| `-a|--all`    | 删除所有标签(需要二次确认) |
| `-g|--global` | 删除全局标签 |

#### cldir使用指南
#### 效果演示

## FAQ
### 1. 明明有设定标签,为什么`cd <,标签>`会进入到其他文件夹？

cdirs会优先确保cd功能,当前目录若存在与标签同名文件夹,会优先进入同名文件夹而非标签路径
可以通过`-l|--label`参数强制指定进入标签路径

### 2. `lsdir -p`嵌入到其他命令中为什么有时会失效？

当绑定的路径存在空格时，`lsdir -p`会失效
例如:
```Bash
$ lsdir -p ,work
/home/user/my work #此路径存在有空格的文件夹'my work'

$ ll `lsdir -p ,work`/src    #等效于"ll /home/user/my work/src"，bash解析为"ll /home/user/my" ; "ll work/src"
```
可以通过添加双引号的方式解决：
```Bash
$ ll "`lsdir -p ,work`"/src
```

### 3. 通过`cldir <路径>`的方式删除匹配路径的标签时为什么有时会删除错了？

cldir的参数无法判断为路径还是标签｜编号时，会优先理解为标签｜编号
例如:
```Bash
$ lsdir ,test
10 )      ,work      /home/user/,test     #标签路径最终为,test
11 )      ,test      /home/user/random   #标签为,test

$ ll
...
2883727 drwxrwxr-x 2 user user    4096 10月 20 13:51 ,test/
#当前目录下存在与标签同名的test文件夹, 且此test文件夹恰巧也登记在标签信息中
...

$ cldir ,test  #只会删除 编号|便签为test 标签信息
delete: 11 )      ,test      /home/user/random   #标签为test

$ lsdir
10 )      ,work    /home/user/test     #,test标签的信息被删除了, 而路径为test的便签并没删除
```
可以通过明确标识为路径的方式解决
```Bash
$ cldir ./,test
```
