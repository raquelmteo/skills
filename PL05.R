library(factoextra)
library(corrgram)
library(tidyverse)
library(ggplot2)

data <- read.csv("casas.csv")
data.c <- data[, c( "price", "bedrooms", "sqft_living","grade", "yr_renovated", "lat", "long")]

#a. Considere o ficheiro fornecido (casas), crie uma tabela normalizada (scaled).
data.s<-scale(data.c)
data.s<-as.data.frame(scale(data.c))

#b. Crie o gráfico cotovelo segundo método silhouette
fviz_nbclust(data.s, kmeans, method="silhouette")

#c. Guarde numa variável o número de cluster ideais.
nclust<-fviz_nbclust(data.s, kmeans, method="silhouette")
nclust<-nclust$data
nclust<-as.numeric(nclust$clusters[which.max(nclust$y)])

#d. Execute a classificação em clusters usando kmeans
clust.km<-kmeans(data.s,centers = nclust,iter.max = 100, nstart = 25)

#e. Cria um gráfico com a representação visual dos clusters
fviz_cluster(clust.km,data=data.s)

#f. Adiciona o número do cluster ao dataset original
data<-data |> mutate(cluster=clust.km$cluster)

#g. Produza um gráfico de dispersão com base nos clusters e tente classificar 
#os grupos gerados
data.c<-data.c |> mutate(cluster=clust.km$cluster)
pairs(data.c[1:8], pch= 21, bg = c("red", "green3")[unclass(data.c$cluster)])

#Cluster 1 (preto): Casas acessíveis com menos atrativos em termos de tamanho e qualidade.
#Cluster 2 (verde): Casas de valor médio, com variações em tamanho, localização e qualidade.
#Cluster 3 (vermelho): Casas de alto padrão, grandes, com melhor localização e maior qualidade..


#2. Considerando o ficheiro fornecido (bancos), crie código em R gerado para responder as seguintes questões:
#a. Gere os clusters e classifique os grupos de acordo com os clusters gerados
#Le arquvo
dataBank<- read.csv2("clients.csv")

nonNumeriCols <- sapply(dataBank, function(col) !is.numeric(col))

#Fatoriza
dataBank[, nonNumeriCols] <- lapply(dataBank[, nonNumeriCols], as.factor)
dataBank.n <- dataBank

factorCols <- sapply(dataBank.n, is.factor)
dataBank.n[, factorCols] <- lapply(dataBank.n[,factorCols], as.numeric)

#Normaliza
dataBank.n<-scale(dataBank.n)
dataBank.s<-as.data.frame(scale(dataBank.n))

#Matodo cotovelo
fviz_nbclust(dataBank.s, kmeans, method="silhouette")

#Num otimo de clusters
nclust<-fviz_nbclust(dataBank.s, kmeans, method="silhouette")
nclust<-nclust$dataBank
nclust<-as.numeric(nclust$clusters[which.max(nclust$y)])

#CLsssificação dos clusters
clust.km<-kmeans(dataBank.s,centers = nclust,iter.max = 100, nstart = 25)

#Representação dos clusters
fviz_cluster(clust.km,data=dataBank.s)

dataBank.n <- as.data.frame(dataBank.n)
dataBank<-dataBank |> mutate(cluster=clust.km$cluster)
dataBank.n<-dataBank.n |> mutate(cluster=clust.km$cluster)

#Gráfico das variaveis
pairs(dataBank.n[1:11], pch= 21, bg = c("red", "green3")[unclass(dataBank.n$cluster)])

#Cluster Vermelho: Jovens com baixa renda, possivelmente solteiros e sem filhos.
#Cluster Verde: Indivíduos mais velhos, com alta renda, casados e com filhos, provavelmente donos de carros.
#Cluster Preto: Um grupo intermediário em termos de idade, renda e posses, com uma distribuição geográfica mais concentrada.
