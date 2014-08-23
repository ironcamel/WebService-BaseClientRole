# NAME

WebService::BaseClientRole - A base role for quickly and easily creating web service clients

# VERSION

version 0.0005

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

# SEE ALSO

- [Net::HTTP::API](http://search.cpan.org/perldoc?Net::HTTP::API)
- [Role::REST::Client](http://search.cpan.org/perldoc?Role::REST::Client)

# AUTHOR

Naveed Massjouni <naveed@vt.edu>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Naveed Massjouni.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
