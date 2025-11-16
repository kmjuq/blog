---
title: "Vim"
date: 2023-11-09T21:31:23+08:00
categories: ["兴趣爱好","编辑器"]
tags: ["VIM"]
description: "学习VIM的使用"
---

## 约定
| 标记     | 按键                       |
| :------- | :------------------------- |
| `<ESC>`  | 按ESC键                    |
| `<CR>`   | 按enter回车键              |
| `<UP>`   | 按上方向键                 |
| `<C-r>`0 | 同时按 Ctrl 和 r，然后按 0 |
| dap      | 依次按`d`、`a`、`p`        |
| :ls      | 依次按`:`、`l`、`s`        |

## vim 的软件思想
可视为我们是一个画家，我们编辑的时候就相当于在作画，但是画家不是时时刻刻都在画板上画画的，都是画一下就停一下，停下来的时候就是在思考画作是否需要调整，而在vim中，我们也是这样，需要经常从编辑状态和思考状态不停切换，进而完成我们的画作。

## vim 模式
vim 分成四个模式，normal模式，插入模式，可视模式，命令模式

normal 模式，是画家在思索调整阶段，也是 vim 打开文件的初始模式。

插入模式，是画家正式在纸张上画画，即用户用来编辑文档，在 normal 模式，可以通过特定指令进入插入模式。

可视模式，通过选择相关字符，行，块等内容，一次性处理量文本。  
可视模式有三种，分别用于操作字符文本、行文本和块文本。  
进入可视模式的三种方法：
- 在 normal 模式输入 v ，即可进入到可视模式，当进入可视模式时，左下角会出现`-- VISUAL --`的标志，此时是面向字符的可视模式。
- 在 normal 模式输入 V ，此时的可视模式，左下角会出现 `-- VISUAL LINE --`，此时是面向行的可视模式。
- 在 normal 模式输入 `<C-v>` ，此时左下角会出现`-- VISUAL BLOCK --`标识，此时是面向列块的可视模式。   

在可视模式下，`o` 可以切换高亮选取的活动端，即可以将光标直接定位到头或者尾。

命令模式，用来执行特定操作的模式，normal 模式和可视模式都可以通过 `:` 来进入命令模式，区别就是选择可视内容时输入 `:` 会在命令中加入 `'<,'>` 变成 `:'<,'>`。  
这个模式和 shell 下的命令行有些类似，我们可以输入一条命令，然后按 `<CR>` 执行它。在任意时刻，我们都可以按 `<Esc>` 键从命令行模式切换回普通模式。

## 移动
### 基础移动
| 指令    | 注释                                                   |
| :------ | :----------------------------------------------------- |
| h j k l | 基础的光标移动                                         |
| 0       | 移动到行首                                             |
| ^       | 移动到有字符的行首，多用于行首是空白符的时候           |
| $       | 移动到行尾                                             |
| w       | 正向移动到下一个单词的开头                             |
| b       | 反向移动到当前单词或者上一个单词的开头                 |
| e       | 正向移动到当前单词或者下一个单词的结尾                 |
| ge      | 反向移动到上一个单词的结尾                             |
| H       | 移动到窗口最上方                                       |
| M       | 移动到窗口中间                                         |
| L       | 移动到窗口最下方                                       |
| \%      | 移动到对称字符的另一半，比如{[()]}[]{}等               |
| G       | 默认到文件底部，前面加行号则是跳转到指定行，例如 `77G` |
| gg      | 默认到文件开头                                         |
| `<C-u>` | 往上翻半页                                             |
| `<C-d>` | 往下翻半页                                             |
| `<C-e>` | 窗口内容下降一行                                       |
| `<C-y>` | 窗口内容上升一行                                       |
| zt      | 当前行内容移动到窗口第一行                             |
| zb      | 当前行内容移动到窗口最后一行                           |
| `<C-o>` | 跳转到上一次的位置                                     |
| `<C-i>` | 回跳回来                                               |

> W B E GE 等移动操作是基于字串的，w b e ge 是基于单词的。

> 光标位于一个单词时，`#` 可以向上搜索相同单词，`*` 则是向下搜索相同单词。

