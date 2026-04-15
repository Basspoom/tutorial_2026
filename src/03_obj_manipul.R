# --------------------------------------------
# 脚本名称：Basic R
# 用途：本部分介绍一些关于数据基础操作与自定义函数的示例
#
# 作者：Fanglin Liu
# 邮箱：flliu315@163.com
# 日期：2026-03-21
# --------------------------------------------

cat("\014") # 清空控制台显示内容
rm(list = ls()) # 删除当前环境中的所有变量

#################################################
## 01- 使用 tidyverse 进行数据操作
#################################################

# 1）内置数据集

data()  # 查看 package “datasets” 中的数据集

data(package = .packages(all.available = TRUE)) # 列出当前所有可用包中的数据集

all_datasets <- data(package = "datasets")$results[, "Item"] # 统计 datasets 包中的内置数据集名称
length(all_datasets) # 统计内置数据集数量
(all_datasets)


# 安装 “ade4”
options(repos = c(CRAN = "https://cloud.r-project.org"))
install.packages("Rcpp")
install.packages("RcppArmadillo")
install.packages("ade4")

data(package = "ade4") 
library(ade4)
data(doubs) # 加载 doubs 数据集
head(doubs) # 查看数据集前几行，检查结构
str(doubs)  # 查看数据集的整体结构
colnames(doubs$env) # 查看 doubs$env 的列名

# 2）使用 tidyverse 进行数据处理
library("tidyverse")  # 加载 tidyverse 套件，其中包含 dplyr、tidyr、ggplot2 等

# A）使用 dplyr 进行 select()、filter()、mutate() 和管道操作

# 使用 “管道操作符 %>% （|>）” 对数据进行处理
# 例：对xx包中的xx数据集，对其行列进行筛选和过滤操作
doubs$env %>% # 取doubs这个数据对象里的env子数据集，%>%是管道符，把左边的数据无缝传给下一行代码
  select(dfs, alt, oxy) %>%   # 选择 dfs（距离源头的距离）、alt（海拔）、oxy（含氧量） 三列，管道符继续传递筛选后的列数据
  filter(alt > 300)  # 筛选（海拔）alt > 300 的行

# 若不使用管道操作符
doubs$env
(tmp <- select(doubs$env, dfs, alt, oxy))
(result <- filter(tmp, alt > 300))


# 使用 mutate() 创建新列
doubs$env %>% 
  filter(!is.na(oxy)) %>%  # 先去掉 oxy 为 NA 的行
  mutate(oxygen_category = ifelse(oxy > 90, "High", "Low")) %>%  # 按 oxy 是否大于 90 生成分类变量
  head() # 查看结果前几行

# Split-apply-combine（拆分-应用-合并）分析思路
doubs$env %>% 
  mutate(oxygen_category = ifelse(oxy > 90, "High", "Low")) %>%  # 新增氧气水平分类列
  group_by(oxygen_category) %>%  # 按氧气水平分类分组
  summarise(mean_alt = mean(alt), 
            mean_pH = mean(pH), 
            .groups = "drop")  # 计算各组的 alt 均值和 pH 均值

# 将上面的步骤整合成一个更完整的示例
doubs$env %>%  
  select(dfs, alt, oxy, pH) %>%  # 选择 dfs、alt、oxy、pH 四列
  filter(alt > 200) %>%   # 保留 alt > 200 的行
  mutate(oxygen_category = ifelse(oxy > 90, "High", "Low")) %>%   # 新增氧气分类列
  rename(distance = dfs, oxygen = oxy) %>%    # 重命名列：dfs -> distance, oxy -> oxygen
  arrange(desc(alt)) %>%  # 按 alt 从大到小排序
  group_by(oxygen_category) %>%  # 按氧气分类分组
  summarise(mean_alt = mean(alt), 
            mean_pH = mean(pH), 
            .groups = "drop")  # 汇总每组平均海拔和平均 pH

# B）在 long 和 wide 格式之间重塑 doubs 数据
# a. 使用 tidyr::gather 和 spread
long_env <- doubs$env |> # 将宽表转换成长表
  gather(key = "variable", value = "value", 
         -dfs) # 保留 dfs 列，其余列展开成长格式

