module MallocArrays

export malloc, free, MallocArray

struct MallocArray{T, N} <: AbstractArray{T, N}
    ptr::Ptr{T}
    size::NTuple{N, Int}
end

function malloc(::Type{T}, dims::Int...) where T
    isbitstype(T) || throw(ArgumentError("malloc: T must be a bitstype"))
    MallocArray(Ptr{T}(Libc.malloc(sizeof(T) * prod(dims))), dims)
end

function free(m::MallocArray)
    Libc.free(m.ptr)
end

Base.size(m::MallocArray) = m.size
Base.IndexStyle(::Type{<:MallocArray}) = IndexLinear()
Base.@propagate_inbounds function Base.getindex(m::MallocArray, i::Int)
    @boundscheck checkbounds(m, i)
    unsafe_load(m.ptr, i)
end
Base.@propagate_inbounds function Base.setindex!(m::MallocArray, v, i::Int)
    @boundscheck checkbounds(m, i)
    unsafe_store!(m.ptr, v, i)
    m
end

end