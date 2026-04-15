# --------------------------------------------
# Script Name: Machine learning
# Purpose:     The script will show how machine learning
#              works and how to build a model with data.

# Author:     Fanglin Liu
# Email:      flliu315@163.com
# Date:       2026-03-21
# --------------------------------------------
cat("\014") # Clears the R console
rm(list = ls()) # Remove all variables

##############################################
# 01-From statistic models to machine learning
##############################################
# A) least square algorithm (statistic model)  最小二乘法
##### 统计学习建模，四大步
# 1. 散点图 - 检验线性关系
# 2. 异常值 - 找出并剔除
# 3. 检验正态分布
# 4. 线性回归得到方程 linearMod <- lm(y ~ x, data = df1) 

x <- c(100,120,140,160,180,200,220,240,260,280)
y <- c(55,60,62,64,68,70,80,85,90,95)
df1 <- data.frame(x,y)
df1

plot(y ~ x) # 绘制散点图，判断x和y的关系
abline(lm(y ~ x)) # 检验是否有线性关系（画一个斜线）
?abline # Add Straight Lines to a Plot

# 提取异常值
boxplot(x, main="x", sub=paste("Outlier rows: ", # 写个标题
                               boxplot.stats(x)$out)) # 这才是求异常值
boxplot(y, main="y", sub=paste("Outlier rows: ",
                               boxplot.stats(y)$out))


# 检验数据是否符合正态分布
library(e1071)   # packageDescription("e1071")
plot(density(x), main = "Density Plot: x", ylab = "Frequency",
     sub= paste("Skewness: ", round(e1071::skewness(y), 2)))
plot(density(y), main = "Density Plot: y", ylab = "Frequency",
     sub= paste("Skewness: ", round(e1071::skewness(y), 2)))
# 先通过density(x)计算向量x的核密度估计（数据的平滑分布曲线），再用plot()绘制这条密度曲线。
# 定义图表主标题为：密度图：x
# 定义 y 轴标签为：频率
# 拼接生成副标题：先通过e1071::skewness(y)调用包函数计算向量y的偏度，round(,2)保留两位小数，最终副标题显示Skewness: 数值。

linearMod <- lm(y ~ x, data = df1)  # build a linear model
print(linearMod)  # y = 0.2227x + 30.5818
summary(linearMod) # examine the significance
# 返回函数式、残差、回归系数和显著性t与p值、模型拟合度
# 截距和 x 的 p 值都远小于 0.001，***，极显著
# Multiple R-squared: 0.9659：x 能解释 96.59% 的 y 变异，拟合效果极好；
# F-statistic p-value: 3.76e-07：整个模型极显著，不是随机拟合。



# B) gradient descent algorithm (machine learning)  梯度下降算法
##### 机器学习建模
# 简单来说，随机初始化一个直线，让所有点到直线的垂直距离之和最小 - 梯度下降
# 1. 初始化：随机给参数 theta 赋初始值（如 0、随机数）；
# 2. 算梯度：计算当前参数下损失函数的梯度；(损失函数为模型预测值与真实值的误差，越小越好)
# 3. 更新参数：按公式沿负梯度调整参数；
# 4. 迭代：重复 2-3，直到梯度接近 0（收敛）或达到最大步数

x <- c(100,120,140,160,180,200,220,240,260,280)
# 数据标准化
x_mean <- mean(x)  # 计算算术平均数
x_sd <- sd(x) # 计算标准差
x_std <- (x - x_mean) / x_sd  # Z-score 标准化：均值为0 标准差为1
(x_std)

(X <- cbind(1,x_std)) # # add a column of 1's as intercept

y <- c(55,60,62,64,68,70,80,85,90,95)

# 标准线性回归代价函数
cost <- function(X, y, theta){ # ≈
  sum((X %*% theta -y)^2/2*length(y))
}

# 设定训练超参数：学习率和最大迭代次数
alpha <- 0.01 
num_iters <- 1000

cost_history <- rep(0, num_iters) # 创建一个长度为 1000 的全 0 向量，记录每次迭代的损失值，方便后续看模型是否收敛
theta_history <- list(num_iters) # 创建一个长度为 1000 的列表，存储每次迭代更新后的参数

theta <- matrix(c(0,0), nrow = 2) # 初始化模型参数为 2 行 1 列的矩阵，初始值都是 0，这是线性回归等模型的起始系数

for(i in 1:num_iters){ # 执行固定次数的梯度下降迭代，num_iters是总迭代次数
  error <- (X %*% theta - y) # 计算预测误差：X%*%theta是模型的预测值，减去真实值y，得到所有样本的误差向量。
  delta <- t(X) %*% error / length(y) # 计算平均梯度：t(X)是特征矩阵转置，矩阵乘法是批量梯度的标准计算；除以样本总数length(y)，得到归一化的梯度值。
  theta <- theta - alpha * delta # 参数更新：沿梯度反方向调整theta，alpha是学习率（控制每一步更新的步长）。
  cost_history[i] <- cost(X, y, theta) # 记录当前迭代的损失值，用于监控模型是否收敛
  theta_history[[i]] <- theta # 记录每一轮迭代后的参数theta，追踪参数的变化过程
}

