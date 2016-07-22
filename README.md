NAME
====

Getopt::Std - Process single-character options with option clustering

SYNOPSIS
========

        use Getopt::Std;

        my Str:D %opts;
        usage() unless getopts('ho:V', %opts, @*ARGS);

        version() if %opts<V>;
        usage(True) if %opts<h>;
        exit(0) if %opts{<V h>}:k;

        my $outfile = %opts<o> // 'a.out';

DESCRIPTION
===========

This module exports the `getopts()` function for parsing command-line arguments similarly to the POSIX getopt(3) standard C library routine.

The options are single letters (no long options) preceded by a single dash character. Options that do not accept arguments may be clustered (e.g. `-hV` for `-h` and `-V`); the last one may be an option that accepts an argument (e.g. `-vo outfile.txt`). Options that accept arguments may have their argument "glued" to the option or in the next element of the arguments array, i.e. `-ooutfile` is equivalent to `-o outfile`. There is no equals character between an option and its argument; if one is supplied, it will be considered the first character of the argument.

If an unrecognized option character is supplied in the arguments array, `getopts()` will display an error message and return false. Otherwise it will return true and fill in the `%opts` hash with the options found in the arguments array. The key in the `%opts` array is the option name (e.g. `h` or `o`); the value is the option argument for options that accept one or the option name (as many times as it has been specified) for options that do not.

FUNCTIONS
=========

  * sub getopts

        sub getopts(Str:D $optstr, Str:D %opts, @args)

    Look for the command-line options specified in `$optstr` in the `@args` array. Record the options found into the `%opts` hash, leave only the non-option arguments in the `@args` array.

    Return true on success, false if an invalid option string has been specified or an unknown option has been found in the arguments array.

AUTHOR
======

Peter Pentchev <[roam@ringlet.net](mailto:roam@ringlet.net)>

COPYRIGHT
=========

Copyright (C) 2016 Peter Pentchev

LICENSE
=======

The Getopt::Std module is distributed under the terms of the Artistic License 2.0. For more details, see the full text of the license in the file LICENSE in the source distribution.
