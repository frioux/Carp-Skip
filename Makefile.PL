use 5.006;
use inc::Module::Install 0.91;
use strict;
use warnings FATAL => 'all';

perl_version '5.006';
all_from 'lib/Carp/Skip.pm';
requires 'Carp';

test_requires 'Test::More';
test_requires 'Test::Warn';
test_requires 'Test::Exception';

WriteAll;
