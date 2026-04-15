# --------------------------------------------
# Script Name: Data retriever and databases  # 脚本名称：数据获取与数据库
# Purpose: My class mainly focuses on exploring the Doubs River  # 用途：本课程主要聚焦于 Doubs River 数据集的探索
#          dataset. This script is to show how to get data from  # 本脚本用于演示如何从
#          free public databases and save a database of SQlite   # 免费公共数据库获取数据，并保存为 SQLite
#          or postgresql.  # 或 PostgreSQL 数据库。

# Author:     Fanglin Liu  # 作者：Fanglin Liu
# Email:      flliu315@163.com  # 邮箱：flliu315@163.com
# Date:       2026-04-01  # 日期：2026-04-01
#
# --------------------------------------------
cat("\014") # Clears the console  # 清空控制台
rm(list = ls()) # Remove all variables  # 删除当前环境中的所有变量

#####################################################
# 01- Get data from an URL or a repository  # 01- 从 URL 或代码仓库获取数据
#####################################################

# A) using R packages to visit databases for data  # A) 使用 R 包访问数据库并获取数据
# rgbif  # rgbif 包
install.packages("rgbif")
library(rgbif)
name_backbone(name = "Lepus saxatilis") # obtaining a species key  # 获取物种对应的 key

key <- 2436775

dat <- occ_search( # searching and downloading data  # 搜索并下载数据
  taxonKey = key,
  # country = "JP",         # 国家筛选，例如日本
  # year = "2000,2020",     # 年份筛选，例如 2000 到 2020
  hasCoordinate = TRUE,
  limit = 2000
)

dat

head(dat$data) # viewing the data  # 查看数据前几行
nrow(dat$data) # number of rows  # 查看数据行数
ncol(dat$data) # number of columns  # 查看数据列数
colnames(dat$data) # column names  # 查看列名

library(ggplot2)
library(maps)

ggplot() +
  borders("world", colour = "gray70", fill = "gray90") +  # world map  # 绘制世界地图底图
  geom_point(data = dat$data,
             aes(x = decimalLongitude, y = decimalLatitude),
             color = "red", size = 1) +
  theme_minimal()

write.csv(dat$data, "../data/lepus.csv", row.names = FALSE) # save as csv  # 保存为 CSV 文件
lepus_data <- read.csv("../data/lepus.csv") # read csv back  # 重新读入 CSV 文件

# using rdataretriever to download data from databases  # 使用 rdataretriever 从数据库下载数据

# # Install rdataretriever in python environment   # 在 Python 环境中安装 rdataretriever
# # https://github.com/ropensci/rdataretriever
# # https://rstudio.github.io/reticulate/
# 
install.packages('reticulate') # interface to Python  # 安装 reticulate，用于连接 Python
library(reticulate) # run in virtual env!!!  # 在虚拟环境中运行
py_config() # check python config  # 查看 Python 配置
$pip install retriever  # 使用 pip 安装 retriever
reticulate::py_run_string("import sys; print(sys.executable)")  # 查看当前 Python 可执行文件
reticulate::py_install("retriever", pip = TRUE)  # 通过 reticulate 安装 retriever

library(reticulate)
install_miniconda()

conda_create("r-reticulate-x86", python_version = "3.11")
conda_install("r-reticulate-x86", packages = c("pip", "numpy"), pip = FALSE)
conda_install("r-reticulate-x86", packages = "retriever", pip = TRUE)

use_condaenv("r-reticulate-x86", required = TRUE)
py_config()
py_module_available("retriever")


library(rdataretriever)
get_updates() # Update the available datasets  # 更新可用数据集列表
datasets() # List the datasets available via the Retriever  # 列出 Retriever 支持的数据集
install_csv('portal') # Install csv portal, i.e. 219 dataset  # 安装 portal 数据集的 CSV 版本
download('portal', 'data/portal') # Download the portal dataset  # 下载 portal 数据集
portal = fetch('portal') # Install and load a dataset  # 安装并加载 portal 数据集
names(portal) # dataset names  # 查看 portal 中包含的数据表名称
head(portal$plot) # preview plot table  # 查看 plot 表前几行

plot <- read.csv("../data/portal/3299474") # read one portal table  # 读取 portal 中的一个表
species <- read.csv("../data/portal/3299483") # read species table  # 读取 species 表
main <- read.csv("../data/portal/5603981") # read main table  # 读取 main 表

library(tidyverse)
glimpse(main) # quick overview of data structure  # 快速查看数据结构

