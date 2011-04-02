package Example::Cute::Default::Controller::Hoge;
use strict;
use warnings;

use Cute 'Example::Cute::Default';

get '/' => sub {
    my ($self, $ctx) = @_;
    $ctx->res->content($self->title('/hoge'));
};

get '/fuga' => sub {
    my ($self, $ctx) = @_;
    $ctx->stash(
        title => $self->title('/hoge/fuga'),
        list  => [
            { value => 'foo' },
            { value => 'bar' },
            { value => 'baz' },
        ],
    );
};

!!1;
