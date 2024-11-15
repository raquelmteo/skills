library(ggplot2)
library(leaps)
library(corrgram)
library(C50)
library(pROC)
library(tidyverse)

data<- read_csv(file="C:/Users/raque/Documents/R/Trabalho Final/ContactLens.csv")

#Fatorar
data$ContactLens <- as.factor(data$ContactLens)
data$TearProdRate <- as.factor(data$TearProdRate)

#Verificando se há valores NA
summary(data)

#1.Qual a distribuição de pacientes que não devem usar lentes de contato em comparação aos que devem usar lentes rígidas ou macias

#Plotar o histograma
ggplot(data, aes(x = ContactLens)) +
  geom_bar(fill = "lightblue") +
  labs(title = "Histograma de Prescrição de Lentes de Contato", 
       x = "Tipo de Lente", 
       y = "Frequência")

#2.Distribuição de tipos de lentes recomendadas por idade
ggplot(data, aes(x = Age, fill = ContactLens)) +
  geom_bar(position = "fill") +
  labs(y = "Proporção", title = "Distribuição de prescrição por idade") + 
  scale_y_continuous(labels = scales::percent)

#3.Qual a relação entre a produção de lágrimas e a prescrição
ggplot(data, aes(x = TearProdRate, fill = ContactLens)) +
  geom_bar(position = "fill") +
  labs(y = "Proporção", title = "Relação entre lágrimas e prescrição") +
  scale_y_continuous(labels = scales::percent)

#Convertendo as variáveis para fatores e numérico para árvore de decisão
data.fac<- data
data.fac$ContactLens <- as.factor(data$ContactLens)
data.fac$Age <- as.factor(data$Age)
data.fac$SpectaclePrescrip <- as.factor(data$SpectaclePrescrip)
data.fac$Astigmatism <- as.factor(data$Astigmatism)
data.fac$TearProdRate <- as.factor(data$TearProdRate)

#Melhores subsets
subsets<- regsubsets( ContactLens ~ TearProdRate + Astigmatism + SpectaclePrescrip + 
                        Age ,data=data.fac, method="exhaustive", nbest=1) 
summary(subsets)
plot(subsets)

#Faz sample do dataset
data.b <-data[sample(nrow(data)),]

#Divide 2/3 treino e 1/3 teste
treino <- data.b[1:16, ]  
teste <- data.b[17:24, ]  

#Criação do modelo
treino$Astigmatism <- factor(treino$Astigmatism, levels = c("no", "yes"), labels = c(0, 1))
model <- C5.0(ContactLens ~ ., data = treino)
plot(model, main = "Árvore de Decisão")

#Previsão
pred <- predict(model, teste)

#Juntando previsões aos dados
testefinal <- cbind(teste, Predicted = pred)

#multiclass
roc_a<- multiclass.roc(as.numeric(teste$ContactLens), as.numeric(pred))

#uniclass
roc_a_uniclass <- roc(as.numeric(teste$ContactLens), as.numeric(pred))
plot(roc_a_uniclass)
auc_value <- auc(roc_a_uniclass)

#Resultado AUC
print(paste("AUC Value: ", auc_value))



