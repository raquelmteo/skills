library(leaps)
library(corrgram)
library(C50)
library(pROC)
library(tidyverse)

#1. Considerando o ficheiro fornecido (datasettitanic.csv), crie código em R gerado para responder as seguintes 
#questões:
#a. Considere o ficheiro fornecido (datasettitanic.csv), importe o mesmo.

data<- read_csv2(file="datasettitanic.csv")

#b. Utilize as funções hist e summary para ter uma visão geral dos dados
#Function hist e summary
hist(data$survived)

#i. Analise que o dataset contem 2 registos com “NAS”
summary(data)

#ii. Use a função na.omit() para remover as linhas que contêm NAS
data<-na.omit(data)

#c. Ordene o dataset por coluna “Age”
data <- data[order(data$age),]

#d. Use a função table() para verificar quantos passageiros entraram em cada porto de embarque 
#(“Embarked”)
resumo<- table(data$embarked)
print(resumo)

#e. Faça uma tabela de correlações a gosto 
data.n<- data
data.n$survived<- as.numeric(data$survived)
corrgram(data.n)

#f. Analise os melhores subsets
subsets<- regsubsets(survived ~ pclass + sex + age + sibsp + parch + fare + embarked, data=data, method="exhaustive", nbest=1) 
summary(subsets)
plot(subsets)

#g. Baralhe o dataset
data.b <-data[sample(nrow(data)),]

#h. Divida o dataset em teste e treino
Columns<-c(3,4,5,7)
treinox<-data.b[1:871,Columns]
treinoy<-as.factor(data.b$survived[1:871])

#teste
testex<-data.b[871:1307,Columns]
testey<-data.b$survived[871:1307]

#i. Faça o modelo de previsão
model<-C50::C5.0(treinox, treinoy)

#j. Gere a arvore de decisão
plot(model, main="Arvore de decisão")

#teste do modelo/aderencia

#previsao
pred<-predict(model,testex)
testefinal<-cbind(testex,testey,pred)

#k. Teste o modelo obtendo o ROC 
#roc (perto de 1 optimo 0.5 aleatorio perto de 0 totalmente errado)
roc_a<- multiclass.roc(as.numeric(testey),as.numeric(pred))
roc_a

#adecencia do modelo  uniclass
#teste area under the curve (quanto mais perto de 1 melhor)
roc_a<-roc(as.numeric(testey), as.numeric(pred))

plot(roc_a)
auc_value<-auc(roc_a)
auc_value

#m. Interprete os dados obtidos na coluna e na arvore de decisão
#A árvore de decisão mostra que as variáveis mais importantes na classificação são "embarked", "parch" e "sibsp"

