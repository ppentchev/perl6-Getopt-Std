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
			} elsif $x !~~ /^ '-' $<opts> = [ .* ] $/ {
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
