/// Multiple precision rational numbers (Q).
module gmp.q;

import gmp.traits;
import gmp.z;

pragma(lib, "gmp");

/** Arbitrary (multi) precision rational number (Q).
    Wrapper for GNU MP (GMP)'s type `mpq_t` and functions `__gmpq_.*`.
 */
struct MpQ
{
    pure nothrow pragma(inline, true):

    /// Convert to `string` in base `base`.
    string toString(uint base = defaultBase,
                    bool upperCaseDigits = false) const @trusted
    {
        assert((base >= -2 && base <= -36) ||
               (base >= 2 && base <= 62));

        assert(false, "TODO");
    }

    // TODO toRCString wrapped in UniqueRange

    /// Returns: A unique hash of the `Mpq` value suitable for use in a hash table.
    size_t toHash() const
    {
        assert(false, "TODO");
    }

    @nogc:

    /// No default construction.
    @disable this();

    /// Construct empty (undefined) from explicit `null`.
    this(typeof(null)) @safe
    {
        initialize();             // TODO is there a faster way?
        // TODO assert(this == MpQ.init); // if this is same as default
    }

    /** Construct from `pValue` / `qValue`. */
    this(P, Q)(P pValue, Q qValue) @trusted
        if (isIntegral!P && isSigned!P &&
            isUnsigned!Q)
    {
        initialize();

        version(ccc) ++_ccc;
        static      if (isUnsigned!P)
            __gmpq_set_ui(_ptr, pValue, qValue);
        else                    // signed integral
            __gmpq_set_si(_ptr, pValue, qValue);
    }

    /** Initialize internal struct. */
    private void initialize() @trusted // cannot be called `init` as that will override builtin type property
    {
        __gmpq_init(_ptr); version(ccc) ++_ccc;
    }

    /// Destruct `this`.
    ~this() @trusted
    {
        if (_ptr)
        {
            __gmpq_clear(_ptr); version(ccc) ++_ccc;
        }
    }

    /// Returns: numerator of `this`.
    @property MpZ numerator() @trusted const
    {
        return MpZ.init;
    }
    alias num = numerator;
    alias P = numerator;

    /// Returns: denominator of `this`.
    @property MpZ denominator() @trusted const
    {
        return MpZ.init;
    }
    alias den = denominator;
    alias Q = denominator;

private:

    /// Default conversion base.
    enum defaultBase = 10;

    /// Returns: pointer to internal GMP C struct.
    inout(__mpq_struct)* _ptr() inout return @system // TODO scope
    {
        return &_z;
    }

    /// Returns: pointer to internal GMP C struct.
    inout(__mpz_struct)* _numptr() inout return @system // TODO scope
    {
        return &_z._mp_num;
    }

    /// Returns: pointer to internal GMP C struct.
    inout(__mpz_struct)* _denptr() inout return @system // TODO scope
    {
        return &_z._mp_den;
    }

    __mpq_struct _z;            // internal libgmp C struct

    // qualified C memory managment
    static @safe
    {
        pragma(mangle, "malloc") void* qualifiedMalloc(size_t size);
        pragma(mangle, "free") void qualifiedFree(void* ptr);
    }

    version(ccc)
    {

        /** Number of calls made to `__gmpq`--functions that construct or changes
            this value. Used to verify correct lowering and evaluation of template
            expressions.

            For instance the `x` in `x = y + z` should be assigned only once inside
            a call to `mpq_add`.
        */
        @property size_t mutatingCallCount() const @safe { return _ccc; }
        size_t _ccc;  // C mutation call count. number of calls to C GMP function calls that mutate this object
    }
}

@safe pure nothrow @nogc:

/// basics
unittest
{
    Q x = null;
    x = Q(11, 13UL);
    // assert(x.numerator == 11);
    // assert(x.denominator == 13);
}

version(unittest)
{
    import dbgio : dln;
    alias Z = MpZ;
    alias Q = MpQ;
    debug import core.stdc.stdio : printf;
    version = ccc;              // do C mutation call count
    static assert(!isMpZExpr!int);
    import std.meta : AliasSeq;
}

// C API
extern(C)
{
    struct __mpq_struct
    {
        __mpz_struct _mp_num;
        __mpz_struct _mp_den;
    }
    static assert(__mpq_struct.sizeof == 32); // fits in four 64-bit words

    alias mpq_srcptr = const(__mpq_struct)*;
    alias mpq_ptr = __mpq_struct*;
    alias mp_bitcnt_t = ulong;

    pure nothrow @nogc:

    void __gmpq_init (mpq_ptr);
    void __gmpq_clear (mpq_ptr);

    void __gmpq_set (mpq_ptr, mpq_srcptr);
    void __gmpq_set_z (mpq_ptr, mpz_srcptr);

    void __gmpq_set_ui (mpq_ptr, ulong, ulong);
    void __gmpq_set_si (mpq_ptr, long, ulong);
}

pragma(lib, "gmp");
