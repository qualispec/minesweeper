require 'debugger'

class Minesweeper
  attr_reader :board

  def initialize(board_size=9, bomb_count=10)
    @board_size = board_size
    @board = create_board(@board_size)
    @bomb_count = bomb_count
  end

  def play
    populate_board

    place_bombs

    until game_won?

      get_move

    end

    puts "Congratulations, you won!!!!!"

    return nil
  end

  def get_move

    until game_won?

      #print_bomb_board
      #puts
      print_board
      puts
      puts "Input a move in the following format (r = reveal, f = flag): F 1 1"
      input = gets.chomp.downcase.split
      command = input[0]
      row = input[1].to_i
      col = input[2].to_i

      square = @board[row][col]

      case command
        when "r"
          if square.bomb
            puts "Sorry, you tried to reveal a bomb!!!!!"
            return
          else
            reveal(square)
          end

        when "f"
          if !square.revealed
            square.place_flag
          end
      end
    end

  end

  def game_won?

    game_won = false

    num_unrevealed_and_bomb = 0
    num_revealed = 0

    @board.each do |row|
      row.each do |square_obj|
        if square_obj.bomb && !square_obj.revealed
          num_unrevealed_and_bomb += 1
        else
          if square_obj.revealed
            num_revealed += 1
          end
        end
      end
    end

    if num_unrevealed_and_bomb == @bomb_count && num_revealed == (@board_size ** 2 - num_unrevealed_and_bomb)
      game_won = true
    end

    game_won
  end

  # This method assumes the square is not a bomb
  def reveal(square)

    # do nothing if it's a bomb or it's flagged
    return if square.bomb
    return if square.flagged

    # If there are adjacent bombs, we just show the number/count
    if square.num_adjacent_bombs != 0
      # Set square's mark to the number of adjacent bombs
      square.mark = square.num_adjacent_bombs.to_s
      square.revealed = true
      return
    end

    # Set the square to 0 or Blank (in user view)
    # square.mark = 0
    square.mark = " "
    square.revealed = true

    # We have to interrogate the square's adjacent neighbors
    square.adjacent_coordinates.each do |square_coord|
      row, col = square_coord
      adj_square = @board[row][col]

      next if adj_square.revealed

      reveal(adj_square)
    end
  end

  def create_board(board_size)
    board = []
    @board_size.times do
      board << Array.new(board_size)
    end
    board
  end

  def populate_board
    @board.each_with_index do |row, row_index|
      row.each_with_index do |square_obj, col_index|
        square_obj = Square.new(@board)
        square_obj.row = row_index
        square_obj.col = col_index
        @board[row_index][col_index] = square_obj
      end
    end
  end

  def print_board
    puts "This is the board:"
    puts
    puts "  0 1 2 3 4 5 6 7 8"

    @board.each_with_index do |row, index|
      print "#{index} "
      row.each do |square|
        print square.mark + " "
      end
      puts
    end
  end

  def print_bomb_board
    puts "This is the bomb board:"
    puts
    puts "  0 1 2 3 4 5 6 7 8"

    @board.each_with_index do |row, index|
      print "#{index} "
      row.each do |square|
        if square.bomb
          print "B "
        elsif
          print square.mark + " "
        end
      end
      puts
    end
  end

  def generate_bomb_coordinates(board_size, bomb_count)
    bomb_coordinates = []
    all_coordinates = []

    board_size.times do |row|
      board_size.times do |col|
        all_coordinates << [row, col]
      end
    end

    shuffled_coordinates = all_coordinates.shuffle
    bomb_count.times { bomb_coordinates << shuffled_coordinates.pop }

    p bomb_coordinates.sort

    bomb_coordinates
  end

  def place_bombs
    bomb_coordinates = generate_bomb_coordinates(@board_size, @bomb_count)

    bomb_coordinates.each do |coordinate|
      row, col = coordinate
      @board[row][col].bomb = true
    end
  end

end


class Square
  attr_accessor :revealed, :bomb, :flagged, :mark, :row, :col, :board

  def initialize(board, mark="*")
    @board = board
    @row = nil
    @col = nil
    @revealed = false
    @flagged = false
    @bomb = false
    @mark = mark
  end

  def place_flag
    @flagged = true
    @mark = "F"
  end

  def num_adjacent_bombs
    num_adjacent_bombs = 0

    adjacent_coordinates.each do |adj_coord|
      adj_row, adj_col = adj_coord
      num_adjacent_bombs += 1 if @board[adj_row][adj_col].bomb
    end

    num_adjacent_bombs
  end

  def adjacent_coordinates
    adjacent_coordinates = []

    (@row-1..@row+1).each do |adj_row|
      (@col-1..@col+1).each do |adj_col|
        unless (adj_row < 0 || adj_col < 0 || adj_row > @board.size-1 || adj_col > @board.size-1 || [adj_row, adj_col] == [@row, @col])
          adjacent_coordinates << [adj_row, adj_col]
        end
      end
    end

    adjacent_coordinates
  end

end

#Scripts-----------------------------------------

game = Minesweeper.new(9,10)
game.play