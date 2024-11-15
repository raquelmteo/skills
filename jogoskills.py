"""import pygame
import numpy as np
import random

pygame.init()
pygame.display.set_caption("Gridgame")

# Game settings
screen_width, screen_height = 910, 910
screen = pygame.display.set_mode((screen_width, screen_height))

# Player (agent) settings
player_size_x, player_size_y = 50, 50
player_position_x, player_position_y = 300, 250
player = pygame.Rect(player_position_x, player_position_y, player_size_x, player_size_y)

# Q-Learning parameters
GRID_SIZE_X, GRID_SIZE_Y = screen_width // player_size_x, screen_height // player_size_y
EPISODES = 1000  # Number of episodes for training

class QLearningAgent:
    def __init__(self, grid_size_x, grid_size_y, learning_rate=0.1, discount_factor=0.9, exploration_rate=0.1):
        self.learning_rate = learning_rate
        self.discount_factor = discount_factor
        self.exploration_rate = exploration_rate
        self.q_table = np.zeros((grid_size_x, grid_size_y, 4))  # Initialize Q-table with zeros

    def choose_action(self, x, y):
        if np.random.uniform(0, 1) < self.exploration_rate:
            return np.random.choice(4)  # Explore randomly
        else:
            return np.argmax(self.q_table[x, y, :])  # Choose the action with the highest Q-value

    def update_q_table(self, state, action, reward, next_state):
        max_next_action = np.argmax(self.q_table[next_state[0], next_state[1], :])
        current_q_value = self.q_table[state[0], state[1], action]
        self.q_table[state[0], state[1], action] += self.learning_rate * (
            reward + self.discount_factor * self.q_table[next_state[0], next_state[1], max_next_action] - current_q_value)

# Initialize agent
agent = QLearningAgent(GRID_SIZE_X, GRID_SIZE_Y)

# Training loop
for episode in range(EPISODES):
    state = (player.x // player_size_x, player.y // player_size_y)  # Start position
    running = True
    total_reward = 0

    while running:
        # Choose action
        action = agent.choose_action(state[0], state[1])

        # Define next position based on action
        if action == 0:  # Up
            next_position = (player.x, max(0, player.y - player_size_y))
        elif action == 1:  # Down
            next_position = (player.x, min(screen_height - player_size_y, player.y + player_size_y))
        elif action == 2:  # Left
            next_position = (max(0, player.x - player_size_x), player.y)
        elif action == 3:  # Right
            next_position = (min(screen_width - player_size_x, player.x + player_size_x), player.y)

        # Check if hit the border and assign rewards
        if next_position[0] == 0 or next_position[1] == 0 or next_position[0] == screen_width - player_size_x or next_position[1] == screen_height - player_size_y:
            reward = -10  # Penalty for hitting the border
            running = False  # End episode if hits the border
        else:
            reward = -1  # Slight penalty per move

        # Update agent position
        player.x, player.y = next_position
        next_state = (player.x // player_size_x, player.y // player_size_y)

        # Update Q-table
        agent.update_q_table(state, action, reward, next_state)
        state = next_state
        total_reward += reward

    print(f"Episode {episode + 1}/{EPISODES}, Total Reward: {total_reward}")

# Close Pygame after training
pygame.quit()

import numpy as np
import pygame

# Define the game environment
GRID_SIZE_X = 20
GRID_SIZE_Y = 20
DEATH_COORDINATES = [(5, 4), (5, 5), (5, 6)]
OBSTACLES = [(3, 3), (3, 4), (3, 5)]
GOAL_POSITION = (GRID_SIZE_X - 1, GRID_SIZE_Y - 1)

# Initialize Pygame
pygame.init()
pygame.display.set_caption("Gridgame")
screen = pygame.display.set_mode((GRID_SIZE_X * 50, GRID_SIZE_Y * 50))

# Player
player_position_x = 0
player_position_y = 0
player_size_x = 50
player_size_y = 50
player = pygame.Rect(player_position_x, player_position_y, player_size_x, player_size_y)

# Q-learning agent
class QLearningAgent:
    def __init__(self, learning_rate=0.1, discount_factor=0.9, exploration_rate=0.1):
        self.learning_rate = learning_rate
        self.discount_factor = discount_factor
        self.exploration_rate = exploration_rate
        self.q_table = np.zeros((GRID_SIZE_X, GRID_SIZE_Y, 4))  # Initialize Q-table with zeros

    def choose_action(self, x, y):
        if np.random.uniform(0, 1) < self.exploration_rate:
            return np.random.choice(4)  # Explore randomly
        else:
            return np.argmax(self.q_table[x, y, :])  # Choose the action with the highest Q-value

    def update_q_table(self, state, action, reward, next_state):
        max_next_action = np.argmax(self.q_table[next_state[0], next_state[1], :])
        current_q_value = self.q_table[state[0], state[1], action]
        self.q_table[state[0], state[1], action] += self.learning_rate * (
                reward + self.discount_factor * self.q_table[next_state[0], next_state[1], max_next_action] - current_q_value)

    def train(self, episodes):
        for episode in range(episodes):
            state = (player_position_x // 50, player_position_y // 50)
            done = False
            while not done:
                action = self.choose_action(state[0], state[1])
                if action == 0:  # Up
                    next_state = (state[0], state[1] - 1)
                elif action == 1:  # Down
                    next_state = (state[0], state[1] + 1)
                elif action == 2:  # Left
                    next_state = (state[0] - 1, state[1])
                else:  # Right
                    next_state = (state[0] + 1, state[1])

                if 0 <= next_state[0] < GRID_SIZE_X and 0 <= next_state[1] < GRID_SIZE_Y and next_state not in OBSTACLES:
                    if next_state in DEATH_COORDINATES:
                        reward = -100
                    elif next_state == GOAL_POSITION:
                        reward = 100
                        done = True
                    else:
                        reward = -1
                    self.update_q_table(state, action, reward, next_state)
                    state = next_state
            print(f"Episode {episode + 1} completed.")

    def test(self, player):
        state = (player.x // 50, player.y // 50)
        while state != GOAL_POSITION:
            action = np.argmax(self.q_table[state[0], state[1], :])
            if action == 0:  # Up
                next_state = (state[0], state[1] - 1)
            elif action == 1:  # Down
                next_state = (state[0], state[1] + 1)
            elif action == 2:  # Left
                next_state = (state[0] - 1, state[1])
            else:  # Right
                next_state = (state[0] + 1, state[1])

            if 0 <= next_state[0] < GRID_SIZE_X and 0 <= next_state[1] < GRID_SIZE_Y and next_state not in OBSTACLES:
                state = next_state
                player.move_ip((next_state[0] - state[0]) * 50, (next_state[1] - state[1]) * 50)
                screen.fill((0, 0, 0))
                pygame.draw.rect(screen, "red", player)
                pygame.draw.rect(screen, "orange", (GOAL_POSITION[0] * 50, GOAL_POSITION[1] * 50, 50, 50))
                pygame.draw.rect(screen, "black", (state[0] * 50, state[1] * 50, 50, 50), 2)
                pygame.display.update()
                pygame.time.delay(100)
            else:
                break

run = True
agent = QLearningAgent()
agent.train(episodes=1000)

while run:
    screen.fill((0, 0, 0))
    key = pygame.key.get_pressed()
    if key[pygame.K_a] == True:
        if player.x > 0:
            player.move_ip(-50, 0)
    elif key[pygame.K_d] == True:
        if player.x < GRID_SIZE_X * 50 - player_size_x:
            player.move_ip(50, 0)
    elif key[pygame.K_w] == True:
        if player.y > 0:
            player.move_ip(0, -50)
    elif key[pygame.K_s] == True:
        if player.y < GRID_SIZE_Y * 50 - player_size_y:
            player.move_ip(0, 50)

    pygame.draw.rect(screen, "red", player)
    pygame.draw.rect(screen, "orange", (GOAL_POSITION[0] * 50, GOAL_POSITION[1] * 50, 50, 50))
    agent.test(player)

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            run = False

    pygame.display.update()
pygame.quit()"""

