local l = require("lexer")
local token, word_match = l.token, l.word_match

local P, R, S = lpeg.P, lpeg.R, lpeg.S

local M = {_NAME = "netrw"}

local ws = token(l.WHITESPACE, l.space^1)

local folder = token(l.KEYWORD, l.any^1 * (S("/") + S("\\")) * l.newline)
local file = token(l.IDENTIFIER, l.any^1 * l.newline)

M._rules = {
    {"whitespace", ws},
    {"keyword", folder},
    {"identifier", file}
}

-- M._tokenstyles = {
-- }

return M
