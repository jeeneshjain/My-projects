
# Import data into  dataframe
library(data.table)
# To make used of pipelining process and cleaning of data and descriptive analysis of data
library(dplyr)
# To visualize the data
library(ggplot2)
# To make a correlation plot
library(corrplot)
# To tune the model, and for feature selection
library(caret)
# To clean the data
library(tidyverse)
# To create a correlation heatmap
library(cowplot)
# To determine metrics of model
library(Metrics)
# To plot the missing values
library(naniar)
# needs to be run every time you start R and want to use %>%
library(magrittr) 
# alternatively, this also loads %>%
library(dplyr)   
# To Importhigh level graphs and functions used for Data Analytics
library(Hmisc)


Sales = read.csv("C:/Users/Admin/Desktop/SMart_sales.csv")

# To list out the type of each attribute used in this dataset
sapply(Sales, class)

#Getting gist of data

head(Sales)

# For Reading all the column Names in the dataset
names(Sales)

#To get the dimension of the specified matrix, array or data frame
dim(Sales)

#To get the summary of all columns in this dataset
summary(Sales)


# Replacing the Values
Sales <- Sales %>% mutate(Customer.type = replace(Customer.type,Customer.type == "Subscribed User","Member"))
Sales <- Sales %>% mutate(Customer.type = replace(Customer.type,Customer.type == "Un Subscribed User","Normal"))

#Sorting the data by Order

Sales[order(Sales$Date),]


# Missing Value Treatment

missing_values <-  summarise_all(Sales, funs(missing=sum(is.na(.))))

#Plotting Missing values to see if there are any missing values

gg_miss_var(Sales)

miss_var_summary(Sales)

Sales

# Converting date to Datetime

library(lubridate)
Sales$Date <- parse_date_time(x = Sales$Date,
                           orders = c("d m y", "d B Y", "m/d/y"),
                           locale = "eng")

# Now consider the number of instances (rows) that belong to each class. 
# Class distribution Summarization

percentage <- prop.table(table(Sales$Payment)) * 100
cbind(freq=table(Sales$Payment), percentage=percentage)

#Data Analysis Section

# Starting off with numerical Columns


# Finding the Correlations with some part of Dataset at significance levels
my_data <- Sales %>% select(7, 8, 9, 10, 14, 15, 16, 17)

# Finding out the polychoric correlation
library(polycor)
polychor(my_data)

# Summarizing Data
table(Sales$City, Sales$Rating)

#Unit Price comparision with gross income
x <- Sales$Unit.price
y <- Sales$gross.income
plot(x, y, col = "Dark green", main="Unit Price Vs Gross Income",
     xlab="Unit Price", ylab="Gross Income")

#Customer Rating Analysis

Rating_Analysis <- Sales$Rating
hist(Rating_Analysis, col = 'Blue')

#Taking Average of the Rating - Overall Average

Rating_Analysis <- Sales$Rating
average <- mean(Rating)
hist(Rating, col = 'Blue')
abline(v= average, col='Red', lwd =4)

# To plot the Histogram for the whole dataset

hist.data.frame(Sales)

# Correlation Matrix


library(corrplot)
library(ggplot2)


# Counting the Branches
counts <- Sales %>% count(Branch)
counts

# Branch Analysis - Operations Persepective to Analyse the Busiest Branch

ggplot(data = Sales, aes(x = Branch)) +
  geom_bar(aes(fill = Branch)) + 
  labs(title = "Branch Analysis - Across Locations",
       subtitle = "Busiest Branch",
       x = "Branch_Name",
       y = "Operations") 

# payment Method Analysis - To Validate and the understand the most used Payment method

ggplot(data = Sales, aes(x = Payment)) +
  geom_bar(aes(fill = Payment)) + 
  labs(title = "Payment Method Analysis",
       subtitle = "Mostly Used Payment Method.",
       x = "Payment methods",
       y = "Number of Times Used")


# Gender Analysis - To check on which gender is giving Most sales

ggplot(data = Sales, aes(x = Gender)) +
  geom_bar(aes(fill = Gender)) + 
  labs(title = "Gender Analysis",
       subtitle = "Count of Gender",
       x = "Gender Type",
       y = "Number")

#Gender Analysis by Product
ggplot(Sales, aes(y=`Product.line`)) + 
  geom_bar(aes(fill = Gender)) + 
  labs(title = "Gender Analysis per Product Type",
       x = "Count",
       y = "Product Type")

#Histogram Charts

hist(Sales$gross.income)
hist(Sales$Quantity)
hist(Sales$Total)


#Correlation Analysis
cor = cor(Sales$Quantity,Sales$gross.income)
cor

#Model 1: Linear Regression - To validate Quantity Vs Total

Sales_Quantity.lm <- lm(Quantity ~ Total, data = Sales)

summary(Sales_Quantity.lm)

#Visualizations: Simple Regression - Plotting the data on graph

Quantity.graph<-ggplot(Sales, aes(x=Quantity, y= gross.income))+
  geom_point()
Quantity.graph

#Model 2 : # Multiple Regression : To Validate Gross Income vs Total

Sales_Gross_Income.lm <- lm(gross.income ~ Quantity + Total, data = Sales)

summary(Sales_Gross_Income.lm)

plotmulti.data <- expand.grid(Total = seq(min(Sales$gross.income), max(Sales$Quantity), length.out=30),
                                Year=c(min(Sales$Total), mean(Sales$Total), max(Sales$Total)))


#Model 3 - Time Series Forecast

Sales = read.csv("C:/Users/Admin/Desktop/SMart_sales.csv", na.strings=c("null", "","NA"), 
                 stringsAsFactors = TRUE)

glimpse(Sales)


#Setting Random Seed
set.seed(149)

#Use 70% of dataset as training set and remaining 30% as testing set 
train <- Sales %>% dplyr::sample_frac(0.7)
test  <- dplyr::anti_join(Sales, train, by = 'Product.line')


#Printing number of rows in testing and training data
nrow(train); nrow(test)

Sales_tsobject <- ts(train[, 6], start = c(15, 1), end = c(1000, 12), frequency = 12)

# create a utility function for calculating Mean Absolute Percentage Error (or MAPE), 
#which shall be used to evaluate the performance of the forecasting models.

mape <- function(actual,pred)
{
  mape <- mean(abs((actual - pred)/actual))*100
  return (mape)
}

#Naive Forecasting Method

naive_mod <- naive(Sales_tsobject, h = 23)
summary(naive_mod)

test$naive = 100
mape(test$unemploy,test$naive)  ## NaN -- Almost Zero

# Arima Model
arima_model <- auto.arima(car_tsobject)
summary(arima_model)
fore_arima = forecast::forecast(arima_model, h=23)
df_arima = as.data.frame(fore_arima)
test$arima = df_arima$`Point Forecast`
mape(test$unemploy, test$arima)