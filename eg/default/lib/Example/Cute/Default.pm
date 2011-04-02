package Example::Cute::Default;
use strict;
use warnings;

use Cute;

sub title {
    my ($self, $suffix) = @_;
    my $title  = 'Hello, Cute!';
       $title .= " ($suffix)" if $suffix;
       $title;
}

get '/' => sub {
    my ($self, $ctx) = @_;
};

get '/foo' => sub {
    my ($self, $ctx) = @_;
    $ctx->res->content($self->title('/foo'));
};

get '/bar/baz' => sub {
    my ($self, $ctx) = @_;
    $ctx->stash(
        title => $self->title('/bar/baz'),
        list  => [
            { value => 'foo' },
            { value => 'bar' },
            { value => 'baz' },
        ],
    );
};

!!1;