head(long_env) # 查看长表前几行

# 反向执行 gather() 操作
wide_env <- long_env |> # 再把长表转回宽表
  spread(key = "variable", value = "value")

head(wide_env) # 查看宽表前几行

# b. 使用 pivot_longer() 和 pivot_wider()
long_env_new <- doubs$env |> 
  pivot_longer(cols = -dfs,  # 除 dfs 外，其余列全部转成长格式
               names_to = "variable",  # 原列名存到 variable 列
               values_to = "value")    # 原数值存到 value 列

print(long_env_new, n = 30) # 打印前 30 行

wide_env_new <- long_env_new |> 
  pivot_wider(names_from = "variable", values_from = "value") # 再转回宽格式


# C）使用 ggplot2 进行数据可视化
env <- doubs$env 

# 绘制散点图或折线图
ggplot(data = env) # 创建一个基础 ggplot 对象
ggplot(data = env,  # aes()是美学映射函数，作用是把数据列绑定到图形坐标轴（绘制一个坐标系）
       aes(x = alt, y = oxy)) # x 为 env 的 alt 列，y 为 env 的 oxy 列

ggplot(data = env, 
       aes(x = alt, y = oxy)) +
  geom_point() # 绘制散点图

ggplot(data = env, 
       aes(x = alt, y = oxy)) +
  geom_line() # 绘制折线图

# 先把图保存为变量，再单独显示
basic_plot1 <- ggplot(data = env, 
                      aes(x = alt, y = oxy, 
                          color = dfs)) + # 点的颜色 → 按dfs列分组自动区分
  geom_point()

basic_plot1 # 显示图形

basic_plot2 <- ggplot(data = env, 
                      aes(x = alt, y = oxy, 
                          color = dfs)) +
  geom_point(color = "red") # 点统一设为蓝色

basic_plot2 # 显示图形


ggplot(data = env, 
       aes(x = alt, y = oxy, color = dfs)) +
  geom_line() # 绘制带颜色映射的折线图


# 通常使用白色背景主题
ggplot(data = env, aes(x = alt, y = oxy, color = dfs)) +
  geom_line() +
  theme_bw() + # 使用白色背景主题
  theme(panel.grid = element_blank()) # 去掉网格线

# 使用 aes 和 title 进行更进一步的自定义
my_plot <- 
  ggplot(doubs$env, aes(x = alt, y = oxy, 
                        color = dfs, size = dfs)) +  # 可用颜色和size表现第三个变量的变化，以比较三个变量的关系
  geom_point(alpha = 0.8) +  # 设置点的透明度
  scale_color_gradient(low = "blue", high = "red") +  # 设置颜色渐变：蓝 -> 红
  labs(title = "alt vs oxygen",
       x = "Altitude",
       y = "Oxygen Level",
       color = "Distance from Source",
       size = "dfs") +
  theme_minimal() +  # 使用极简主题
  theme(plot.title = element_text(hjust = 0.5, # 标题居中
                                  face = "bold")) # 标题加粗
my_plot
ggsave("../results/name_of_file.png", 
       my_plot, width = 15, height = 10) # 保存图像到文件

################################################
## 02- 使用 for 和 apply 的自定义函数/批量计算示例
################################################

# 1）使用 for 循环

y1 <- rnorm(10)       # 生成 10 个标准正态分布随机数
y2 <- rnorm(10) + 10  # 生成 10 个均值偏移到 10 附近的随机数
dat <- data.frame(y1, y2) # 组成数据框
dat # 查看数据框

result <- list() # 定义一个空列表，用于保存结果
for(i in 1:2){
  result[[i]] <- mean(dat[,i]) # 计算第 i 列的平均值并存入列表
}
result # 查看结果

# 2）使用 apply()

apply(dat, 2, mean) # 对 dat 的第 2 维（列）应用 mean 函数，即计算每列平均值

################################################
## 03- 在文本中插入代码：rmarkdown
################################################