> `<C-i>` 和 `<C-o>` 两个功能只适用于跳转移动，例如 G

### 查找移动
#### 查找功能
在 normal 模式直接输入 `/` 会进入查找功能，输入 `/vim` 就会从光标往下进行查找匹配上的关键词，默认支持正则表达式。  
在 normal 模式直接输入 `?` 会进入查找功能，输入 `?vim` 就会从光标往上进行查找匹配上的关键词，默认支持正则表达式。  
`n` 跳转到下一个匹配，`N` 跳转到上一个匹配。  
进入查找功能后可以使用 `<UP>` 来浏览历史搜索指令。

```text
\v 开启very magic模式的模式匹配，vim 自带的模式匹配的语法风格偏向于 POSIX ，而 very magic 模式更偏向 perl。
/\v<vim><CR>        该指令会只匹配 vim 单词，neovim 不会被匹配，而 `/vim` 则会匹配到 neovim

\V 原义开关
// 通过 /a.k.a 和 /\Va.k.a 查找看看区别 不然默认正则匹配
The N key searches backward...
...the \v pattern switch (a.k.a. very magic search)...
```

#### fFtT指令
通过 `f` 指令可以查找当前光标之后的字符并移动到该字符，只在当前行有效。  
例如在上文的英文环境的第二行，使用`fe`可以移动到 pattern 的 e ，very 的 e，search 的 e。  
如果有多个匹配，可以通过 `;` 指令和 `,` 指令来向下或向上移动。

`F`指令作用和`f`相同，只不过是往前查找。  
tT指令和fF类似，只是查找到字符时，光标是移动到字符的上一位，而不是字符所在位。
### 标记移动
给当前行添加标记，添加标记的指令是 `m[a-zA-Z]`，a-z是只在当前文件添加标记，A-Z是全局标记，即用vim打开多个文件也可以直接移动过去。  
使用标记的时候需要使用 `` ` `` 符号，如果你的标记是A，则使用 `` `A `` 指令移动到标记位置。

可以通过 `:marks` 来查看标记内容。  
`'` `"` `[` `]` 四个是默认标记位：
- `'` 跳转到跳转之前
- `"` 跳转到上一次编辑时
- `[` 上一次更改开始
- `]` 上一次更改结束

## 编辑
|   指令    | 注释                                                        |
| :-------: | :---------------------------------------------------------- |
|     i     | 在光标所在字符之前进入插入模式                              |
|     a     | 在光标所在字符之后进入插入模式                              |
|     I     | 光标移至行首，并进入插入模式                                |
|     A     | 光标移至行尾，并进入插入模式                                |
|     o     | 在当前行下面创建一个新行，并移动到下一行                    |
|     O     | 在当前行上面创建一个新行，并移动到上一行                    |
|     u     | 撤销操作，以`<ESC>`为单位                                   |
|  `<C-r>`  | 撤销撤销操作                                                |
|     J     | 将下一行和该行合并                                          |
|    dw     | 删除一个单词，单词后的空格也会删除                          |
|    de     | 删除一个单词                                                |
| D 或者 d$ | 当前光标字符之后的字符都删除                                |
|    dd     | 剪切整行                                                    |
|   cw ce   | 删除当前光标之后一个单词的字符，并进入插入模式              |
| C 或者 c$ | 删除当前光标字符及其之后的所有字符，并进入插入模式          |
|   S cc    | 剪切整行，并进入插入模式                                    |
|   x dl    | 剪切光标所在字符                                            |
|   X dh    | 剪切光标所在之前的一个字符                                  |
|   s cl    | 剪切光标所在字符，并进入插入模式                            |
|     r     | 替换当前字符                                                |
|     R     | 替换模式输入                                                |
|     .     | 录制从进入插入模式到退出插入模式的操作，`.` 符号会再次执行  |
|     p     | d x 等指令会将内容放入寄存器，p会拿出来粘贴，在光标之后粘贴 |
|     P     | 在光标之前粘贴                                              |
|     y     | 复制，一般搭配w e和可视模式                                 |

