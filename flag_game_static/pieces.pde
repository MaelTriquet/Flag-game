class Piece {
  PVector pos;
  PVector prev_pos;
  int team;
  int value;
  boolean isDead = false;
  boolean selected = false;
  ArrayList<PVector> possible_moves = new ArrayList<PVector>();
  ArrayList<Piece> teleport = new ArrayList<Piece>();
  float size_percent = .94;
  boolean teleporting;
  int visible_turn = 0;
  PImage image;
  Piece(PVector pos_, int team_, int value_) {
    pos = pos_;
    team = team_;
    if (value_ <= 10) {
      value = value_;
    } else {
      value = 10 - value_;
    }
    if (value == -2) {
      image = flag;
    }
    if (value == -1) {
      image = bomb;
    }
    //if (value == 0) {
    //  image = _0;
    //}
    //if (value == 1) {
    //  image = _1;
    //}
    //if (value == 2) {
    //  image = _2;
    //}
    //if (value == 3) {
    //  image = _3;
    //}
    //if (value == 4) {
    //  image = _4;
    //}
    //if (value == 5) {
    //  image = _5;
    //}
    //if (value == 6) {
    //  image = _6;
    //}
    //if (value == 7) {
    //  image = _7;
    //}
    //if (value == 8) {
    //  image = _8;
    //}
    //if (value == 9) {
    //  image = _9;
    //}
    //if (value == 10) {
    //  image = _10;
    //}
    if (image != null) {
      image.resize(floor(size_percent * tile_w * .6), floor(size_percent * tile_h * .6));
    }
  }

  void show(boolean visible) {
    textSize(30);
    if (isDead) {
      pos = new PVector(-1, -1);
    }
    if (selected) {
      pos = new PVector(floor(mouseX / tile_w), floor(mouseY / tile_h));
      fill(0, 255, 0);
      for (PVector move : possible_moves) {
        circle(move.x * tile_w + side_w / 2 + tile_w / 2, move.y * tile_h + tile_h / 2, tile_w * .3);
      }
      size_percent = 1.1;
      textSize(40);
    }
    fill(col(team));
    circle(pos.x * tile_w + side_w / 2 + tile_w / 2, pos.y * tile_h + tile_h / 2, tile_w * size_percent);
    if ((visible || visible_turn > 0) && !changing_turn) {
      if (image != null) {
        image(image, pos.x * tile_w + side_w / 2 + tile_w * .3, pos.y * tile_h + tile_h * .2);
      }
      if (value >= 0) {
        fill(255);
        text(value, pos.x * tile_w + tile_w * 0.4 + side_w / 2, pos.y * tile_h + tile_h * 0.6);
      }
    }
  }

  void fight(Piece other) {
    other.visible_turn = 2;
    visible_turn = 2;
    if (other.value == -1 && value != 4) { // bomb vs 4
      isDead = true;
      activate_power(other);
    } else if (other.value == -1 && value == 4) {
      other.isDead = true;
    } else if (value == 1 && other.value == 10) { // 10 vs 1
      other.isDead = true;
      pos = other.pos.copy();
      prev_pos = pos.copy();
      other.activate_power(other);
    } else if (value == 10 && other.value == 1) {
      isDead = true;
      activate_power(other);
    } else if (other.value == -2) {
      background(col(team));
      noLoop();
    } else if (value < other.value) { // regular rules
      isDead = true;
      if (other.value == 8) {
        rand_swap(team);
      }
      activate_power(other);
    } else if (value > other.value) {
      other.isDead = true;
      rand_swap(3 - team);
      pos = other.pos.copy();
      prev_pos = pos.copy();
      other.activate_power(this);
    } else {
      activate_power(other);
      isDead = true;
      other.isDead = true;
    }
    selected = false;
    piece_selected = false;
  }

  void activate_power(Piece killer) {
    if (value == -2) {
      background(col(2-team));
      noLoop();
    }
    if (value == 0) {
      float eps = .1;
      for (Piece p : team_1) {
        if (abs(dist(p.pos.x, p.pos.y, pos.x, pos.y) - 1) < eps || abs(dist(p.pos.x, p.pos.y, pos.x, pos.y) - dist(1, 1, 0, 0)) < eps) {
          p.isDead = true;
          p.activate_power(this);
        }
      }
      for (Piece p : team_2) {
        if (abs(dist(p.pos.x, p.pos.y, pos.x, pos.y) - 1) < eps || abs(dist(p.pos.x, p.pos.y, pos.x, pos.y) - dist(1, 1, 0, 0)) < eps) {
          p.isDead = true;
          p.activate_power(this);
        }
      }
      killer.isDead = true;
    }
    if (value == 5) {
      if (team == 1) {
        killing2 = true;
      } else {
        killing1 = true;
      }
    }
    if (value == 6) {
      if (team == 1) {
        for (Piece p : team_1) {
          if (p.value == 6 && !p.isDead) {
            return;
          }
        }
        stealing2 = true;
      } else {
        for (Piece p : team_2) {
          if (p.value == 6 && !p.isDead) {
            return;
          }
        }
        stealing1 = true;
      }
    }
  }

  void select() {
    selected = true;
    prev_pos = pos.copy();
    if (team == 1) {
      create_possible_moves(team_1);
    } else {
      create_possible_moves(team_2);
    }
  }

  void create_possible_moves(ArrayList<Piece> team_mates) {
    possible_moves.clear();
    if (value == 2) {
      for (int i = 0; i < 10; i++) {
        possible_moves.add(new PVector(pos.x, i));
        possible_moves.add(new PVector(i, pos.y));
      }
      for (Piece allie : team_mates) {
        for (PVector move : possible_moves) {
          if (move.x == allie.pos.x && move.y == allie.pos.y) {
            vision_remove(move, false);
            break;
          }
        }
      }
      if (team == 1) {
        for (Piece enemie : team_2) {
          for (PVector move : possible_moves) {
            if (move.x == enemie.pos.x && move.y == enemie.pos.y) {
              vision_remove(move, true);
              break;
            }
          }
        }
      } else {
        for (Piece enemy : team_1) {
          for (PVector move : possible_moves) {
            if (move.x == enemy.pos.x && move.y == enemy.pos.y) {
              vision_remove(move, true);
              break;
            }
          }
        }
      }
    } else if (value == 9) {
      possible_moves.add(new PVector(pos.x-1, pos.y-1));
      possible_moves.add(new PVector(pos.x, pos.y-1));
      possible_moves.add(new PVector(pos.x+1, pos.y-1));
      possible_moves.add(new PVector(pos.x-1, pos.y));
      possible_moves.add(new PVector(pos.x+1, pos.y));
      possible_moves.add(new PVector(pos.x-1, pos.y+1));
      possible_moves.add(new PVector(pos.x, pos.y+1));
      possible_moves.add(new PVector(pos.x+1, pos.y+1));

      for (Piece p : team_mates) {
        for (PVector move : possible_moves) {
          if (int(p.pos.x) == int(move.x) && int(p.pos.y) == int(move.y)) {
            possible_moves.remove(move);
            break;
          }
        }
      }
    } else {
      possible_moves.add(new PVector(pos.x, pos.y-1));
      possible_moves.add(new PVector(pos.x-1, pos.y));
      possible_moves.add(new PVector(pos.x+1, pos.y));
      possible_moves.add(new PVector(pos.x, pos.y+1));
      for (Piece p : team_mates) {
        for (PVector move : possible_moves) {
          if (int(p.pos.x) == int(move.x) && int(p.pos.y) == int(move.y)) {
            if (value == 7) {
              teleport.add(p);
            } else {
              possible_moves.remove(move);
            }
            break;
          }
        }
      }
    }
  }

  void vision_remove(PVector move, boolean isEnemy) {
    if (!isEnemy) {
      if (move.x == pos.x) {
        if (move.y < pos.y) {
          for (int i = possible_moves.size() - 1; i > -1; i--) {
            if (possible_moves.get(i).y <= move.y) {
              possible_moves.remove(i);
            }
          }
        }
        if (move.y > pos.y) {
          for (int i = possible_moves.size() - 1; i > -1; i--) {
            if (possible_moves.get(i).y >= move.y) {
              possible_moves.remove(i);
            }
          }
        }
      } else {
        if (move.x < pos.x) {
          for (int i = possible_moves.size() - 1; i > -1; i--) {
            if (possible_moves.get(i).x <= move.x) {
              possible_moves.remove(i);
            }
          }
        }
        if (move.x > pos.x) {
          for (int i = possible_moves.size() - 1; i > -1; i--) {
            if (possible_moves.get(i).x >= move.x) {
              possible_moves.remove(i);
            }
          }
        }
      }
    } else {
      if (move.x == pos.x) {
        if (move.y < pos.y) {
          for (int i = possible_moves.size() - 1; i > -1; i--) {
            if (possible_moves.get(i).y < move.y) {
              possible_moves.remove(i);
            }
          }
        }
        if (move.y > pos.y) {
          for (int i = possible_moves.size() - 1; i > -1; i--) {
            if (possible_moves.get(i).y > move.y) {
              possible_moves.remove(i);
            }
          }
        }
      } else {
        if (move.x < pos.x) {
          for (int i = possible_moves.size() - 1; i > -1; i--) {
            if (possible_moves.get(i).x < move.x) {
              possible_moves.remove(i);
            }
          }
        }
        if (move.x > pos.x) {
          for (int i = possible_moves.size() - 1; i > -1; i--) {
            if (possible_moves.get(i).x > move.x) {
              possible_moves.remove(i);
            }
          }
        }
      }
    }
  }


  void release() {
    for (Piece p : teleport) {
      if (p.pos.x == pos.x && p.pos.y == pos.y) {
        visible_turn = 2;
        p.teleporting = true;
        tping = true;
        pos = prev_pos.copy();
        selected = false;
        piece_selected = false;
        size_percent = .94;
        return;
      }
    }
    for (PVector move : possible_moves) {
      if (move.x == pos.x && move.y == pos.y) {
        next_turn();
        if (team == 1) {
          for (Piece p : team_2) {
            if (p.pos.x == pos.x && p.pos.y == pos.y) {
              fight(p);
              break;
            }
          }
        } else {
          for (Piece p : team_1) {
            if (p.pos.x == pos.x && p.pos.y == pos.y) {
              fight(p);
              break;
            }
          }
        }
        prev_pos = pos.copy();
      }
    }
    pos = prev_pos.copy();
    selected = false;
    piece_selected = false;
    size_percent = .94;
  }

  void teleport(int a, int b) {
    if (team == 1 && b <= max_row1) {
      pos = new PVector(a, b);
      teleporting = false;
      tping = false;
      next_turn();
    }
    if (team == 2 && b >= max_row2) {
      pos = new PVector(a, b);
      teleporting = false;
      tping = false;
      next_turn();
    }
  }

  void reveal_ennemies(ArrayList<Piece> ennemies) {
    float eps = .1;
    for (Piece p : ennemies) {
      if (abs(dist(p.pos.x, p.pos.y, pos.x, pos.y) - 1) < eps || abs(dist(p.pos.x, p.pos.y, pos.x, pos.y) - dist(1, 1, 0, 0)) < eps) {
        p.visible_turn = 2;
      }
    }
  }
}

color col(int team) {
  if (team == 1) {
    return color(255, 0, 0);
  }
  return color(100, 100, 255);
}

void rand_swap (int team) {
  if (team == 1) {
    int a = floor(random(team_1.size()));
    int b = floor(random(team_1.size()));
    while (team_1.get(a).isDead) {
      a = floor(random(team_1.size()));
    }
    while (team_1.get(b).isDead) {
      b = floor(random(team_1.size()));
    }
  } else {
    int a = floor(random(team_2.size()));
    int b = floor(random(team_2.size()));
    while (team_2.get(a).isDead) {
      a = floor(random(team_2.size()));
    }
    while (team_1.get(b).isDead) {
      b = floor(random(team_2.size()));
    }
  }
}
