# --------------------------------------------
# 脚本名称：Basic R（面向对象与基础操作入门）
# 用途：概览 RStudio 的基本界面与 R 控制台常见操作，
#      包括安装/加载包、对象类型、数据结构与函数等内容。
#
# 作者：Fanglin Liu
# 邮箱：flliu315@163.com
# 日期：2026-03-11
# 中文批注整理：用于学习理解
# --------------------------------------------

cat("\014")         # 清空控制台内容
rm(list = ls())     # 删除当前环境中的所有变量

# 参考资料：
# https://bookdown.org/manishpatwal/bookdown-demo/list-in-r.html

#######################################################
################ I. R 与 RStudio 基础 ##################
#######################################################

# 01. 启动 RStudio 并配置界面
# 这里通常会介绍：
# - RStudio 的外观设置
# - 四个窗格（脚本区、控制台、环境区、文件/绘图/帮助区）的功能

# getwd()      # 获取当前工作目录
# setwd()      # 设置工作目录，也可通过 Session > Set Working Directory
# list.files() # 或 dir()，查看当前目录下的文件
# rm(list=ls())# 清空工作环境中的对象

# 02. 在 R 控制台中做基本运算（方式一）
# 在控制台提示符后输入命令并回车执行

# -------------------------
# 算术运算 Arithmetic
# -------------------------
7 + 4    # 加法
7 - 4    # 减法
7 * 2    # 乘法
7 / 2    # 除法

3^2      # 平方
sqrt(2)  # 开平方
5 %/% 2  # 整数除法，结果为 2
5 %% 2   # 取余数，结果为 1

# -------------------------
# 逻辑运算 Logical
# -------------------------
!TRUE         # 逻辑非 NOT
TRUE & FALSE  # 逻辑与 AND
TRUE | FALSE  # 逻辑或 OR

# 03. 在 RStudio 编辑器中写代码（方式二）
# 可通过 File > New File > R Script 打开脚本编辑器
# 将上面的命令写入脚本中，再逐行运行
# 脚本可保存到指定文件夹中，例如 Desktop/myClass

##################################################
########## II. R 对象与基本操作 ##################
##################################################

# 01. R 中的变量（Variables）
# 变量本质上是 R 中存储数据的对象
# 参考：
# https://www.geeksforgeeks.org/r-language/r-variables/

# A) 使用 "=", "<-" 或 "->" 赋值
var1 = "Hello Geeks"   # 把字符串赋给变量 var1
var1 <- "Hello Geeks"
"var2" -> Hello_Geeks  # 赋值方向

x <- 5                 # 将 5 赋值给 x
y <- 7                 # 将 7 赋值给 y
9 -> z                 # 将 9 赋值给 z（不常用，但合法）

# 变量输出有两种方式
(var1 <- "Hello Geeks")  # 赋值的时候用括号括起来
print(var1) # print函数

# 打印所有变量
ls()

# 删除所有变量
rm(list = ls())



# B) 变量命名与大小写敏感
# R 区分大小写，因此 o 和 O 是两个不同变量

o <- 10
O <- 5

o * O
o * 0   # 注意：大写 O 和数字 0 不一样
o / O
O / 0   # 除以 0，会得到 Inf（无穷大）或报相关警告

length(o)  # 对象长度。标量长度也为 1
dim(o)     # 标量通常没有维度，因此返回 NULL

mode(o)    # 对象模式（如 numeric）
dim(o)

# 推荐用字母、数字、下划线命名变量，避免空格
# 例如 tea_pot，而不是 tea pot

var2 <- 10
var.name <- "2.91"   # 变量名里可以有点号
var_name <- TRUE

value1 <- 100
Value1 <- 200        # 大小写不同，视为不同变量

var <- 10
.var <- "Hello"      # 变量名可以用点开头，但有规则限制

# C) 以下写法是不允许的

var$1 <- 5    # 非法：$ 通常用于访问列表/数据框的列
var#1 <- 10   # 非法：# 后面会被当作注释

2var <- 5     # 非法：变量名不能以数字开头
_var <- 10    # 一般不推荐，有些环境下可用，但教学中通常视为不规范
.3var <- 10   # 非法：点后不能直接接数字形成变量名

