NAME
====

Curry - a [Raku](https://www.raku-lang.ir/en) module for currying functions.

DESCRIPTION
===========

Curry is a [Raku](https://www.raku-lang.ir/en) module for currying functions plus partially applying them.

SYNOPSIS
========

```raku
use Curry:auth<zef:CIAvash> :all;

# Curried subs
sub f ($a, $b) is curry {
    $a × $b;
}
my &pf = f 2;
say pf 3;
=output 6␤

sub f2 ($a, $b, :$c = 1) is curry {
    [×] $a, $b, $c;
}
my &pf2 = f 2, :c(4);
say pf 3;
=output 24␤

sub f3 (*@a) is curry {
    [×] @a;
}
my &pf3 = f 2, 3;
say pf;
=output 6␤
say pf(4)();
=output 24␤

# Curried method and attribute
my class C {
    has &.f is curry is rw;

    method m (Int $a, Int $b) is curry {
        $a × $b;
    }
}
my C $c .= new;
# Method
say $c.m(2, 3)()
=output 6␤
my &pm = $c.m(2, 3);
say pm;
=output 6␤
say pm(4)();
=output 24␤
# Attribute
$c.f = * + *;
say $c.f.(1, 2);
=output 3␤
my &pa = $c.f.(1);
say pa 2;
=output 3␤

# Making Curry
my &f3 = Curry[* + *];
# Or
my &f4 = make_curry * + *;

my &cgrep = Curry[&grep];
# Or better
my &cgrep2 = new_curry &grep;

# Be careful with this
make_curry &grep;
# Or
make_curryable &grep; # This changes function's signature
# Original function (before being curried)
my &lost_grep = &grep.original_function;
```

INSTALLATION
============

You need to have [Raku](https://www.raku-lang.ir/en) and [zef](https://github.com/ugexe/zef), then run:

```console
zef install --/test Curry:auth<zef:CIAvash>
```

or if you have cloned the repo:

```console
zef install .
```

TESTING
=======

```console
prove -ve 'raku -I.' --ext rakutest
```

ROLES
=====

## role Curry [Code:D $function]

Curry role takes a function as parameter and does the `Callable` role

### method CALL-ME

```raku
method CALL-ME(
    |c
) returns Mu
```

Calls the function if all parameters are provided or returns a partially applied function

### method curry

```raku
method curry(
    |c
) returns Curry:D
```

Like `assuming` but returns a Curry. And tries to preserve the parameters of the partial function.

Unfortunately cannot do so for the default value of optional positional parameters.

### method original_function

```raku
method original_function() returns Code:D
```

Returns the original function, the function that was curried

## role Curry::CaptureAll

A role with a signature that captures all arguments

SUBS
====

## multi sub make_curry

```raku
multi sub make_curry(
    Code:D $f
) returns Curry:D is export(:all, :subs)
```

Takes a function, gives a cloned version of it to `Curry`, then adds the role to the function

## multi sub make_curry

```raku
multi sub make_curry(
    *@f where { ... }
) returns Array[Curry:D] is export(:all, :subs)
```

Takes functions, gives a cloned version of each to `Curry`, then adds the role to each function

## multi sub new_curry

```raku
multi sub new_curry(
    Code:D $f
) returns Curry:D is export(:all, :subs)
```

Takes a function, creates a copy of it with role `Curry` mixed in

## multi sub new_curry

```raku
multi sub new_curry(
    *@f where { ... }
) returns Array[Curry:D] is export(:all, :subs)
```

Takes functions, creates a copy of each with role `Curry` mixed in

## multi sub make_curryable

```raku
multi sub make_curryable(
    Code:D $f
) returns Curry:D is export(:all, :subs)
```

Takes a function and returns a curried function that does `Curry::CaptureAll`

## multi sub make_curryable

```raku
multi sub make_curryable(
    *@f where { ... }
) returns Array[Curry:D] is export(:all, :subs)
```

Takes functions and returns an array of curried functions that does `Curry::CaptureAll`

## multi sub trait_mod:<is>

```raku
multi sub trait_mod:<is>(
    Sub:D $sub,
    :$curry!
) returns Mu is export(:all, :traits)
```

`is curry` trait for `Sub`; Makes the function a curried function that does `Curry::CaptureAll`

## multi sub trait_mod:<is>

```raku
multi sub trait_mod:<is>(
    Method:D $method,
    :$curry!
) returns Mu is export(:all, :traits)
```

`is curry` trait for `Method`; Makes the function a curried function that does `Curry::CaptureAll`

## multi sub trait_mod:<is>

```raku
multi sub trait_mod:<is>(
    Attribute:D $attribute,
    :$curry!
) returns Mu is export(:all, :traits)
```

`is curry` trait for `Attribute`; Makes the function a curried function that does `Curry::CaptureAll`.

If you want to be able to set the function from outside of the class, you need to make the attribute writable
with `is rw`. Setting the attribute with `new` doesn't work, only assignment works.

REPOSITORY
==========

[https://github.com/CIAvash/Curry/](https://github.com/CIAvash/Curry/)

BUG
===

[https://github.com/CIAvash/Curry/issues](https://github.com/CIAvash/Curry/issues)

AUTHOR
======

Siavash Askari Nasr - [https://www.ciavash.name](https://www.ciavash.name)

COPYRIGHT
=========

Copyright © 2021 Siavash Askari Nasr

LICENSE
=======

This file is part of Curry.

Curry is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Curry is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with Curry. If not, see <http://www.gnu.org/licenses/>.

