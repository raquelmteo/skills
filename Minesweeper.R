
if (!require(repr)) install.packages("repr", dependencies=TRUE)
library(repr)

# Função para inicializar o tabuleiro 
inicializar_tabuleiro <- function(tamanho, num_minas) {
  tabuleiro <- matrix(0, nrow = tamanho, ncol = tamanho)
  
  # Coloca minas aleatoriamente
  minas <- sample(tamanho * tamanho, num_minas)
  tabuleiro[minas] <- -1
  
  # Conta minas ao redor de cada célula
  for (i in 1:tamanho) {
    for (j in 1:tamanho) {
      if (tabuleiro[i, j] != -1) {
        # Verifica as células ao redor
        for (di in -1:1) {
          for (dj in -1:1) {
            if (di != 0 || dj != 0) {  # Ignora a célula central
              ni <- i + di
              nj <- j + dj
              # Verifica se a célula vizinha está nos limites
              if (ni >= 1 && ni <= tamanho && nj >= 1 && nj <= tamanho) {
                if (tabuleiro[ni, nj] == -1) {
                  tabuleiro[i, j] <- tabuleiro[i, j] + 1
                }
              }
            }
          }
        }
      }
    }
  }
  
  return(tabuleiro)
}

# Função para mostrar o tabuleiro
mostrar_tabuleiro <- function(tabuleiro, revelado) {
  tamanho <- nrow(tabuleiro)
  
  # Número das colunas
  cat("        ")
  for (j in 1:ncol(tabuleiro)) {
    cat(sprintf("%d ", j))
  }
  cat("\n")
  
  # Campo Minado
  for (i in 1:nrow(tabuleiro)) {
    linha <- sprintf("%2d ", i)
    for (j in 1:ncol(tabuleiro)) {
      if (revelado[i, j]) {
        if (tabuleiro[i, j] == -1) {
          linha <- paste(linha, "* ", sep="")
        } else {
          linha <- paste(linha, sprintf("%d ", tabuleiro[i, j]), sep="")
        }
      } else {
        linha <- paste(linha, ". ", sep="")
      }
    }
    print(linha)
  }
}

# Função pra mostrar as estatísticas
mostrar_estatisticas <- function(estatisticas) {
  cat("Estatísticas do Jogador:\n")
  cat("Nome: ", estatisticas$nome, "\n")
  cat("Número de jogadas: ", estatisticas$num_jogadas, "\n")
  cat("Tempo de jogo: ", round(estatisticas$tempo_jogo, 2), " segundos\n")
  cat("Vitórias: ", estatisticas$vitórias, "\n")
  cat("Derrotas: ", estatisticas$derrotas, "\n")
}

# Função para validar jogada
validar_jogada <- function(linha, coluna, tamanho) {
  if (is.na(linha) || is.na(coluna)) {
    return(FALSE)
  }
  if (linha < 1 || linha > tamanho || coluna < 1 || coluna > tamanho) {
    return(FALSE)
  }
  return(TRUE)
}

# Função para registrar estatísticas
registrar_jogador <- function(nome) {
  # Arquivo com os dados
  arquivo <- "estatisticas_jogadores.csv"
  
  # Verifica se o arquivo já existe
  if (!file.exists(arquivo)) {
    write.csv(data.frame(nome = character(),
                         num_jogadas = integer(),
                         tempo_jogo = numeric(),
                         vitórias = integer(),
                         derrotas = integer()),
              arquivo, row.names = FALSE)
  }
  
  # Ler estatísticas atuais
  estatisticas <- read.csv(arquivo, stringsAsFactors = FALSE)
  
  # Verifica o registro
  if (nome %in% estatisticas$nome) {
    return(estatisticas[estatisticas$nome == nome, ])
  } else {
    # Adiciona novo jogador
    novo_jogador <- data.frame(nome = nome,
                               num_jogadas = 0,
                               tempo_jogo = 0,
                               vitórias = 0,
                               derrotas = 0)
    estatisticas <- rbind(estatisticas, novo_jogador)
    write.csv(estatisticas, arquivo, row.names = FALSE)
    return(novo_jogador)
  }
}

# Função para atualizar estatísticas dos jogadores
atualizar_estatisticas <- function(nome, novas_estatisticas) {
  arquivo <- "estatisticas_jogadores.csv"
  estatisticas <- read.csv(arquivo, stringsAsFactors = FALSE)
  
  estatisticas[estatisticas$nome == nome, ] <- novas_estatisticas
  write.csv(estatisticas, arquivo, row.names = FALSE)
}

# Função para mostrar o ranking
mostrar_ranking <- function() {
  arquivo <- "estatisticas_jogadores.csv"
  if (!file.exists(arquivo)) {
    cat("Nenhum registro encontrado.\n")
    return()
  }
  
  estatisticas <- read.csv(arquivo, stringsAsFactors = FALSE)
  
  # Ordena os jogadores por numero de vitórias
  ranking <- estatisticas[order(-estatisticas$vitórias), ]
  
  cat("Ranking dos Jogadores:\n")
  print(ranking[, c("nome", "vitórias")])
}

# Função pra exibir o menu 
menu_principal <- function() {
  cat("Menu Principal:\n")
  cat("1. Jogar com um registro existente\n")
  cat("2. Se registrar pela primeira vez\n")
  cat("3. Ver estatísticas de um jogador\n")
  cat("4. Ver ranking dos jogadores\n")
  cat("5. Sair\n")
  cat("Digite a opção desejada (1, 2, 3, 4 ou 5): ")
  opcao <- as.integer(readline())
  return(opcao)
}

