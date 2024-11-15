import numpy as np
import matplotlib.pyplot as plt
import pygame
import time
import threading

WIDTH = 910
HEIGHT = 910
# Define the size of the grid
GRID_SIZE_X = 20
GRID_SIZE_Y = 20
EPISODES=100000
DEATH3=
OSTACLES3=

WIN = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("GridGame")

BG = pygame.transform.scale(pygame.image.load("mapa1.png"))

PLAYER_WIDTH = 20
PLAYER_HEIGHT = 20
PLAYER_HM = 35
PLAYER_VM = 37
MAP_BORDER = 150

RED = (255, 0, 0)

CUSTOM_EVENT = pygame.USEREVENT + 1

PLAYER = pygame.Rect(MAP_BORDER, MAP_BORDER + 7, PLAYER_WIDTH, PLAYER_HEIGHT)
OBSTACLES1 = [(2, 2), (2, 3), (2, 4), (2, 13), (2, 15)]
OBSTACLES2 = [(0, 4), (0, 5), (0, 6), (0, 7), (0, 8), (0, 9)]
OBSTACLES3 = [(0, 10), (0, 11), (0, 12), (0, 13)]

DEATH1 = 
DEATH2 =
DEATH3 =

EPISODES= 30000
PRINTS=1000

class MapEnvironment:
    def __init__(self):
        self.grid = np.zeros((GRID_SIZE_X, GRID_SIZE_Y))  # Initialize empty grid
        
        self.death_coordinates = DEATH3  # Define death coordinates
        self.obstacles = OBSTACLES3  # Define obstacles
        
        for coord in self.death_coordinates:
            self.grid[coord] = -2000  # Set death coordinates to -100
        for obstacle in self.obstacles:
            self.grid[obstacle] = -1000  # Set obstacles to -10

    def is_valid_location(self, x, y):
        return 0 <= x < GRID_SIZE_X and 0 <= y < GRID_SIZE_Y and (x, y) not in self.obstacles

    def is_death_location(self, x, y):
        return (x, y) in self.death_coordinates

    def is_obstacle_location(self, x. y):
        return (x, y) in self.obstacles

    def is_goal_location(self, x, y):
        return x == GRID_SIZE_X - 1 and y == GRID_SIZE_Y - 1
    
    def get_reward(self, x, y):
        if self.is_death_location(x, y):
            return -2000
        elif self.is_goal_location(x, y):
            return 5000
        else:
            return -1
    
    def print_grid(self, agent_position):
        for i in range(GRID_SIZE_X):
            for j in range(GRID_SIZE_Y):
                if (i, j) == agent_position:
                    print("A", end=" ")  # Represent agent position
                elif (i, j) in self.death_coordinates:
                    print("X", end=" ")  # Represent death coordinates
                elif (i, j) in self.obstacles:
                    print("O", end=" ")  # Represent obstacles
                elif i == GRID_SIZE_X - 1 and j == GRID_SIZE_Y - 1:
                    print("G", end=" ")  # Represent goal location
                else:
                    print(".", end=" ")  # Represent empty space
            print()
        print()

