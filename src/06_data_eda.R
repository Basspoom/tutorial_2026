# --------------------------------------------
# 脚本名称：Doubs 数据探索性分析
# 用途：本部分用于展示如何进行探索性数据分析（EDA），
#       以寻找生态学模式。
#       本分析以 doubs 数据集为例，
#       对群落数据开展 EDA。

# 作者：Fanglin Liu
# 邮箱：flliu315@163.com
# 日期：2026-04-05
#
# --------------------------------------------
cat("\014") # 清空控制台
rm(list = ls()) # 删除所有变量

##################################################
# 01-获取 doubs 的 OSM 数据用于绘图
##################################################

# A）使用 qgis
# https://www.youtube.com/watch?v=gahG3OAdZQs
# // 安装插件：quickmapservices 和 quickOSM
# quickservice -> metasearch -> add default（基础地图）

# // 在 QUICKOSM 中填写键值对以下载数据
# quickOSM -> waterway 和 river -> doubs →runs

# // 通过选择要素获取 Le Doubs 河流
# 打开属性表 -> 按表达式选择
# "name" LIKE '%Le Doubs%'

# // 复制并粘贴要素以保存河流
# Edit -> Copy -> paste features as

# // 将 doubs 的 OSM 数据保存到 postgresql
# https://www.youtube.com/watch?v=H9o0wme0nuk

# B）使用 R 代码
# 向 ChatGPT 询问如何从 OSM 下载河流数据

"基于 openstreetmap 数据，编写 R 代码查找法国-瑞士区域的 Le Doubs，
并使用 mapview 在地图上进行可视化"

# 安装并加载必要的包

library(osmdata) # 从 OSM 下载数据
library(mapview) # 交互式可视化空间数据

# 获取 Le Doubs 河流的边界框

bbox <- c(left = 5.5, bottom = 46.5, right = 7.5, top = 48)

# 在边界框内查询名称为 “Le Doubs” 的河流水系
doubs_query <- opq(bbox = bbox) |>
  add_osm_feature(key = "waterway", value = "river") |>
  add_osm_feature(key = "name", value = "Le Doubs") |>
  osmdata_sf()
doubs_query

# 在地图上可视化 Le Doubs（sf 对象）
mapview(doubs_query$osm_lines)

# 将 LINE 转为 MULTILINES，并合并为一个 sf 对象
# https://ourcodingclub.github.io/tutorials/spatial-vector-sf/
#
# ?bind_rows
# ?st_cast
library(sf)
library(dplyr)
river_sf <- dplyr::bind_rows(
  sf::st_cast(doubs_query$osm_lines, "MULTILINESTRING"), # 从 lines 转为 MULTILINES
  doubs_query$osm_multilines) |>
  select(name, osm_id, role)

class(river_sf)
head(river_sf)

# 绘制 doubs_sf
plot(river_sf)

# unique(river_sf$role)

# 过滤不需要的图形，确保几何对象有效
river_sf_clean <-
  river_sf |>
  filter(is.na(role) == FALSE) |> # 删除 role 为 NA 的记录
  rename(doubs_type = role) |> # 将 role 重命名为 doubs_type
  st_make_valid()

unique(river_sf_clean$doubs_type)

st_write(river_sf_clean, "../data/gisdata/DOUBS_river.shp")
DOUBS_river <- st_read("../data/gisdata/DOUBS_river.shp")

st_write(river_sf_clean, "../data/gisdata/DOUBS_river.gpkg")
DOUBS_river <- st_read("../data/gisdata/DOUBS_river.gpkg")

library(ggplot2)
DOUBS_river <- ggplot(DOUBS_river) +
  geom_sf(color = "blue")
DOUBS_river

ggsave("../data/gisdata/DOUBS_river.png",
       plot = DOUBS_river,
       width = 8, height = 6.5)

##################################################
# 02-载入鱼类-环境数据并进行预处理
##################################################
# 1）从 postgresql 载入 Doubs 数据

