#!/usr/bin/env perl6

use v6.c;

unit module Getopt::Std;

sub getopts(Str:D $optstr, Str:D %opts, @args) returns Bool:D is export
{
	if $optstr eq '' {
		note 'No options defined';
		return False;
	}

	# TODO: weird stuff like ':', '-', or '+' at the start of the string
	# TODO: use a grammar to parse this one at least
	my Bool:D %defs;
	my Str:D $ostr = $optstr;
	while $ostr ~~ /^
	    $<opt> = [ <[a..zA..Z0..9?]> ]
	    $<arg> = [ ':' ? ]
	    $<rest> = [ .* ]
	    $/ {
		die "Duplicate option '-$<opt>' defined" if %defs{$<opt>}:k;
		%defs{$<opt>} = $<arg> eq ':';
		$ostr = ~$<rest>;
	}

	my Str:D @restore;
	my Bool:D $result = True;
	%opts = ();
	try {
		while @args {
			my $x = @args.shift;
			if $x eq '--' {
				last;
			} elsif $x !~~ /^ '-' $<opts> = [ .+ ] $/ {
				# TODO: permute
				push @restore, $x;
				last;
			}
			$x = $<opts>;
	
			while $x ~~ /^ $<opt> = [ <[a..zA..Z0..9?]> ] $<rest> = [ .* ] $/ {
				$x = $<rest>;
				if not %defs{$<opt>}:k {
					die "Invalid option '-$<opt>' specified";
				} elsif !%defs{$<opt>} {
					%opts{$<opt>} ~= $<opt>;
				} elsif $x ne '' {
					%opts{$<opt>} = ~$x;
					$x = '';
				} elsif @args.elems == 0 {
					die "Option '-$<opt>' requires an argument";
				} else {
					%opts{$<opt>} = @args.shift;
				}
			}
			if $x ne '' {
				die "Invalid option string '$x' specified";
			}
		}
	};
	if $! {
		note "$!";
		$result = False;
	}

	@args.unshift(|@restore);
	return $result;
}

=begin pod

=head1 NAME

Getopt::Std - Process single-character options with option clustering

=head1 SYNOPSIS

=begin code
    use Getopt::Std;

    my Str:D %opts;
    usage() unless getopts('ho:V', %opts, @*ARGS);

    version() if %opts<V>;
    usage(True) if %opts<h>;
    exit(0) if %opts{<V h>}:k;

    my $outfile = %opts<o> // 'a.out';
=end code

=head1 DESCRIPTION

This module exports the C<getopts()> function for parsing command-line
arguments similarly to the POSIX getopt(3) standard C library routine.

The options are single letters (no long options) preceded by a single
dash character.  Options that do not accept arguments may be clustered
(e.g. C<-hV> for C<-h> and C<-V>); the last one may be an option that accepts
an argument (e.g. C<-vo outfile.txt>).  Options that accept arguments may
have their argument "glued" to the option or in the next element of
the arguments array, i.e. C<-ooutfile> is equivalent to C<-o outfile>.
There is no equals character between an option and its argument; if one is
supplied, it will be considered the first character of the argument.

If an unrecognized option character is supplied in the arguments array,
C<getopts()> will display an error message and return false.  Otherwise
it will return true and fill in the C<%opts> hash with the options found
in the arguments array.  The key in the C<%opts> array is the option name
(e.g. C<h> or C<o>); the value is the option argument for options that
accept one or the option name (as many times as it has been specified) for
options that do not.

=head1 FUNCTIONS

=begin item1
sub getopts

    sub getopts(Str:D $optstr, Str:D %opts, @args)

Look for the command-line options specified in C<$optstr> in the C<@args>
array.  Record the options found into the C<%opts> hash, leave only
the non-option arguments in the C<@args> array.

Return true on success, false if an invalid option string has been
specified or an unknown option has been found in the arguments array.
=end item1

=head1 AUTHOR

Peter Pentchev <L<roam@ringlet.net|mailto:roam@ringlet.net>>

=head1 COPYRIGHT

Copyright (C) 2016  Peter Pentchev

=head1 LICENSE

The Getopt::Std module is distributed under the terms of
the Artistic License 2.0.  For more details, see the full text of
the license in the file LICENSE in the source distribution.

=end pod
