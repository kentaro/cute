use strict;
use warnings;
use Path::Class;

my $root;
BEGIN {
    $root = dir(__FILE__)->parent;
    unshift @INC, 'lib', "$root/lib";
}

use Plack::Builder;
use Example::Cute::Default;

builder {
    enable 'Plack::Middleware::Static',
        root     => $root->subdir('public'),
        path     => qr{^/(images|js|css|favicon)};

    sub {
        my $env = shift;
        Example::Cute::Default->run(
            env  => $env,
            root => $root->stringify,
        )
    }
};