# library(DBI) # 帮助 R 连接数据库
# library(RPostgreSQL) # 提供与 SQLite 的接口
library(DBI)
con <- dbConnect(RPostgreSQL::PostgreSQL(),
                 dbname = 'doubs',
                 host = 'localhost',
                 port = 5432,
                 user = 'doubs',
                 password = 'xxxx')

dbListTables(con)
dbListFields(con, "doubs_env") # 列出 doubs_env 表的字段

# ?dbReadTable
doubs_spe <- dbReadTable(conn = con, "doubs_spe")
doubs_env <- dbReadTable(conn = con, "doubs_env")
doubs_spa <- dbReadTable(conn = con, "doubs_spa")
dbDisconnect(con)
dbGetInfo(con)

# 直接本地读取
doubs_spe <- read.csv("../data/DoubsSpe.csv", row.names = 1, check.names = FALSE)
doubs_env <- read.csv("../data/DoubsEnv.csv", row.names = 1, check.names = FALSE)
doubs_spa <- read.csv("../data/DoubsSpa.csv", row.names = 1, check.names = FALSE)

# 2）对鱼类和环境数据进行预处理

# A）鱼类群落数据

# a. 删除没有鱼类的行

str(doubs_spe) # 对象结构
head(doubs_spe) # 前 6 行
summary(doubs_spe) # 汇总统计
dim(doubs_spe) # 维度
names(doubs_spe) # 对象名称

row_sums <- rowSums(doubs_spe)
which(row_sums == 0)
spe_clean <- doubs_spe[-8, ] # 删除无鱼类的样点

# spe_clean <- doubs_spe %>%
#   filter(rowSums(.) != 0)

str(doubs_env) # 对象结构
summary(doubs_env) # 汇总统计
head(doubs_env) # 前 6 行
dim(doubs_env) # 维度
names(doubs_env) # 对象名称

env_clean <- doubs_env[-8, ] # 删除无鱼类的样点
spa_clean <- doubs_spa[-8, ] # 删除无鱼类的样点

# b. 频率分布与转换

library(vegan)

range(spe_clean)
(ab <- table(unlist(spe_clean))) # 数据框→向量→频数表→输出
barplot(ab,
        las = 1, # 设置标签为水平显示
        xlab = "丰度等级",
        ylab = "频数",
        col = gray(5:0 / 5)
)

sum(spe_clean == 0) / (nrow(spe_clean) * ncol(spe_clean))

# 对鱼类群落数据进行转换

# spe_pa <- decostand(spe_clean, method = "pa")
spe_hel <- decostand(spe_clean, method = "hellinger")
spe_log <- decostand(spe_clean, method = "log")

# c. 稀有种或优势种的数量

colSums(spe_clean > 0) # 每个物种出现于多少个样点（丰度）
rowSums(spe_clean > 0) # 物种丰富度

abund <- colSums(spe_clean)
abund_sorted <- sort(abund, decreasing = TRUE)
plot(abund_sorted,
     type = "b",
     log = "y",
     main = "等级-丰度曲线",
     xlab = "物种排序",
     ylab = "丰度（对数尺度）")

# df2 <- data.frame(
#   rank = 1:length(abund_sorted),
#   abundance = abund_sorted
# )
#
# ggplot(df2, aes(x = rank, y = abundance)) +
#   geom_line() +
#   scale_y_log10() +
#   theme_minimal() +
#   labs(title = "等级-丰度曲线")

apply(spe_clean, 2, max) # 检查每一列的最大值

# d. 双零问题
# 避免使用 stats 包中的 dist()
library(vegan)
fish_comm <- spe_clean[, colSums(spe_clean > 0) >= 3]
dim(fish_comm)
spe_hel <- decostand(fish_comm, method = "hellinger") # Hellinger 转换
dist_mat <- vegdist(spe_hel, method = "euclidean") # 欧氏距离
dist_mat <- vegdist(spe_hel, method = "bray") # Bray-Curtis 距离

