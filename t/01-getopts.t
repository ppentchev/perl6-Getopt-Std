#!/usr/bin/env perl6

use v6.c;

use Test;

use Getopt::Std;

my Str:D %base_opts = :foo('bar'), :baz('quux'), :h(''), :something('15'), :O('-3.5');
my Str:D @base_args = <-v -I tina -vOverbose something -o something -- else -h>;
my $base_optstr = 'I:O:o:v';
my Str:D %empty_hash;

sub test-getopts(Str:D :$name, Str:D :$optstring = $base_optstr, :@args = @base_args, Str:D :%opts = %base_opts, Bool:D :$res = True, :@res-args, :%res-opts)
{
	my Str:D @test-args = @args;
	my Str:D %test-opts = %opts;
	my Bool:D $result = getopts($optstring, %test-opts, @test-args);
	is $result, $res, "$name: returned result";
	is-deeply %test-opts, Hash[Str:D].new(%res-opts), "$name: stores the expected options";
	is-deeply @test-args, Array[Str:D](|@res-args), "$name: leaves the expected arguments";
}

my @tests = (
	{
		:name('empty string'),
		:optstring(''),
		:!res,
		:res-args(@base_args),
		:res-opts(%base_opts),
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
		:res-opts({:v('vv')}),
	},
	{
		:name('another repeated flag'),
		:args(<-v -v out>),
		:res-args([<out>]),
		:res-opts({:v('vv')}),
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
		:name('complicated example'),
		:res-args(<something -o something -- else -h>),
		:res-opts({:I('tina'), :O('verbose'), :v('vv')}),
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

plan 3 * @tests.elems;
test-getopts(|$_) for @tests;
