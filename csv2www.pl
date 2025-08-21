#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Text::CSV;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use HTML::Entities qw(encode_entities);

binmode(STDOUT, ":encoding(UTF-8)");

# -----------------------
# --- Read config     ---
# -----------------------
sub read_config {
    my ($file) = @_;
    open my $fh, "<:encoding(utf8)", $file or die "Impossible d'ouvrir $file: $!";
    my %config;
    while (<$fh>) {
        chomp;
        s/^\s+|\s+$//g;
        next if /^#/;
        next unless /=/;
        my ($key, $val) = split(/\s*=\s*/, $_, 2);
        $config{$key} = $val;
    }
    close $fh;
    return \%config;
}

my $config = read_config('config.cfg');

my $csv_file       = $config->{csv_file} // 'data.csv';
my $lines_per_page = $config->{lines_per_page} // 5;
my @search_fields  = split /\s*,\s*/, ($config->{search_fields} // '');
my @alpha_fields   = split /\s*,\s*/, ($config->{alpha_index_fields} // '');

# -----------------------
# --- CGI / Parameters ---
# -----------------------
my $cgi  = CGI->new;
my $page = $cgi->param('page') // 1;
$page = 1 if $page !~ /^\d+$/;

my $search = $cgi->param('search') // '';
my $alpha  = $cgi->param('alpha') // '';
my $alpha_field = $cgi->param('field') // '';  # champ sélectionné pour alpha filter

# -----------------------
# --- Read CSV     ------
# -----------------------
my $sep = detect_separator($csv_file);
my ($header, $rows) = read_csv($csv_file, $sep);

# -----------------------
# --- Filters  ----------
# -----------------------
my $filtered_rows = filter_rows($rows, $header, \@search_fields, \@alpha_fields, $search, $alpha, $alpha_field);

# -----------------------
# --- Pagering   --------
# -----------------------
my $total_rows  = scalar @$filtered_rows;
my $total_pages = int(($total_rows + $lines_per_page -1)/$lines_per_page) || 1;
$page = $total_pages if $page > $total_pages;
my $start = ($page -1) * $lines_per_page;
my $end   = $start + $lines_per_page -1;
$end = $total_rows -1 if $end > $total_rows -1;

my @page_rows = @$filtered_rows[$start .. $end];

# -----------------------
# --- CGI Header  -------
# -----------------------
print header(-type => 'text/html; charset=UTF-8');

# -----------------------
# --- HTML vars   -------
# -----------------------
my $page_lang = $config->{page_lang} // 'en';
my $page_intro_text = $config->{page_intro} // '';
my $page_title_text = $config->{page_title} // 'CSV Viewer';
my $url = $cgi->url(-path_info => 1, -query => 1);
my $illus = $config->{illus};

print start_html(
    -title    => $page_title_text,
    -encoding => 'UTF-8',
    -style    => { -src => 'style.css' },
    -lang     => $page_lang,
    -meta     => {'robots'=>'follow, index', 'title'=>$page_intro_text, 'description'=>$page_intro_text, 'og:description'=>$page_intro_text, 'twitter:description'=>$page_intro_text, 'og:title'=>$page_title_text, 'twitter:title'=>$page_title_text, 'og:url'=>$url, 'og:image'=>$illus, 'og:logo'=>$illus, 'og:locale'=>$page_lang, 'og:type'=>'website', 'twitter:image'=>$illus}
);

# -----------------------------
# --- Title and description ---
# -----------------------------
my $page_title_text = $config->{page_title} // 'CSV Viewer';
my $page_intro_text = $config->{page_intro} // '';
my $ico = $config->{ico} // 'csv2www.png';
print qq{
<table>
  <tr>
    <td><img src="$ico" width="50" height="50"/></td>
    <td><h1 class="title">$page_title_text</h1></td>
  </tr>
</table>
<p class="description">$page_intro_text</p>
};

# -------------------
# --- Search form ---
# -------------------
if ($cgi->param('reset')) {
    $search = '';
    $alpha  = '';
    $alpha_field = '';
    $page   = 1;
}
my $search_escaped = encode_entities($search);
my $button_ok = $config->{button_ok} // 'Search';
my $button_raz = $config->{button_raz} // 'Reset';
my $input_search = $config->{input_search} // 'Search';
my $button_clean = $config->{button_clean} // 'Search';
print qq{
<form method="get">
$input_search: <input type="text" name="search" value="$search_escaped">
<input type="submit" name="ok" value="$button_ok">
<input type="submit" name="reset" value="$button_raz"> | 
<input type="submit" value="$button_clean">
</form>
};

# -----------------------
# --- Perl functions ----
# -----------------------

sub result_counter {
    my ($total_rows, $page_rows) = @_;
    my $shown = scalar @$page_rows;
    return qq{
    <div class="result_count">
        Résultats trouvés : $total_rows 
        (dont $shown affichés sur cette page)
    </div>
    };
}

sub detect_separator {
    my ($file) = @_;
    open my $fh, "<:encoding(utf8)", $file or die "Impossible d'ouvrir $file: $!";
    my $line = <$fh>;
    close $fh;
    return ';' if $line =~ /;/;
    return "\t" if $line =~ /\t/;
    return ',';  # défaut
}

sub read_csv {
    my ($file, $sep) = @_;
    my $csv = Text::CSV->new({ binary => 1, sep_char => $sep })
        or die "Erreur création Text::CSV: " . Text::CSV->error_diag();

    open my $fh, "<:encoding(utf8)", $file or die "Impossible d'ouvrir $file: $!";

    my $header = $csv->getline($fh);
    my @rows;
    while (my $row = $csv->getline($fh)) {
        push @rows, $row;
    }
    close $fh;
    return ($header, \@rows);
}

sub generate_html_tables {
    my ($header, $rows) = @_;
    my $html = '';
    foreach my $row (@$rows) {
        $html .= qq{<table class="csv_table">\n};
        for my $i (0 .. $#$header) {
            my $field = $header->[$i];
            my $val   = $row->[$i] // '';
            my $cell_html = '';
            my $trim = $val;
            $trim =~ s/^\s+|\s+$//g;

            if ($trim =~ m{^https://}i) {
                my $href  = $trim;
                $href =~ s/"/&quot;/g;
                my $label = encode_entities($trim);
                $cell_html = qq{<a href="$href" target="_blank" rel="noopener noreferrer">$label</a>};
            } else {
                $cell_html = encode_entities($val);
                $cell_html =~ s/\r?\n/<br>/g;
            }

            $html .= qq{<tr><th>$field</th><td>$cell_html</td></tr>\n};
        }
        $html .= "</table><br>\n";
    }
    return $html;
}

sub filter_rows {
    my ($rows, $header, $search_fields_ref, $alpha_fields_ref, $search_val, $alpha_val, $alpha_field_val) = @_;
    return $rows unless $search_val || $alpha_val;

    my @filtered;
    ROW: for my $row (@$rows) {

        # --- Search ---
        if ($search_val) {
            my $found = 0;
            for my $i (0 .. $#$header) {
                my $field = $header->[$i];
                my $val   = $row->[$i] // '';
                if (grep { lc($_) eq lc($field) } @$search_fields_ref) {
                    if ($val =~ /\Q$search_val\E/i) {
                        $found = 1;
                        last;
                    }
                }
            }
            next ROW unless $found;
        }

        # --- Indexes ---
        if ($alpha_val && $alpha_field_val) {
            my $match = 0;
            for my $i (0 .. $#$header) {
                my $field = $header->[$i];
                if (lc($field) eq lc($alpha_field_val)) {
                    my $val = $row->[$i] // '';
                    if ($val =~ /^\Q$alpha_val\E/i) {
                        $match = 1;
                        last;
                    }
                }
            }
            next ROW unless $match;
        }

        push @filtered, $row;
    }

    return \@filtered;
}

sub pagination_links {
    my ($page, $total_pages) = @_;
    my $html = '<div class="pagination">';
    if ($page > 1) {
        my $prev = $page-1;
        $html .= qq{<a href="?page=$prev&search=@{[escapeHTML($search)]}&alpha=@{[escapeHTML($alpha)]}&field=@{[escapeHTML($alpha_field)]}">Précédent</a> };
    }
    if ($page < $total_pages) {
        my $next = $page+1;
        $html .= qq{<a href="?page=$next&search=@{[escapeHTML($search)]}&alpha=@{[escapeHTML($alpha)]}&field=@{[escapeHTML($alpha_field)]}">Suivant</a> };
    }
    $html .= '</div>';
    return $html;
}

sub alpha_index_menu {
    my $html = '';

    for my $field (@alpha_fields) {
        next unless $field;
        my $title = encode_entities($field);
        my $index_name = $config->{alpha_index_name} // 'Index from :';
        $html .= qq{<div class="alpha_index"><strong>$index_name “$title”</strong> };
        for my $letter ('A' .. 'Z') {
            $html .= qq{<a href="?alpha=@{[escapeHTML($letter)]}&field=@{[escapeHTML($field)]}&search=@{[escapeHTML($search)]}">$letter</a> };
        }
        $html .= '</div><br>';
    }

    return $html;
}

sub footer {
    my $title = $config->{footer} // 'CSV Viewer - © Stéphane Pouyllau';
    my $html = qq{<div class="footer">$title</div><br>};
    $html .= '<!-- csv2www © 2025 Stéphane POUYLLAU -->';
    return $html;
}

# ------------------
# --- HTML pager ---
# ------------------

# --- Index ---
print alpha_index_menu();

# --- Pager ---
print pagination_links($page, $total_pages);

# -- Counters ---
print result_counter($total_rows, \@page_rows);

# --- Table ---
print generate_html_tables($header, \@page_rows);

# --- Pager ---
print pagination_links($page, $total_pages);

# --- Footer ---
print footer();

# --- EOF ---
print end_html;