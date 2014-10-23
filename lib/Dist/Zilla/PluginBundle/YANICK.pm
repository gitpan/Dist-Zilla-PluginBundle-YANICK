package Dist::Zilla::PluginBundle::YANICK;
BEGIN {
  $Dist::Zilla::PluginBundle::YANICK::AUTHORITY = 'cpan:yanick';
}
BEGIN {
  $Dist::Zilla::PluginBundle::YANICK::VERSION = '0.4.0';
}

# ABSTRACT: Be like Yanick when you build your dists


use strict;

use Moose;

use Dist::Zilla::Plugin::ModuleBuild;
use Dist::Zilla::Plugin::GithubMeta;
use Dist::Zilla::Plugin::Homepage;
use Dist::Zilla::Plugin::Bugtracker;
use Dist::Zilla::Plugin::MetaYAML;
use Dist::Zilla::Plugin::MetaJSON;
use Dist::Zilla::Plugin::PodWeaver;
use Dist::Zilla::Plugin::License;
use Dist::Zilla::Plugin::ReadmeFromPod;
use Dist::Zilla::Plugin::NextRelease;
use Dist::Zilla::Plugin::MetaProvides::Package;
use Dist::Zilla::Plugin::InstallRelease;
use Dist::Zilla::Plugin::InstallGuide;

with 'Dist::Zilla::Role::PluginBundle::Easy';

sub configure {
    my ( $self ) = @_;
    my $arg = $self->payload;

    my $release_branch = 'releases';
    my $upstream       = 'github';

    my %mb_args;
    $mb_args{mb_class} = $arg->{mb_class} if $arg->{mb_class};
    $self->add_plugins([ 'ModuleBuild', \%mb_args ]);

    $self->add_plugins(
        'InstallGuide',
        [ GithubMeta => { remote => $upstream, } ],
        qw/ Homepage Bugtracker MetaYAML MetaJSON PodWeaver License
          ReadmeFromPod 
          ReadmeMarkdownFromPod
          /,
        [ NextRelease => { 
                time_zone => 'America/Montreal',
                format    => '%-9v %{yyyy-MM-dd}d',
            } ],
        'MetaProvides::Package',
        qw/ MatchManifest
          ManifestSkip
          GatherDir
          ExecDir
          PkgVersion /,
          [ Authority => { 
            ( authority => $arg->{authority} ) x !!$arg->{authority}  
          } ],
          qw/ ReportVersions
          Signature /,
          [ AutoPrereqs => { skip => $arg->{autoprereqs_skip} } ],
          qw/ CheckChangesHasContent
          TestRelease
          ConfirmRelease
          Git::Check
          /,
        [ 'Git::CommitBuild' => { release_branch => $release_branch } ],
        [ 'Git::Tag'  => { tag_format => 'v%v', branch => $release_branch } ],
    );

    if ( $arg->{fake_release} ) {
        $self->add_plugins( 'FakeRelease' );
    }
    else {
        $self->add_plugins(
            [ 'Git::Push' => { push_to    => $upstream } ],
            'UploadToCPAN',
            [ 'InstallRelease' => { install_command => 'cpanm .' } ],
            'Twitter',
        );
    }

    $self->add_plugins(qw/
        Author::YANICK::NextSemanticVersion
        Git::Commit 
    /);

    $self->config_slice( 'mb_class' );

    return;
}

1;

__END__
=pod

=head1 NAME

Dist::Zilla::PluginBundle::YANICK - Be like Yanick when you build your dists

=head1 VERSION

version 0.4.0

=head1 DESCRIPTION

This is the plugin bundle that Yanick uses to release
his distributions. It's roughly equivalent to

    [ModuleBuild]

    [InstallGuide]

    [GithubMeta]
    remote=github

    [Homepage]
    [Bugtracker]

    [MetaYAML]
    [MetaJSON]

    [PodWeaver]

    [License]

    [ReadmeFromPod]
    [ReadmeMarkdownFromPod]

    [NextRelease]
    time_zone = America/Montreal

    [MetaProvides::Package]

    [MatchManifest]
    [ManifestSkip]

    [GatherDir]
    [ExecDir]

    [PkgVersion]
    [Authority]

    [ReportVersions]
    [Signature]

    [AutoPrereqs]

    [CheckChangesHasContent]

    [TestRelease]

    [ConfirmRelease]

    [Git::Check]
    [Git::Commit]
    [Git::CommitBuild]
        release_branch = releases
    [Git::Tag]
        tag_format = v%v
        branch     = releases
    [Git::Push]
        push_to = github

    [UploadToCPAN]

    [InstallRelease]
    install_command = cpanm .

    [Twitter]

    [Author::YANICK::NextSemanticVersion]

=head2 ARGUMENTS

=head3 autoprereqs_skip

Passed as C<skip> to AutoPrereqs.

=head3 authority

Passed to L<Dist::Zilla::Plugin::Authority>.

=head3 fake_release

If given a true value, uses L<Dist::Zilla::Plugin::FakeRelease>
instead of 
L<Dist::Zilla::Plugin::Git::Push>,
L<Dist::Zilla::Plugin::UploadToCPAN>,
L<Dist::Zilla::Plugin::InstallRelease> and
L<Dist::Zilla::Plugin::Twitter>.

=head3 mb_class

Passed to C<ModuleBuild> plugin.

=head1 AUTHOR

Yanick Champoux <yanick@babyl.dyndns.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

