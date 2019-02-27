function dnf_and(exprs::BoolExprVec)::Or
    dnf_exprs = map(dnf, exprs)
    # Each item in dnf_exprs is in DNF form, that is
    # * A variable
    # * A disjunction (Or) of conjunctions (And) of variables
    childDNFs = map(children, dnf_exprs)
    prod = cartprod(childDNFs)
    Or(map(a -> And(children(a)), prod))
end

function dnf_or(exprs::BoolExprVec)::Or
    dnf_exprs = map(dnf, exprs)
    Or(flatmap(children, dnf_exprs))
end

dnf_not(parent::Not, expr::BoolExpr) = parent
dnf_not(parent::Not, expr::And) = dnf(Or(negate(expr.exprs))) # DeMorgan
dnf_not(parent::Not, expr::Or)  = dnf(And(negate(expr.exprs))) # DeMorgan
dnf_not(parent::Not, expr::Not) = dnf(expr.expr) # Double negation
dnf_not(parent::Not, expr::True) = f
dnf_not(parent::Not, expr::False) = t

dnf(expr::Not) = dnf_not(expr, expr.expr)
dnf(expr::And) = dnf_and(expr.exprs)
dnf(expr::Or) = dnf_or(expr.exprs)
dnf(expr::BoolExpr) = expr
