import pygame
import numpy as np
import threading
import time

# Initialize Pygame
pygame.init()
pygame.display.set_caption("Q-Learning Grid Game")

# Screen settings
SCREEN_WIDTH = 910
SCREEN_HEIGHT = 910
MARGIN_LEFT = 50  # Margem esquerda de 50 pixels
MARGIN_TOP = 50   # Margem superior de 50 pixels
GRID_SIZE_X = 20
GRID_SIZE_Y = 20
EPISODES = 1000
CELL_SIZE = (SCREEN_WIDTH - 2 * MARGIN_LEFT) // GRID_SIZE_X  # Ajuste para a margem esquerda

# Load background image
BG1 = pygame.transform.scale(pygame.image.load("mapa1.png"), (SCREEN_WIDTH, SCREEN_HEIGHT))
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))

class MapEnvironment:
    def _init_(self):
        self.grid = np.zeros((GRID_SIZE_X, GRID_SIZE_Y))
        self.death_coordinates = [(5, 4), (5, 5), (5, 6)]
        self.obstacles = [(3, 3), (3, 4), (3, 5)]  # Coordenadas de obstáculos

        # Atribui os valores das recompensas
        for coord in self.death_coordinates:
            self.grid[coord] = -2000
        for obstacle in self.obstacles:
            self.grid[obstacle] = -1000

    def is_valid_location(self, x, y):
        # Verificar se a posição está dentro do grid e não é um obstáculo
        return 0 <= x < GRID_SIZE_X and 0 <= y < GRID_SIZE_Y and (x, y) not in self.obstacles

    def is_death_location(self, x, y):
        return (x, y) in self.death_coordinates

    def is_goal_location(self, x, y):
        return x == GRID_SIZE_X - 1 and y == GRID_SIZE_Y - 1  # Posição da célula objetivo

    def is_obstacle_location(self, x, y):
        return (x, y) in self.obstacles

    def get_reward(self, x, y):
        if self.is_death_location(x, y):
            return -2000  # Recompensa de morte
        elif self.is_goal_location(x, y):
            return 5000  # Recompensa de sucesso
        elif self.is_obstacle_location(x, y):
            return -1000  # Recompensa por bater em um obstáculo
        else:
            return -1  # Recompensa por mover-se para uma célula vazia

class QLearningAgent:
    def _init_(self, environment, learning_rate=0.1, discount_factor=0.9, exploration_rate=0.1):
        self.environment = environment
        self.learning_rate = learning_rate
        self.discount_factor = discount_factor
        self.exploration_rate = exploration_rate
        self.q_table = np.zeros((GRID_SIZE_X, GRID_SIZE_Y, 4))  # Q-table com 4 ações (up, down, left, right)
        self.current_state = (0, 0)  # Posição inicial
        self.training = False
        self.best_reward = -float('inf')  # Inicializa a melhor recompensa como o valor mais baixo possível
        self.best_episode = -1  # Para armazenar o número do episódio com a melhor recompensa

    def choose_action(self, x, y):
        # Exploração vs Exploração (ε-greedy)
        if np.random.uniform(0, 1) < self.exploration_rate:
            return np.random.choice(4)
        else:
            return np.argmax(self.q_table[x, y, :])

    def update_q_table(self, state, action, reward, next_state):
        max_next_action = np.argmax(self.q_table[next_state[0], next_state[1], :])
        current_q_value = self.q_table[state[0], state[1], action]
        self.q_table[state[0], state[1], action] += self.learning_rate * (
            reward + self.discount_factor * self.q_table[next_state[0], next_state[1], max_next_action] - current_q_value
        )

    def train(self, episodes):
        self.training = True
        for episode in range(episodes):
            state = (0, 0)  # Começa na posição inicial
            total_reward = 0  # Variável para acompanhar a pontuação total do episódio
            while not self.environment.is_goal_location(state[0], state[1]):
                action = self.choose_action(state[0], state[1])
                x, y = state
                next_state = self.get_next_state(state, action)

                if self.environment.is_valid_location(next_state[0], next_state[1]):
                    reward = self.environment.get_reward(next_state[0], next_state[1])
                    total_reward += reward  # Atualiza a pontuação total
                    self.update_q_table(state, action, reward, next_state)
                    state = next_state
                    self.current_state = state

                if self.environment.is_death_location(state[0], state[1]):
                    break

            # Verifica se a recompensa deste episódio foi a melhor
            if total_reward > self.best_reward:
                self.best_reward = total_reward
                self.best_episode = episode + 1  # Número do episódio com a melhor recompensa

            print(f"Episode {episode + 1}/{episodes} completed. Total Reward: {total_reward}")

        self.training = False
        self.exploration_rate = 0  # Desliga a exploração após o treinamento

        # Imprime a melhor tentativa após o treinamento
        print(f"Best episode: {self.best_episode} with reward: {self.best_reward}")

    def get_next_state(self, state, action):
        x, y = state
        if action == 0:  # Up
            return (x - 1, y)
        elif action == 1:  # Down
            return (x + 1, y)
        elif action == 2:  # Left
            return (x, y - 1)
        else:  # Right
            return (x, y + 1)

def draw_grid(screen, environment, agent):
    screen.blit(BG1, (0, 0))  # Desenhar a imagem de fundo

    # Desenhar a posição do agente e a posição do objetivo na área de jogo
    agent_rect = pygame.Rect(
        MARGIN_LEFT + agent.current_state[1] * CELL_SIZE, 
        MARGIN_TOP + agent.current_state[0] * CELL_SIZE, 
        CELL_SIZE, CELL_SIZE
    )
    pygame.draw.rect(screen, (255, 0, 0), agent_rect)  # Posição do agente (vermelho)

    goal_rect = pygame.Rect(
        MARGIN_LEFT + (GRID_SIZE_Y - 1) * CELL_SIZE, 
        MARGIN_TOP + (GRID_SIZE_X - 1) * CELL_SIZE, 
        CELL_SIZE, CELL_SIZE
    )
    pygame.draw.rect(screen, (255, 165, 0), goal_rect)  # Posição do objetivo (laranja)

    pygame.display.update()

def main():
    environment = MapEnvironment()
    agent = QLearningAgent(environment)

    # Start training in a separate thread
    training_thread = threading.Thread(target=agent.train, args=(EPISODES,))
    training_thread.start()

    clock = pygame.time.Clock()
    running = True  # Variável 'running' para controlar o loop principal

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:  # Se o usuário clicar no X para fechar a janela
                running = False  # Define a variável 'running' como False para sair do loop
                break  # Sai do loop de eventos

        # Update the display
        draw_grid(screen, environment, agent)
        clock.tick(30)  # Controla a taxa de quadros por segundo (FPS)

        # Se o treinamento terminou, move o agente de acordo com a Q-table
        if not agent.training:
            current_state = agent.current_state
            action = np.argmax(agent.q_table[current_state[0], current_state[1], :])
            next_state = agent.get_next_state(current_state, action)

            if environment.is_valid_location(next_state[0], next_state[1]):
                agent.current_state = next_state

            if environment.is_goal_location(next_state[0], next_state[1]):
                agent.current_state = (0, 0)  # Reset para a posição inicial

            time.sleep(0.2)  # Atrasar a visualização para não mover muito rápido

    # Wait for training thread to finish before quitting
    training_thread.join()  # Espera o treinamento terminar antes de sair

if __name__ == "__main__":
    main()