# B）检测并替换环境变量中的离群值

# # 对每个变量检测离群值
# dfs <- env_clean$dfs
#
# Q1 <- quantile(dfs, 0.25)
# Q3 <- quantile(dfs, 0.75)
# IQR <- Q3 - Q1
# # 下界和上界
# lower_bound <- Q1 - 1.5 * IQR
# upper_bound <- Q3 + 1.5 * IQR
# outliers <- dfs[dfs < lower_bound | dfs > upper_bound]
# print(outliers)
#
# par(mfrow = c(1, 2))
# boxplot(dfs, ylab = "dfs")
# boxplot(dfs, ylab = "dfs", horizontal = TRUE)
# par(mfrow = c(1, 1))

# a. 检测数据框所有列中的离群值，并替换为 NA
library(dplyr)
detect_outliers <- function(x) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  x < (q1 - 1.5 * iqr) | x > (q3 + 1.5 * iqr)
}

outlier <- env_clean %>%
  mutate(across(where(is.numeric), detect_outliers))
outlier

boxplot(env_clean, horizontal = TRUE,
        main = "所有变量的箱线图")

library(dplyr)
replace_outliers <- function(x) {
  if (!is.numeric(x)) return(x)
  
  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  lower <- Q1 - 1.5 * IQR
  upper <- Q3 + 1.5 * IQR
  x[x < lower | x > upper] <- NA
  return(x)
}

env_cleanNA <- env_clean %>%
  mutate(across(everything(), replace_outliers))
env_cleanNA

# b. 用每列均值填补 NA

env_filled <- env_cleanNA %>%
  mutate(across(where(is.numeric),
                ~ ifelse(is.na(.), mean(., na.rm = TRUE), .)))

env_filled

# 3）初步探索鱼类与环境之间的关系
# A）采样点的空间分布

plot(spa_clean, # 使用 plot(...) 配合 lines(...)、
     # points(...)、text(...)、polygon(...) 等
     # 构建更复杂的图形
     asp = -1,
     type = "p", # 绘制点数据
     main = "采样点",
     xlab = "x 坐标（km）",
     ylab = "y 坐标（km）"
)

lines(spa_clean, col = "light blue") # 添加线/标签/文本
text(spa_clean, row.names(spa_clean), cex = 1.0, col = "red")

text(40, 20, "上游", cex = 1.2, col = "blue")
text(15, 120, "下游", cex = 1.2, col = "blue")

# B）指示性鱼类的分布
par(mfrow = c(2, 2)) # 绘制 4 个物种
xl <- "x 坐标（km）"
yl <- "y 坐标（km）"
plot(spa_clean, asp = 1, col = "brown", cex = spe_clean$LOC,
     main = "Stone loach", xlab = xl, ylab = yl)
lines(spa_clean, col = "light blue", lwd = 2)
plot(spa_clean, asp = 1, col = "brown", cex = spe_clean$CHA,
     main = "European bullhead", xlab = xl, ylab = yl)
lines(spa_clean, col = "light blue", lwd = 2)
plot(spa_clean, asp = 1, col = "brown", cex = spe_clean$BAR,
     main = "Barbel", xlab = xl, ylab = yl)
lines(spa_clean, col = "light blue", lwd = 2)
plot(spa_clean, asp = 1, col = "brown", cex = spe_clean$BCO,
     main = "Common bream", xlab = xl, ylab = yl)
lines(spa_clean, col = "light blue", lwd = 2)
par(mfrow = c(1, 1))

# 典型环境变量的分布

par(mfrow = c(1, 4))
plot(spa_clean, asp = 1, main = "海拔", pch = 21, col = "white",
     bg = "red", cex = 5 * env_filled$alt / max(env_filled$alt), xlab = "x", ylab = "y")
