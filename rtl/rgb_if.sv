interface rgb_if();
    logic [11:0] rgb_start;
    logic [11:0] rgb_game;
    logic [11:0] rgb_gameover;
    logic valid_start;
    logic valid_game;
    logic valid_gameover;

modport in (input rgb_start, rgb_game, rgb_gameover, valid_start, valid_game, valid_gameover);
modport out (output rgb_start, rgb_game, rgb_gameover, valid_start, valid_game, valid_gameover );
endinterface