```text
Whether the character under the cursoris included depends on the command you
used to move to that character.  The reference manual calls this "exclusive"
when the character isn't included and "inclusive" when it is.
```
> 当需要输入批量字符时，可以通过数字再进入插入模式，比如：用 `10i` 进入到插入模式，输入任意字符比如 kmj ，再输入 `<ESC>` 退出插入模式，则会批量插入10个kmj。

## 文本对象
vim 里面有一个特殊的对象，就是文本对象，主要用来方便的选择文本内容。通过例子，更容易学习。

一般在操作文本对象时，需要选择操作范围 `a` 或者 `i` ，然后再选择作用范围 `w` `s` `p` `i`等。

在操作文本对象时，我们可以先拿可视模式来练习。
| 指令        | 注释                                                                      |
| :---------- | :------------------------------------------------------------------------ |
| vaw         | 光标位于文章的一个单词中，选择一个单词，包括后续空格                      |
| viw         | 光标位于文章的一个单词中，选择一个单词                                    |
| vas         | 光标位于文章的一个单词中，选择一个句子，包括后续空格                      |
| vap         | 光标位于文章的一个单词中，选择一个段落，包括后续空格                      |
| vi[ vi]     | 光标位于`[`或`]`两个符号中间，选择[]内的内容                              |
| vi( vi) vib | 光标位于`(`或`)`两个符号中间，选择()内的内容                              |
| vi> vi<     | 光标位于`<`或`>`两个符号中间，选择<>内的内容                              |
| vit         | 光标位于`<aa>`或`</aa>`两个符号中间，选择两个标签内的内容，比如html的标签 |
| vi{ vi} viB | 光标位于`{`或`}`两个符号中间，选择{}内的内容                              |
| vi\`        | 光标位于`` ` ``或`` ` ``两个符号中间，选择`` `` ``内的内容                |
| vi"         | 光标位于`"`或`"`两个符号中间，选择""内的内容                              |
| vi'         | 光标位于`'`或`'`两个符号中间，选择''内的内容                              |
```text
Note the difference between using a movement command and an object.  The
movement command operates from here (cursor position) to where the movement
takes us.  When using an object the whole object is operated upon, no matter
where on the object the cursor is.  For example, compare "dw" and "daw": "dw"
deletes from the cursor position to the start of the next word, "daw" deletes
the word under the cursor and the space after or before it.
```
```js
function text(){
    var str = '字符串测试呢'
    var arr = [
      <h1>菜鸟教程</h1>,
      `<h2>学的不仅是技术，更是梦想！${str}</h2>`,
    ];
    ReactDOM.render(
      <div>{arr}</div>,
      document.getElementById('example')
    );
}
```

## 寄存器
通过 `:reg` 命令可以查看当前软件的寄存器相关内容，当需要使用寄存器时，可以在命令前面加入寄存器名称，例如：
- "ayiw       该指令会将复制的单词存入寄存器`"a`中
- "ap         该指令会讲复制的单词粘贴到当前行或者下一行

如下内容是 neovim 软件的内容，与 vim 软件寄存器数目也不一致。
```text
 类型  名称  内容                                                        
 l     ""    ^J                                                          
 l     "0    ^J                                                          
 l     "1    ^J                                                          
 l     "2    类型 名称 内容^J  c  ""^J  l  "0   ^J^J  l  "1   ^J^J  l  " 
 b     "3    d by The Pragmatic Bookshelf.^J * Copyrights apply to this  
 b     "4    d by The Pragmatic Bookshelf.^J * Copyrights apply to this  
 b     "5    d by The Pragmatic Bookshelf.^J * Copyrights apply to this  
 c     "6    Contact us if you are in doubt.^J * We make no guar^J  l  " 
 c     "7    It may not be used to create training material,^J * courses 
 c     "8    cl by The Pragmatic Bookshelf.^J * Copyrights apply to this 
 l     "9    ^J                                                          
 c     "a    gg/class^MOmodule Rankj<80>kb^j>GGoend^                   
 c     "g    kkjjjjjjjjjkkkkkkkkkkkkkkkkkkkkkkkkkkkkkjjjjjjjjjjjjjjjjjjj 
 c     "j    jjjjjjjjjjjjjjjjjjjjjjanum := 2^Mswitch num {}<80>kl^M^M<80 
 c     "k    kkj:w^M                                                     
 c     "u    uu^:w^M:<80>ku<80>ku^M<80>krx<80>klx^:w^M:<80>ku<80>ku^M\ 
 c     "w    ew                                                          
 c     "-                                                                
 l     "*    ^J                                                          
 l     "+    ^J                                                          
 c     ".                                                                
 c     ":    q!                                                          
 c     "%    /Users/kmj/WorkSpace/blog/kmjIt/content/posts/vim.md        
 c     "#    /Users/kmj/Downloads/code/copy_and_paste/collection.js      
 c     "/    class                                                       
 c     "=    pfile                                                       
```

