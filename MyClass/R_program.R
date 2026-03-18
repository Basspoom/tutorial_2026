# 查看目录，设置目录，查看工作目录下文件
getwd()
setwd("/Users/basspoom/try")
list.files()
dir()

# 基本运算
4 + 7
4 - 7 
4 * 7
4 / 7
4 ^ 7      # 幂运算，4 的 7 次方
7 %% 4     # 取余数
7 %/% 4    # 整数除法

# 比较运算
4 > 7
4 < 7
4 >= 7
4 <= 7
4 == 7   # 是否相等
4 != 7   # 是否不等

# 赋值运算
x <- 4
y = 7
x
y

# 逻辑运算
TRUE & FALSE   # 与
TRUE | FALSE   # 或
!TRUE          # 非

# 数据类型
class(4)
class("ASD")
class(114.514)

x <- "Basspoom"
is.character("x")
is.complex("x")

typeof("x")


# 向量
v <- c(10, 20, 30, 40)
v
class(v) # 对象类型
typeof(v) #底层存储类型
length(v) #长度
str(v) #内部结构


# 列表
lst <- list(
  name = "Basspoom",
  age = 25,
  score = c(90, 85, 88),
  passed = TRUE
)

lst
class(lst)
typeof(lst)
length(lst)
str(lst)


# 数组（可以看成是多维的向量）
arr <- array(1:12, dim = c(2, 3, 2))  # 表示这是一个 2 × 3 × 2 的数组
arr
class(arr)
typeof(arr)
length(arr)
dim(arr) # 查看维度
str(arr)


# 矩阵是 二维、同一类型 的数据结构
mat <- matrix(1:9, nrow = 3, ncol = 3)
mat
class(mat)
typeof(mat)
length(mat)
dim(mat)  #维度
nrow(mat)  #行数
ncol(mat)  #列数
str(mat)


# 数据框 data.frame
df <- data.frame(
  id = 1:3,
  name = c("A", "B", "C"),
  score = c(88.5, 92.0, 79.5),
  passed = c(TRUE, TRUE, FALSE)
)

df
class(df)
typeof(df)
dim(df)
nrow(df)
ncol(df)
names(df)  # 表头（列名）
str(df)  # 适合查看每列类型


# 因子 - 适合分类变量
f <- factor(c("high", "low", "medium", "low", "high"))
f
class(f)
typeof(f)
length(f)
levels(f) # 查看因子的水平
str(f)



7:9

