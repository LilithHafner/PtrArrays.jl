module MallocArrays

export malloc, free, MallocArray

struct MallocArray{T, N} <: AbstractArray{T, N}
    ptr::Ptr{T}
    size::NTuple{N, Int}
end

# Because Core.checked_dims is buggy 😢
checked_dims(elsize::Int) = elsize
function checked_dims(elsize::Int, d0::Int, d::Int...)
    overflow = false
    neg = (d0+1) < 1
    zero = false # of d0==0 we won't have overflow since we go left to right
    len = d0
    for di in d
        len, o = Base.mul_with_overflow(len, di)
        zero |= di === 0
        overflow |= o
        neg |= (di+1) < 1
    end
    len, o = Base.mul_with_overflow(len, elsize)
    err = o | neg | overflow & !zero
    err && throw(ArgumentError("invalid malloc dimensions"))
    len
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
    ptr = Libc.malloc(checked_dims(sizeof(T), dims...))
    ptr === C_NULL && throw(OutOfMemoryError())
    MallocArray(Ptr{T}(ptr), dims)
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