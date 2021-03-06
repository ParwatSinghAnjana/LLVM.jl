## reader

import Base: parse

function parse(::Type{Module}, ir::String, ctx::Context=GlobalContext())
    data = convert(Vector{UInt8}, ir)
    membuf = MemoryBuffer(data, "", false)

    out_ref = Ref{API.LLVMModuleRef}()
    out_error = Ref{Cstring}()
    status = BoolFromLLVM(API.LLVMParseIRInContext(ref(ctx), ref(membuf), out_ref, out_error))

    if status
        error = unsafe_string(out_error[])
        API.LLVMDisposeMessage(out_error[])
        throw(LLVMException(error))
    end

    Module(out_ref[])
end


## writer

import Base: convert

convert(::Type{String}, mod::Module) = unsafe_string(API.LLVMPrintModuleToString(ref(mod)))