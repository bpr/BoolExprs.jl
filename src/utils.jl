# Cartesian product. See https://en.wikipedia.org/wiki/Cartesian_product

# next_tuple is a helper function which extracts all combinations of arrays by
# using the length of each array Yn and counting up from 0 at each index. For
# example, if we had an array X of lengths [2, 3, 3] next_tuple will adjust indices
# as follows: [0, 0, 0] -> [1, 0, 0] -> [0, 1, 0] -> [1, 1, 0] -> [0, 2, 0] ... [1, 2, 2]

function next_tuple!(indices::Array{Int,1}, sizes::Array{Int,1})::Bool
    for i in length(indices):-1:1
        if indices[i] < sizes[i]
            indices[i] += 1
            return true
        else
            indices[i] = 1
        end
    end
    false
end

# N fold Cartesian product
function cartprod(aa::Array{Array{T, 1}, 1})::Array{Array{T, 1}, 1} where {T}
    result::Array{Array{T, 1}, 1} = []
    indices = ones(Int, length(aa))
    sizes = map(a -> length(a), aa)
    hasMore = length(indices) > 0     
    while hasMore
        elt = [aa[i][indices[i]] for i in 1:length(indices)]
        push!(result, elt)
        hasMore = next_tuple!(indices, sizes)
    end

  return result
end

function flatmap(f, a)
    result = []
    for elt in a
        push!(result, f(elt)...)
    end
    result
end

isVar(::Var) = true
isVar(::BoolExpr) = false
isAnd(::And) = true
isAnd(::BoolExpr) = false

children(e::Var)::BoolExprVec = [e]
children(e::Not)::BoolExprVec = [e.expr]
children(e::And)::BoolExprVec = e.exprs
children(e::Or)::BoolExprVec = e.exprs

function children(v::BoolExprVec)
    result = []
    for e in v
        for o in children(e)
            push!(result, o)
        end
    end
    result
end

negate(exprs::BoolExprVec) = map(e -> Not(e), exprs)
