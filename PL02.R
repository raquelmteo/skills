#a. Apresentar todos os números pares entre X e Y. (atribua valores a X e Y) 
x<-as.integer(100)
y<-as.integer(200)

for (i in x:y) {
  if (i %% 2 == 0) {
    print(i)
  }
}

#b. Crie um vetor com 10 números aleatórios a soma e média de todos os números introduzidos. 
#i. Imprime o vetor todo ordenado

num<- sample(1:100, 10)
soma<- sum(num)
media<- mean(num)
ordenar<- sort(num)

cat("Soma: ", soma, "\nMédia: " , media, "\nVetor ordenado: " , ordenar)

#c. Determinar a percentagem dos N alunos de uma turma com idade superior a uma dada idade definida 
#pelo utilizador
alunos<- sample(18:80, replace = TRUE)
idade<- as.integer(readline(prompt="Idade: "))
contagem<- 0

for (i in alunos) {
  if (i > idade) {
    contagem<- contagem + 1
  }
}

percentagem<- (contagem/length(alunos)) * 100

cat("Percentagem de alunos com mais que", idade, "anos:", percentagem, "%")

#d. Crie um vetor com 10 números aleatórios inteiros e mostre o maior número par. Se não tiver sido 
#introduzido nenhum número par deve aparecer uma mensagem adequada
alunos<- sample(1:100, 10)
par<- 0

for (i in alunos) {
  if (i %% 2 == 0 && i > par) {  
      par<- i 
  }
}

if (par) {
  cat("O maior número par encontrado é:", par)
} else {
  cat("Não foi encontrado nenhum número par")
}

#e. Ler um vector de N números inteiros e escrevê-lo pala mesma ordem
n<- 15
vec<- sample(1:100, n)
print(vec)

# f. Ler um vetor de N e escrevê-lo pela ordem inversa
print(rev(vec))

# g. Dados dois vetores VEC1 e VEC2 ambos de N elementos, some os 2 vetores e apresente o resultado.
n<- 10
vec1<- sample(1:100, n)
vec2<- sample(1:100, n)
print(vec1)
print(vec2)
resultado<- vec1 + vec2
cat("Soma dos vetores:", resultado, "\n")
cat("Resultado ordenado decrescentemente:", rev(resultado))

# h. Ler duas matrizes, A e B, de N linhas e Y colunas, e inserir o resultado da soma das matrizes A e B numa nova matriz C.
n<- 3
y<- 4
a<- matrix(sample(1:100, n*y, replace = TRUE), nrow = n, ncol = y)
b<- matrix(sample(1:100, n*y, replace = TRUE), nrow = n, ncol = y)
print(a)
print(b)
c<- a + b
print(c)

# i. Guardar numa estrutura de dados adequada, os dados de N funcionários de uma empresa
n<- 5
cod_func<- 1:n
nome<- paste("Funcionario", 1:n)
salario<- round(runif(n, 800, 2000), 2)

funcionarios<- matrix(c(as.character(cod_func), nome, as.character(salario)), nrow = n, ncol = 3, byrow = FALSE)
colnames(funcionarios)<- c("Cod_Func", "Nome", "Salario")

print(funcionarios)

salarios_altos<- which(as.numeric(funcionarios[, "Salario"]) > 1000)
cat("Códigos dos funcionários com salário superior a 1000€:", funcionarios[salarios_altos, "Cod_Func"], "\n")

# j. Guardar numa estrutura de dados adequada os dados de N alunos de uma turma
n<- 10
alunos<- matrix(nrow = n, ncol = 2)
colnames(alunos)<- c("Numero", "Idade")
alunos[, "Numero"]<- 1:n
alunos[, "Idade"]<- sample(15:25, n, replace = TRUE)

print(alunos)

alunos_16_20<- which(alunos[, "Idade"] >= 16 & alunos[, "Idade"] <= 20)
cat("Números dos alunos com idade entre 16 e 20:", alunos[alunos_16_20, "Numero"], "\n")

# k. Guardar numa estrutura de dados adequada os dados de N alunos de uma turma
n<- 10
alunos<- matrix(nrow = n, ncol = 2)
colnames(alunos)<- c("Numero", "Media")
alunos[, "Numero"]<- 1:n
alunos[, "Media"]<- round(runif(n, 0, 20), 2)

print(alunos)

# Encontrar o aluno com a melhor média
melhorAluno<- which.max(as.numeric(alunos[, "Media"]))
cat("Número do aluno com melhor média:", alunos[melhorAluno, "Numero"], "\n")
cat("Melhor média:", alunos[melhorAluno, "Media"])
