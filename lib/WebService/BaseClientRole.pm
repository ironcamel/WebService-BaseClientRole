package WebService::BaseClientRole;
use Moo::Role;

# VERSION

use HTTP::Request::Common qw(DELETE GET POST PUT);
use JSON qw(decode_json encode_json);
use LWP::UserAgent;

has base_url => ( is => 'ro', required => 1 );

has ua => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $ua = LWP::UserAgent->new;
        $ua->timeout($self->timeout);
        return $ua;
    },
);

has timeout => ( is => 'ro', default => 10 );

has retries => ( is => 'ro', default => 0 );

has logger => ( is => 'ro' );

sub get {
    my ($self, $path, $params) = @_;
    $params ||= {};
    my $q = '';
    if (%$params) {
        $q = '?' . join '&', map { "$_=$params->{$_}" } keys %$params;
    }
    return $self->_req(GET "$path$q");
}

sub post {
    my ($self, $path, $params) = @_;
    return $self->_req(POST $path, content => encode_json $params);
}

sub put {
    my ($self, $path, $params) = @_;
    return $self->_req(PUT $path, content => encode_json $params);
}

sub delete {
    my ($self, $path) = @_;
    return $self->_req(DELETE $path);
}

# Prefix the path param of the http methods with the base_url
around qw(delete get post put) => sub {
    my $orig = shift;
    my $self = shift;
    my $path = shift;
    die 'Path is missing' unless $path;
    my $url = $self->_url($path);
    return $self->$orig($url, @_);
};

sub _req {
    my ($self, $req) = @_;
    $req->header(content_type => 'application/json');
    $self->_log_request($req);
    my $res = $self->ua->request($req);
    Moo::Role->apply_roles_to_object($res, 'HTTP::Response::Stringable');
    $self->_log_response($res);

    my $retries = $self->retries;
    while ($res->code =~ /^5/ and $retries--) {
        sleep 1;
        $res = $self->ua->request($req);
        $self->_log_response($res);
    }

    return undef if $res->code =~ /404|410/;
    die $res unless $res->is_success;
    return $res->content ? decode_json($res->content) : 1;
}

sub _url {
    my ($self, $path) = @_;
    return $path =~ /^http/ ? $path : $self->base_url . $path;
}

sub _log_request {
    my ($self, $req) = @_;
    $self->log($req->method . ' => ' . $req->uri);
    my $content = $req->content;
    return unless length $content;
    $self->log($content);
}

sub _log_response {
    my ($self, $res) = @_;
    $self->log("$res");
}

sub log {
    my ($self, $msg) = @_;
    return unless $self->logger;
    $self->logger->DEBUG($msg);
}

=head1 SYNOPSIS

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

=head1 DESCRIPTION

This module is a base role for quickly and easily creating web service clients.
Every time I created a web service client, I noticed that I kept rewriting the
same boilerplate code independent of the web service.
This module does the boring boilerplate for you so you can just focus on
the fun part - writing the web service specific code.

=head1 SEE ALSO

=over

=item *

L<Net::HTTP::API>

=item *

L<Role::REST::Client>

=back

=cut

1;