print(theta)

plot(x_std, y, main = "Linear regression by gradient descent")

# 根据参数的历史记录“theta_history”
# 循环选取关键迭代步数（1、3、6... 每 50 步一次），绘制拟合直线
for (i in c(1,3,6,10,14,seq(50,num_iters,by=50))) {
  abline(coef=theta_history[[i]])
}
abline(coef=theta, col='cyan') # 最终拟合结果



#################################################
## 02-CRAT for classification and regression  分类 & 回归
#################################################
# A) CRAT for classification
# https://medium.com/@justindixon91/decision-trees-afc984d161bf
Class <- as.factor(c(0,0,0,0,0,1,1,1,1,1)) # 2 class vector 二分类标签向量
X1 <- c(0.6,0.8,1.2,1.3,1.7,2.3,2.5,2.9,3.1,3.2) # feature1
X2 <- c(0.8,1.8,2.7,0.4,2.2,0.7,2.4,1.6,2.1,0.2) # feature2
df <- cbind.data.frame(Class, X1, X2) # cbind.data.frame()按列合并，10行3列


plot(X1,X2,col="white") #散点图
# points()在已有画布上追加绘制点
points(X1[Class=="0"], X2[Class=="0"], col="blue", pch=19) # 给所有分类标签为0的样本画蓝色实心点
points(X1[Class=="1"], X2[Class=="1"], col="red", pch=19) # 给所有分类标签为1的样本画红色实心点

# calculate Gini Impurity to decide The potential splits
# # 计算基尼不纯度以确定潜在的分裂点
min(X1)
max(X1)
# 生成，起始+终止+步长
Predictor1test <- seq(from = 0, to = 4, by = 0.1) # 生成的序列范围 小于 X1 最小值、大于 X1 最大值
length(Predictor1test)
Predictor2test <- seq(from =0, to = 3, by = 0.1) 
length(Predictor2test)

# Function to calculate the proportion of obs in the split 
# 按指定阈值分割数据，计算分割区域中目标类别的占比，并返回该区域的样本总数
# 若m="L"：选取df中index 列 ≤ 阈值 i的所有样本（左区域）
# 若m≠"L"：选取df中index 列 > 阈值 i的所有样本（右区域）
CalculateP <- function(i, index, m, k) { 
  if(m=="L") { # region (m) which match to class (k) 
    Nm <- length(df$Class[which(df[,index] <= i)]) # The number of obs in the region Rm 
    Count <- df$Class[which(df[,index] <= i)] == k # The number of obs that match the class k
  } else {
    Nm <- length(df$Class[which(df[,index] > i)])
    Count <- df$Class[which(df[,index] > i)] == k
  } 
  P <- length(Count[Count==TRUE]) / Nm # Proportion calculation
  return(c(P,Nm)) # Returns the proportion and the number of obs
}

# 计算基尼不纯度，哦情蛊特征分割点的优劣（基尼值越小，分割效果越好）
CalculateGini <- function(x, index) { # calculate the Gini Impurity
  Gini <- NULL # Create the Gini variables
  for(i in x) {
    # 调用自定义函数CalculateP：分别计算左区域（L）、右区域（R）中类别 0、类别 1 的样本占比
    pl0 <- CalculateP(i, index, "L", 0) # Proportion in the left region with class 0
    pl1 <- CalculateP(i, index, "L", 1)
    GiniL <- pl0[1]*(1-pl0[1]) + pl1[1]*(1-pl1[1]) # The Fini for the left region 计算子区域基尼值
    pr0 <- CalculateP(i, index, "R", 0)
    pr1 <- CalculateP(i, index, "R", 1)
    GiniR <- pr0[1]*(1-pr0[1]) + pr1[1]*(1-pr1[1])
    # 加权合并总基尼
    Gini <- rbind(Gini, sum(GiniL * pl0[2]/(pl0[2] + pr0[2]),GiniR * pr0[2]/(pl0[2] + pr0[2]), na.rm = TRUE)) # Need to weight both left and right Gini scores when combining both
  }
  return(Gini)
}

Gini <- CalculateGini(Predictor1test, 2)
Predictor1test_gini <- cbind.data.frame(Predictor1test, Gini)
Predictor1test_gini

library(ggplot2)

ggplot(data = Predictor1test_gini, aes(x = Predictor1test, 
                                       y = Gini)) +
  geom_line() # 折线图

Gini <- CalculateGini(Predictor2test, 3)
Predictor2test_gini<- cbind.data.frame(Predictor2test, Gini)
Predictor2test_gini
ggplot(data = Predictor2test_gini, aes(x = Predictor2test, y = Gini)) +
  geom_line() 

# plot the tree with one root node
library(tree)
tree_df = tree(Class ~ ., data = df2)  # 用df2数据集训练一棵分类决策树：
plot(tree_df) # 画出决策树的框架结构（只有分支、节点，没有文字）
text(tree_df, pretty = 0) # 给决策树添加文字标签
title(main = "Classification Tree") # 加标题

