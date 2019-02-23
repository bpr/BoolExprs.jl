function makeDisjunction(a::BoolExprVec)::Or
    Or(children(a))
end

function cnfCaseAnd(exprs::BoolExprVec)::And
    newChildren = map(cnf, exprs)
    And(flatMap(children, newChildren))
end

function cnfCaseOr(exprs::BoolExprVec)::And
    newChildren = map(cnf, exprs)
    # Each item in newChildren is in CNF form, that is
    # * A variable
    # * A disjunction (Or) of conjunctions (And) of variables
    prod = cartesianProduct(map(children, newChildren))
    And(map(makeDisjunction, prod))
end

cnfCaseNot(parent::Not, expr::BoolExpr) = parent
cnfCaseNot(parent::Not, expr::And) = cnf(Or(negate(expr.exprs))) # DeMorgan
cnfCaseNot(parent::Not, expr::Or)  = cnf(And(negate(expr.exprs))) # DeMorgan
cnfCaseNot(parent::Not, expr::Not) = cnf(expr.expr) # Double negation
cnfCaseNot(parent::Not, expr::True) = f
cnfCaseNot(parent::Not, expr::False) = t

cnf(expr::Not) = cnfCaseNot(expr, expr.expr)
cnf(expr::And) = cnfCaseAnd(expr.exprs)
cnf(expr::Or)  = cnfCaseOr(expr.exprs)
cnf(expr::BoolExpr) = expr
