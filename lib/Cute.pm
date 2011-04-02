package Cute;
use strict;
use warnings;
use parent qw(Cute::Controller);

use Tiffany;
use Smart::Args;
use Module::Collect;
use Class::Inspector;
use UNIVERSAL::isa;
use UNIVERSAL::require;
use Path::Class qw(dir file);
use Encode qw(encode_utf8 is_utf8);

use Cute::View;
use Cute::Context;
use Cute::Request;
use Cute::Response;
use Cute::Controller;

__PACKAGE__->mk_classdata('root');
__PACKAGE__->mk_classdata('config');
__PACKAGE__->mk_classdata('logger');

use Router::Simple;
__PACKAGE__->mk_classdata(router => Router::Simple->new);

use Cute::Action;
__PACKAGE__->mk_classdata(action => Cute::Action->new);

sub import {
    my ($class, $base) = @_;
    my ($call_pkg) = caller();

    {
        no strict 'refs';
        $base ||= __PACKAGE__;

        if (!UNIVERSAL::isa($base, __PACKAGE__)) {
            die qq{base class `$base' must be a subclass of @{[__PACKAGE__]}};
        }

        unshift @{"$call_pkg\::ISA"}, $base;
    }

    $class->install_methods($call_pkg);
    $call_pkg->install_controlers;
}

sub install_methods {
    my ($class, $call_pkg) = @_;
    for my $method (qw(get post put delete)) {
        no strict 'refs';

        *{"$call_pkg\::$method"} = sub ($&) {
            my ($pattern, $code) = @_;
            $pattern ||= '';
            $pattern =~ s{^/}{};
            my ($path_segments)  = $call_pkg =~ /Controller::(.+)$/;
            $path_segments = join '/', (split /::/, lc($path_segments || ''));
            $path_segments .= '/' if $path_segments;
            my $path = '/' . ($path_segments || '') . ($pattern || '');
            $class->router->connect(
                $path,
                {
                    controller => $call_pkg, path => $path },
                {
                    method  => uc $method },
            );
            $class->action->register($path, $method, $code);
        }
    }
}

sub install_controlers {
    my $class  = shift;
    return if $class =~ /::Controller::/;

    my $filename = Class::Inspector->resolved_filename($class);
    (my $path = $filename) =~ s/\.pm$//;
    my $prefix = "${class}::Controller";
    my $collect  = Module::Collect->new(
        path   => $path,
        prefix => $prefix,
    );
    for my $module (@{$collect->modules}) {
        $module->require;
    }
}

sub run {
    args my $class  => 'ClassName',
         my $root   => 'Str',
         my $env    => 'HashRef',
         my $config => { isa => 'Cute::Config', optional => 1 };

    $class->setup_config($config);
    $class->root(dir($root));

    my $request  = Cute::Request->new($env);
    my $response = Cute::Response->new;
    my $context  = Cute::Context->new({
        request  => $request,
        response => $response,
    });

    if (my $route = $class->router->match($env)) {
        my $controller = $route->{controller}->new;
        $context->controller = $controller;
        my $path = $route->{path};
        $response->path($path);
        my $method  = lc $env->{REQUEST_METHOD};
        my $action  = $class->action->retrieve($path, $method);
        eval { $action->($controller, $context) };
        if (my $exception = HTTP::Exception->caught) {
            $response->code($exception->code);
        }
        $response->code($response->code || 200);
    }
    else {
        $response->code(404);
    }

    $class->handle_response($context);
}

sub setup_config {
    my ($class, $config) = @_;
    if ($config || !$class->config) {
        $class->config($config);
    }
}

sub handle_response {
    my ($class, $context) = @_;
    my $view_option = ($class->config && $class->config->param('view')) || {};
    my $engine      = $view_option->{engine} || 'Text::Xslate';
    my $option      = $view_option->{option} || {};
    my $view        = Cute::View->new({ engine => $engine, option => $option });

    if ($context->response->is_success && !$context->response->content) {
        my $template = eval {
            my $file     = $context->response->template;
            my $template = $class->root->subdir('templates')->file($file);
            (!-e $template) && HTTP::Exception->throw(404);
            $template;
        };
        if (my $exception = HTTP::Exception->caught) {
            $context->response->code(404);
        }
        else {
            my $args = +{
                c   => $context->controller,
                ctx => $context,
                %{$context->stash->to_hash},
            };
            my $content = $view->render($template->stringify, $args);
               $content = encode_utf8($content) if is_utf8($content);

            $context->response->content($content);
        }
    }

    if ($context->response->is_error) {
        $class->handle_error($context, $view);
    }

    $context->response->content_type($context->response->content_type || 'text/html');
    $context->response->finalize;
}

sub handle_error {
    my ($class, $context, $view) = @_;
    my $file = $context->response->code . '.html';
    my $template = $class->root->subdir('templates/_errors')->file($file);
    if (-e $template) {
        my $content = $view->render($template->stringify, {});
        $context->response->content($content);
    }
}

!!1;
