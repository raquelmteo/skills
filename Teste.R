# Instala e carrega o pacote necessário
if(!require(repr)) install.packages("repr", dependencies=TRUE)
library(repr)

# Inicializa um dataframe para guardar as estatísticas dos jogadores
estatisticas_jogadores <- data.frame(
  nome = character(),
  num_jogadas = integer(),
  tempo_jogo = numeric(),
  vitorias = integer(),
  derrotas = integer(),
  stringsAsFactors = FALSE
)

# Função para inicializar o tabuleiro com minas
inicializar_tabuleiro <- function(tamanho, num_minas) {
  tabuleiro <- matrix(0, nrow = tamanho, ncol = tamanho)
  
  # Coloca minas aleatoriamente no tabuleiro
  minas <- sample(tamanho * tamanho, num_minas)
  tabuleiro[minas] <- -1
  
  # Conta minas ao redor de cada célula
  for (i in 1:tamanho) {
    for (j in 1:tamanho) {
      if (tabuleiro[i, j] != -1) {
        for (di in -1:1) {
          for (dj in -1:1) {
            if (di != 0 || dj != 0) {
              ni <- i + di
              nj <- j + dj
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

# Função para mostrar o tabuleiro com números das linhas e colunas
mostrar_tabuleiro <- function(tabuleiro, revelado) {
  tamanho <- nrow(tabuleiro)
  
  cat("   ")
  for (j in 1:ncol(tabuleiro)) {
    cat(sprintf("%2d ", j))
  }
  cat("\n")
  
  for (i in 1:nrow(tabuleiro)) {
    linha <- sprintf("%2d ", i)
    for (j in 1:ncol(tabuleiro)) {
      if (revelado[i, j]) {
        if (tabuleiro[i, j] == -1) {
          linha <- paste(linha, "* ", sep="")
        } else {
          linha <- paste(linha, sprintf("%2d ", tabuleiro[i, j]), sep="")
        }
      } else {
        linha <- paste(linha, ". ", sep="")
      }
    }
    cat(linha, "\n")
  }
}

# Função para mostrar as estatísticas do jogador
mostrar_estatisticas <- function(estatisticas) {
  cat("Estatísticas do Jogador:\n")
  cat("Nome: ", estatisticas$nome, "\n")
  cat("Número de jogadas: ", estatisticas$num_jogadas, "\n")
  cat("Tempo de jogo: ", round(estatisticas$tempo_jogo, 2), " segundos\n")
  cat("Vitórias: ", estatisticas$vitorias, "\n")
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

# Função para registrar estatísticas dos jogadores
registrar_jogador <- function(nome) {
  if (nome %in% estatisticas_jogadores$nome) {
    return(estatisticas_jogadores[estatisticas_jogadores$nome == nome, ])
  } else {
    novo_jogador <- data.frame(
      nome = nome,
      num_jogadas = 0,
      tempo_jogo = 0,
      vitorias = 0,
      derrotas = 0,
      stringsAsFactors = FALSE
    )
    estatisticas_jogadores <<- rbind(estatisticas_jogadores, novo_jogador)
    return(novo_jogador)
  }
}

# Função para atualizar estatísticas dos jogadores
atualizar_estatisticas <- function(nome, novas_estatisticas) {
  estatisticas_jogadores[estatisticas_jogadores$nome == nome, ] <<- novas_estatisticas
}

# Função para exibir o menu principal
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

# Função para mostrar estatísticas de um jogador específico
ver_estatisticas <- function() {
  if (nrow(estatisticas_jogadores) == 0) {
    cat("Nenhum registro encontrado.\n")
    return()
  }
  
  cat("Jogadores registrados:\n")
  print(estatisticas_jogadores$nome)
  
  nome <- readline(prompt="Digite o nome do jogador para ver as estatísticas: ")
  
  if (nome %in% estatisticas_jogadores$nome) {
    mostrar_estatisticas(estatisticas_jogadores[estatisticas_jogadores$nome == nome, ])
  } else {
    cat("Jogador não encontrado.\n")
  }
}

# Função para mostrar o ranking dos jogadores
ver_ranking <- function() {
  if (nrow(estatisticas_jogadores) == 0) {
    cat("Nenhum registro encontrado.\n")
    return()
  }
  
  ranking <- estatisticas_jogadores[order(-estatisticas_jogadores$vitorias), ]
  cat("Ranking dos Jogadores:\n")
  print(ranking)
}

# Função principal do jogo
jogar <- function(tamanho = 10, num_minas = 20) {
  nome_jogador <- readline(prompt="Digite seu nome: ")
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
        estatisticas$vitorias <- estatisticas$vitorias + 1
        print("Parabéns! Você ganhou!")
      }
    }
  }
  
  end_time <- Sys.time()
  estatisticas$tempo_jogo <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  mostrar_tabuleiro(tabuleiro, revelado)
  mostrar_estatisticas(estatisticas)
  
  # Atualiza as estatísticas do jogador
  atualizar_estatisticas(nome_jogador, estatisticas)
}

# Função principal
main <- function() {
  repeat {
    opcao <- menu_principal()
    
    switch(opcao,
           `1` = {
             nome_jogador <- readline(prompt="Digite seu nome: ")
             if (nome_jogador %in% estatisticas_jogadores$nome) {
               jogar()
             } else {
               cat("Jogador não registrado. Por favor, registre-se primeiro.\n")
             }
           },
           `2` = {
             nome_jogador <- readline(prompt="Digite seu nome: ")
             registrar_jogador(nome_jogador)
             cat("Registro concluído.\n")
           },
           `3` = ver_estatisticas(),
           `4` = ver_ranking(),
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

# Executa o menu principal
main()