lines(spa_clean, col = "light blue", lwd = 2)
plot(spa_clean, asp = 1, main = "流量", pch = 21, col = "white",
     bg = "blue", cex = 5 * env_filled$flo / max(env_filled$flo), xlab = "x", ylab = "y")
lines(spa_clean, col = "light blue", lwd = 2)
plot(spa_clean, asp = 1, main = "溶解氧", pch = 21, col = "white",
     bg = "green3", cex = 5 * env_filled$oxy / max(env_filled$oxy), xlab = "x", ylab = "y")
lines(spa_clean, col = "light blue", lwd = 2)
plot(spa_clean, asp = 1, main = "硝酸盐", pch = 21, col = "white",
     bg = "brown", cex = 5 * env_filled$nit / max(env_filled$nit), xlab = "x", ylab = "y")
lines(spa_clean, col = "light blue", lwd = 2)
par(mfrow = c(1, 1))

############################################
# 03-鱼类与环境的 Q 模式和 R 模式分析
###########################################
# 1）环境数据分析

# A）R 模式（变量/列之间的关系）
# https://www.rpubs.com/dvallslanaquera/pca

# 对环境变量做标准化（z-score）
library(vegan)
env_z <- decostand(env_filled, "standardize")
# apply(env_z, 2, mean) # 均值 = 0
# apply(env_z, 2, sd) # 标准差 = 1
# env_z 等价于 env_scaled <- scale(env_filled)
# apply(env_scaled, 2, mean) # 均值 = 0
# apply(env_scaled, 2, sd) # 标准差 = 1

# 相关性分析

PerformanceAnalytics::chart.Correlation(env_z,
                                        histogram = TRUE,
                                        pch = 19) # 共线性

# B）Q 模式（样点/行之间的差异）

par(mfrow = c(1, 1))
env_d <- dist(env_z)
env_d_single <- hclust(env_d, method = "single")
plot(env_d_single)

# C）PCA 的 R 模式和 Q 模式

pca_env1 <- prcomp(env_z)
summary(pca_env1) # 方差解释率
pca_env1$rotation # 变量贡献
pca_env1$x # 样本得分
biplot(pca_env1) # 点 = pca$x；箭头 = pca$rotation
biplot(pca_env1, scale = 1)
biplot(pca_env1, scale = 2)

# 使用 vegan 包中的 rda()

vegan::decorana(env_clean) # 模型选择
env_pca <- rda(env_clean, # 运行 PCA，等价于 rda(env_z)
               scale = TRUE) # 调用标准化

summary(env_pca, scaling = 2) # 默认 scaling = 2
summary(env_pca, scaling = 1)

# (env_ev <- env_pca$CA$eig) # 选择主成分
# env_ev[env_ev > mean(env_ev)]
# env_n <- length(env_ev)
# barplot(env_ev, main = "特征值", col = "grey", las = 2)
# abline(h = mean(env_ev), col = "red")
# legend("topright", "平均特征值", lwd = 1, col = 2, bty = "n")

plot(env_pca) # 各轴解释方差
biplot(env_pca, scaling = 1, # Q 模式
       main = "scaling=1：对象相似性")
biplot(env_pca, scaling = 2, # R 模式
       main = "scaling=2：重要性与相关性")

# 2）物种数据分析
# A）R 模式分析

spe_hel <- decostand(spe_clean, "hellinger")
cor_mat <- cor(spe_hel) # 共现关系
heatmap(cor_mat)

# B）Q 模式分析

# a. 定量数据分析

# 原始数据的 Bray-Curtis 差异
spe_db <- vegan::vegdist(spe_clean) # 默认即 Bray-Curtis
# 等价于 vegdist(spe_clean, "bray")
spe_db

# Hellinger 距离
spe_hel <- decostand(spe_clean, "hel")
spe_dh <- vegdist(spe_hel, method = "euclidean")

# b. 存在-缺失数据分析