# download('harvard-forest', 'data/data_db') # vector [162]  # 下载 harvard-forest 数据集
# unzip("data/data_db/hf110-01-gis.zip")  # 解压 GIS 压缩文件
# 
# library(sf)
# sf <- st_read(unzip("data/data_db/hf110-01-gis.zip", #read .shp into R  # 将 shp 文件读入 R
#                     "Harvard_Forest_Properties_GIS_Layers/stands_1937.shp"))

# B) download.file() or read_csv() from websites  # B) 使用 download.file() 或 read_csv() 从网站下载数据
# https://www.davidzeleny.net/anadat-r/doku.php/en:data:doubs

# Set the base URL for the datasets  # 设置数据集的基础 URL

base_url <- "https://raw.githubusercontent.com/zdealveindy/anadat-r/master/data/"

datasets <- c("DoubsSpe.csv","DoubsEnv.csv","DoubsSpa.csv")  # List of datasets  # 数据集文件名列表

# Download each dataset  # 下载每个数据集

for(dataset in datasets) {
  full_url <- paste0(base_url, dataset) # full URL of files  # 拼接完整下载地址
  dest_file <- file.path("../data/", dataset) # the destination  # 设置本地保存路径
  download.file(full_url, destfile = dest_file, mode = "wb") # Download  # 下载文件
  cat("Downloaded:", dataset, "\n") # Print a message for complete  # 打印下载完成信息
}

# if getting an error, check DNS (sudo vim /etc/resolv.conf)  # 如果报错，可检查 DNS 配置

# C) get data from web APIs  # C) 从 Web API 获取数据

library(httr2)
response <- request("https://api.gbif.org/v1/occurrence/search") %>%
  req_url_query(
    scientificName = "Lepus saxatilis",
    hasCoordinate = TRUE,
    limit = 100
  ) %>%
  req_perform() # perform request  # 执行请求


library(jsonlite)

lepus_data <- fromJSON(
  resp_body_string(response),
  flatten = TRUE
) # parse JSON response  # 解析 JSON 响应

df <- lepus_data$results
df_key <- df[, c(
  "decimalLongitude",
  "decimalLatitude",
  "eventDate",
  "country",
  "basisOfRecord"
)] # select key fields  # 提取关键字段

str(df_key) # inspect structure  # 查看数据结构

#####################################################
# 02- loading and saving data from the R environment  # 02- 在 R 环境中加载与保存数据
#####################################################

Env <- read.csv("../data/DoubsEnv.csv", row.names = 1) # read environmental data  # 读取环境数据
# row.names = 1 表示去掉索引行号，即第一列 fields
Spe <- read.csv("../data/DoubsSpe.csv", row.names = 1) # read species data  # 读取物种数据
write.csv(Env, "../data/Env.csv", row.names = FALSE) # save Env as csv  # 将 Env 保存为 CSV
write.csv(Spe, "../data/Spe.csv", row.names = FALSE) # save Spe as csv  # 将 Spe 保存为 CSV

saveRDS(Env, "../data/Env.rds") # save Env as RDS  # 将 Env 保存为 RDS
saveRDS(Spe, "../data/Spe.rds") # save Spe as RDS  # 将 Spe 保存为 RDS
Env <- readRDS("../data/Env.rds") # load Env from RDS  # 从 RDS 读取 Env
Spe <- readRDS("../data/Spe.rds") # load Spe from RDS  # 从 RDS 读取 Spe


#####################################################
# 03-Working on the SQLite with R  # 03- 在 R 中操作 SQLite
#####################################################
# 1) Installing SQLite and DB Browser  # 1) 安装 SQLite 和 DB Browser
# to check if SQLite is installed, installing on Ubuntu  # 在 Ubuntu 上检查并安装 SQLite
# by reference to https://www.jianshu.com/p/54261f6105a0

# sudo apt-get install sqlite3  # 安装 sqlite3
# sudo apt-get install libsqlite3-dev   # 安装 sqlite3 开发库
# sudo apt-get install sqlitebrowser  # 安装 sqlitebrowser

# A) exporting data to a sqlite db by DB brower  # A) 使用 DB Browser 将数据导出到 SQLite 数据库

# importing Env and Spe into a sqlite  # 将 Env 和 Spe 导入 SQLite
# a. creating a sqlite such as doubs.sqlite  # 新建一个 SQLite 文件，例如 doubs.sqlite
# b. File → Import → Table from CSV  # 通过菜单导入 CSV 为表

