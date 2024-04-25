module MallocArrays

export malloc, free, MallocArray

struct MallocArray{T, N} <: AbstractArray{T, N}
    ptr::Ptr{T}
    size::NTuple{N, Int}
end

"""
    malloc(T::Type, dims::Int...) -> MallocArray{T, N} <: AbstractArray{T, N}

Allocate a new array of type `T` and dimensions `dims` using the C stdlib's `malloc`.

`T` must be an `isbitstype`.

This array is not tracked by Julia's garbage collector, so it is the user's responsibility
to call [`free`](@ref) on it when it is no longer needed.
"""
function malloc(::Type{T}, dims::Int...) where T
    isbitstype(T) || throw(ArgumentError("malloc only supports isbits types"))
    MallocArray(Ptr{T}(Libc.malloc(sizeof(T) * prod(dims))), dims)
end

"""
    free(m::MallocArray)

Free the memory allocated by a MallocArray.

See also [`malloc`](@ref).
"""
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