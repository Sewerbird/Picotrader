-- LIBRARY

function times(func,cnt,with)
  local result = {}
  with = with or {}
  for i = 1,cnt do
    add(result, func(i,with))
  end
  return result
end

function each(array, func)
  for v in all(array) do
    func(v)
  end
end

function map(a,func)
  local result = {}
  for v in all(a) do
    add(result, func(v))
  end
  return result
end

function mapo(a,func)
  local result = {}
  for v in all(a) do
    key, value = func(v)
    result[v] = value
  end
  return result
end

function clamp(a,low,high)
  return low > a and low or (high < a and high or a)
end

function wrap(a,low,high)
  return low > a and high or (high < a and low or a)
end

function lerp(input,start,finish)
  range = finish - start
  return start + input*range
end

function ease_in(input,start,finish)
  range = finish - start
  return start + (input*input)*range
end

function ease_in_out(input, start, max)
  if input < 0.5 then
    return ease_in(input*2, start, max)
  else
    return ease_in((input-0.5)*2, max, start)
  end
end

function mod(a,b)
  local q = flr(a/b)
  return a - (q*b)
end

function rndi(z)
  return flr(rnd() * z)
end

function print_centered_text_on_point(text, c_x, c_y, col)
  local w = #text * 4
  print(text, c_x - w/2, c_y - 2, col)
end

function print_centered_text_in_rect(text, x1, y1, x2, y2, col)
  local w = #text * 4
  local c_x = (x2-x1)/2 + x1
  local c_y = (y2-y1)/2 + y1 - 2
  --rect(x1,y1,x2,y2,7) --Debug rect
  print(text, c_x - w/2, c_y, col)
end

