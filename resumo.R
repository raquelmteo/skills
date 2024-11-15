install.packages("mice")
install.packages("lubridate")
install.packages("corrplot")
install.packages("leaps")
install.packages("pROC")
install.packages("corrgram")
install.packages("RColorBrewer")
install.packages("factoextra")

library(factoextra)
library(pROC)
library(leaps)
library(corrplot)
library(lubridate)
library(mice)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(corrgram)



#obter dataset 
dataset <- read.csv("c:/data/datasettitanic.csv", sep=';')

#ordenar por coluna
datasetordenado <- dataset[order(dataset$age ),]


#leitura visual de dados
View(dataset)
summary(dataset)

#histogramas
hist(dataset$X.pclass , col=brewer.pal(8,'Pastel2'))
hist(dataset$sex , col=brewer.pal(8,'Pastel2')) 
hist(dataset$age , col=brewer.pal(8,'Pastel2')) 
hist(dataset$sibsp , col=brewer.pal(8,'Pastel2')) 
hist(dataset$parch , col=brewer.pal(8,'Pastel2')) 
hist(dataset$fare , col=brewer.pal(8,'Pastel2')) 
hist(dataset$embarked , col=brewer.pal(8,'Pastel2')) 
hist(dataset$survived , col=brewer.pal(8,'Pastel2')) 

dataF<-dataset

#colocar coluna em factorial
dataF$sex <- factor(dataset$sex, levels=c("F", "M"))


#converter em numerico
dataN<-dataF
dataN$sex <- as.numeric(dataF$sex)


#corrigir NAS via  predictive mean matching
imputed_data <- mice(dataset, method = "pmm", seed = 123)
completed_data <- complete(imputed_data)


#sumario e relacionamento
summary(completed_data)
correlation<-cor(completed_data)
corrplot(correlation, method = "square", sig.level = 0.9, tl.col = "black", tl.srt = 90)

#correlação 2 (opcional)
corrgram(completed_data)
corrgram(completed_data, order=TRUE, lower.panel=panel.shade, upper.panel=panel.pie,text.panel=panel.txt, main="titanic")


##############arvore de decisão##############

#Analise dos melhores subsets
lmsubset<-regsubsets(survived ~ X.pclass + sex + age + sibsp + parch + fare + embarked , data = completed_data, method = "exhaustive",nbest = 1)
summary(lmsubset)
bestlmsubset<-summary(lmsubset)
plot(lmsubset)

#par(mar = c(4, 4, 2, 2))
#(width = 10, height = 8)

par(mfrow=c(1,2))
plot(bestlmsubset$cp)

#baralhamento de dados.
Ba1 <- completed_data[ sample( nrow( completed_data ) ), ]

#colunas a analisar
cols<-c(1:3)
X <- Ba1[,cols]

#colunas de classe de decisão
y <- Ba1[,8]


# 1/3 linhas para teste e 2/3 para treino
trainX <- X[1:900,]
trainy <- y[1:900]
testX <- X[901:1309,]
testy <- y[901:1309]


#Construção da arvore de decisão
model <- C50::C5.0( trainX, as.factor(trainy) )
summary( model )
plot(model, main = 'decision tree')

#predição de valores
pred <- predict(model, testX)

#cria dataser de teste com o resultado da previsão ####linhas de teste
resultadopred1<-cbind(completed_data[901:1309,],pred)


#analise do modelo
#------Area under the curve quanto mais perto de 1 mais perfeito é o modelo---#
roc_a <- roc(as.numeric(testy), as.numeric(pred))
plot(roc_a)
auc_value <- auc(roc_a)
auc_value
sensitivity <- roc_a$sensitivities
sensitivity
specificity <- roc_a$specificities
specificity



############### regressao linear ################
#Analise dos melhores subsets
lmsubset<-regsubsets( fare ~ X.pclass + sex + survived + sibsp + parch + age + embarked ,  data = completed_data,method = "exhaustive",nbest = 1)
summary(lmsubset)
bestlmsubset<-summary(lmsubset)
plot(lmsubset)
par(mfrow=c(1,2))
plot(bestlmsubset$cp)

#Construção do modelo de analise
Ba2 <- completed_data[ sample( nrow( completed_data ) ), ]

###### colunas a analizar 
cols<-c(1:8)
X <- Ba2[,cols]


##### 1/3 linhas para teste e 2/3 para treino
trainX <- X[1:900,]
testX <- X[901:1309,]


Ba21 <- lm(fare ~ X.pclass + sex + survived + sibsp + parch + age + embarked, data = trainX)
summary(Ba21)



predictions <- predict(Ba21, newdata = testX)
residuals <- residuals(Ba21)

#cria dataser de teste com o resultado da previsão
resultadopred2<-cbind(completed_data[901:1309,],predictions)

# Plot the residuals against the predictor variable x
plot(trainX$age, residuals, xlab = "x", ylab = "Residuals", main = "Residual Plot")


qqnorm(residuals)
qqline(residuals)  


############## Kmeans #############

#criação de grafico "cotovelo"

fviz_nbclust(datairis.s, kmeans, method = "silhouette")

#guarda infor do grafico 
n_clust<-fviz_nbclust(datairis.s, kmeans, method = "silhouette")

#obtem numero de clusters
n_clust<-n_clust$data
num_cluster<-as.numeric(n_clust$clusters[which.max(n_clust$y)])


#corre algoritmos kmeans
km<-kmeans(datairis.s,center=num_cluster,iter.max = 100,nstart = 25)

#visualiza clusters
fviz_cluster(km,data=datairis.s)


#adiciona o numero de cluster ao dataset scaled
datairis.s<- datairis.s |> mutate(Cluster=km$cluster)


#adiciona o numero de cluster ao dataset "normal"
datairis<- datairis |> mutate(Cluster=km$cluster)

#plot 
datairis |> ggplot(aes(x =Petal.Length , y = Sepal.Width, col = as.factor(Cluster))) + geom_point()
pairs(datairis[, 1:4], col = as.factor(datairis$Cluster))


################# Apriori ############
#leitura em formato carrinho 
trr <- read.transactions('D:/conjuntosa.csv', format = 'basket', sep=';')


View(trr)
inspect(trr)

#executa o algoritmo (ajustar o suporte e a confiança conforme necessario)
rules <- apriori(trr,parameter = list(support=0.001, confidence=0.001,minlen=2,target='rules'))

#ver resultados (com base nos resultados ordenados obtemos a sugestão de artigos principais)
inspect(rules[1:10])
inspect(sort(rules, by='support', decreasing = T)[1:5]) #ordenado por suporte representa o grupo vendas mais comuns (geral)
inspect(sort(rules, by='confidence', decreasing = T)[1:5]) #ordenado por confiança representa o mais comum de ser vendido em conjunto
inspect(sort(rules, by='lift', decreasing = T)[1:5])

#plot
itemFrequencyPlot(trr,topN=5,type="absolute",col=brewer.pal(8,'Pastel2'), main="Absolute Item Frequency Plot")
itemFrequencyPlot(trr,col=brewer.pal(8,'Pastel2'), main="items with support bigger then 0.2", support = 0.2)