# Função pra mostrar estatísticas de um jogador
ver_estatisticas <- function() {
  arquivo <- "estatisticas_jogadores.csv"
  if (!file.exists(arquivo)) {
    cat("Nenhum registro encontrado.\n")
    return()
  }
  
  estatisticas <- read.csv(arquivo, stringsAsFactors = FALSE)
  
  cat("Jogadores registrados:\n")
  print(estatisticas$nome)
  
  nome <- readline(prompt="Digite o nome do jogador para ver as estatísticas: ")
  
  if (nome %in% estatisticas$nome) {
    mostrar_estatisticas(estatisticas[estatisticas$nome == nome, ])
  } else {
    cat("Jogador não encontrado.\n")
  }
}

# Função que mostra a lista de jogadores registrados
mostrar_lista_jogadores <- function() {
  arquivo <- "estatisticas_jogadores.csv"
  if (!file.exists(arquivo)) {
    cat("Nenhum registro encontrado.\n")
    return(NULL)
  }
  
  estatisticas <- read.csv(arquivo, stringsAsFactors = FALSE)
  cat("Jogadores registrados:\n")
  print(estatisticas$nome)
  return(estatisticas$nome)
}

# Função do jogo
jogar <- function(tamanho = 10, num_minas = 20) {
  cat("Escolha um jogador para jogar:\n")
  jogadores <- mostrar_lista_jogadores()
  
  if (is.null(jogadores)) {
    cat("Nenhum jogador registrado. Volte ao menu para se registrar.\n")
    return(invisible(NULL))
  }
  
  nome_jogador <- readline(prompt="Digite o nome do jogador: ")
  
  if (!(nome_jogador %in% jogadores)) {
    cat("Jogador não encontrado. Por favor, registre-se primeiro.\n")
    return(invisible(NULL))
  }
  
  estatisticas <- registrar_jogador(nome_jogador)
  
  tabuleiro <- inicializar_tabuleiro(tamanho, num_minas)
  revelado <- matrix(FALSE, nrow = tamanho, ncol = tamanho)
  
  perdeu <- FALSE
  ganhou <- FALSE
  jogadas_restantes <- tamanho * tamanho - num_minas
  
  start_time <- Sys.time()
  
  while (!perdeu && !ganhou) {
    mostrar_tabuleiro(tabuleiro, revelado)
    
    jogada_valida <- FALSE
    while (!jogada_valida) {
      linha <- readline(prompt="Digite a linha (ou 'q' para sair): ")
      if (linha == "q") {
        cat("Você decidiu sair do jogo. Até a próxima!\n")
        return(invisible(NULL))
      }
      coluna <- readline(prompt="Digite a coluna (ou 'q' para sair): ")
      if (coluna == "q") {
        cat("Você decidiu sair do jogo. Até a próxima!\n")
        return(invisible(NULL))
      }
      linha <- as.integer(linha)
      coluna <- as.integer(coluna)
      
      if (validar_jogada(linha, coluna, tamanho)) {
        jogada_valida <- TRUE
      } else {
        cat("Jogada inválida! Tente novamente.\n")
      }
    }
    
    estatisticas$num_jogadas <- estatisticas$num_jogadas + 1
    
    if (tabuleiro[linha, coluna] == -1) {
      perdeu <- TRUE
      revelado[,] <- TRUE
      estatisticas$derrotas <- estatisticas$derrotas + 1
      print("Você pisou em uma mina! Fim de jogo.")
    } else {
      if (!revelado[linha, coluna]) {
        revelado[linha, coluna] <- TRUE
        jogadas_restantes <- jogadas_restantes - 1
      }
      if (jogadas_restantes == 0) {
        ganhou <- TRUE
        revelado[,] <- TRUE
        estatisticas$vitórias <- estatisticas$vitórias + 1
        print("Parabéns! Você ganhou!")
      }
    }
  }
  
  end_time <- Sys.time()
  estatisticas$tempo_jogo <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  mostrar_tabuleiro(tabuleiro, revelado)
  mostrar_estatisticas(estatisticas)
  
  # Atualiza as estatísticas
  atualizar_estatisticas(nome_jogador, estatisticas)
}


main <- function() {
  repeat {
    opcao <- menu_principal()
    
    switch(opcao,
           `1` = jogar(),  
           `2` = {
             nome_jogador <- readline(prompt="Digite seu nome: ")
             registrar_jogador(nome_jogador)
             jogar()
           },
           `3` = ver_estatisticas(),  
           `4` = mostrar_ranking(),  
           `5` = {
             cat("Saindo do programa. Até a próxima!\n")
             break
           },
           {
             cat("Opção inválida. Por favor, escolha uma opção válida.\n")
           }
    )
  }
}

main()

# # Dados para testar
# estatisticas_ficticias <- data.frame(
#   nome = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
#   num_jogadas = c(15, 20, 10, 25, 18),
#   tempo_jogo = c(30, 40, 25, 50, 35),
#   vitórias = c(5, 7, 3, 10, 6),
#   derrotas = c(3, 5, 2, 7, 4)
# )
# write.csv(estatisticas_ficticias, "estatisticas_jogadores.csv", row.names = FALSE)




