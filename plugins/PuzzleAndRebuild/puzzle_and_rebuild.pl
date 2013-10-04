# $Id$

package MT::Plugin::PuzzleAndRebuild;

use strict;
use MT::Plugin;
use base qw( MT::Plugin );

use vars qw($PLUGIN_NAME $VERSION);
$PLUGIN_NAME = 'PuzzleAndRebuild';
$VERSION = '0.1';

use MT;
my $plugin = MT::Plugin::PuzzleAndRebuild->new({
    id => 'puzzleandrebuild',
    key => __PACKAGE__,
    name => $PLUGIN_NAME,
    version => $VERSION,
    description => "<MT_TRANS phrase='description of PuzzleAndRebuild'>",
    author_name => 'ENDO, Katsuhiro',
    author_link => '/',
    l10n_class => 'PuzzleAndRebuild::L10N',
    registry => {
        applications => {
            cms => {
                menus => {
                    'tools:rebuild' => {
                        label => 'Puzzle & Rebuild',
                        order => 10000,
                        mode => 'rebuild_start',
                        permission => 'administer_blog',
                        view => [ 'blog', 'website', 'system' ],
                    },
                },
                methods => {
                  rebuild_start => '$PuzzleAndRebuild::PuzzleAndRebuild::CMS::rebuild_start',
                  rebuild_entry => '$PuzzleAndRebuild::PuzzleAndRebuild::CMS::rebuild_entry',
                  rebuild_entry_count => '$PuzzleAndRebuild::PuzzleAndRebuild::CMS::rebuild_entry_count',
                },
            },
        },
        tags => {
            function => {
                EntryFileModDate => \&hdlr_entry_file_mod_date,
            },
        },
    },
});

MT->add_plugin($plugin);

sub instance { $plugin; }

sub doLog {
    my ($msg) = @_; 
    return unless defined($msg);

    require MT::Log;
    my $log = MT::Log->new;
    $log->message($msg) ;
    $log->save or die $log->errstr;
}

sub hdlr_entry_file_mod_date {
    my ( $ctx, $args ) = @_;
    my $e = $ctx->stash('entry')
        or return $ctx->_no_entry_error();
    my $blog = $e->blog;
    my $file = $e->archive_file
        or return '';
    $file = File::Spec->catfile( $blog->archive_path, $file );
   
    my $fmgr = $blog->file_mgr;
    my $mod_time;
    if ( $mod_time = $fmgr->file_mod_time($file) ) {
        require MT::Util;
        $args->{ts} = MT::Util::epoch2ts($blog, $mod_time); 
    }
    else {
        return '';
    }
    return $ctx->build_date($args);
}

1;
__END__