# exporting Env and Spe from the sqlite  # 从 SQLite 导出 Env 和 Spe
# a. open DB brower  # 打开 DB Browser
# b. File → Export → Table(s) as CSV  # 通过菜单导出表为 CSV
# c. specifying the folder and file name  # 指定导出目录和文件名

# B) exporting data to a sqlite db using R code  # B) 使用 R 代码将数据导出到 SQLite
# https://caltechlibrary.github.io/data-carpentry-R-ecology-lesson/05-r-and-databases.html

library(tidyverse) # for the read_csv()  # 用于 read_csv()
SPE <- read_csv("../data/Spe.csv") # read species table  # 读取物种表
ENV <- read_csv("../data/Env.csv") # read environmental table  # 读取环境表


# connecting or creating db with dplyr  # 使用 dplyr 连接或创建数据库
library(DBI)
library(dplyr) 
install.packages("RSQLite")
library(RSQLite) 
# create a database by src_sqlite()  # 使用 src_sqlite() 创建数据库
my_db <- dplyr::src_sqlite("../data/DOUBS.sqlite", 
                           create = TRUE)
my_db <- dbConnect(RSQLite::SQLite(), "../data/DOUBS-2.sqlite")
my_db # print database connection  # 打印数据库连接对象

# copying the data.frames into the empty database  # 将数据框复制到空数据库中
copy_to(my_db, SPE, temporary = FALSE) # copy SPE table  # 复制 SPE 表
copy_to(my_db, ENV, temporary = FALSE) # copy ENV table  # 复制 ENV 表
my_db # inspect database  # 查看数据库状态

# dbDisconnect(my_db$con) # disconnect database  # 断开数据库连接
DBI::dbDisconnect(my_db)
class(my_db)
# my_db$con # inspect connection object  # 查看连接对象

# C) Connecting to RStudio using R code or rstdudio pane  # C) 使用 R 代码或 RStudio 面板连接数据库

# https://www.youtube.com/watch?v=id0GX4sXnyI
# https://www.youtube.com/watch?v=0euy9b3CjuY
# https://staff.washington.edu/phurvitz/r_sql/
# https://solutions.posit.co/connections/db/best-practices/drivers/

# // setup sqlite for rstudio's connections  # 为 RStudio 连接面板配置 sqlite
# apt install unixodbc   # 安装 unixODBC
# apt install sqliteodbd  # 安装 sqlite ODBC 驱动

# // two files used to set up the DSN information  # 下面两个文件用于配置 DSN 信息
# vim /etc/odbcinst.ini  # 编辑 odbcinst.ini
# vim /etc/odbc.ini  # 编辑 odbc.ini

con <- DBI::dbConnect(RSQLite::SQLite(), # create a connect  # 创建数据库连接
                        "../data/DOUBS-2.sqlite")
library(dbplyr)
dbplyr::src_dbi(con) # view the database  # 查看数据库内容

dbListTables(con) # list tables  # 列出所有表
dbListFields(con, "ENV") # list fields of ENV table  # 列出 ENV 表字段

# creating tables and inserting data by dbplyr  # 用 dbplyr 查询表并读取数据

env <- dplyr::tbl(con, "ENV") # Querying table  # 查询 ENV 表
head(env) # preview table  # 查看表前几行
library(tidyverse)
env_clean <- env |>
  select(-X) |>
  collect() # load into the R session  # 拉取到当前 R 会话中
env_clean  # view cleaned data  # 查看清洗后的数据

DBI::dbDisconnect(con) # disconnect  # 断开连接
con # inspect object after disconnect  # 查看断开后的连接对象

#################################################
# 04-Working on PostgreSQL with R  # 04- 在 R 中操作 PostgreSQL
#################################################
# ## A) Installing PostgreSQL and pgAdmin4   # A) 安装 PostgreSQL 和 pgAdmin4
# 
# # Install and configure postgresql by following  # 按以下资料安装并配置 PostgreSQL
# # https://www.youtube.com/watch?v=OxIQ_xJ-yzI
# 
# # For ubuntu 22.04, install a default postgresql version by following the site   # 在 Ubuntu 22.04 上安装默认 PostgreSQL 版本
# # https://www.rosehosting.com/blog/how-to-install-postgresql-on-ubuntu-22-04/
# # 
# # Verify the installation  # 验证安装是否成功
# # $ dpkg --status postgresql  # 查看 postgresql 软件包状态
# # $ whereis postgresql  # 查找 postgresql 路径
# # $ which psql # psql is an interactive PostgreSQL client  # 查找 psql，交互式 PostgreSQL 客户端
# # $ ll /usr/bin/psql  # 查看 psql 文件
# # $ psql -V # check postgresql version  # 查看 PostgreSQL 版本
# 
# # Configure the postgresql  # 配置 PostgreSQL
# # Including client authentication methods,connecting to   # 包括客户端认证、连接服务器、
# # PostgreSQL server, authenticating with users, etc. see  # 用户认证等内容，参见
# # https://ubuntu.com/server/docs/databases-postgresql
# 
# # Create a database and enable PostGIS extension  # 创建数据库并启用 PostGIS 扩展
# # https://staff.washington.edu/phurvitz/r_sql/
# 

