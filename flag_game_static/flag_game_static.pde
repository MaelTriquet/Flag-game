import processing.net.*;

int max_row1 = 2;
int max_row2 = 7;
float tile_w;
float tile_h;
float side_w;
PImage flag;
PImage bomb;
PImage _0;
PImage _1;
PImage _2;
PImage _3;
PImage _4;
PImage _5;
PImage _6;
PImage _7;
PImage _8;
PImage _9;
PImage _10;
ArrayList<Piece> team_1 = new ArrayList<Piece>();
ArrayList<Piece> team_2 = new ArrayList<Piece>();
boolean piece_selected = false;
boolean killing1 = false;
boolean killing2 = false;
boolean stealing1 = false;
boolean stealing2 = false;
Piece im_selected = null;
boolean tping = false;
int playing = 2;
boolean changing_turn = true;
int show_rules = -2;
void setup() {
  size(800, 800);
  frameRate(15);
  side_w = width - height;
  tile_w = (width-side_w) / 10;
  tile_h = height / 10;
  flag = loadImage("flag.png");
  bomb = loadImage("bomb.png");
  _0 = loadImage("0.png");
  _1 = loadImage("1.png");
  _2 = loadImage("2.png");
  //_3 = loadImage("3.png");
  //_4 = loadImage("4.png");
  _5 = loadImage("5.png");
  _6 = loadImage("6.png");
  _7 = loadImage("7.png");
  //_8 = loadImage("8.png");
  _9 = loadImage("9.png");
  _10 = loadImage("10.png");
  rand_setup_1();
  rand_setup_2();
}

void draw() {
  if (show_rules >= -1) {
    show_rules();
  } else {
    draw_board();
    for (Piece p : team_1) {
      p.show(playing == 1);
      if (p.selected) {
        im_selected = p;
      }
    }
    for (Piece p : team_2) {
      p.show(playing == 2);
      if (p.selected) {
        im_selected = p;
      }
    }
    if (im_selected != null) {
      im_selected.show(playing == im_selected.team);
    }
    im_selected = null;
    if (killing1 || killing2) {
      fill(255, 0, 0, 80);
      rect(0, 0, width, height);
    }
    if (stealing1 || stealing2) {
      fill(180, 0, 180, 80);
      rect(0, 0, width, height);
    }
    if (tping) {
      fill(0, 255, 0, 80);
      rect(0, 0, width, height);
    }
  }
}
void draw_board() {
  background(0, 255, 0);
  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 10; j++) {
      if (j%2 + i%2 == 1) {
        fill(255);
      } else {
        fill(0);
      }
      rect(i * tile_w + side_w / 2, j * tile_h, tile_w, tile_h);
    }
  }
}

void rand_setup_1() {
  int[] pieces_allowed = new int[13];
  pieces_allowed[0] = 1;
  pieces_allowed[1] = 2;
  pieces_allowed[2] = 5;
  pieces_allowed[3] = 3;
  pieces_allowed[4] = 3;
  pieces_allowed[5] = 2;
  pieces_allowed[6] = 3;
  pieces_allowed[7] = 3;
  pieces_allowed[8] = 2;
  pieces_allowed[9] = 1;
  pieces_allowed[10] = 1;
  pieces_allowed[11] = 3;
  pieces_allowed[12] = 1;

  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 3; j++) {
      int rand = floor(random(13));
      while (pieces_allowed[rand] == 0) {
        rand = floor(random(13));
      }
      team_1.add(new Piece(new PVector(i, j), 1, rand));
      pieces_allowed[rand]--;
    }
  }
}

void rand_setup_2() {
  int[] pieces_allowed = new int[13];
  pieces_allowed[0] = 1;
  pieces_allowed[1] = 2;
  pieces_allowed[2] = 5;
  pieces_allowed[3] = 3;
  pieces_allowed[4] = 3;
  pieces_allowed[5] = 2;
  pieces_allowed[6] = 3;
  pieces_allowed[7] = 3;
  pieces_allowed[8] = 2;
  pieces_allowed[9] = 1;
  pieces_allowed[10] = 1;
  pieces_allowed[11] = 3;
  pieces_allowed[12] = 1;

  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 3; j++) {
      int rand = floor(random(13));
      while (pieces_allowed[rand] == 0) {
        rand = floor(random(13));
      }
      team_2.add(new Piece(new PVector(i, j+7), 2, rand));
      pieces_allowed[rand]--;
    }
  }
}

void mousePressed() {
  if (tping) {
    if (playing == 1) {
      for (Piece p : team_1) {
        if (p.teleporting) {
          p.teleport(floor(mouseX / tile_w), floor(mouseY / tile_h));
        }
      }
    } else {
      for (Piece p : team_2) {
        if (p.teleporting) {
          p.teleport(floor(mouseX / tile_w), floor(mouseY / tile_h));
        }
      }
    }
  }
  if (playing == 1) {
    for (Piece p : team_1) {
      if (floor(mouseX / tile_w) == p.pos.x && floor(mouseY / tile_h) == p.pos.y && !piece_selected) {
        if (stealing1) {
          team_2.add(new Piece(p.pos.copy(), 2, p.value));
          p.isDead = true;
          stealing1 = false;
        } else if (killing1) {
          p.isDead = true;
          killing1 = false;
        } else if (p.value >= 0) {
          p.select();
        }
        return;
      }
    }
  } else {
    for (Piece p : team_2) {
      if (floor(mouseX / tile_w) == p.pos.x && floor(mouseY / tile_h) == p.pos.y && !piece_selected) {
        if (stealing2) {
          team_1.add(new Piece(p.pos.copy(), 1, p.value));
          p.isDead = true;
          stealing2 = false;
        } else if (killing2) {
          p.isDead = true;
          killing2 = false;
        } else if (p.value >= 0) {
          p.select();
        }
        return;
      }
    }
  }
}

