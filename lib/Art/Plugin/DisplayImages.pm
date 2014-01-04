package Art::Plugin::DisplayImages;
use parent Art::Plugin;

use Gtk2;
use Glib qw/TRUE FALSE/;
use Data::Dumper;
use Moo;

has window => (
    is => 'rw',
);

has draw => (
    is => 'rw',
);

has images => (
    is => 'rw',
);

has application => (
    is => 'rw',
);

=head2 METHODS

=over 4

=item BUILD

Initialize attributes

=cut
sub BUILD
{
    my $self = shift;

    $self->images([]);

    $self->is_recursive(1);
}

sub display
{
    my $self = shift;

    Gtk2->init;

    # on crée la fenêtre
    my $window = Gtk2::Window->new('toplevel');

    # la fenêtre est plein écran
    $window->fullscreen;

    # la fenêtre est au centre
    $window->set_position('center');

    # on gère le bouton échap pour arrêter l'application
    $window->signal_connect(
	'key-press-event' => sub
	{
	    my ($widget,$event,$parameter)= @_;

	    # on appuie sur 'escape'
	    if ($event->keyval() == 65307
		and defined $self->application)
	    {
		$self->application->stop;
	    };
	});

    # on stocke la fenêtre
    $self->window($window);

    # on crée un endroit où dessiner
    my $draw = Gtk2::DrawingArea->new();

    # on ajoute à la fenêtre
    $window->add($draw);

    # on stocke cet endroit
    $self->draw($draw);

    # on affiche la fenêtre
    $window->show_all;
}

sub on_input
{
    my($self, $web, $tagname, $attr) = @_;

    return unless defined $tagname and $tagname eq 'img';

    # on récupère l'url de l'image
    my $url = $attr->{src} // return;

    # on envoie la requête
    $web->add_request(
	$url, sub
	{
	    # on récupère l'image
	    $self->draw_pixbuf_randomly(
		$self->get_pixbuf_from_data(shift));

	});
}

sub get_pixbuf_from_data
{
    my($self, $data) = @_;

    # get pixbuf from data
    my $pixbuf_loader = Gtk2::Gdk::PixbufLoader->new;
    $pixbuf_loader->write($data);
    $pixbuf_loader->close;

    # return image
    return $pixbuf_loader->get_pixbuf;
}

sub draw_pixbuf_randomly
{
    my($self, $pixbuf) = @_;

    my($window_width, $window_height) =
	$self->window->get_size;

    # on affiche l'image
    $self->draw->window->draw_pixbuf(
	undef, $pixbuf, 0, 0,
	int rand($window_width - $pixbuf->get_width),
	int rand($window_height - $pixbuf->get_height),
	$pixbuf->get_width,
	$pixbuf->get_height,
	'none', 0, 0);
}

1;
__END__
