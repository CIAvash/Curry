use v6.d;

#| A package for trying to preserve parameters of partially applied functions
unit package Curry::PreserveParams:auth($?DISTRIBUTION.meta<auth>);

#| A role that has a C<params> method that uses the parameters of a function and its C<Capture> to create a new
#| list of parameters for a partially applied function.
#| It removes the named parameters which exist in the C<Capture>.
#| It keeps the parameters which have default values or are required.
role InSignature [Signature:D $partial_signature, Signature:D $signature, Capture $capture] {
    method params {
        $partial_signature.params.map: -> $param {
            # Skip parameter if it is a named parameter which exists in the capture
            next if $param.named && $param.named_names.any eq $capture.hash.keys.any;

            # Keep parameters with default value and required parameters
            if $param.optional || $param.named {
                $signature.params.first: {
                    .positional || .name eq $param.named_names.any and .default || .suffix eq '!'
                } orelse $param;
            }
            else {
                $param;
            }
        } andthen .List;
    }
}

#| A role that has a C<signature> method which adds the C<Curry::InSignature> role to the signature of
#| partially applied function. Trying to preserve needed parameters.
role InSub [|c (Signature:D $partial_signature, Signature:D $signature, Capture $capture)] {
    method signature {
        $partial_signature but InSignature[|c];
    }
}

=COPYRIGHT Copyright © 2021 Siavash Askari Nasr

=begin LICENSE
This file is part of Curry.

Curry is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Curry is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Curry.  If not, see <http://www.gnu.org/licenses/>.
=end LICENSE
