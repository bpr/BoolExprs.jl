function makeConjunction(a::BoolExprVec)::And
    And(children(a))
end

function dnfCaseAnd(exprs::BoolExprVec)::Or
    newChildren = map(dnf, exprs)
    # Each item in newChildren is in DNF form, that is
    # * A variable
    # * A disjunction (Or) of conjunctions (And) of variables
    childDNFs = map(children, newChildren)
    prod = cartesianProduct(childDNFs)
    Or(map(makeConjunction, prod))
end

function dnfCaseOr(exprs::BoolExprVec)::Or
    newChildren = map(dnf, exprs)
    Or(flatMap(children, newChildren))
end

dnfCaseNot(parent::Not, expr::BoolExpr) = parent
dnfCaseNot(parent::Not, expr::And) = dnf(Or(negate(expr.exprs))) # DeMorgan
dnfCaseNot(parent::Not, expr::Or)  = dnf(And(negate(expr.exprs))) # DeMorgan
dnfCaseNot(parent::Not, expr::Not) = dnf(expr.expr) # Double negation
dnfCaseNot(parent::Not, expr::True) = f
dnfCaseNot(parent::Not, expr::False) = t

dnf(expr::Not) = dnfCaseNot(expr, expr.expr)
dnf(expr::And) = dnfCaseAnd(expr.exprs)
dnf(expr::Or) = dnfCaseOr(expr.exprs)
dnf(expr::BoolExpr) = expr
