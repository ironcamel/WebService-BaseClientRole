# NAME

WebService::BaseClientRole - A base role for quickly and easily creating web service clients

# VERSION

version 0.0007

# SYNOPSIS

    {
        package WebService::Foo;
        use Moo;
        with 'WebService::BaseClientRole';

        has auth_token => ( is => 'ro', required => 1 );
        has '+base_url' => ( default => 'https://foo.com/v1' );

        sub BUILD {
            my ($self) = @_;
            $self->ua->default_header('X-Auth-Token' => $self->auth_token);
            # or if the web service uses http basic/digest authentication:
            # $self->ua->credentials( ... );
        }

        sub get_widgets {
            my ($self) = @_;
            return $self->get("/widgets");
        }

        sub get_widget {
            my ($self, $id) = @_;
            return $self->get("/widgets/$id");
        }

        sub create_widget {
            my ($self, $widget_data) = @_;
            return $self->post("/widgets", $widget_data);
        }
    }

    my $client = WebService::Foo->new(
        auth_token => 'abc',
        logger     => Log::Tiny->new('/tmp/foo.log'), # optional
        timeout    => 10, # optional, defaults to 10
        retries    => 0,  # optional, defaults to 0
    );
    $client->create_widget({ color => 'blue' });

# DESCRIPTION

This module is a base role for quickly and easily creating web service clients.
Every time I created a web service client, I noticed that I kept rewriting the
same boilerplate code independent of the web service.
This module does the boring boilerplate for you so you can just focus on
the fun part - writing the web service specific code.

It is important to note that this only supports JSON based web services.
If your web service does not support JSON, then I am sorry.

# METHODS

These are the methods this role composes into your class.
The HTTP methods (get, post, put, and delete) will return the deserialized
response data, assuming the response body contained any data.
This will usually be a hashref.
If the web service responds with a failure, then the corresponding HTTP
response object is thrown as an exception.
This exception is simply an [HTTP::Response](http://search.cpan.org/perldoc?HTTP::Response) object that can be stringified.
HTTP responses with a status code of 404 or 410 will not result in an exception.
Instead, the corresponding methods will simply return `undef`.
The reasoning behind this is that GET'ing a resource that does not exist
does not warrant an exception.

## get

    $client->get('/foo')

Makes an HTTP POST request.

## post

    $client->post('/foo', { some => 'data' })

Makes an HTTP POST request.

## put

    $client->put('/foo', { some => 'data' })

Makes an HTTP PUT request.

## delete

    $client->delete('/foo')

Makes an HTTP DELETE request.

## req

    my $req = HTTP::Request->new(...);
    $client->req($req);

This is called internally by the above HTTP methods.
You will usually not need to call this explicitly.
It is exposed as part of the public interface in case you may want to add
a method modifier to it.
Here is a contrived example:

    around req => sub {
        my ($orig, $self, $req) = @_;
        $req->authorization_basic($self->login, $self->password);
        return $self->$orig($req, @rest);
    };

## log

Logs a message using the provided logger.

# EXAMPLES

Here are some examples of web service clients built with this role.
You can view their source to help you get started.

- [Business::BalancedPayments](http://search.cpan.org/perldoc?Business::BalancedPayments)
- [WebService::HipChat](http://search.cpan.org/perldoc?WebService::HipChat)
- [WebService::Lob](http://search.cpan.org/perldoc?WebService::Lob)
- [WebService::SmartyStreets](http://search.cpan.org/perldoc?WebService::SmartyStreets)

# SEE ALSO

- [Net::HTTP::API](http://search.cpan.org/perldoc?Net::HTTP::API)
- [Role::REST::Client](http://search.cpan.org/perldoc?Role::REST::Client)

# AUTHOR

Naveed Massjouni <naveed@vt.edu>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Naveed Massjouni.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