TRUE <- 1     # 非法：TRUE 是保留字
function <- 10# 非法：function 是关键字

# 02. 数据类型与数据对象
# 参考：
# https://www.geeksforgeeks.org/r-data-types/

# -------------------------
# 1) 基本数据类型
# numeric, integer, logical, character, complex
# -------------------------

# Double / numeric（双精度数值）
x1 <- 5.23

is.numeric(x1)   # 是否为数值型
is.integer(x1)   # 是否为整数型
is.double(x1)    # 是否为双精度，通常 numeric 默认就是 double

class(x1)        # 对象类别
typeof(x1)       # 底层存储类型
mode(x1)         # 模式（旧风格概念）

# Integer（整数）
x2 <- 5L         # 注意：要加 L，才是整数型

# Logical（逻辑型）
x3 <- TRUE

# Character（字符型）
x4 <- "elevated"
is.character(x4)
is.numeric(x4)

x5 <- "3.14"     # 看起来像数字，但本质仍是字符串
is.character(x5)
is.numeric(x5)

# Complex（复数）
x6 <- 1 + 2i
class(x6)

# -------------------------
# 2) 数据对象（Data Objects）
# -------------------------
# R 中常见数据对象包括：
# 向量、矩阵、数据框、因子、列表、数组等

# A) 向量 / 标量（Vectors / Scalars）

Num_variable <- c(1, 4, 7)  # 用 c() 组合成一个数值向量
print(Num_variable)
(Num_variable <- c(1, 4, 7)) # 赋值并立即打印

# 查看基本信息
length(Num_variable)     # 元素个数
typeof(Num_variable)     # 元素类型
is.vector(Num_variable)  # 是否为向量
is.list(Num_variable)    # 是否为列表
str(Num_variable)        # 紧凑显示对象结构

a <- 100
is.vector(a)             # R 中单个数值也可看作长度为1的向量
length(a)

# 访问向量元素
Num_variable[2]          # 第 2 个元素
Num_variable[-2]         # 排除第 2 个元素
which(Num_variable == "4") # 查找值等于 4 的位置（这里 "4" 会自动转成数值比较）

# 使用 subset() 做索引筛选
(v <- c(1:2, NA, 4:6, NA, 8:10))

v[v > 5]              # 逻辑索引，NA 会被保留
subset(v, v > 5)      # subset() 会丢掉 NA
# 等价于：
# v[(v > 5) & !is.na(v > 5)]

# B) 矩形数据对象（Rectangular Objects）

# a) 矩阵 / 数组（matrices / arrays）

(m0 <- matrix(data = 1:9, nrow = 3, byrow = TRUE))
# 生成 3 行矩阵，按行填充

x <- 1:3
y <- 4:6
z <- 7:9

(m1 <- rbind(x, y, z))  # 按行拼接成矩阵

# 查看矩阵属性
mode(m1)
typeof(m1)
length(m1)
is.vector(m1)
is.matrix(m1)
dim(m1)                # 返回维度：行数和列数

# 矩阵索引与运算
m1[2, 3]     # 第 2 行第 3 列
m1 > 5       # 返回逻辑矩阵
sum(m1)      # 所有元素求和
max(m1)
mean(m1)
colSums(m1)  # 每列求和
rowSums(m1)  # 每行求和
t(m1)        # 转置

# b) 数据框 / tibbles

name   <- c("Adam", "Bertha", "Cecily", "Dora", "Eve", "Nero", "Zeno")
gender <- c("male", "female", "female", "female", "female", "male", "male")
age    <- c(21, 23, 22, 19, 21, 18, 24)
height <- c(165, 170, 168, 172, 158, 185, 182)

df <- data.frame(name, gender, age, height,
                 stringsAsFactors = TRUE)
df

is.matrix(df)
is.data.frame(df)
dim(df)

tb <- tibble::as_tibble(df)  # 将 data.frame 转成 tibble
dim(tb)

# 数据框基本操作
df[5, 3]   # 第 5 行第 3 列
df[6, ]    # 第 6 行所有列
df[, 4]    # 第 4 列所有行

