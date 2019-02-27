abstract type BoolExpr end

struct True <: BoolExpr end
struct False <: BoolExpr end

struct Var <: BoolExpr
    name::String
    function Var(name)
        new(name)
    end
end

struct Not <: BoolExpr
    expr::BoolExpr
    function Not(expr)
        new(expr)
    end
end

struct And <: BoolExpr
    exprs::Array{BoolExpr, 1}
    function And(exprs)
        new(exprs)
    end
end

struct Or <: BoolExpr
    exprs::Array{BoolExpr, 1}
    function Or(exprs)
        new(exprs)
    end
end

const BoolExprVec = Array{BoolExpr, 1}

const t = True()
const f = False()

export BoolExpr, Var, Not, And, Or
export BoolExprVec
export t, f

