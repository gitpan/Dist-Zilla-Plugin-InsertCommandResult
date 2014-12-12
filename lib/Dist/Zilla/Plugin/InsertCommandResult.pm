package Dist::Zilla::Plugin::InsertCommandResult;

our $DATE = '2014-12-12'; # DATE
our $VERSION = '0.01'; # VERSION

use 5.010001;
use strict;
use warnings;

use Proc::ChildError qw(explain_child_error);

use Moose;
with (
    'Dist::Zilla::Role::FileMunger',
    'Dist::Zilla::Role::FileFinderUser' => {
        default_finders => [':InstallModules', ':ExecFiles'],
    },
);

use namespace::autoclean;

sub munge_files {
    my $self = shift;

    $self->munge_file($_) for @{ $self->found_files };
}

sub munge_file {
    my ($self, $file) = @_;
    my $content = $file->content;
    if ($content =~ s{^#\s*COMMAND:\s*(.*)\s*$}{$self->_command_result($1)."\n"}egm) {
        $self->log(["inserting result of command '%s' in %s", $1, $file->name]);
        $file->content($content);
    }
}

sub _command_result {
    my($self, $cmd) = @_;

    my $res = `$cmd`;

    if ($?) {
        die "Command '$cmd' failed: " . explain_child_error();
    }

    $res =~ s/^/ /gm;
    $res;
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Insert the result of command into your POD

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Plugin::InsertCommandResult - Insert the result of command into your POD

=head1 VERSION

This document describes version 0.01 of Dist::Zilla::Plugin::InsertCommandResult (from Perl distribution Dist-Zilla-Plugin-InsertCommandResult), released on 2014-12-12.

=head1 SYNOPSIS

In dist.ini:

 [InsertCommandResult]

In your POD:

 # COMMAND: netstat -anp

=head1 DESCRIPTION

This module finds C<# COMMAND: ...> directives in your POD, pass it to the
Perl's backtick operator, and insert the result into your POD as a verbatim
paragraph. If command fails (C<$?> is non-zero), build will be aborted.

=for Pod::Coverage .+

=head1 SEE ALSO

L<Dist::Zilla::Plugin::InsertCodeResult>, which can also be used to accomplish
the same thing, e.g. with C<# CODE: my $res = `netstat -anp`; die if $?; $res>
except the DZP::InstallCommandResult plugin is shorter.

L<Dist::Zilla::Plugin::InsertExample>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Dist-Zilla-Plugin-InsertCommandResult>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Dist-Zilla-Plugin-InsertCommandResult>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-InsertCommandResult>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