# B) creating a database and some schemas with psql   # B) 使用 psql 创建数据库和 schema

# // create the user for the database  # 创建数据库用户
# create user doubs with encrypted password 'doubs';

# // default high level privileges for this user  # 为该用户设置默认高权限
# alter default privileges grant all on schemas to doubs;
# alter default privileges grant all on tables to doubs;
# alter default privileges grant all on sequences to doubs;
# alter default privileges grant all on functions to doubs;

# // create a few schemas  # 创建几个 schema
# create schema DOUBS; --for doubsEnv, doubsSpe, doubsSpa  # 用于 doubsEnv、doubsSpe、doubsSpa
# create schema postgis;  # 创建 postgis schema

# // extension  # 启用扩展
# create extension postgis with schema postgis;

# C) connecting to a database of PostgreSQL via DBI  # C) 使用 DBI 连接 PostgreSQL 数据库

library(RPostgreSQL)
doubsdata <- DBI::dbConnect(RPostgreSQL::PostgreSQL(), # connect  # 建立连接
                          dbname = 'doubs',
                          host = 'localhost',
                          port = 5432,
                          user = 'doubs',
                          password = 'doubs')

doubsdata # print connection info  # 查看连接对象
dbGetInfo(doubsdata) # get connection information  # 获取连接信息

# reading data and saving them into postgresql  # 读取数据并写入 PostgreSQL
SPE <- read.csv("data/DoubsSpe.csv", row.names = 1) # species table  # 读取物种表
ENV <- read.csv("data/DoubsEnv.csv", row.names = 1) # environmental table  # 读取环境表
SPA <- read.csv("data/DoubsSpa.csv", row.names =1) # spatial table  # 读取空间表

dbWriteTable(conn = doubsdata,
             name = "doubs_env", 
             value = ENV,
             row.names = FALSE,
             overwrite = TRUE) # write ENV table  # 写入 ENV 表

dbWriteTable(conn = doubsdata,
             name = "doubs_spe",
             value = SPE,
             row.names = FALSE,
             overwrite = TRUE) # write SPE table  # 写入 SPE 表

dbWriteTable(conn = doubsdata,
             name = "doubs_spa",
             value = SPA,
             row.names = FALSE,
             overwrite = TRUE) # write SPA table  # 写入 SPA 表

dbListFields(doubsdata, "doubs_env") # List fields of the table  # 列出 doubs_env 表字段

dbDisconnect(doubsdata) # disconnect database  # 断开数据库连接
dbGetInfo(doubsdata) # check connection object info  # 查看连接对象信息

# Connect to PostgreSQL via Rstudio connection pane  # 通过 RStudio connection 面板连接 PostgreSQL
# https://www.youtube.com/watch?v=0euy9b3CjuY&t=551s

# //open ubuntu terminal to edit /etc/odbc.ini like this  # 在 Ubuntu 终端中编辑 /etc/odbc.ini，如下所示
# [doubsdata]
# Driver = CData ODBC Driver for PostgreSQL  # PostgreSQL 的 ODBC 驱动
# Description = My Description  # 描述信息
# User = doubs  # 用户名
# Password = xxxx  # 密码
# Database = doubs  # 数据库名
# Server = 127.0.0.1  # 服务器地址
# Port = 5432  # 端口号

# # saving doubs data into postgresql  # 将 doubs 数据写入 PostgreSQL
# ?dbWriteTable # from RPostgreSQL package  # 查看 RPostgreSQL 包中的 dbWriteTable 帮助
# dbWriteTable(con, "doubs_env", ENV, overwrite = TRUE)  # 写入 doubs_env
# dbWriteTable(con, "doubs_spe", SPE, overwrite = TRUE)  # 写入 doubs_spe
