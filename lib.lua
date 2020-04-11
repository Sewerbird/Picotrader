-- LIBRARY

function append(a,b)
  for e in all(b) do
    add(a,e)
  end
  return a
end

function flatten(array)
  local result = {}
  for e in all(array) do
    local was_array = false
    for z in all(e) do
      was_array = true
      add(result, z)
    end
    if not was_array then add(result, e) end
  end
  return result
end

function dist(x1,y1,x2,y2)
  return (x2-x1)^2+(y2-y1)^2
end

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

function ease_in_out(input, start, max, linger)
  local ramp = (1-linger)/2
  if input < ramp then
    return ease_in(input/ramp, start, max)
  elseif input > (1-ramp) then
    return ease_in((input-(1-ramp))/ramp, max, start)
  else
    return max
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

_memo_wrapped_strings = {}
function wrap_string(string, w)
  if _memo_wrapped_strings[string] then return _wrapped_strings[string] end
  local token = ""
  local tokens = {}
  for i=1,#string do
    local char = sub(string,i,i)
    if char == ' ' then 
      add(tokens, token)
      token = ""
    elseif char ~= ' ' then 
      token = token..char 
    end
  end
  add(tokens, token)
  local result = ""
  local curr_width = 0
  for token in all(tokens) do
    local token_width = #token * 4
    if token_width > w then
      result = result .. "\n" .. token
      curr_width = token_width
    elseif curr_width + token_width > w then
      result = result .. "\n" .. token
      curr_width = token_width
    else
      result = result .. " " .. token
      curr_width += 4+token_width
    end
  end
  return result
end

function print_text_in_rect(text, x1, y1, x2, y2, col)
  local max_w = x2-x1
  local max_c = flr(max_w/4)
  local lines = ceil(#text/max_c)
  print(wrap_string(text, max_w),x1,y1,col)
end