## B) CART for regresssion
# data and plot
x <- c(84, 100, 180, 253, 264, 286, 400, 130, 480, 1000, 
       1990, 2000, 2110, 2120, 2300, 1610, 2430, 2500, 2590, 2680,
       2720, 2790,2880, 2976, 3870, 3910, 3960, 4320, 6670, 6900)
y <- c(6.176, 3.434, 3.683, 3.479, 3.178, 3.497, 4.205, 3.258,
       2.565, 4.605, 3.783, 2.833, 3.091, 2.565, 1.792, 3.045, 1.792,
       2.197, 1.792, 2.197, 2.398, 2.708, 2.565, 1.386, 1.792,
       1.792, 2.565, 1.386, 1.946, 1.099)

df3 <- cbind.data.frame(x, y)
plot(x, y, pch=21)

# the first point for partitioning
library(tree)
thresh <- tree(y ~ x) # 自变量x拟合因变量y的回归决策树
print(thresh)
# 手动绘制第一层划分
a <- mean(y[x<2115]) # 根节点（第一层）的划分阈值是2125
b <- mean(y[x>=2115])
lines(c(80, 2115, 2115, 7000),
      c(a, a, b, b)) # 画阶梯线，可视化第一层手动划分

lines(c(80, 2115, 2115, 7000), 
      c(a, a, b, b), col = "red", lwd = 2)  # 美化粗线

# the final tree 绘制最终完整决策树
model <- tree(y ~ x)
z <- seq(80, 7000) # 生成 x 的连续序列（80~7000）
y <- predict(model, list(x =z)) # predict：用完整决策树预测所有 z 对应的 y 值
lines(z, y) # 画出多层划分后的完整决策树预测曲线

#############################################################
## 03- the "boosting tree" for regression
#############################################################
# A) run one round by one round to understand the "boosting"

library(tree) # calculating residuals in decision tree 在决策树中计算残差
library(caret) # calculating mean squared error 计算均方误
library(ggplot2) # visualizating
library(randomForest) # comparing two building models

df4 <- mtcars
df4
x_vars1 <- names(df4[2:ncol(df4)]) # 从数据框 df4 中，提取出除第 1 列以外的所有列名，并赋值给变量 x_vars1。
x_vars <- paste(x_vars1, collapse = " + ") # 用 + 把向量里的所有元素连接成一个字符串

# ROUND 1
df4$pred_1 <- mean(df4$mpg) # 新增一列
df4

df4$resd_1 <- (df4$mpg - df4$pred_1) # 再加一列差
head(df4)

# ROUND 2
mdl <- eval(
  parse(text = 
          paste0(
            "tree(resd_1~", x_vars, ", data=df4)"
          ) # creating string with paste0 - 字符串拼接函数，把固定文本 tree(resd_1~、变量x_vars（自变量集合）
  )  # changing to expression with parse - 将拼接好的字符串转换为 R 可识别的代码表达式
) # evaluating the expression with eval - 执行 parse 转换后的表达式，即真正运行 tree () 函数构建决策树模型

?eval # 执行
?parse  # 返回已解析但未计算的表达式
?paste0 # 连接字符串，paste是空格拼接，paste0是无空格拼接

df4$pred_2 <- predict(mdl, df4)
?predict # 从模型拟合函数的结果中进行预测
head(df4)

df4$pred_1 + df4$pred_2
df4$pred_1 + (0.1*df4$pred_2) # using LR=0.1 to avoid overfitting
df4$resd_2 <- (df4$mpg- (df4$pred_1 + (0.1*df4$pred_2)))
head(df4)

# ROUND 3
mdl <-eval(parse(text = paste0("tree(resd_2~", x_vars, ", data=df4)")))
df4$pred_3 <- predict(mdl, df4)
df4
LR=0.1
df4$resd_3 <- (df4$mpg- (df4$pred_1 + (LR*df4$pred_2) + (LR*df4$pred_3)))
head(df4)

# B) writing a "for" loop to complete a "boosting" process

library(tree)
library(caret) 
library(ggplot2)
library(randomForest)

LR <- 0.15
nrounds <- 50

df4 <- mtcars
x_vars1 <- names(df4[2:ncol(df4)])
x_vars <- paste(x_vars1, collapse = " + ")

prediction <- NaN
df4 <- cbind(df4[1], prediction, df4[2:ncol(df4)]) # 第 1 列 + 新增预测列 + 原 2~ 最后一列，在数据中插入空的预测列
head(df4)

# ROUND 1
df4$pred_1 <- mean(df4$mpg)
df4$prediction <- df4$pred_1
df4$resd_1 <- (df4$mpg - df4$prediction)
df4

rmse <- RMSE(df4$mpg, df4$prediction) # RMSE() of caret
results <- data.frame("Round" = c(1), "RMSE" = c(rmse))

# a for loop from ROUND 2
# 通过多轮迭代训练决策树，逐步优化预测结果，每一轮记录模型的 RMSE 误差，最终输出每一轮的训练效果表results

