use strict;
use warnings;

# without this the stacktrace of $schema will be activated
BEGIN { $ENV{DBIC_TRACE} = 0 }

use Test::More;
use Test::Warn;
use Test::Exception;
use DBIx::Class::Carp;
use lib 't/lib';

{
  sub DBICTest::DBICCarp::frobnicate {
    DBICTest::DBICCarp::branch1();
    DBICTest::DBICCarp::branch2();
  }

  sub DBICTest::DBICCarp::branch1 { carp_once 'carp1' }
  sub DBICTest::DBICCarp::branch2 { carp_once 'carp2' }


  warnings_exist {
    DBICTest::DBICCarp::frobnicate();
  } [
    qr/carp1/,
    qr/carp2/,
  ], 'expected warnings from carp_once';
}

done_testing;
