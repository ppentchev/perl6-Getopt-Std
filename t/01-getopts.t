#!/usr/bin/env perl6

use v6.c;

use Test;

use Getopt::Std :DEFAULT, :util;

my Str:D %base-opts = :foo('bar'), :baz('quux'), :h(''), :something('15'), :O('-3.5');
my Str:D @base-args = <-v -I tina -vOverbose something -o something -- else -h>;
my $base-optstr = 'I:O:o:v';
my Str:D %empty_hash;

sub check-deeply-relaxed($got, $expected) returns Bool:D
{
	given $expected {
		when Associative {
			return False unless $got ~~ Associative;
			return False if Set.new($got.keys) ⊖ Set.new($expected.keys);
			return ?( $got.keys.map(
			    { check-deeply-relaxed($got{$_}, $expected{$_}) }
			    ).all);
		}
		
		when Positional {
			return False unless $got ~~ Positional;
			return False unless $got.elems == $expected.elems;
			return ?( ($got.list Z $expected.list).map(-> ($g, $e)
			    { check-deeply-relaxed($g, $e) }
			    ).all);
			return True;
		}
		
		when Str {
			return $got eq $expected;
		}
		
		when Numeric {
			return $got == $expected;
		}
		
		default {
			return False;
		}
	}
}

sub test-deeply-relaxed($got, $expected) returns Bool:D
{
	return True if check-deeply-relaxed($got, $expected);
	diag "Expected:\n\t$expected.perl()\nGot:\n\t$got.perl()\n";
	return False;
}

sub test-getopts(Str:D :$name, Str:D :$optstring = $base-optstr, :@args = @base-args, Str:D :%opts = %base-opts, Bool:D :$res = True, :@res-args, :%res-opts)
{
	my Bool:D %defs = getopts-parse-optstring($optstring);

	for (False, True) -> $all {
		my Str:D $test = "$name [all: $all]";
		my Str:D @test-args = @args;
		my %test-opts = %opts;
		my Bool:D $result = getopts($optstring, %test-opts, @test-args, :$all);
		is $result, $res, "$test: returned result";

		my %exp-opts = %res-opts;
		getopts-collapse-array(%defs, %exp-opts) unless $all;
		ok test-deeply-relaxed(%test-opts, %exp-opts), "$test: stores the expected options";
		ok test-deeply-relaxed(@test-args, @res-args), "$test: leaves the expected arguments";
	}
}

my @tests = (
	{
		:name('empty string'),
		:optstring(''),
		:!res,
		:res-args(@base-args),
		:res-opts(%base-opts),
	},
	{
		:name('no command-line arguments'),
		:args(()),
		:res-args(()),
		:res-opts({}),
	},
	{
		:name('no options specified'),
		:args(<no options specified>),
		:res-args(<no options specified>),
		:res-opts({}),
	},
	{
		:name('early --'),
		:args(<-- -v -I -i -O -o>),
		:res-args(<-v -I -i -O -o>),
		:res-opts({}),
	},
	{
		:name('single flag'),
		:args(<-v out>),
		:res-args([<out>]),
		:res-opts({:v('v')}),
	},
	{
		:name('repeated flag'),
		:args(<-vv out>),
		:res-args([<out>]),
		:res-opts({:v([<v v>])}),
	},
	{
		:name('another repeated flag'),
		:args(<-v -v out>),
		:res-args([<out>]),
		:res-opts({:v([<v v>])}),
	},
	{
		:name('glued argument'),
		:args(<-Ifoo bar>),
		:res-args([<bar>]),
		:res-opts({:I('foo')}),
	},
	{
		:name('separate argument'),
		:args(<-I foo bar>),
		:res-args([<bar>]),
		:res-opts({:I('foo')}),
	},
	{
		:name('glued argument and an option'),
		:args(<-vIfoo bar>),
		:res-args([<bar>]),
		:res-opts({:I('foo'), :v('v')}),
	},
	{
		:name('separate argument and an option'),
		:args(<-vI foo bar>),
		:res-args([<bar>]),
		:res-opts({:I('foo'), :v('v')}),
	},
	{
		:name('repeated argument 1'),
		:args(<-Ifoo -Ibar baz>),
		:res-args([<baz>]),
		:res-opts({:I[<foo bar>]}),
	},
	{
		:name('repeated argument 2'),
		:args(<-Ifoo -I bar baz>),
		:res-args([<baz>]),
		:res-opts({:I[<foo bar>]}),
	},
	{
		:name('repeated argument 3'),
		:args(<-I foo -Ibar baz>),
		:res-args([<baz>]),
		:res-opts({:I[<foo bar>]}),
	},
	{
		:name('repeated argument 4'),
		:args(<-I foo -I bar baz>),
		:res-args([<baz>]),
		:res-opts({:I[<foo bar>]}),
	},
	{
		:name('complicated example'),
		:res-args(<something -o something -- else -h>),
		:res-opts({:I('tina'), :O('verbose'), :v([<v v>])}),
	},
	{
		:name('unrecognized option'),
		:args([<-X>]),
		:!res,
		:res-args(()),
		:res-opts({}),
	},
	{
		:name('unrecognized option glued to a good one'),
		:args([<-vX>]),
		:!res,
		:res-args(()),
		:res-opts({:v('v')}),
	},
	{
		:name('unrecognized option after a good one'),
		:args([<-v -X>]),
		:!res,
		:res-args(()),
		:res-opts({:v('v')}),
	},
	{
		:name('-X as an option argument'),
		:args([<-I -X>]),
		:res-args(()),
		:res-opts({:I('-X')}),
	},
	{
		:name('-X after --'),
		:args(<-v -- -X>),
		:res-opts({:v('v')}),
		:res-args([<-X>]),
	},
	{
		:name('-X after a non-option argument'),
		:args(<-v nah -X>),
		:res-opts({:v('v')}),
		:res-args(<nah -X>),
	},
	{
		:name('a dash after the options'),
		:args(<-v - foo>),
		:res-args(<- foo>),
		:res-opts({:v('v')}),
	},
);

plan 3 * 2 * @tests.elems;
test-getopts(|$_) for @tests;
