NAME
====

Getopt::Std - Process single-character options with option clustering

SYNOPSIS
========

        use Getopt::Std;

        # Classical usage, slightly extended:
        # - for options that take an argument, return only the last one
        # - for options that don't, return a string containing the option
        #   name as many times as the option was specified

        my Str:D %opts;
        usage() unless getopts('ho:V', %opts, @*ARGS);

        version() if %opts<V>;
        usage(True) if %opts<h>;
        exit(0) if %opts{<V h>}:k;

        my $outfile = %opts<o> // 'a.out';

        # "All options" usage:
        # - for options that take an argument, return an array of all
        #   the arguments supplied if specified more than once
        # - for options that don't, return the option name as many times
        #   as it was specified

        my Array[Str:D] %opts;
        usage() unless getopts('o:v', %opts, @*ARGS, :all);

        $verbose_level = %opts<v>.elems;

        for %opts<o> -> $fname {
            process_outfile $fname;
        }

DESCRIPTION
===========

This module exports the `getopts()` function for parsing command-line arguments similarly to the POSIX getopt(3) standard C library routine.

The options are single letters (no long options) preceded by a single dash character. Options that do not accept arguments may be clustered (e.g. `-hV` for `-h` and `-V`); the last one may be an option that accepts an argument (e.g. `-vo outfile.txt`). Options that accept arguments may have their argument "glued" to the option or in the next element of the arguments array, i.e. `-ooutfile` is equivalent to `-o outfile`. There is no equals character between an option and its argument; if one is supplied, it will be considered the first character of the argument.

If an unrecognized option character is supplied in the arguments array, `getopts()` will display an error message and return false. Otherwise it will return true and fill in the `%opts` hash with the options found in the arguments array. The key in the `%opts` array is the option name (e.g. `h` or `o`); the value is the option argument for options that accept one or the option name (as many times as it has been specified) for options that do not.

FUNCTIONS
=========

  * sub getopts

        sub getopts(Str:D $optstr, Str:D %opts, @args, Bool :$all) returns Bool:D

    Look for the command-line options specified in `$optstr` in the `@args` array. Record the options found into the `%opts` hash, leave only the non-option arguments in the `@args` array.

    The `:all` flag controls the behavior in the case of the same option specified more than once. Without it, options that take arguments have only the last argument recorded in the `%opts` hash; with the `:all` flag, all `%opts` values are arrays containing all the specified arguments. For example, the command line <var>-vI foo -I bar -v</var>, matched against an option string of <var>I:v</var>, would produce `{ :I<bar> :v<vv> }` without `:all` and `{ :I(['foo', 'bar']) :v(['v', 'v']) }` with `:all`.

    Return true on success, false if an invalid option string has been specified or an unknown option has been found in the arguments array.

  * sub getopts-collapse-array

        sub getopts-collapse-array(Bool:D %defs, %opts)

    This function is only available with a `:util` import.

    Collapse a hash of option arrays as returned by `getopts(:all)` into  a hash of option strings as returned by `getopts(:!all)`. Replace the value of non-argument-taking options with a string containing the option name as many times as it was specified, and the value of argument-taking options with the last value supplied on the command line. Intended for `getopts()` internal use and testing.

  * sub getopts-parse-optstring

        sub getopts-parse-optstring(Str:D $optstr) returns Hash[Bool:D]

    This function is only available with a `:util` import.

    Parse a `getopts()` option string and return a hash with the options as keys and whether the respective option expects an argument as values. Intended for `getopts()` internal use and testing.

AUTHOR
======

Peter Pentchev <[roam@ringlet.net](mailto:roam@ringlet.net)>

COPYRIGHT
=========

Copyright (C) 2016 Peter Pentchev

LICENSE
=======

The Getopt::Std module is distributed under the terms of the Artistic License 2.0. For more details, see the full text of the license in the file LICENSE in the source distribution.