names(df)      # 查看列名
names(df)[4]   # 查看第 4 个列名

df$gender      # 访问 gender 列
df$age         # 访问 age 列

df$gender == "male"
sum(df$gender == "male")   # 统计 male 的人数

df$age < 21
df$age[df$age < 21]        # 筛选年龄小于 21 的年龄值
df$name[df$age < 21]       # 筛选年龄小于 21 的姓名

subset(df, age > 20)                    # 年龄大于20
subset(df, gender == "male")            # 性别为 male
subset(df, age > 20 | gender == "male") # 满足任一条件

df[age > 20, ]
df[gender == "male", ]
df[age > 20 | gender == "male", ]
df[age > 20 & gender == "male", ]

# c) 分类变量与因子（categories and factors）

df <- data.frame(name, gender, age, height,
                 stringsAsFactors = FALSE) # 从 R 4.0 起默认通常是 FALSE
df
df$gender
is.character(df$gender)
is.factor(df$gender)
all.equal(df$gender, gender)

df <- data.frame(name, gender, age, height,
                 stringsAsFactors = TRUE) # 现在是因子，打印后会显示分类的水平

df$gender
is.factor(df$gender)
typeof(df$gender)
unclass(df$gender)   # 查看因子的底层编码（整数）

df$gender <- as.factor(df$gender)  # 显式转成因子
df$gender

# d) 列表（Lists）

l_1 <- list(1, 2, 3)       # 3 个元素，都是数值标量
l_1

l_2 <- list(1, c(2, 3))    # 第 2 个元素本身是一个向量
l_2

l_3 <- list(1, "B", 3)     # 列表可以存不同类型的元素
l_3

# 查看列表属性
is.list(l_3)   # TRUE，说明是列表
is.list(1:3)   # FALSE，1:3 是向量
is.list("A")   # FALSE
str(l_3)

# 访问列表元素
l_2[2]    # 返回“子列表”
l_2[[2]]  # 返回列表中第2个元素本身

x <- list(1:3)
x
x[[1]][3] # 先取出第1个元素（向量 1:3），再取其第3个值

# C) 对象之间的转换

df$gender <- as.factor(df$gender)
df$gender

# 矩阵转 data.frame
m2 = matrix(c(1,2,3,4,5,6,7,8), nrow = 4) # 默认按列填充
print(m2)
class(m2)
ƒ
df2 = as.data.frame(m2)  # 矩阵转为数据框
print(df2)
class(df2)

df3 <- data.frame(
  a = 1:3,
  b = letters[10:12],
  c = seq(as.Date("2004-01-01"), by = "week", length.out = 3),
  stringsAsFactors = TRUE
)
df3
class(df3)

m3 <- data.matrix(df3[1:2])  # 将前两列尽量转为数值矩阵
m3
class(m3)

# 数据框转数组
df4 <- data.frame(x = 1:5, y = 5:1)
df4

df5 <- data.frame(x = 11:15, y = 15:11)
df5

# 查询函数功能，且运行并查看结果
?unlist
unlist(df4)

array1 <- array(
  data = c(unlist(df4), unlist(df5)), # 先把数据框拍平成向量
  dim = c(5, 2, 2),                   # 5行、2列、2层
  dimnames = list(rownames(df4), colnames(df4))
)

(data = c(unlist(df4), unlist(df5)))

array1

# 03. R 中的函数对象与操作

# -------------------------
# 1) 内置函数
# -------------------------
# 参考：
# https://www.datacamp.com/doc/r/functions

# 数值函数
abs(12)       # 绝对值
log(12)       # 自然对数
sqrt(121)     # 开平方
exp(15)       # e^15
floor(8.9)    # 向下取整
ceiling(8.9)  # 向上取整
round(8.4)    # 四舍五入

# 字符串函数
x <- "abcdef"
?substr                  # 查看 substr 帮助文档
substr(x, 2, 4)          # 截取第2到第4个字符
substr(x = "television", start = 5, stop = 10)

text_vector <- c("DataScience", "datascience", "DATA", "science", "Science")
grep("science", text_vector, ignore.case = TRUE) # 搜索包含 science 的位置