> 寄存器`*` 和 linux 的 x11 相关，寄存器`+`和系统剪切板相关，当是 window 和 macos 操作系统时，这两者相同

> 指令 x s d c y 都会在 `""` 寄存器存储数据，y 同时会在 `"0` 再存一份。

## 替换
替换命令 `:substitute` 的格式为 `:[range]s[ubstitute]/{pattern}/{string}/[flags]`  
range 标记执行范围，指从多少行到多少行  
pattern 正则表达式  
string 替换的字符  
flags 标记 主要有g c n
- g 标记代表一行了所有的匹配项都会进行替换
- c 标记代表每次替换都会询问
- n 标记代表不进行替换，只报告匹配到的数量

例如：
- :s/going/rolling                将光标所在行匹配到的第一个going替换为rolling
- :s/going/rolling/g              将光标所在行匹配到的所有going替换为rolling
- :%s/going/rolling/g             将文件所有行匹配到的going替换为rolling
- :50,100s/apply/aly/gc           将50行到100行的数据进行匹配替换，将aly替换为apply，并在替换时进行询问

```text
原始文本如下：
last name,first name,email
neil,drew,drew@vimcasts.org
doe,john,john@example.com

执行步骤：
/\v^([^,]*),([^,]*),([^,]*)$    执行查找匹配
:%s//\3,\2,\1                   具体执行时，可以加上行数限制执行，以免影响其他行数据

操作之后文本如下：
email,first name,last name
drew@vimcasts.org,drew,neil
john@example.com,john,doe
```

## global 命令 
global 命令格式为：`:[range] global[!]/{pattern}/[cmd]`
默认情况下，global命令是作用于整个文件的，{pattern} 默认是上次 `/` 或者 `?` 查找命令，[cmd] 默认是 :print 命令。
`:global!` 或者 `:vglobal` 反转 global 命令。
:global 命令可以简写为 :g 
:vglobal 命令可以简写为 :v

可以使用 global 命令将匹配上的数据存入寄存器
- :reg a            查看寄存器a的内容
- :qaq              清除寄存器a的内容
- :g/re/y A         re是正则匹配，A指的是数据追加到寄存器a
- :reg a            查看寄存器a的内容

## 宏录制
宏就是一系列操作的集合。使用的时候需要指定寄存器， `q{register}` 表示录制开始，`q` 表示录制结束。
例如，`qa` 开始在寄存器a中录制，`q` 结束录制，结束录制之后，可以通过 `:reg "a` 来查看录制结果。
宏录制好之后，就可以开始回放宏了，即将录制的操作再执行一次。

回放宏有两种方法：
第一种通过 `@{register}` 来回放宏，可通过 `@@` 来简化回放，然后可以通过 `3@a` 等类似指令进行多次回放，当进行多次回放时，录制的宏必须前后连贯。
第二种通过可视模式选择需要执行宏的行，然后输入 `normal @{register}` 来给所有行进行回放，此时命令会变成 `:'<,'>normal @{register}`

如下是回放宏的例子，可以将执行步骤进行改造，以应用上述回放宏的方法。
```text
原始文本如下：
foo = 1
bar = 'a'
baz = 'z'

执行步骤：
qa              移动光标到foo的f，按键qa，开始录制
A;<ESC>         A指令移动到行尾，并进入插入模式，添加;，退出插入模式
Ivar <ESC>      I指令移动到行首，并进入插入模式，添加var和空格，退出插入模式
q               结束录制
j               移动到下一行
@a              回放宏
j@@             在下一行来回放同样的宏

操作之后的文本如下：
var foo = 1;
var bar = 'a';
var baz = 'z';
```

