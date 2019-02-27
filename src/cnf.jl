function cnf_and(exprs::BoolExprVec)::And
    cnf_exprs = map(cnf, exprs)
    And(flatmap(children, cnf_exprs))
end

function cnf_or(exprs::BoolExprVec)::And
    cnf_exprs = map(cnf, exprs)
    # Each item in cnf_exprs is in CNF form, that is
    # * A variable
    # * A conjunction (And) of disjunctions (Or) of variables
    prod = cartprod(map(children, cnf_exprs))
    And(map(a -> Or(children(a)), prod))
end

cnf_not(parent::Not, expr::BoolExpr) = parent
cnf_not(parent::Not, expr::And) = cnf(Or(negate(expr.exprs))) # DeMorgan
cnf_not(parent::Not, expr::Or)  = cnf(And(negate(expr.exprs))) # DeMorgan
cnf_not(parent::Not, expr::Not) = cnf(expr.expr) # Double negation
cnf_not(parent::Not, expr::True) = f
cnf_not(parent::Not, expr::False) = t

cnf(expr::Not) = cnf_not(expr, expr.expr)
cnf(expr::And) = cnf_and(expr.exprs)
cnf(expr::Or)  = cnf_or(expr.exprs)
cnf(expr::BoolExpr) = expr
