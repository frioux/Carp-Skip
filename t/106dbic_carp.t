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
    DBICTest::DBICCarp::branch3();
  }

  sub DBICTest::DBICCarp::branch1 { carp_once 'carp1' }
  sub DBICTest::DBICCarp::branch2 { carp_once 'carp2' }
  sub DBICTest::DBICCarp::branch3 { carp_unique 'carp3' }


  warnings_exist {
    DBICTest::DBICCarp::frobnicate();
  } [
    qr/carp1/,
    qr/carp2/,
    qr/carp3/,
  ], 'expected warnings from carp_once';

   warnings_exist {
     DBICTest::DBICCarp::frobnicate();
   } [qr/carp3/], 'carp_unique fires for new callsite';

   warnings_are {
     DBICTest::DBICCarp::branch1();
     DBICTest::DBICCarp::branch2();
   } [], 'still no warnings from carp_once again';

   for (1, 0) {
      my $warning = '';
      local $SIG{__WARN__} = sub { $warning = shift };
      DBICTest::DBICCarp::branch3();

      like($warning, ( $_
         ? qr/carp3/
         : qr/^$/
      ), ( $_
         ? 'first warning warns'
         : 'second is silent'
      ));
   }
}

done_testing;
