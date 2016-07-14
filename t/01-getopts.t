#!/usr/bin/env perl6

use v6.c;

use Test;

use Getopt::Std;

plan 48;

my Str:D %base_opts = :foo('bar'), :baz('quux'), :h(''), :something('15'), :O('-3.5');
my @base_args = <-v -I tina -vOverbose something -o something -- else -h>;
my $base_optstr = 'I:O:o:v';
my Str:D %empty_hash;

my Str:D %opts = %base_opts;
my @args = @base_args;
nok getopts('', %opts, @args), 'fails with an empty option string';
is-deeply %opts, %base_opts, 'does not modify the result with an empty option string';
is-deeply @args, @base_args, 'does not modify the arguments with an empty option string';

%opts = %base_opts;
@args = ();
ok getopts($base_optstr, %opts, @args), 'succeeds with no command-line arguments';
is %opts.elems, 0, 'clears the result hash with an empty option string';
is @args.elems, 0, 'does not modify the empty arguments array';

%opts = %base_opts;
@args = <no options specified>;
ok getopts($base_optstr, %opts, @args), 'succeeds with no options specified';
is %opts.elems, 0, 'clears the result hash with no options specified';
is-deeply @args, [<no options specified>], 'does not modify the arguments with no options specified';

%opts = %base_opts;
@args = <-- -v -I -i -O -o>;
ok getopts($base_optstr, %opts, @args), 'succeeds with an early --';
is %opts.elems, 0, 'clears the result hash with an early --';
is-deeply @args, [<-v -I -i -O -o>], 'removes the early -- from the arguments array';

%opts = %base_opts;
@args = <-v out>;
ok getopts($base_optstr, %opts, @args), 'succeeds with a single flag';
is-deeply %opts, Hash[Str:D].new(<v v>), 'stores a single flag into the result hash';
is-deeply @args, [<out>], 'removes the single flag from the arguments array';

%opts = %base_opts;
@args = <-vv out>;
ok getopts($base_optstr, %opts, @args), 'succeeds with a repeated flag';
is-deeply %opts, Hash[Str:D].new(<v vv>), 'stores a repeated flag into the result hash';
is-deeply @args, [<out>], 'removes the repeated flag from the arguments array';

%opts = %base_opts;
@args = <-v -v out>;
ok getopts($base_optstr, %opts, @args), 'succeeds with another repeated flag';
is-deeply %opts, Hash[Str:D].new(<v vv>), 'stores another repeated flag into the result hash';
is-deeply @args, [<out>], 'removes the other repeated flag from the arguments array';

%opts = %base_opts;
@args = <-Ifoo bar>;
ok getopts($base_optstr, %opts, @args), 'succeeds with a glued argument';
is-deeply %opts, Hash[Str:D].new(<I foo>), 'stores the glued argument into the result hash';
is-deeply @args, [<bar>], 'removes the glued argument from the arguments array';

%opts = %base_opts;
@args = <-I foo bar>;
ok getopts($base_optstr, %opts, @args), 'succeeds with a separate argument';
is-deeply %opts, Hash[Str:D].new(<I foo>), 'stores the separate argument into the result hash';
is-deeply @args, [<bar>], 'removes the separate argument from the arguments array';

%opts = %base_opts;
@args = <-vIfoo bar>;
ok getopts($base_optstr, %opts, @args), 'succeeds with a glued argument and an option';
is-deeply %opts, Hash[Str:D].new(<I foo v v>), 'stores the option and the argument into the result hash';
is-deeply @args, [<bar>], 'removes the option and the argument from the arguments array';

%opts = %base_opts;
@args = <-vI foo bar>;
ok getopts($base_optstr, %opts, @args), 'succeeds with a separate argument and an option';
is-deeply %opts, Hash[Str:D].new(<I foo v v>), 'stores the option and the argument into the result hash';
is-deeply @args, [<bar>], 'removes the option and the argument from the arguments array';

%opts = %base_opts;
@args = @base_args;
ok getopts($base_optstr, %opts, @args), 'succeeds with a complicated example';
is-deeply %opts, Hash[Str:D].new(<I tina O verbose v vv>), 'stores the options properly';
is-deeply @args, [<something -o something -- else -h>], 'removes the options from the arguments array';

%opts = %base_opts;
@args = <-X>;
nok getopts($base_optstr, %opts, @args), 'fails on an unrecognized option';

%opts = %base_opts;
@args = <-vX>;
nok getopts($base_optstr, %opts, @args), 'fails on an unrecognized option glued to a good one';

%opts = %base_opts;
@args = <-v -X>;
nok getopts($base_optstr, %opts, @args), 'fails on an unrecognized option after a good one';

%opts = %base_opts;
@args = <-I -X>;
ok getopts($base_optstr, %opts, @args), 'treats -X correctly as an option argument';
is-deeply %opts, Hash[Str:D].new(<I -X>), 'stores -X correctly';
is @args.elems, 0, 'removes -I -X from the arguments array';

%opts = %base_opts;
@args = <-v -- -X>;
ok getopts($base_optstr, %opts, @args), 'ignores -X after --';
is-deeply %opts, Hash[Str:D].new(<v v>), 'stores the options before the --';
is-deeply @args, [<-X>], 'removes the options and the --';

%opts = %base_opts;
@args = <-v nah -X>;
ok getopts($base_optstr, %opts, @args), 'ignores -X after a non-option argument';
is-deeply %opts, Hash[Str:D].new(<v v>), 'stores the options before the non-option argument';
is-deeply @args, [<nah -X>], 'removes the options before the non-option argument';
