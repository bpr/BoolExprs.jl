using Test

# A recursive descent parser for a string representation of boolean expressions

mutable struct ExprString
    data::String
    pos::Int
    ExprString(data, pos) = pos != 1 ? error("start must be 1") : new(data, 1)
end

ExprString(s::String) = ExprString(s, 1)

hasmore(e::ExprString) = e.pos <= length(e.data)
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

function parse_expr(e::ExprString)::BoolExpr
    term = parse_term(e)
    if hasmore(e)
        tok_string = peek(e)
        if tok_string == "&"
            consume(e, "&")
            return And([term, parse_expr(e)])
        elseif tok_string == "|"
            consume(e, "|")
            return Or([term, parse_expr(e)])
        end
    end
    return term
end

function parse_term(e::ExprString)::BoolExpr
    tok_string = peek(e)
    if tok_string == "!"
        consume(e, "!")
        result = parse_term(e)
        return Not(result)
    elseif tok_string == "("
        consume(e, "(")
        result = parse_expr(e)
        consume(e, ")")
        return result
    elseif true # isAlpha(tok_string)
        consume(e, tok_string)
        return Var(tok_string)
    else
        throw(ArgumentError("Syntax error: expected variable name or \"(\", found \"$tok_string\")"))
    end
end

Base.show(io::IO, exprString::ExprString) = print(io, "ExprString(data=$e.data, pos=$e.pos)")
Base.show(io::IO, boolExpr::BoolExpr) = BoolExprs.show(io, boolExpr)
mkexpr(s) = parse_expr(ExprString(s))


"""
"""
#######

Base.:(==)(x::BoolExpr, y::BoolExpr)::Bool = equiv(x, y)

@testset "Make expressions from strings" begin
    x1 = mkexpr("x1")
    @test x1 == Var("x1")
    x2 = mkexpr("x2")
    @test x2 == Var("x2")
    x3 = mkexpr("x3")
    @test x3 == Var("x3")

    not_x3 = mkexpr("!x3")
    @test not_x3 == Not(Var("x3"))

    and_x1_x2 = mkexpr("x1&x2")
    @test and_x1_x2 == And([x1, x2])

    and_x2_x3 = And([x2, x3])
    @test and_x2_x3 == And([x2, x3])

    or_x1_x2 = mkexpr("x1|x2")
    @test or_x1_x2 == Or([x1, x2])

    or_x2_x3 = mkexpr("x2|x3")
    @test or_x2_x3 == Or([x2, x3])
end
#######

@testset "DNF" begin
    s = "(x1&x2) & (x2&x3)"
    dnf_expr = dnf(mkexpr(s))
    @test dnf_expr == Or([And([Var("x1"), Var("x2"), Var("x2"), Var("x3")])])
    println("dnf($s) = $dnf_expr")
    s = "(x1&x2) | (x2&x3)"
    dnf_expr = dnf(mkexpr(s))
    @test dnf_expr == Or([And([Var("x1"), Var("x2")]), And([Var("x2"), Var("x3")])])
    println("dnf($s) = $dnf_expr")
    s = "(x1|x2) & (x2|x3)"
    dnf_expr = dnf(mkexpr(s))
    @test dnf_expr == Or([And([Var("x1"), Var("x2")]), And([Var("x1"), Var("x3")]), And([Var("x2"), Var("x2")]), And([Var("x2"), Var("x3")])])
    println("dnf($s) = $dnf_expr")
end

@testset "CNF" begin
    s = "(x1&x2) & (x2&x3)"
    cnf_expr = cnf(mkexpr(s))
    @test cnf_expr == And([Var("x1"), Var("x2"), Var("x2"), Var("x3")])
    println("cnf($s) = $cnf_expr")
    s = "(x1&x2) | (x2&x3)"
    cnf_expr = cnf(mkexpr(s))
    @test cnf_expr == And([Or([Var("x1"), Var("x2")]), Or([Var("x1"), Var("x3")]), Or([Var("x2"), Var("x2")]), Or([Var("x2"), Var("x3")])])
    println("cnf($s) = $cnf_expr")
    s = "(x1|x2) & (x2|x3)"
    cnf_expr = cnf(mkexpr(s))
     @test cnf_expr == And([Or([Var("x1"), Var("x2")]), Or([Var("x2"), Var("x3")])])
   println("cnf($s) = $cnf_expr")
end