## 多文件编辑
### 多窗口
| 指令            | 注释                                       |
| :-------------- | :----------------------------------------- |
| `<C-w>`s        | 水平切分当前窗口，新窗口仍显示当前缓冲区   |
| `<C-w>`v        | 垂直切分当前窗口，新窗口仍显示当前缓冲区   |
| :sp {filename}  | 水平切分当前窗口，缓冲区内容切换到指定文件 |
| :vsp {filename} | 垂直切分当前窗口，缓冲区内容切换到指定文件 |
| `<C-w>`w        | 在窗口间进行切换                           |
| `<C-w>`h        | 切换到左边的窗口                           |
| `<C-w>`j        | 切换到下边的窗口                           |
| `<C-w>`k        | 切换到上边的窗口                           |
| `<C-w>`l        | 切换到右边的窗口                           |
| :vert help      | 垂直切分打开help界面                       |
| `<C-W>` <       | 减少当前窗口的宽度                         |
| `<C-W>` >       | 增加当前窗口的宽度                         |
| `<C-W>` +       | 增加当前窗口的高度                         |
| `<C-W>` -       | 增加当前窗口的高度                         |

> `:resize 10` 设置当前窗口的高度，`:vertical resize 30` 设置当前窗口的宽度
### 多标签页
| 指令             | 注释                                                   |
| :--------------- | :----------------------------------------------------- |
| :tabe {filename} | 在新标签页中打开文件                                   |
| `<C-w>`T         | 将当前窗口移动到一个新标签页，必须当前工作区有多个窗口 |
| :tabc            | 关闭当前标签页及其中的所有窗口                         |
| :tabo            | 只保留当前标签页，关闭所有其他标签页                   |
| :tabn {N}        | 切换到编号为 {N} 的标签页                              |
| :tabn            | 切换到下一个标签页                                     |
| :tabp            | 切换到上一个标签页                                     |
| {N}gt            | 切换到编号为 {N} 的标签页                              |
| gt               | 切换到下一个标签页                                     |
| gT               | 切换到上一个标签页                                     |

## 文件管理
### 使用 edit 命令打开文件
使用 vim 打开文件时，会将执行 vim 时的当前目录当作 vim 的工作目录，通过 `:pwd` 命令来查看 vim 的当前工作目录。  
使用 `:edit {filename}` 打开文件时，{filename} 文件的相对路径模式即是相对于vim的工作目录。  
`:edit %<Tab>`      `%` 符号代表当前缓冲区的完成文件路径，也是相对于 vim 的工作目录的。  
`:edit %:h<Tab>`    `%:h` 符号代表当前缓冲区的所在目录。
### 使用 find 命令打开文件
使用 `:find` 命令打开文件时，需要将工作目录加入到 path 参数中，例如 `:set path+=./**` ，将当前工作目录加入到 find 命令的搜索范围中。  
配置了 path 之后，执行 `:find <Tab>` 可以不停通过 `<Tab>` 来提示文件路径。
### 使用 netrw 管理文件系统
netrw 是当前版本自带的 vim 插件，最简单的使用方式是在 shell 中执行 `vim .` ，就进入了 netrw 界面。

| 指令  | 注释                               |
| :---- | :--------------------------------- |
| F1    | 帮助                               |
| Enter | 进入该目录或者打开文件             |
| d     | 新建目录                           |
| %     | 新建并打开文件                     |
| R     | 重命名文件或者目录                 |
| D     | 删除文件或者目录，目录必须为空目录 |
| v     | 在新窗口打开文件或者目录，水平分割 |
| o     | 在新窗口打开文件或者目录，垂直分割 |
| cd    | 使当前浏览目录作为工作目录         |
| t     | 在新标签页中打开文件或者目录       |

> 通过 netrw 创建编辑文件之后，可以使用 `:e.` 命令重新进入 netrw  

> 使用 vim 可以直接创建不存在目录的文件，在编辑完文件之后，可以通过 `!mkdir -p %:h` 命令来创建缓冲区文件所在的目录。

