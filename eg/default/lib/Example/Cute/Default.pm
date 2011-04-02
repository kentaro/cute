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

get '/{year:[0-9]{4}}/{month:[0-9]{2}}' => sub {
    my ($self, $ctx) = @_;
    $ctx->response->set_template('path_query.html');
    $ctx->stash(
        year  => $ctx->req->path_query('year'),
        month => $ctx->req->path_query('month'),
    );
};

!!1;