strsplit("abc", "")      # 按字符拆分

?paste
paste("y", 1:3, sep = "")# 拼接成 y1 y2 y3

x <- "abcdef"
toupper(x)               # 转为大写

# 统计函数
x <- c(2, 4, 6, 100)
mean(x)                  # 均值
mean(x, trim = 0.25)     # 去掉两端一定比例后再求均值（稳健一些）

sum(x)
range(x)                 # 最小值与最大值

# 其他示例
sum(c(1, 2))
sum(1, 2, 3, NA, na.rm = TRUE) # 忽略缺失值 NA
paste0("hell", "o ", "world", "!") # 直接拼接字符串

# -------------------------
# 2) 安装与加载包
# -------------------------

# -- 从 CRAN 安装
# install.packages('readr')
# install.packages(c('readr', 'ggplot2', 'tidyr'))

# -- 从 GitHub 安装
# install.packages('devtools')
# devtools::install_github('rstudio/shiny')

# -- 从其他仓库安装
# install.packages('furrr',
#                  repos='http://cran.us.r-project.org',
#                  dependencies=TRUE)

# -- 从 zip 文件安装
# 也可以在 IDE 中安装本地 zip 包

library(tidyverse)

?filter()   # filter() 可能来自不同包，会有歧义

# 明确指定包中的函数
?stats::filter
?dplyr::filter

# -------------------------
# 3) 自定义函数
# -------------------------
# 参考：
# https://rpubs.com/NateByers/functions
# # Writing functions
myMean <- function(x){
  total_count_of_values <- length(x)
  total_sum_of_values <- sum(x)
  average_of_values <- total_sum_of_values/total_count_of_values
  average_of_values
}
#
# 这里不是直接写函数，而是从外部脚本读取函数定义
source("src/myMean.R")

my_vector <- c(1, 3, 5, 2, 6, 9, 0)
vector_mean <- myMean(x = my_vector)
vector_mean

source("src/add_three.R")
add_three(5)

quadratic <- function(a, b, c) {
  root1 <- (-b + sqrt(b^2 - 4 * a * c)) / (2 * a)
  root2 <- (-b - sqrt(b^2 - 4 * a * c)) / (2 * a)
  root1 <- paste("x =", root1)
  root2 <- paste("x =", root2)
  
  # 若两根相同，则返回一个值；否则返回两个值
  ifelse(root1 == root2, return(root1), return(c(root1, root2)))
}

quadratic(1, 6, 9)
quadratic(1, -8, 15)
quadratic(1, 9, 4)

##############################################
########### III. R 编程最佳实践 ################
##############################################
# 参考：
# https://swcarpentry.github.io/r-novice-inflammation/06-best-practices-R.html
# https://www.r-bloggers.com/2024/06/writing-r-code-the-good-way/

# 01. 将 RStudio 项目与 GitHub 关联
# 方便版本管理、协作开发与代码追踪
# 例如把 myClass 项目连接到 tutorial_2026 仓库

# 02. 保持良好的项目目录结构
# 清晰的目录有助于管理数据、脚本和结果文件
#
# project/
#   ├── data/      # 原始数据或中间数据
#   ├── scripts/   # R 脚本
#   └── results/   # 输出结果、图表等

# 03. 自定义代码片段（Snippets）与文件头
# 在脚本开头写清楚：
# - 作者
# - 目的
# - 日期
# - 输入输出说明
# 便于后续追踪和维护代码

# 04. 使用相对路径读写文件
# 这样项目迁移时不容易出错

input_file <- "data/data.csv"
output_file <- "data/results.csv"

# 05. 适当添加注释，标记代码用途或分块
# 用 # 注释代码逻辑，提高可读性

input_data <- read.csv(input_file)           # 读入输入数据
sample_number <- nrow(input_data)            # 统计样本数
results <- some_other_function(input_file,
                               sample_number)

# 06. 保持良好的缩进与空格风格
# 有助于提升代码可读性和维护性

vec <- c(1, 2, 3)

# 07. 使用管道符 %>% 让代码更流畅、更易读
library(dplyr)

data %>%
  filter(x > 1) %>%
  summarise(mean_y = mean(y))
  