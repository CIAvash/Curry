use v6.d;

use Curry::PreserveParams:auth<zef:CIAvash>;

=NAME Curry - a L<Raku|https://www.raku-lang.ir/en> module for currying functions.

=DESCRIPTION Curry is a L<Raku|https://www.raku-lang.ir/en> module for currying functions plus partially applying them.

=begin SYNOPSIS

=begin code :lang<raku>

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

=end code

=end SYNOPSIS

=begin INSTALLATION

You need to have L<Raku|https://www.raku-lang.ir/en> and L<zef|https://github.com/ugexe/zef>,
then run:

=begin code :lang<console>

zef install --/test Curry:auth<zef:CIAvash>

=end code

or if you have cloned the repo:

=begin code :lang<console>

zef install .

=end code

=end INSTALLATION

=begin TESTING

=begin code :lang<console>

prove -ve 'raku -I.' --ext rakutest

=end code

=end TESTING

=ROLES

#| Curry role takes a function as parameter and does the C<Callable> role
role Curry:auth($?DISTRIBUTION.meta<auth>):ver($?DISTRIBUTION.meta<version>) [Code:D $function] does Callable {
    #| Calls the function if all parameters are provided or returns a partially applied function
    method CALL-ME (|c) {
        my Int:D $named_params = +$function.signature.params.grep: *.named;

        if $function.arity == c == 0 or $function.count + $named_params == c + c.hash {
            $function(|c);
        } else {
            self.curry: |c;
        }
    }

    #| Like C<assuming> but returns a Curry. And tries to preserve the parameters of the partial function.
    method curry (|c --> Curry:D) {
        my &partial_function = $function.assuming: |c;
        &partial_function does Curry::PreserveParams::InSub[
            &partial_function.signature,
            $function.signature,
            c
        ];

        make_curry &partial_function;

        # Deal with positional and named parameters that have default value
        &partial_function.wrap: sub (|c) {
            if c + c.hash == 0 {
                $function.signature.params.grep(*.default) ∩ &partial_function.signature.params
                ==> keys()
                ==> map({
                    my $defaul_value = .default.();
                    .positional ?? $defaul_value !! (.usage-name => $defaul_value);
                })
                ==> classify({
                    when Pair:D { 'named' }
                    default     { 'positional' }
                })
                ==> my %args_with_default_value is default(Empty);

                if %args_with_default_value -> $_ {
                    callwith |.<positional>, |.<named>.Map;
                } else {
                    callsame;
                }
            } else {
                callsame;
            }
        }

        &partial_function;
    }

    #| Returns the original function, the function that was curried
    method original_function returns Code:D {
        $function;
    }
}

#| A role with a signature that captures all arguments
role Curry::CaptureAll {
    method signature {
        :(|);
    }
}

=SUBS

proto make_curry (|) is export(:all, :subs) {*}

#| Takes a function, gives a cloned version of it to C<Curry>, then adds the role to the function
multi make_curry (Code:D $f --> Curry:D) {
    $f does Curry[$f.clone];
}

#| Takes functions, gives a cloned version of each to C<Curry>, then adds the role to the function
multi make_curry (*@f where .all ~~ Code:D --> Array[Curry:D]) {
    Array[Curry:D].new: |@f.map: { samewith $_ };
}

proto new_curry (|) is export(:all, :subs) {*}

#| Takes a function, creates a copy of it with role C<Curry> mixed in
multi new_curry (Code:D $f --> Curry:D) {
    $f but Curry[$f];
}

#| Takes functions, creates a copy of each with role C<Curry> mixed in
multi new_curry (*@f where .all ~~ Code:D --> Array[Curry:D]) {
    Array[Curry:D].new: |@f.map: { samewith $_ };
}

proto make_curryable (|) is export(:all, :subs) {*}

#| Takes a function and returns a curried function that does C<Curry::CaptureAll>
multi make_curryable (Code:D $f --> Curry:D) {
    make_curry $f;
    $f does Curry::CaptureAll;
}

#| Takes functions and returns an array of curried functions that do C<Curry::CaptureAll>
multi make_curryable (*@f where .all ~~ Code:D --> Array[Curry:D]) {
    Array[Curry:D].new: |@f.map: { samewith $_ };
}

#| C<is curry> trait for C<Sub>; Makes the function a curried function that does C<Curry::CaptureAll>
multi trait_mod:<is>(Sub:D $sub, :$curry!) is export(:all, :traits) {
    make_curryable $sub;
}

#| C<is curry> trait for C<Method>; Makes the function a curried function that does C<Curry::CaptureAll>
multi trait_mod:<is>(Method:D $method, :$curry!) is export(:all, :traits) {
    make_curryable $method;
}

#| C<is curry> trait for C<Attribute>; Makes the function a curried function that does C<Curry::CaptureAll>.
#| If you want to be able to set the function from outside of the class, you need to make the attribute writable
#| with C<is rw>. Setting the attribute with C<new> doesn't work, only assignment works.
multi trait_mod:<is>(Attribute:D $attribute, :$curry!) is export(:all, :traits) {
    $attribute.set_build: -> \SELF, | {
        my $value = $attribute.get_value: SELF;

        $attribute.set_value: SELF, Proxy.new: FETCH =>          { $value },
                                               STORE => -> $, $f { $value = make_curryable $f }
    }
}

=REPOSITORY L<https://github.com/CIAvash/Curry/>

=BUG L<https://github.com/CIAvash/Curry/issues>

=AUTHOR Siavash Askari Nasr - L<https://www.ciavash.name>

=COPYRIGHT Copyright © 2021 Siavash Askari Nasr

=begin LICENSE
This file is part of Curry.

Curry is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at yoption) any later version.

Curry is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Curry.  If not, see <http://www.gnu.org/licenses/>.
=end LICENSE
