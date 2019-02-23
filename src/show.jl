"""
    show

"""
toString(e::True)::String = "T"
toString(e::False)::String = "F"
toString(e::Var)::String = "Var($(e.name))"
toString(e::Not)::String = "Not($(toString(e)))"

function toString(e::And)::String
    innerString = join(map(e -> toString(e), e.exprs), ", ")
    "And($innerString)"
end

function toString(e::Or)::String
    innerString = join(map(e -> toString(e), e.exprs), ", ")
    "Or($innerString)"
end

show(io::IO, e::BoolExpr) = print(io, toString(e))
