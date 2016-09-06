Change log for the Getopt::Std Perl 6 module
============================================

1.0.0.dev1 (not yet)
--------------------

- Add the Rakudo 2016.08 release to the ones tested at Travis CI.
- Do not error out on an empty option string if the :unknown or
  :nonopts flags are specified.
- Throw an X::Getopt::Std exception instead of returning false.
- Stop exporting two internal utility functions even if :util is
  specified when importing the module.
- Skip the :unknown :!all cases in the test suite.
- Remove the :all flag and split it out into the getopts-all()
  function instead, if only to be able to predict the type of
  the returned options array.  Closes: #1; thanks, Tom Browder!

0.1.0
-----

Initial public release.
