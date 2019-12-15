-- takes x, y, w, h returns x, y, hw, hh
function fizzRect(x, y, w, h)
    return x + w/2, y + h/2, w/2, h/2
end