for (i in 2:nrounds){
  mdl <-eval(parse(text = paste0("tree(resd_", i-1, "~", x_vars, ", 
                                 data=df4)"))) # 训练决策树，用tree()拟合上一轮的残差（resd_{i-1}），自变量是x_vars，数据为df4，得到当前轮的弱学习器
  df4[[paste0("pred_", i)]] <- predict(mdl, df4) # 用训练好的树对数据预测，结果存为pred_i列
  
  df4$prediction <- df4$prediction + # 总预测 = 历史预测 + 学习率 (LR) × 当前树预测
    (LR*df4[[paste0("pred_", i)]])
  df4[[paste0("resd_", i)]] <- (df4$mpg- df4$prediction) # 计算新残差（真实值 mpg - 当前总预测），作为下一轮树的训练目标。
  
  rmse <- RMSE(df4$mpg, df4$prediction) # 用RMSE()计算当前轮预测误差，把「迭代轮数 + RMSE」绑定到results表格
  results <- rbind(results, list("Round" = i, "RMSE" = rmse)) # 一个数据框，包含两列：Round（迭代轮数）、RMSE（每轮的预测误差）
}

results


# C) compare the boosting algorithm to tree and rf models

# tree model 单棵决策树模型
# 用tree()构建单棵决策树（基础树模型，结构简单、易过拟合 / 欠拟合）
# 计算训练集上的 RMSE（均方根误差，越小代表预测越准
tree_mdl <-eval(parse(text = paste0("tree(mpg~", x_vars, ", 
                                    data=df4)")))
prediction <- predict(tree_mdl, df4)
tree_rmse <- RMSE(df4$mpg, prediction)

# rf model  随机森林模型
# 用randomForest()构建随机森林（Bagging 集成思想：合并多棵独立树，降低方差、比单树更稳定）
# 同样计算训练集 RMSE，作为对比基准
rf_mdl <-eval(parse(text = paste0("randomForest(mpg~", x_vars, ", 
                                  data=df4)")))
prediction <- predict(rf_mdl, df4)
rf_rmse <- RMSE(df4$mpg, prediction)

# 可视化对比
ggplot() +
  geom_line(data = results, aes(x=Round, y=RMSE)) +
  geom_hline(yintercept = tree_rmse, color = "red", linetype = "dashed") +
  geom_hline(yintercept = rf_rmse, color = "blue", linetype = "dashed") 
# 折线：Boosting 提升算法每一轮迭代的 RMSE（逐轮优化，误差持续下降）
# 红虚线：单棵决策树的最终误差
# 蓝虚线：随机森林的最终误差

################################################
## 04-build models and optimize their parameters
##    to obtain high performance
################################################
install.packages("rpart")
install.packages("gbm")
install.packages("rpart.plot")

library("rpart")
library("gbm")
rm(list = ls())

data() 
data("mtcars") # 32 条汽车数据（32 款车型），共11 个全数值型变量
?mtcars

# 1) for a decision tree model

# A) Split data into train and test (70/30 split)
set.seed(123)  # Reproducibility
ind <- sample(1:nrow(mtcars), size = 0.7 * nrow(mtcars))
train_data <- mtcars[ind, ]
test_data <- mtcars[-ind, ]

# B) find the most optimum parameters for a tree model
# https://danstich.github.io/stich/classes/BIOL217/12_cart.html
# https://rpubs.com/mpfoley73/529130

library(rpart)
?rpart
library(rpart.plot)
fulltree <- rpart(mpg ~ ., data = train_data,  # 目标变量是 mpg（连续型油耗值）
                  method = "anova",  # 选择回归树（anova 方差分析法）
                  minsplit = 2, minbucket = 1,   #点只要有 2 个样本就尝试分割，最终叶子节点最少仅需 1 个样本
                  xval = 5) # 5-fold cross-validation

print(fulltree)
rpart.plot(fulltree)
printcp(fulltree) # 打印决策树的CP（复杂度参数）信息表
plotcp(fulltree)

opt_index <- which.min(fulltree$cptable[,"xerror"]) # 找到决策树交叉验证误差最低的最优剪枝节点位置，后续用这个索引取最优 CP 值做决策树剪枝
opt_cp <- fulltree$cptable[opt_index, "CP"] # 从完整决策树的 CP 表中，取出最优复杂度参数
opt_cp
prunedtree <- prune(fulltree, cp = opt_cp) # 决策树剪枝函数，砍掉完整决策树里冗余的分支，解决过拟合
rpart.plot(prunedtree) # rpart决策树的可视化

# C) model evaluation on test_data using R2 and RMSE
tree_pred <- predict(prunedtree, test_data, type = "vector")  
# type="vector"：返回连续数值型预测结果（回归任务专用）
library(caret)
tree_R2 = R2(tree_pred, test_data$mpg) # 计算R^2 决定系数，提供预测值和实际值即可
tree_R2 
tree_rmse = RMSE(tree_pred, test_data$mpg) # 计算RMSE
tree_rmse 

# 2) for a random forest model

# A) Split data for proper evaluation (70/30 split)

set.seed(123)  # Reproducibility
ind <- sample(1:nrow(mtcars), size = 0.7 * nrow(mtcars))
train_data <- mtcars[ind, ]
test_data <- mtcars[-ind, ]

# B) find the most optimum parameters for a tree model
# https://www.geeksforgeeks.org/r-machine-learning/how-to-calculate-the-oob-of-random-forest-in-r/
library(randomForest)
set.seed(123)

rf_model <- randomForest(
  mpg ~ ., 
  data = mtcars,
  ntree = 500,
  mtry = 3,   # 初始值（p=10 → p/3≈3）
  importance = TRUE
)

plot(rf_model)

# C) optimal mtry based on oob
# tuneRF是随机森林专用的参数调优函数，专门找最优mtry
# （每棵树随机选择的特征数量，随机森林核心超参）
tune <- tuneRF(
  x = mtcars[, -1],  
  y = mtcars$mpg,
  stepFactor = 1.5,  
  improve = 0.01,    
  ntreeTry = 500,
  trace = TRUE,
  plot = TRUE
)
best_mtry <- tune[which.min(tune[,2]), 1]
best_mtry

# D) using optimal mtry to re-train rf model

rf_best <- randomForest(
  mpg ~ ., 
  data = mtcars,
  ntree = 500,
  mtry = best_mtry,
  importance = TRUE
)

print(rf_best)

# further optimizing ntree
# 先建大量树，用于后续找最优值
rf_temp <- randomForest(mpg ~ ., data = mtcars, ntree = 1000)
# 树数量增加到一定程度，OOB 误差会趋于稳定
# 通过这张图，找到误差稳定时的最小 ntree
plot(rf_temp$mse, type = "l", xlab = "Number of Trees", ylab = "OOB MSE")

# optimal nodesize 
# 测试不同nodesize（节点最小样本数）对模型性能的影响，找到最优节点大小
nodesize_vals <- c(3, 5, 10)
results <- data.frame() # 建一个空数据框，用来存每个nodesize对应的模型结果

for (n in nodesize_vals) {
  rf <- randomForest(
    mpg ~ ., data = mtcars,
    ntree = 500,
    mtry = best_mtry,
    nodesize = n
  )
  
  res <- rbind(results, data.frame( # 把每个nodesize和对应的OOB_MSE（袋外均方误差）存起来
    nodesize = n,
    OOB_MSE = rf$mse[500]
  ))
}

res

# # view the importance of features
importance(rf_best)
varImpPlot(rf_best)

# Evaluation on test data

rf_model <- randomForest(
  mpg ~ ., 
  data = train_data,
  ntree = 1000,
  mtry = 3,
  importance = TRUE
)

rf_model

rf_pred <- predict(rf_model, newdata = test_data)
rf_rmse <- sqrt(mean((test_data$mpg - rf_pred)^2))
rf_R2 <- 1 - sum((test_data$mpg - rf_pred)^2) /
  sum((test_data$mpg - mean(test_data$mpg))^2)

rf_rmse
rf_R2


# build a boosting tree
library(gbm)
boost_model <- gbm(
  mpg ~ ., 
  data = train_data,
  distribution = "gaussian",   # for regres
  n.trees = 500,              
  interaction.depth = 3,      
  shrinkage = 0.01,            
  n.minobsinnode = 2           
)

boost_pred <- predict(boost_model, newdata = test_data)
boost_rmse <- RMSE(test_data$mpg, boost_pred)
boost_rmse 

cat("Tree RMSE: ", tree_rmse, "\n")
cat("Boosting RMSE: ", boost_rmse, "\n")
cat("RF RMSE: ", rf_rmse, "\n")

results <- data.frame(
  Actual = test_data$mpg,
  RF_Pred = rf_pred,
  Boost_Pred = boost_pred,
  Tree_Pred = tree_pred
)

results_long <- reshape(results, 
                        varying = c("RF_Pred", "Boost_Pred", "Tree_Pred"), 
                        v.names = "Prediction", 
                        timevar = "Model", 
                        times = c("RF", "Boosting", "Tree"),
                        direction = "long")

ggplot(results_long, aes(x = Actual, y = Prediction, color = Model)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal() +
  labs(title = "Model Comparison: Actual vs Predicted MPG",
       x = "Actual MPG", y = "Predicted MPG") +
  theme(legend.position = "top")

##########################################  
## 05-build machine learning models by caret  # 第 05 节：使用 caret 构建机器学习模型
##########################################  
# https://r.qcbs.ca/workshop04/book-en/multiple-linear-regression.html  # 原教程参考链接

library(caret)  # 加载 caret 包：统一建模、预处理、重采样、调参接口
# 1) taking a look at the algorithms  # 第一步：先查看 caret 支持的算法
modelnames <- paste(names(getModelInfo()), collapse=',')  # getModelInfo() 返回所有可用模型；paste 合并成一个字符串
modelnames  # 打印所有模型名称

modelLookup("rpart")  # 查看 rpart 决策树模型的参数信息
modelLookup("rf")  # 查看随机森林模型的参数信息
modelLookup("gbm")  # 查看 GBM 提升树模型的参数信息

# 2) training regression models   # 第二部分：训练回归模型
# A) load and split data   # A 步：读取数据并划分训练集/测试集
df5 <- read.csv("../data/dickcissel.csv",   # 读入 CSV 数据文件
                stringsAsFactors = TRUE)  # 将字符串自动转成因子，便于分类变量建模
str(df5)  # 查看数据框结构：变量类型、样本数等
head(df5)  # 查看前 6 行数据

set.seed(123)  # 固定随机种子，保证结果可复现
Index <- createDataPartition(df5$abund, p = 0.7,   # 按 abund 分层抽样，70% 作为训练集
                             list = FALSE,   # 返回矩阵/索引而不是列表
                             times = 1) # a partition  # 只做 1 次划分
data_train <- df5[Index,]  # 训练集
data_test <- df5[-Index,]  # 测试集


# # B) self-defining pre-processing of training data  # B 步示例：手动定义训练数据预处理流程
#   # 注：这一整段目前是注释状态，仅作演示
# #   # 注释占位
# # a. one-hot encoding（categories → numeric）  # a. 独热编码：把分类变量转成数值哑变量
#   # 注释占位
# dmy <- dummyVars(~ ., data = train_data)  # dummyVars() 基于所有自变量创建哑变量编码器
#   # 注释占位
# train_x <- predict(dmy, train_data)  # 用编码器转换训练集
# test_x  <- predict(dmy, test_data)  # 用同一编码器转换测试集
#   # 注释占位
# train_x <- as.data.frame(train_x)  # 转回 data.frame，便于后续处理
# test_x  <- as.data.frame(test_x)  # 转回 data.frame
#   # 注释占位
# # b. impute missing if having missing data  # b. 若存在缺失值，可先做缺失值填补
#   # 注释占位
# library(skimr)  # 加载 skimr 包，用于快速查看数据概况
# skim(train_x)  # 检查训练集变量分布和缺失情况
# skim(test_x)  # 检查测试集变量分布和缺失情况
#   # 注释占位
# pre <- preProcess(train_x,   # 基于训练集拟合预处理器
#                   method = c("medianImpute", "center", "scale"))  # 中位数填补 + 中心化 + 标准化
#   # 注释占位
# train_x <- predict(pre, train_x)  # 将预处理器应用到训练集
# test_x  <- predict(pre, test_x)  # 将同一预处理器应用到测试集
#   # 注释占位
# # c. pre-processing usually includes center and scale data  # c. 常见预处理包括中心化和标准化
#   # 注释占位
# train_x_stded <- preProcess(train_x, method = c("center", "scale"))  # 拟合一个仅做中心化/标准化的预处理器

data_train_stded <- preProcess(data_train, method = c("center", "scale"))  # 对训练集拟合标准化规则；这里只是创建对象，后面未直接使用

# C) self-defining re-sampling process for validation, and   # C 步：自定义重采样验证方案
# citing it in train() by the parameter trControl  # 然后通过 train() 的 trControl 参数传入

fitControl <- trainControl(method = "repeatedcv",     # repeatedcv：重复 k 折交叉验证
                           number = 5,     # number of folds  # 每次做 5 折
                           repeats = 2)    # repeated two times  # 整个 5 折过程重复 2 次

# ml_rpart <- train(...  # 示例：train() 中通过 trControl 使用上述验证方案
#                   trControl = fitControl,  # 指定重采样/验证控制参数
#                   ...  # 其他参数省略
#                   )   # 训练结束

# D) self-defining way for finding hyperparameters   # D 步：自定义超参数搜索方式

# the ways include tunelength (automatically),  # tuneLength：自动尝试若干个参数组合
# tuneGrid (manually) and search = “random”,  # tuneGrid：手工给定参数网格；search="random"：随机搜索

# E) training and evaluating models  # E 步：真正训练并评估模型
# a. a decision tree   # a. 决策树回归
model_rpart <- train(abund ~ ., data = data_train,   # 使用 abund 作为响应变量，其余列作为自变量
                     method = "rpart", # the tree algorithm  # 指定算法为 rpart 决策树
                     trControl = fitControl,  # 使用前面定义的重复交叉验证
                     preProcess = c('scale', 'center'),  # 在训练流程中自动标准化
                     tuneLength = 5,# find an optimal cp based on its 5 values  # 自动测试 5 个 cp 值
                     metric="RMSE")   # 以 RMSE 作为回归模型优化指标

# sum(is.na(data_train))  # number of missing values  # 统计训练集缺失值总数
# data_train <- na.omit(data_train) # Remove the rows with missing values  # 直接删除含缺失值的行
# or use imputation  # 或者使用缺失值填补
# preProcess(data_train, method = c("medianImpute"))  # 用中位数填补缺失值
#   # 注释占位
# fitControl <- trainControl(method = "repeatedcv",     # 重新定义较简单的交叉验证方案
#                            number = 5) # reduce size of folds  # 这里只保留 5 折，不重复

# Predict on the test data  # 在测试集上进行预测
predictions_rpart <- predict(model_rpart, newdata = data_test)  # 用训练好的决策树模型预测测试集

# evaluate regression performance  # 评估回归性能
Metrics::rmse(data_test$abund, predictions_rpart)  # 计算测试集真实值与预测值之间的 RMSE

# b. training a rf regression  # b. 训练随机森林回归

model_rf <- train(abund ~ ., data = data_train,   # 仍然以 abund 为响应变量
                  method = "rf",# rf algorithm  # 指定算法为随机森林
                  trControl = fitControl,  # 使用同样的重采样策略
                  preProcess = c('scale', 'center'),  # 自动标准化
                  tuneLength = 5,  # 自动尝试 5 组超参数
                  metric="RSE")   # 这里大概率应为 "RMSE"，原文可能写错了

predictions_rf <- predict(model_rf, newdata = data_test)  # 用随机森林模型预测测试集

Metrics::rmse(data_test$abund, predictions_rf)  # 计算随机森林回归的测试 RMSE

# c. training a boosting regression  # c. 训练 boosting 回归模型

model_gbm <- train(abund ~ ., data = data_train,   # 使用同一回归公式
                   method = "gbm", # boosting algorithm  # 指定算法为 GBM 提升树
                   trControl = fitControl,  # 使用相同交叉验证方案
                   preProcess = c('scale', 'center'),  # 自动标准化
                   tuneLength = 5,  # 自动搜索 5 组参数
                   metric="RMSE")    # 以 RMSE 为优化指标

predictions_gbm <- predict(model_gbm, newdata = data_test)  # 用 GBM 模型预测测试集

Metrics::rmse(data_test$abund, predictions_gbm)  # 计算 GBM 回归的测试 RMSE

# d. Compare the models' performances for final picking  # d. 比较多个模型表现，选择最终模型
models_compare <- resamples(list(TREE=model_rpart,   # 将多个训练结果对象放入列表
                                 RF=model_rf,   # 随机森林结果
                                 GBM=model_gbm))  # GBM 结果
summary(models_compare)  # 汇总各模型在重采样中的性能统计量

# Draw box plots to compare models  # 画箱线图比较不同模型表现
scales <- list(x=list(relation="free"),   # x 轴自由缩放
               y=list(relation="free"))  # y 轴自由缩放
bwplot(models_compare, scales=scales)  # 对重采样结果画箱线图

# 3) building classification models  # 第三部分：构建分类模型

# the models from caret  # 查看 caret 中分类/建模相关信息
model_info <- getModelInfo()  # 获取所有模型的详细信息列表
names(model_info)  # 查看所有模型名称
model_info[["rf"]]$parameters  # 查看随机森林模型的可调参数说明

# A) loading and spliting data  # A 步：加载并划分分类数据集

data(iris)   # 载入 R 自带 iris 鸢尾花数据集
head(iris)  # 查看前 6 行

set.seed(123)  # 固定随机种子
index <- createDataPartition(iris$Species, p=0.8, list=FALSE) #   # 按物种类别分层抽样，80% 训练集
train_data <- iris[index,]  # 分类训练集
test_data <- iris[-index,]  # 分类测试集

# B) feature selection  # B 步：特征选择/特征探索
featurePlot(x = iris[, 1:4], y = iris$Species, plot = "density",  # 绘制各特征在不同类别下的密度图
            scales = list(x = list(relation = "free"), y = list(relation="free")),  # 各面板自由坐标
            pch = "|",  # 点形样式
            layout = c(4, 1),  # 4 行 1 列排布
            auto.key = list(columns = 3))  # 图例分 3 列显示


set.seed(123)   # 固定随机种子
ctrl <- rfeControl(functions = rfFuncs,  # RFE：递归特征消除，使用随机森林函数集
                   method = "repeatedcv",  # 采用重复交叉验证
                   repeats = 5,  # 重复 5 次
                   verbose = FALSE)  # 不打印详细过程

lmProfile <- rfe(x = iris[, 1:4], y = iris$Species, rfeControl = ctrl)  # 基于前 4 个特征做递归特征消除
lmProfile  # 查看最优特征子集结果

# C) training a model with rf  # C 步：用随机森林训练分类模型
# a. using default trainControl for optimal mtry  # a. 使用默认 trainControl 自动寻找最优 mtry
# i.e. trainControl(method = "boot", number = 25)  # 默认常见方式是 bootstrap 重采样
set.seed(123)  # 固定随机种子
rf_fit1 <- train(Species~.,   # 以 Species 为分类标签，其他变量为特征
                 data = train_data,   # 使用训练集
                 method="rf")    # 指定分类器为随机森林

# rf_fit1 <- train(Species~.,   # 另一种等价写法：显式指定 trainControl
#                  data = train_data,   # 训练数据
#                  method="rf",  # 随机森林
#                  trControl = trainControl(method = "boot",   # bootstrap 重采样
#                                           number = 25))    # 重采样 25 次

rf_fit1  # 打印模型结果，包括最优参数和性能
plot(rf_fit1)  # 绘制调参结果图


# b. using self-defined trainControl way for optimal mtry  # b. 使用自定义交叉验证方式寻找最优 mtry
fitControl <- trainControl(method = "repeatedcv", number = 5,   # 5 折重复交叉验证
                           repeats=3)   # 重复 3 次

set.seed(123)  # 固定随机种子
rf_fit2 <- train(Species ~ ., data = train_data, method = "rf",  # 训练随机森林分类器
                 trControl = fitControl)   # 使用自定义验证方案

rf_fit2  # 查看模型结果

library(ModelMetrics)    # 加载 ModelMetrics 包，提供分类/回归指标函数
library(MLmetrics)  # 加载 MLmetrics 包，提供更多机器学习评估指标

# c. self-defined optimal parameters  # c. 更完整地自定义评估设置与调参过程
fitControl <- trainControl(method = 'repeatedcv', number = 5, repeats =3,  # 5 折、重复 3 次
                           savePredictions = 'final', # keep results  # 保存最终重采样预测结果
                           classProbs = TRUE, # prob values                  # 计算类别概率
                           summaryFunction=multiClassSummary) # metrics  # 使用多分类综合指标函数

rf_fit3 <- train(Species ~ ., data = train_data, method = "rf",   # 训练随机森林分类器
                 tuneLength = 5, # optimal mtry  # 自动尝试 5 个 mtry 值
                 trControl = fitControl,  # 使用上面的控制参数
                 verbose = FALSE)  # 不输出详细训练日志

rf_fit3  # 查看模型结果

# rf_pred <- predict(rf_fit3, test_data)  # 用测试集生成类别预测
# rf_pred  # 查看预测标签
# caret::confusionMatrix(reference = test_data$Species, data = rf_pred, # 用test评估模型  # 计算混淆矩阵及详细分类指标
#                        mode = "everything")  # 输出尽可能完整的评估结果
# library(MLeval)   # 加载 MLeval 包
# x <- evalm(rf_fit3)  # 评估模型并生成 ROC 等结果
# x$roc  # 查看 ROC 相关输出

tune_grid <- expand.grid(mtry = c(1, 2, 3, 4))  # 手工定义 mtry 参数网格
set.seed(123)   # 固定随机种子
rf_fit4 <- train(Species ~ ., data = train_data,  method = "rf",  # 用手工网格训练随机森林
                 tuneGrid = tune_grid,  # 指定 mtry 搜索范围
                 trControl = fitControl,  # 使用自定义交叉验证方案
                 metric = "Accuracy")  # 用 Accuracy 作为优化指标
rf_fit4  # 查看网格搜索后的模型结果

# d. adding data preProcess   # d. 在训练前加入数据预处理
set.seed(123)  # 固定随机种子
rf_fit5 <- train(Species ~ .,  # 分类公式
                 data = train_data,   # 训练集
                 method = "rf",  # 随机森林
                 preProcess = c("nzv", "center", "scale", "knnImpute", "BoxCox"),  # 去近零方差 + 标准化 + KNN 填补 + BoxCox 变换
                 na.action = na.pass,   # 遇到 NA 不直接删除，交给预处理处理
                 trControl = fitControl,  # 使用交叉验证控制参数
                 tuneLength=5)   # 自动调参长度为 5
rf_fit5  # 查看加入预处理后的模型结果

# D) comparison of several algorithms  # D 步：比较多个分类算法

library(caretEnsemble)  # 加载 caretEnsemble，用于多模型集成与批量比较
fitControl <- trainControl(  # 重新定义一个适合集成学习的控制参数
  method = "repeatedcv",  # 重复交叉验证
  number = 10,  # 10 折
  repeats = 3,  # 重复 3 次
  savePredictions = TRUE,  # 保存预测结果，便于后续集成
  classProbs = TRUE  # 保存类别概率
)

algorithmList <- c('rf', 'rpart', 'gbm')  # 指定要比较/集成的算法：随机森林、决策树、GBM

set.seed(123)  # 固定随机种子
options(na.action = na.pass)  # 全局设置：遇到 NA 不直接删除
models <- caretList(  # caretList() 可一次性训练多个 caret 模型
  Species ~ .,   # 分类公式
  data = train_data,   # 训练数据
  trControl = fitControl,  # 统一的重采样控制参数
  methodList = algorithmList,  # 要训练的模型列表
  preProcess = c("nzv", "center", "scale", "knnImpute", "BoxCox")  # 对所有模型统一做预处理
)

# Resample results  # 汇总重采样结果
results <- resamples(models)  # 把多个模型结果整合成可比较对象
summary(results)  # 输出多个模型性能的统计摘要

# Plot the results  # 画图比较结果
scales <- list(x = list(relation = "free"), y = list(relation = "free"))  # 坐标轴自由缩放
bwplot(results, scales = scales)  # 用箱线图比较多个算法在重采样中的表现