# Jaccard 矩阵
spe_dj <- dist(spe_clean, "binary")
# 等价于 vegdist(spe_clean, "jac", binary = TRUE)
spe_dj

spe_db_single <- hclust(spe_db, method = "single")
plot(spe_db_single)

spe_db_complete <- hclust(spe_db, method = "complete")
plot(spe_db_complete)

spe_db_ward <- hclust(spe_db, method = "ward.D2")
plot(spe_db_ward)

library(vegan)
spe_dh <- vegdist(spe_hel, method = "euclidean")
par(mfrow = c(1, 1))
spe_dh_single <- hclust(spe_dhel, method = "single")
plot(spe_dh_single, main = "单连接聚类",
     hang = -1)

spe_dh_complete <- hclust(spe_dh, method = "complete")
plot(spe_dh_complete, main = "完全连接聚类",
     hang = -1)

# C）PCA 的 R 模式与 Q 模式

pca_spe1 <- prcomp(spe_hel)
summary(pca_spe1)
pca_spe1$rotation
pca_spe1$x
biplot(pca_spe1)

# 使用 vegan 包中的 rda()

spe_hel <- decostand(spe_clean, "hellinger")
vegan::decorana(spe_hel) # DCA1 > 4 为单峰模型；DCA1 < 3 为线性模型

spe_pca <- rda(spe_hel) # 使用 rda() 运行 PCA
summary(spe_pca, scaling = 2)
summary(spe_pca, scaling = 1)

# spe_ev <- spe_pca$CA$eig # 选择主成分
# spe_ev[spe_ev > mean(spe_ev)]
# n <- length(spe_ev)
# barplot(spe_ev, main = "特征值", col = "grey", las = 2)
# abline(h = mean(spe_ev), col = "red")
# legend("topright", "平均特征值", lwd = 1, col = 2, bty = "n")

biplot(spe_pca, scaling = 1, main = "PCA scaling=1")
biplot(spe_pca, scaling = 2, main = "PCA scaling=2")

# 3）RDA——物种与环境之间的关系

spe_hel <- decostand(spe_clean, "hellinger")
env_z <- decostand(env_filled, "standardize") # 中心化并标准化变量

env_spe_rda <- rda(spe_hel ~ .,
                   data = env_z) # 默认 scaling = 2
vif.cca(env_spe_rda) # 多重共线性
summary(env_spe_rda)

anova(env_spe_rda, permutations = 1000) # 拟合优度
anova(env_spe_rda, by = "axis", permutations = 1000)
anova(env_spe_rda, by = "term", permutations = 1000)

plot(env_spe_rda, scaling = 1, main = "scaling 1") # scaling 1
plot(env_spe_rda, main = "scaling 2") # scaling 2

# 进一步优化 RDA
vif.cca(env_spe_rda) # 删除 vif > 10 的变量

env_spe_rda_null <- rda(spe_hel ~ 1, data = env_z)
env_spe_rda_all <- rda(spe_hel ~ ., data = env_z)
(step_forward <-
    ordiR2step(env_spe_rda_null,
               scope = formula(env_spe_rda_all),
               direction = "forward",
               pstep = 1000))
RsquareAdj(step_forward)$adj.r.squared

env_spe_rda_pars <- step_forward # 简约模型

anova.cca(env_spe_rda_pars, permutations = 1000)
anova(env_spe_rda_pars, permutations = 1000, by = "axis")
anova(env_spe_rda_pars, permutations = 1000, by = "term")

vif.cca(env_spe_rda_all) # VIF 对比
vif.cca(env_spe_rda_pars)

par(mfrow = c(1, 2)) # 绘制最终三元图

plot(env_spe_rda_pars, scaling = 1, display = c("sp", "lc", "cn"),
     main = "Scaling 1") # Scaling 1

plot(env_spe_rda_pars,
     display = c("sp", "lc", "cn"), # sp(物种), lc(地点), cn(约束变量)
     main = "Scaling 2") # Scaling 2

