using Test

# A recursive descent parser for a string representation of boolean expressions

mutable struct ExprString
    data::String
    pos::Int
    ExprString(data, pos) = pos != 1 ? error("start must be 1") : new(data, 1)
end

ExprString(s::String) = ExprString(s, 1)

hasMore(e::ExprString) = e.pos <= length(e.data)
isparen(c::Char) = c == '(' || c == ')'
isbinop(c::Char) = c == '&' || c == '|'
isunop(c::Char) = c == '!'
isalphanum(c::Char) = isletter(c) || isnumeric(c)

function skip_when(f, s, start)::Int
    len = length(s)
    if start <= len
        for i in start:len
            if !f(s[i])
                return i
            end
        end
    end
    return len + 1
end

function next_pos(s::String, pos::Int)::Int
    c = s[pos]
    if isparen(c) || isunop(c) || isbinop(c)
        return skip_when(isspace, s, pos + 1)
    elseif isletter(c) #We're inside a variable name, skip alphanumeric
        return skip_when(isalphanum, s, pos + 1)
    else
        throw(ArgumentError("Expected alphanum, parens, \"&\", \"|\", or \"!\", found \"$c\""))
    end
end

function peek(e::ExprString)::String
    c = e.data[e.pos]
    if isparen(c) || isbinop(c)
        return string(c)
    end
    endPos = next_pos(e.data, e.pos)
    strip(e.data[e.pos:endPos-1])
end

function consume(e::ExprString, s::String)
    nextStartPos = next_pos(e.data, e.pos)
    expected = strip(e.data[e.pos:nextStartPos-1])
    if expected == s
        e.pos = nextStartPos
    else
        throw(ArgumentError("Expected $expected, saw $s"))
    end
end

function nextTokenString(e::ExprString)::String
    c = e.data[e.pos]
    if isparen(c) || isbinop(c)
        return c
    end
    endPos = next_pos(e.data, e.pos)
    strip(e.data[pos:endPos-1])
end

function parseExpr(e::ExprString)::BoolExpr
    term = parseTerm(e)
    if hasMore(e)
        tokString = peek(e)
        if tokString == "&"
            consume(e, "&")
            return And([term, parseExpr(e)])
        elseif tokString == "|"
            consume(e, "|")
            return Or([term, parseExpr(e)])
        end
    end
    return term
end

function parseTerm(e::ExprString)::BoolExpr
    tokString = peek(e)
    if tokString == "!"
        consume(e, "!")
        result = parseTerm(w)
        return Not(result)
    elseif tokString == "("
        consume(e, "(")
        result = parseExpr(e)
        consume(e, ")")
        return result
    elseif true # isAlpha(tokString)
        consume(e, tokString)
        return Var(tokString)
    else
        throw(ArgumentError("Syntax error: expected variable name or \"(\", found \"$tokString\")"))
    end
end

Base.show(io::IO, exprString::ExprString) = print(io, "ExprString(data=$e.data, pos=$e.pos)")
Base.show(io::IO, boolExpr::BoolExpr) = BoolExprs.show(io, boolExpr)

# Toy dataset.
# Format: each row is an example.

"""
"""
#######
# Demo:
# Let"s look at some example to understand how Gini Impurity works.
#
# First, we"ll look at a dataset with no mixing.
@testset "" begin
    x1 = Var("x1")
    x2 = Var("x2")
    x3 = Var("x3")
    and_x1_x2 = And([x1, x2])
    and_x2_x3 = And([x2, x3])
    expr1 = And([and_x1_x2, and_x2_x3])
    dnf_expr = dnf(expr1)
    println("dnf((x1&x2) & (x2&x3)) = $dnf_expr")
    expr2 = Or([and_x1_x2, and_x2_x3])
    dnf_expr = dnf(expr2)
    println("dnf((x1&x2) | (x2&x3)) = $dnf_expr")
    or_x1_x2 = Or([x1, x2])
    or_x2_x3 = Or([x2, x3])
    expr3 = And([or_x1_x2, or_x2_x3])
    dnf_expr = dnf(expr3)
    println("dnf((x1|x2) & (x2|x3)) = $dnf_expr")
    cnf_expr = cnf(expr3)
    println("cnf((x1|x2) & (x2|x3)) = $cnf_expr")
    @test true
end
#######

#######
# Demo:
# Calculate the uncertainy of our training data.
@testset "Parser" begin
    expr1 = parseExpr(ExprString("(x1&x2) & (x2&x3)"))
    dnf_expr = dnf(expr1)
    println("dnf((x1&x2) & (x2&x3)) = $dnf_expr")
end

@testset "Big tree" begin
end

@testset "Print tree" begin
end

