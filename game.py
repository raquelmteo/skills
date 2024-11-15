import pygame

pygame.init()
pygame.display.set_caption("Gridgame")


screen_width=910
screen_height=910

screen = pygame.display.set_mode((screen_width,screen_height))

#payer 

player_position_x=300
player_position_y=250

player_size_x=50
player_size_y=50

player = pygame.Rect(player_position_x,player_position_y,player_size_x,player_size_y)

run = True
while run:
    screen.fill((0,0,0))

    key = pygame.key.get_pressed()
    if key[pygame.K_a]==True:
        if player.x > 0:
            player.move_ip(-1,0)
    elif key[pygame.K_d]==True:
        if player.x < screen_width-player_size_x:
            player.move_ip(1,0)
    elif key[pygame.K_w]==True:
        if player.y > 0:
            player.move_ip(0,-1)
    elif key[pygame.K_s]==True:
        if player.y < screen_height-player_size_y:
            player.move_ip(0,1)

    


    pygame.draw.rect(screen,"red", player)
    for event in pygame.event.get():
        if event.type== pygame.QUIT:
            run= False


    pygame.display.update()


pygame.quit()