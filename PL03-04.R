#PL03
#a. Considere o ficheiro fornecido (casas), importe o ficheiro para o r-studio 
#e guarde dentro de um dataset
casas <- read.csv("C:/Users/dataan/Desktop/R/casas.csv")
casas <- data.frame(casas)

#b. Liste as primeiras 5 linhas da lista
head(casas,5)

#c. Execute a função summary() ao dataset completo
summary(casas)

#i. Execute summary() a coluna “yr_built”
summary(casas$yr_built)

#ii. Analise e tente entender o resultado obtido
# - Dados das casas começam do ano 1900, e vão até 2015. 
# - O dataset tem 21613 linhas e 21 variaveis.
# - O preço vai de 7500 a 7700000.

#d. Execute histograma para os seguintes campos:
#i. price
hist(casas$price)

#ii. grade
hist(casas$grade)

#iii. yr_built
hist(casas$yr_built)

#e. crie um histograma para price, mas usando breaks= "Freedman-Diaconis"
#e foque na gama 0 a 1000000
hist(casas$price, breaks = "Freedman-Diaconis", xlim = range(0,1000000))

#i. adicione uma linha que represente a media
hist(casas$price, breaks = "Freedman-Diaconis", xlim = range(0,1000000))
abline(v = mean(casas$price), col = 'red', lwd = 2)

#f. Crie uma copia do dataset criado na alínea A
casas_copia <- casas

#g. Use a função table() para contar a quantidade de cada $grade
table(casas_copia$grade)

#i. Crie um pie chart que contenha as 5 grades mais recorrentes
pie(sort(table(casas$grade), decreasing = TRUE)[1:5])

#. Execute o mesmo da alínea mas para a coluna $floors 
table(casas_copia$floors)
pie(sort(table(casas$floors), decreasing = TRUE)[1:5])

#i. Usando o plot() crie um gráfico de dispersão com base no campo 
#$yr_built e $price 
plot(casas$yr_built, casas$price)

#i. Consegue identificar algum padrão?
# - Uma maior dispersão nos anos que teve uma maior frequência de construções.
# - 3 outliers com preços mais altos.

#j. Considere o ficheiro fornecido (bank clients.csv), importe o ficheiro para 
#o r-studio e guarde dentro de um dataset
clients <- read.csv("C:/Users/dataan/Desktop/R/bank clients.csv", sep = ";")
clients <- data.frame(clients)

#k. Crie um dataset baseado no anterior em que os campos da tabela se encontrem
#em fatorial
clients.f <- data.frame(lapply(clients, factor))

#l. Crie um dataset baseado no anterior em que os campos da tabela se encontrem 
#em numérico
clients.num <- data.frame(lapply(clients.f, as.numeric))
      
#i. Execute as funções summary e hist de forma a analisar pelo menos 3 campos 
#a escolha
summary(clients)
hist(clients$age)
hist(clients$income)
hist(clients$children)
################################################################################
#PL04
#a. Considere o ficheiro fornecido (casas), crie a tabela de correlações
casas.f <- data.frame(lapply(casas, factor))
casas.num <- data.frame(lapply(casas.f, as.numeric))
casas.c <- cor(casas.num)
corrplot(casas.c)

#b. Crie uma versão arredondada as 2 casas decimais 
casas.c <- round(casas.c, 2)
corrplot(casas.c)

#c. Usando o corrplot crie o gráfico de correlações recorrendo ao método “square”
corrplot(casas.c, method = "square")

#d. Use o corrgram para criar um gráfico com o painel superior do tipo “pie” o 
#inferior do tipo “bars” e a diagonal “density” 
install.packages("corrgram")
library(corrgram)
corrgram(casas.c, 
         upper.panel = panel.pie, 
         lower.panel = panel.bar, 
         diag.panel = panel.density)

#e. Explique a correlação entre sqft_living e bathrooms
#- Mostram uma correlação positiva, acredito que quantos mais banheiros maior 
#o tamanho da casa.

#f. Explique a correlação entre sqft_lot e floors 
#- Mostra uma correlação negativa, quanto menos pisos a casa tem, menor será 
#o tamanho total do lote.

#g. Faz sentido executar uma correlação a campos tipo ID? 
#-Não, os campos de ID não tem informação relevante para a correlação.

#h. Considere o ficheiro fornecido (bank clients.csv), importe o ficheiro 
#para o r-studio e guarde dentro de um dataset 
clients <- read.csv("C:/Users/dataan/Desktop/R/bank clients.csv", sep = ";")
clients <- data.frame(clients)

#i. Use e explore a uma das librarias a gosto de forma a obter um gráfico 
#customizado 
clients.f <- data.frame(lapply(clients, factor))
clients.num <- data.frame(lapply(clients.f, as.numeric))
corrplot(cor(clients.num), method = "circle")

#j. Analise e explique a correlação entre o campo “age” e “income” 
# - Existe uma correlação positiva entre a idade e o salário, provavelmente
# quanto mais velho, mas possível de ter salários mais altos.


