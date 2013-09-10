use strict;
use warnings;

# without this the stacktrace of $schema will be activated
BEGIN { $ENV{DBIC_TRACE} = 0 }

use Test::More;
use Test::Warn;
use Test::Exception;
use Carp::Skip;
use lib 't/lib';

{
  sub A::frobnicate {
    A::branch1();
    A::branch2();
    A::branch3();
  }

  sub A::branch1 { carp_once 'carp1' }
  sub A::branch2 { carp_once 'carp2' }
  sub A::branch3 { carp_unique 'carp3' }


  warnings_exist {
    A::frobnicate();
  } [
    qr/carp1/,
    qr/carp2/,
    qr/carp3/,
  ], 'expected warnings from carp_once';

   warnings_exist {
     A::frobnicate();
   } [qr/carp3/], 'carp_unique fires for new callsite';

   warnings_are {
     A::branch1();
     A::branch2();
   } [], 'still no warnings from carp_once again';

   for (1, 0) {
      my $warning = '';
      local $SIG{__WARN__} = sub { $warning = shift };
      A::branch3();

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