import numpy as np
import pygame

# Define o ambiente do jogo
GRID_SIZE_X = 20
GRID_SIZE_Y = 20
EPISODES=10000

# Inicializa o Pygame
pygame.init()
pygame.display.set_caption("Gridgame")
screen = pygame.display.set_mode((GRID_SIZE_X * 50, GRID_SIZE_Y * 50))

# Jogador
player_position_x = 0
player_position_y = 0
player_size_x = 50
player_size_y = 50
player = pygame.Rect(player_position_x, player_position_y, player_size_x, player_size_y)

# Agente de Q-learning
class QLearningAgent:
    def __init__(self, learning_rate=0.1, discount_factor=0.9, exploration_rate=0.1):
        self.learning_rate = learning_rate
        self.discount_factor = discount_factor
        self.exploration_rate = exploration_rate
        self.q_table = np.zeros((GRID_SIZE_X, GRID_SIZE_Y, 4))  # Inicializa a Q-table com zeros

    def choose_action(self, x, y):
        if np.random.uniform(0, 1) < self.exploration_rate:
            return np.random.choice(4)  # Exploração aleatória
        else:
            return np.argmax(self.q_table[x, y, :])  # Escolhe a ação com maior valor Q

    def update_q_table(self, state, action, reward, next_state):
        max_next_action = np.argmax(self.q_table[next_state[0], next_state[1], :])
        current_q_value = self.q_table[state[0], state[1], action]
        self.q_table[state[0], state[1], action] += self.learning_rate * (
                reward + self.discount_factor * self.q_table[next_state[0], next_state[1], max_next_action] - current_q_value)

    def train(self, episodes):
        for episode in range(episodes):
            state = (player_position_x // 50, player_position_y // 50)
            done = False
            while not done:
                action = self.choose_action(state[0], state[1])
                if action == 0:  # Cima
                    next_state = (state[0], state[1] - 1)
                elif action == 1:  # Baixo
                    next_state = (state[0], state[1] + 1)
                elif action == 2:  # Esquerda
                    next_state = (state[0] - 1, state[1])
                else:  # Direita
                    next_state = (state[0] + 1, state[1])

                # Verifica se o próximo estado é válido
                if 0 <= next_state[0] < GRID_SIZE_X and 0 <= next_state[1] < GRID_SIZE_Y and next_state not in OBSTACLES:
                    if next_state in DEATH_COORDINATES:
                        reward = -100
                    elif next_state == GOAL_POSITION:
                        reward = 100
                        done = True
                    else:
                        reward = -1
                    self.update_q_table(state, action, reward, next_state)
                    state = next_state
            print(f"Episode {episode + 1} completed.")

    def test(self, player):
        state = (player.x // 50, player.y // 50)
        while state != GOAL_POSITION:
            action = np.argmax(self.q_table[state[0], state[1], :])
            if action == 0:  # Cima
                next_state = (state[0], state[1] - 1)
            elif action == 1:  # Baixo
                next_state = (state[0], state[1] + 1)
            elif action == 2:  # Esquerda
                next_state = (state[0] - 1, state[1])
            else:  # Direita
                next_state = (state[0] + 1, state[1])

            # Verifica se o próximo estado é válido
            if 0 <= next_state[0] < GRID_SIZE_X and 0 <= next_state[1] < GRID_SIZE_Y and next_state not in OBSTACLES:
                state = next_state
                player.move_ip((next_state[0] - state[0]) * 50, (next_state[1] - state[1]) * 50)
                screen.fill((0, 0, 0))
                pygame.draw.rect(screen, "red", player)
                pygame.draw.rect(screen, "orange", (GOAL_POSITION[0] * 50, GOAL_POSITION[1] * 50, 50, 50))
                pygame.draw.rect(screen, "black", (state[0] * 50, state[1] * 50, 50, 50), 2)
                pygame.display.update()
                pygame.time.delay(100)
            else:
                break

# Inicializando o agente de Q-learning
agent = QLearningAgent()
agent.train(episodes=1000)

# Loop principal do jogo
run = True
while run:
    screen.fill((0, 0, 0))
    key = pygame.key.get_pressed()
    if key[pygame.K_a] == True:
        if player.x > 0:
            player.move_ip(-50, 0)
    elif key[pygame.K_d] == True:
        if player.x < GRID_SIZE_X * 50 - player_size_x:
            player.move_ip(50, 0)
    elif key[pygame.K_w] == True:
        if player.y > 0:
            player.move_ip(0, -50)
    elif key[pygame.K_s] == True:
        if player.y < GRID_SIZE_Y * 50 - player_size_y:
            player.move_ip(0, 50)

    pygame.draw.rect(screen, "yellow", player)
    pygame.draw.rect(screen, "orange", (GOAL_POSITION[0] * 50, GOAL_POSITION[1] * 50, 50, 50))
    agent.test(player)

    # Desenha os obstáculos no grid
    for obstacle in OBSTACLES:
        pygame.draw.rect(screen, "grey", (obstacle[0] * 50, obstacle[1] * 50, 50, 50))

    # Desenha as coordenadas de morte
    for death_coord in DEATH_COORDINATES:
        pygame.draw.rect(screen, "red", (death_coord[0] * 50, death_coord[1] * 50, 50, 50))

    # Loop de eventos
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            run = False

    pygame.display.update()

pygame.quit()

