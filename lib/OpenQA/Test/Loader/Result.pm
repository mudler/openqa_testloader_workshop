package OpenQA::Test::Loader::Result;

# Include OpenQA libs, not needed if called inside OpenQA codebase
use lib '/usr/share/openqa/lib';

use Mojo::Base 'OpenQA::Parser::Result';
#use Mojo::Util qw(b64_decode b64_encode); # IT does use padding / break string
 use MIME::Base64;
has [qw(test vars modules)];

# Let's use base64 for our purposes
sub encode { MIME::Base64::encode_base64url shift->serialize }
sub decode { __PACKAGE__->new->deserialize(MIME::Base64::decode_base64url pop) }

1;
