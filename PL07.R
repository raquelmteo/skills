
library(leaps)
library(corrgram)
library(mice)
library(tidyverse)
library(ggplot2)
library(reshape2)
#1. Considerando o ficheiro fornecido anteriormente (casas.csv), crie código em R gerado para responder as 
#seguintes questões:
data<- read_csv(file="casas.csv")

resumo<- table(data$Species)
print(resumo)

#a. Recrie a tabela de correlações (anteriormente executado) 
#i. Analise os campos que têm melhor correlação com o campo “price"

hist(as.numeric(data$price))

data.n<- datai
data.n$price<-as.numeric(data$price)
corrgram(data.n)

#"sqft_living" e "grade" têm as correlações mais fortes e positivas com "price". Quanto maior a área do imóvel e melhor o "grade", maior o preço.
#"bathrooms" e "sqft_above" também apresentam correlações positivas significativas.
#"yr_built" e "zipcode" têm correlação muito baixa ou próxima de zero.

#best subsets 
subsets<- regsubsets( price ~ sqft_living + grade + bathrooms + sqft_above, data=data, method="exhaustive", nbest=1) 
summary(subsets)
plot(subsets)

#b. Baralhe o dataset
data.b <-data[sample(nrow(data)),]

cols<-c(3:21)
x<-data.b[,cols]


#c. Divida o dataset em teste e treino
train<-x[1:14409,]
test<-x[14409:21613,]

#d. Faça o modelo de previsão
model.data<-lm(price ~ sqft_living + grade + bathrooms + sqft_above, data=train)

#Resumo modelo
summary(model.data)

#e. Teste o modelo obtendo o R2
predictions <- predict(model.data, test)


#f. Adicione a coluna gerada ao dataset original
result<-cbind(test, predictions)

#g. Interprete os dados obtidos na coluna
#Com o R2 0.55 sugere o modelo explica somente 55% da variação dos preços e que podem existir outros fatores que influenciam.
varTest <- result[[1]]
varPred <- result[[20]]

df <- data.frame(varTest, varPred)

#Gráfico com a diferença testexprevisão
df$Diferenca <- df$varTest - df$varPred

ggplot(df, aes(x = factor(1:nrow(df)), y = Diferenca)) +
  geom_bar(stat = "identity") +
  labs(x = "Observações", y = "Diferença", title = "Teste X Previsão")





