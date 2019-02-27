function equiv(exprs1::BoolExprVec, exprs2::BoolExprVec)::Bool
    if length(exprs1) == length(exprs2)
        for (e1, e2) in zip(exprs1, exprs2)
            if !equiv(e1, e2)
                return false
            end
        end
        true
    else
        false
    end
end

equiv(x::True, y::True) = true
equiv(x::False, y::False) = true
equiv(x::Var, y::Var) = x.name == y.name
equiv(x::And, y::And) = equiv(x.exprs, y.exprs)
equiv(x::Or, y::Or)   = equiv(x.exprs, y.exprs)
equiv(x::Not, y::Not)   = equiv(x.expr, y.expr)
equiv(x::BoolExpr, y::BoolExpr) = false

export equiv
