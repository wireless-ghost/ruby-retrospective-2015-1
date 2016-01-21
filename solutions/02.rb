def move(snake, direction)
  new_snake = snake.dup
  new_snake.shift
  new_snake.push(calculate_new_element(new_snake.last, direction))
end

def calculate_new_element(old_position, direction)
  [old_position.first + direction.first, old_position.last + direction.last]
end

def grow(snake, direction)
  new_snake = snake.dup
  new_snake.push(calculate_new_element(new_snake.last, direction))
end

def snake_head_in_bounds?(snake_head, dimension)
  in_x_bounds = snake_head.first >= 0 && snake_head.first <= dimension[:width]
  in_y_bounds = snake_head.last >= 0 && snake_head.last <= dimension[:height]
  in_x_bounds && in_y_bounds
end

def danger?(snake, direction, dimension)
  new_snake = move(snake, direction)
  first_move_in_bounds = snake_head_in_bounds?(new_snake.last, dimension)
  new_snake = move(new_snake, direction)
  second_move_in_bounds = snake_head_in_bounds?(new_snake.last, dimension)
  !first_move_in_bounds || !second_move_in_bounds
end

def obstacle_ahead?(snake, direction, dimension)
  new_snake = snake.dup
  new_element = calculate_new_element(new_snake.last, direction)
  is_snake_element = new_snake.include?(new_element)
  !is_snake_element && snake_head_in_bounds?(new_element, dimension)
end

def random_in_bounds(width, height)
  [Random.new.rand(width), Random.new.rand(height)]
end

def new_food(food, snake, dimension)
  new_food = random_in_bounds(dimension[:width], dimension[:height])
  while(food.include?(new_food) || snake.include?(new_food)) do
   new_food = random_in_bounds(dimension[:width], dimension[:height])
  end
  new_food
end