class QLearningAgent:
    def __init__(self, environment, learning_rate=0.1, discount_factor=0.9, exploration_rate=0.1):
        self.environment = environment
        self.learning_rate = learning_rate
        self.discount_factor = discount_factor
        self.exploration_rate = exploration_rate
        self.q_table = np.zeros((GRID_SIZE_X, GRID_SIZE_Y, 4))  # Initialize Q-table with zeros

    def available_actions(self, x, y, lastaction):
        actions = []
        if x > 0 and lastaction!=1:
            actions.append(0)
        if x < GRID_SIZE_X - 1 and lastaction!=0:
            actions.append(1)
        if y > 0 and lastaction!=3:
            actions.append(2)
        if y < GRID_SIZE_Y - 1:
            actions.append(3) and lastaction!=2
        return actions
    
    def choose_action(self, x, y):
        if np.random.uniform(0, 1) < self.exploration_rate:
            return np.random.choice(4)  # Explore randomly
        else:
            available_actions = self.available_actions(x, y, self.lastaction)
            q_values = [self.q_table[x, y, action] for action in available_actions]
            return available_actions[np.argmax(q_values)]

    

    def update_q_table(self, state, action, reward, next_state):
        max_next_action = np.argmax(self.q_table[next_state[0], next_state[1], :])
        current_q_value = self.q_table[state[0], state[1], action]
        self.q_table[state[0], state[1], action] += self.learning_rate * (
                reward + self.discount_factor * self.q_table[next_state[0], next_state[1], max_next_action] - current_q_value)

    def train(self, episodes):
        episode_n=0
        for episode in range(episodes):
            episode_n +=1
            moves=0
            state = (0, 0)  # Start at the top-left corner
            while not self.environment.is_goal_location(state[0], state[1]):
                moves +=1
                action = self.choose_action(state[0], state[1])
                x, y = state
                if action == 0:  # Up
                    next_state = (x - 1, y)
                elif action == 1:  # Down
                    next_state = (x + 1, y)
                elif action == 2:  # Left
                    next_state = (x, y - 1)
                else:  # Right
                    next_state = (x, y + 1)

                    reward = self.environment.get_reward(next_state[0], next_state[1])
                    
                    self.update_q_table(state, action, reward, next_state)
                    state = next_state
                if episode_n%PRINTS==0:
                    print(episode_n)
                    self.test()

            print(f"Episode {episode + 1}/{episodes} completed {reward}/{moves}")
        self.test()
   

    def test(self):
        print("HERE")
        state = (0, 0)  # Start at the top-left corner
        states_visited = [state]  # Store visited states for plotting
        action=-10
        nsteps=0
        while not self.environment.is_goal_location(state[0], state[1]):
            
            nsteps+=1
            x, y = state
            available_actions = self.available_actions(x, y, action)
            q_values = [self.q_table[x, y, action] for action in available_actions]
            action=available_actions[np.argmax(q_values)]

            if action == 0:  # Up
                next_state = (x - 1, y)
            elif action == 1:  # Down
                next_state = (x + 1, y)
            elif action == 2:  # Left
                next_state = (x, y - 1)
            else:  # Right
                next_state = (x, y + 1)

            if self.environment.is_valid_location(next_state[0], next_state[1]):
                state = next_state
                states_visited.append(state)

        # Create a grid plot
        grid = self.environment.grid.copy()
        for state in states_visited:
            grid[state] = 1

        plt.imshow(grid, cmap='viridis', interpolation='nearest')
        plt.title('Agent\'s Movement on the Grid')
        plt.xlabel('X-axis')
        plt.ylabel('Y-axis')
        plt.colorbar(label='State Value')
        plt.grid(visible=True)
        plt.show()

if __name__ == "__main__":
    environment = MapEnvironment()
    agent = QLearningAgent(environment)
    agent.train(episodes=EPISODES)

    state = (0, 0)  # Start at the top-left corner
    while not environment.is_goal_location(state[0], state[1]):
        agent_position = state
        environment.print_grid(agent_position)
        action = np.argmax(agent.q_table[state[0], state[1], :])
        x, y = state
        if action == 0:  # Up
            next_state = (x - 1, y)
        elif action == 1:  # Down
            next_state = (x + 1, y)
        elif action == 2:  # Left
            next_state = (x, y - 1)
        else:  # Right
            next_state = (x, y + 1)

        if environment.is_valid_location(next_state[0], next_state[1]):
            state = next_state
        else:
            break  # Stop if the agent hits an obstacle or goes out of bounds

def q_learning_training(agent, episodes):
    agent.train(episodes)

def main():
    pygame.init()
    run = True

    pygame.draw(PLAYER)
    clock = pygame.time.Clock()

    environment = MapEnvironment()
    agent = QLearningAgent(environment)

    training_thread = threading.Thread(target=agent.train, args=(EPISODES,))
    training_thread.start()

    start_time = time.time()
    elapsed_time = 0

    while run:
        clock.tick(30) 
        
        for event in pygame.event.get():
            if event.type == pygame.QUIT: 
                run = False
                break

        draw_grid(screen, environment, agent)

        elapsed_time = time.time() - start_time  # Tempo que passou desde o início do jogo
        pygame.display.update()  # Atualiza a tela

    # Espera o treinamento terminar antes de sair
    training_thread.join()  # Espera o treinamento finalizar antes de encerrar o programa

    pygame.quit()