## 用例
### 用面向列块的可视模式编辑表格数据
```text
以下为原始文本：
Chapter            Page
Normal mode          15
Insert mode          31
Visual mode          44

采取的步骤：
<ESC>       进入 normal 模式
<C-v>3j     选择中间空白列，进入面向列块的可视模式
x...        删除此列，执行三次
gv          重复上一次选的范围
r|          字符替换为｜
yyp         复制Chapter这行
Vr-         将整行换成-

操作之后的表格数据
Chapter      | Page
-------------------
Normal mode  |   15
Insert mode  |   31
Visual mode  |   44
```
### 修改列文本
```text
以下为原始文本：
li.one      a{ background-image: url('/images/sprite.png'); }
li.two      a{ background-image: url('/images/sprite.png'); }
li.three    a{ background-image: url('/images/sprite.png'); }

采取的步骤：
<ESC>       进入 normal 模式，光标移动到 images 的 i 中。
<C-v>jje    进入面向列块的可视模式，选择三行的 images 单词。
c           清除三行的 images 单词。
components  输入单词 components。
<ESC>       退出插入模式，进入 normal 模式。

操作之后的文本：
li.one      a{ background-image: url('/components/sprite.png'); }
li.two      a{ background-image: url('/components/sprite.png'); }
li.three    a{ background-image: url('/components/sprite.png'); }
```
### 给指定行添加编号
```text
原始文本如下：
partridge in a pear tree
turtle doves
French hens
calling birds
golden rings

执行步骤：
:let i=1                    申请一个变量复制为1
qa                          光标移动到partridge的p上，输入指令qa开始录制
I<C-r>=i<CR>) <ESC>         I使光标移动到行首并进入到插入模式，<C-r>= 是表达式寄存器，i<CR> 执行表达式i，<ESC> 退出插入模式
:let i +=1                  修改变量i
q                           退出录制，此时第一行已经有序号 1) 
jVjjj                       移动到第二行，进入选行的可视模式，选择第二行第五行
:'<,'>normal @a             输入 : 进入命令模式，然后输入 normal @a<CR> 执行选择行进行宏回放

操作之后的文本如下：
1) partridge in a pear tree
2) turtle doves
3) French hens
4) calling birds
5) golden rings
```

## 附录
### vim 中的概念
#### 缓冲区
在 Vim 中，缓冲区（Buffer）是一个用于存储文本内容的内存区域。缓冲区存储了文件的文本内容以及与文件相关的其他信息。
每个打开的文件都关联有一个缓冲区，这意味着你可以同时在 Vim 中编辑多个文件，每个文件对应一个缓冲区。
通过 `:ls` 命令可以查看缓冲区列表。
#### 窗口
窗口是 Vim 中用于在屏幕上显示缓冲区内容的区域。一个窗口可以显示一个缓冲区，也可以分割成多个窗口以同时显示多个缓冲区。
每个窗口都有自己的光标位置和视图，允许用户在一个屏幕上同时查看和编辑多个文件。使用 `:vsp` 和 `:sp` 命令可以创建垂直和水平分割窗口。
#### 标签页
标签页是 Vim 中用于组织和切换窗口布局的概念。一个标签页可以包含多个窗口，每个窗口显示一个缓冲区。
用户可以通过创建和切换标签页来组织不同的窗口布局。使用 :tabnew 命令可以创建新的标签页。
#### 动作
动作是用于移动光标的指令，比如说 w e b 等
#### 操作符
操作符是用于在文本上执行操作的指令，比如说 d c s 等
#### 文本对象
文本对象是一种用于选择文本块的方式，一般用于可视模式，或者与操作符组合。
#### vim 的模式语法
vim 默认使用 magic 搜索模式，nomagic 模式则用于模拟 vi 的行为，可以通过 \m 与 \M 开关来分别使用这两种语法。
very magic 模式的指令为 `\v`，`\v` 开启very magic模式的模式匹配，vim 自带的模式匹配的语法风格偏向于 POSIX ，而 very magic 模式更偏向 perl。
very nomagic 模式的指令为 \V          

### 帮助命令
:Tutor
:vert help
:help
### 参考书籍或者博客
- 《vim实用技巧》
- [《vim从入门到精通》](!https://gitlab.com/wsdjeg/vim-galore-zh_cn)