void mouseReleased() {
  for (Piece p : team_1) {
    if (p.selected) {
      p.release();
      return ;
    }
  }
  for (Piece p : team_2) {
    if (p.selected) {
      p.release();
      return ;
    }
  }
  update_max_row();
}

void update_max_row() {
  max_row1 = 0;
  for (Piece p : team_1) {
    if (p.pos.y > max_row1) {
      max_row1 = int(p.pos.y);
    }
  }
  max_row2 = 9;
  for (Piece p : team_2) {
    if (p.pos.y < max_row2) {
      max_row2 = int(p.pos.y);
    }
  }
}

void next_turn() {
  for (Piece p : team_1) {
    if (p.value == 3) {
      p.reveal_ennemies(team_2);
    }
  }
  for (Piece p : team_2) {
    if (p.value == 3) {
      p.reveal_ennemies(team_1);
    }
  }
  if (playing == 1) {
    for (Piece p : team_1) {
      p.visible_turn--;
    }
  } else {
    for (Piece p : team_2) {
      if (p.value == 3) {
        p.reveal_ennemies(team_1);
      }
      p.visible_turn--;
    }
  }
  playing = 3 - playing;
  changing_turn = true;
}

void keyPressed() {
  if (keyCode == ENTER) {
    changing_turn = false;
  }
  if (key == 'q') {
    show_rules = -2;
  }
  if (key == 'i') {
    show_rules ++;
    if (show_rules > 12) {
      show_rules = -2;
    }
  }
}

void show_rules() {
  background(0);
  fill(255);
  textSize(30);
  if (show_rules == -1) {
    text("Flag Game", 10, 30);
    text("Votre but est de capturer le drapeau ennemi.", 10, 80);
    text("pour cela, déplacer vos soldats au tour par tour.", 10, 130);
    text("chaque soldat peut se déplacer d'une case", 10, 180);
    text("seulement, sauf exeption.", 10, 210);
    text("lors d'une rencontre avec un ennemi, un combat à lieu.", 10, 280);
    text("le plus gros soldat remporte le combat, sauf exeption.", 10, 330);
    text("le vainqueur est alors dévoilé à l'ennemi pendant", 10, 380);
    text("1 tour.", 10, 410);
  }
  if (show_rules == 0) {
    text("0 : kamikaze", 10, 30);
    text("quand il meurt, il explose et tue tout autour de lui", 10, 80);
    text("allié ou ennemi!", 10, 110);
  }
  if (show_rules == 1) {
    text("1 : le petit pousset", 10, 30);
    text("gagne son combat contre le 10", 10, 80);
  }
  if (show_rules == 2) {
    text("2 : éclaireur", 10, 30);
    text("peut se déplacer comme la tour aux echecs", 10, 80);
  }
  if (show_rules == 3) {
    text("3 : espion", 10, 30);
    text("révèle les identités des ennemis autour de lui", 10, 80);
    text("pendant 1 tour", 10, 110);
  }
  if (show_rules == 4) {
    text("4 : démineur", 10, 30);
    text("gagne son combat contre les bombes et annule le 0", 10, 80);
  }
  if (show_rules == 5) {
    text("5 : avenger", 10, 30);
    text("quand il meurt, choisi un ennemi a assassiner au prochain", 10, 80);
    text("tour", 10, 110);
  }
  if (show_rules == 6) {
    text("6 : secte de l'apocalypse", 10, 30);
    text("S'il ne reste aucun 6 dans l'équipe, choisit un adversaire", 10, 80);
    text("et le contrôle", 10, 110);
  }
  if (show_rules == 7) {
    text("7 : téléporteur", 10, 30);
    text("peut téléporter un allié voisin dans la zone d'occupation", 10, 80);
    text("(pas plus loin que le plus avancé des alliés)", 10, 110);
  }
  if (show_rules == 8) {
    text("8 : théoricien du chaos", 10, 30);
    text("quand il gagne un combat, échange aléatoirement", 10, 80);
    text("les positions de deux ennemis", 10, 110);
  }
  if (show_rules == 9) {
    text("9 : roi", 10, 30);
    text("se déplace comme le roi aux echecs", 10, 80);
  }
  if (show_rules == 10) {
    text("10 : géant", 10, 30);
    text("il est très gros", 10, 80);
  }
  if (show_rules == 11) {
    text("mine", 10, 30);
    text("quand attaqué par un ennemi différent du 4, il explose", 10, 80);
    text("la mine reste. Elle ne peut pas se déplacer", 10, 110);
  }
  if (show_rules == 12) {
    text("drapeau", 10, 30);
    text("capturez le drapeau ennemi pour remporteer la victoire", 10, 80);
    text("Il ne peut pas se déplacer", 10, 110);
  }
}
//0 = kamikaze                        -->  codé
//1 = assassin de 10                  -->  codé
//2 = voyage loin éclaireur           -->  codé
//3 = ???
//4 = demineur                        -->  codé
//5 = chasseur du loup garou          -->  codé
//6 = control mental quand genocidé   -->  codé
//7 = téléporteur                     -->  codé
//8 = swap advers quand win           -->  codé
//9 = diagonales                      -->  codé
//10 = fat                            -->  codé
//11 = bomb                           -->  codé
//12 = flag                           -->  codé
