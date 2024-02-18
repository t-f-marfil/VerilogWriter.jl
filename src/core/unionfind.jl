struct UnionFindTree
    parent::Vector{Int}
    depth::Vector{Int}
end

function Base.broadcastable(x::UnionFindTree)
    return Ref(x)
end

function UnionFindTree(nodes::Int)
    return UnionFindTree(
        [i for i in 1:nodes],
        fill(0, nodes)
    )
end

function getRoot(node::Int, tree::UnionFindTree)
    parent = tree.parent[node]
    if parent == node
        return node
    else
        return getRoot(parent, tree)
    end
end

function ofSameParent(node1::Int, node2::Int, tree::UnionFindTree)
    return getRoot(node1, tree) == getRoot(node2, tree)
end

function uniteTree(node1::Int, node2::Int, tree::UnionFindTree)
    root1, root2 = getRoot.((node1, node2), Ref(tree))
    if root1 != root2
        if tree.depth[root1] < tree.depth[root2]
            tree.parent[root1] = root2
        else
            tree.parent[root2] = root1
            if tree.depth[root1] == tree.depth[root2]
                tree.depth[root1]+=1
            end
        end
    end
    return nothing
end