# $Id$

package PuzzleAndRebuild::CMS;

use strict;
use warnings;
use utf8;
use MT::Entry;
use MT::WeblogPublisher;

sub rebuild_start {
    my $app = shift;
    my (%opt) = @_;

    my $q = $app->{query};
    my $blog_id = scalar $q->param('blog_id');

    my $tmpl = $app->load_tmpl('rebuild_start.tmpl');
    $tmpl->param('blog_id'  => $blog_id);
    $app->add_breadcrumb($app->translate("Main Menu"),$app->{mtscript_url});
    require MT::Blog;
    my $blog = MT::Blog->load ($blog_id);
    $app->add_breadcrumb($blog->name,$app->mt_uri( mode => 'menu', args => { blog_id => $blog_id }));
    $app->add_breadcrumb($app->translate("PuzzleAndRebuild"));

    $tmpl->param(breadcrumbs       => $app->{breadcrumbs});
    return $app->build_page($tmpl);
}

sub rebuild_entry {
    my $app = shift;

    my $blog_id = $app->param('blog_id')
        or return $app->json_error( 'no blog_id' );
    my $blog = MT::Blog->load( $blog_id )
        or return $app->json_error( 'no blog' );

    my %args = ( 
        sort => 'authored_on',
        direction => 'descend',
    );
    $args{offset} = $app->param('offset') || 0;
    $args{limit} = $app->param('limit') || 1; 
    my $iter = MT::Entry->load_iter(
        {
            blog_id => $blog_id,
            class => '*',
            status => MT::Entry::RELEASE(),
        },
        \%args,
    );

    my $count = 0;
    while ( my $entry = $iter->() ) {
        $app->rebuild_entry(
            Entry => $entry,
            Blog => $blog,
            BuildDependencies => 1,
        ) or $app->json_error( $app->log($app->publisher->errstr) );
        $count++;
    }

    return $app->json_result( { count => $count } );
}

sub rebuild_entry_count {
    my $app = shift;

    my $blog_id = $app->param('blog_id')
        or return $app->json_error( 'no blog_id' );
    my $blog = MT::Blog->load( $blog_id )
        or return $app->json_error( 'no blog' );

    my %args = ( 
        sort => 'authored_on',
        direction => 'descend',
    );
    my $count = MT::Entry->count(
        {
            blog_id => $blog_id,
            class => '*',
            status => MT::Entry::RELEASE(),
        },
        \%args,
    );

    return $app->json_result( { count => $count } );
}

1;
__END__

