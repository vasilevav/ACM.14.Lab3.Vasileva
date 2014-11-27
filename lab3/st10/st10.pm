package ST10;

use strict;

use DBI;
use Text::Iconv;

use constant API_KEY => '0add42399f47c5125b45b292b8efb2b4';

my $dsn = 'DBI:mysql:lab3:localhost'; # ‘®¥¤¨­¥­¨¥ á ¡ §®©
my $db_user_name = 'perl_lab';
my $db_password = '1234';
my $dbh;

my $iconvTo = Text::Iconv->new('cp866', 'cp1251');
my $iconvFrom = Text::Iconv->new('cp1251', 'cp866');

my @dbm_attributes = (
    'name',
    'lastname',
    'age',
);

my %types = (
    'default' => 'Student',
    'captain' => 'Captain',
);

my %attributes = (
    'default' => ['name', 'lastname', 'age'],
    'captain' => ['name', 'lastname', 'age', 'group'],
);
my %attributesLabels = (
    'name' => 'First Name',
    'lastname' => 'Last Name',
    'age' => 'Age',
    'group' => 'Group'
);

my $currentAction;
my $studentId;

my %ACTIONS = 
(
	'add' => \&add,
	'edit' => \&edit,
	'remove' => \&remove,
	'list' => \&list,
	'import_dbm' => \&import_dbm,
	'export' => \&export
);

sub list
{
    my ($q, $global) = @_;
    
    printHtmlHeader($q, $global);
    
    my @objects = get_objects();
    
    if(scalar @objects == 0) {
        print '<div class="empty">No results.</div>';
    }
    
    print '<div id="items-list">';
    for(my $i = $[; $i <= $#objects; $i++) {
        my $obj = $objects[$i];
        my @attributesSort = @{$attributes{$obj->{'type'}}};
        
        print '<div class="item clearfix">';
        print '<div class="item-header left">' . $types{$obj->{'type'}} . '</div><form class="manage-buttons right" method="post" action="' . $global->{selfurl} . '">';
        print '<div class="buttons"><button type="submit" name="action" value="edit">Edit</button> <button type="submit" name="action" value="remove" onclick="return confirm(\'Delete object?\');">&times Delete</button></div>';
        print '<div class="id">#' . $obj->{'id'} . '</div>';
        print '<input type="hidden" name="student" value="' . $studentId . '" /><input type="hidden" name="id" value="' . $obj->{'id'} . '" />
        </form><div class="clearfix"></div>';
        
        foreach my $key (values @attributesSort) {
            print '<div class="row clearfix">';
            print '<span class="label">' . $attributesLabels{$key} . ':</span>';
            print '<span class="value">' . encode_entities($iconvTo->convert($obj->{$key})) . '</span>';
            print '</div>';
        }
        
        print '</div>';
    }
    print '</div>';
    
    printHtmlFooter();
}

sub edit
{
    my ($q, $global) = @_;
    
    my $id = $q->param('id');
    
    my $obj = get_object($id);
    
    if(!$obj) {
        printErrorMessage($q, $global, 'Object not found.');
        return;
    }
    
    if($q->param('save')) {
        foreach my $key (values $attributes{$obj->{'type'}}) {
            my $query = "SELECT id FROM st10_object_property WHERE code=? AND object_id=?";
            my $sth = $dbh->prepare($query);
            $sth->execute($key, $obj->{'id'});
            my $prop = $sth->fetchrow_hashref();
            
            my $value = $iconvFrom->convert($q->param('field_' . $key));
            $obj->{$key} = $value;
            if($prop) {
                $query = "UPDATE st10_object_property SET value=? WHERE id=?";
                $dbh->prepare($query)->execute($value, $prop->{'id'});
            } else {
                $query = "INSERT INTO st10_object_property (object_id, code, value) VALUES (?, ?, ?)";
                $dbh->prepare($query)->execute($obj->{'id'}, $key, $value);
            }
            
            $dbh->prepare("UPDATE st10_object SET date_changed=NOW() WHERE id=?")->execute($obj->{'id'});
        }
        
        print $q->redirect($global->{selfurl} . '?student=' . $studentId);
    }
    
    printItemForm($q, $global, $id, $obj, 'edit');
}

sub add
{
    my ($q, $global) = @_;
    
    my $type = $q->param('type');
    if(!$type) {
        printHtmlHeader($q, $global);
        print '<h2>New object</h2>';
        print '<ol>';
        for my $key (sort keys %types) {
            print '<li><a href="' . $global->{selfurl} . '?student=' . $studentId . '&action=add&type=' . $key . '">' . $types{$key} . '</a></li>';
        }
        print '</ol>';
        printHtmlFooter();
        return;
    }
    
    my %obj = (
        'type' => $type
    );
    foreach my $key (keys $attributes{$obj{'type'}}) {
        $obj{$key} = '';
    }
    
    if($q->param('save')) {
        my $sth = $dbh->prepare('INSERT INTO st10_object(`type`, date_added) VALUES (?, NOW())');
        $sth->execute($obj{'type'});
        my $id = $sth->{'mysql_insertid'};
        
        foreach my $key (values $attributes{$obj{'type'}}) {
            my $value = $iconvFrom->convert($q->param('field_' . $key));
            $obj{$key} = $value;
            $dbh->prepare('INSERT INTO st10_object_property(object_id, code, value) VALUES(?, ?, ?)')->execute($id, $key, $value);
        }
        
        print $q->redirect($global->{selfurl} . '?student=' . $studentId);
    }
    
    printItemForm($q, $global, 0, \%obj, 'add');
}

sub printItemForm
{
    my ($q, $global, $id, $obj, $action) = @_;
    
    printHtmlHeader($q, $global);
    
    print '<div class="item clearfix">';
    if($id) {
        print '<div class="item-header">' . $types{$obj->{'type'}} . '</div><div class="manage-buttons right"><div class="id">#' . ($id) . '</div></div><div class="clearfix"></div>';
    }
    print '<form class="item-form" method="post" action="' . $global->{selfurl} . '">';
    print '<input type="hidden" name="student" value="' . $studentId . '" />';
    print '<input type="hidden" name="id" value="' . ($id) . '" />';
    print '<input type="hidden" name="action" value="' . $action . '" />';
    print '<input type="hidden" name="type" value="' . $obj->{'type'} . '" />';

    my @attributesSort = @{$attributes{$obj->{'type'}}};
    foreach my $key (values @attributesSort) {
        print '<div class="row clearfix">';
        print '<span class="label">' . $attributesLabels{$key} . ':</span>';
        print '<span class="value"><input type="text" name="field_' . $key . '" value="' . encode_entities($iconvTo->convert($obj->{$key})) . '" /></span>';
        print '</div>';
    }
    
    print '<div class="row clearfix"><span class="label"></span><span class="value"><button type="submit" name="save" value="1">Save</button></span></div>';
    print '</form></div>';
    
    printHtmlFooter();
}

sub remove
{
    my ($q, $global) = @_;
    
    my $id = $q->param('id');

    if($q->request_method() != 'POST') {
        printErrorMessage($q, $global, 'Bad request.');
        return;
    }
    
    my $obj = get_object($id);
    
    if(!$obj) {
        printErrorMessage($q, $global, 'Object not found.');
        return;
    }
    
    $dbh->prepare('DELETE FROM st10_object WHERE id=?')->execute($obj->{'id'});
    $dbh->prepare('DELETE FROM st10_object_property WHERE object_id=?')->execute($obj->{'id'});
    
    print $q->redirect($global->{selfurl} . '?student=' . $studentId);
}

sub import_dbm
{
    my ($q, $global) = @_;
    
    use Cwd 'abs_path';
    my ($v, $path, $file) = File::Spec->splitpath(__FILE__);
    $path = abs_path($path);
    
    my $fileName = $path . '/data/data';
    
    my %dbm_objects = ();
    my %hash;
    dbmopen(%hash, $fileName, 0666) or die "Can't open $fileName: $!";
    
    my $template = '';
    foreach my $key (sort values @dbm_attributes) {
        $template .= 'u i ';
    }
    my @attr_keys = sort values @dbm_attributes;
    foreach my $key (keys %hash) {
        my @d = unpack($template, $hash{$key});
        $dbm_objects{$key} = {};
        my $i = 0;
        foreach my $k (keys @d) {
            if(($k % 2) != 0) {
                next;
            }
            $dbm_objects{$key}->{$attr_keys[$i]} = $d[$k];
            $i++;
        }
    }
    
    dbmclose(%hash);
    
    foreach my $id (sort keys %dbm_objects) {
        my $obj = $dbm_objects{$id};
        
        my $query = "INSERT INTO st10_object (date_added) VALUES(NOW())";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        
        my $o_id = $sth->{mysql_insertid};
        
        $query = "INSERT INTO st10_object_property(object_id, code, value) VALUES ";
        my $is_first = 1;
        my @values = ();
        foreach my $key (values @dbm_attributes) {
            my $value = $obj->{$key};
            
            if(!$is_first) {
                $query .= ',';
            } else {
                $is_first = 0;
            }
            $query .= " (?, ?, ?)";
            
            push @values, $o_id;
            push @values, $key;
            push @values, $value;
        }
        
        if(@values > 0) {
            my $sth = $dbh->prepare($query);
            for (my $i = $[; $i <= $#values; $i++) {
                $sth->bind_param($i + 1, $values[$i]);
            }
            $sth->execute();
        }
    }
    
    print $q->redirect($global->{selfurl} . '?student=' . $studentId);
}

sub export
{
    my ($q, $global) = @_;
    
    print $q->header('Content-type: text/html; charset=cp866');
    
    my $key = $q->param('API_KEY');
    if($key != API_KEY) {
        die "Access denied.";
    }
    
    my %obj = (
        'type' => 'default'
    );
    
    my $sth = $dbh->prepare('INSERT INTO st10_object(`type`, date_added) VALUES (?, NOW())');
    $sth->execute($obj{'type'});
    my $id = $sth->{'mysql_insertid'};
    
    foreach my $key (values $attributes{$obj{'type'}}) {
        my $value = $q->param('field_' . $key);
        $obj{$key} = $value;
        $dbh->prepare('INSERT INTO st10_object_property(object_id, code, value) VALUES(?, ?, ?)')->execute($id, $key, $value);
    }
    
    print 'OK';
}

sub get_objects
{
    my ($_f) = @_;
    my %filter = $_f ? %{$_f} : ();
    
    my $query = "SELECT * FROM st10_object as t WHERE 1";
    if(exists($filter{'ids'})) {
        $query .= " AND t.id IN (";
        for(my $i = 0; $i < (keys $filter{'ids'}); $i++) {
            if($i != 0) {
                $query .= ", ";
            }
            $query .= "?";
        }
        $query .= ")";
    }
    
    my $sth = $dbh->prepare($query);
    if(exists($filter{'ids'})) {
        my $i = 1;
        for my $_id (values $filter{'ids'}) {
            $sth->bind_param($i, $_id);
            $i++;
        }
    }
    
    my @ids;
    my @result = ();
    my %ids_map = ();
    
    $sth->execute();
    while(my $obj = $sth->fetchrow_hashref) {
        my $id = int $obj->{'id'};
        push @ids, $id;
        $ids_map{$id} = $#ids;
        
        my %item = (
            'id' => $id,
            'type' => $obj->{'type'}
        );
        
        push @result, $obj;
    }
    
    if(@ids) {
        $query = "SELECT * FROM st10_object_property as t WHERE t.object_id IN (" . join(',', @ids) . ")";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        while(my $property = $sth->fetchrow_hashref) {
            my $id = $property->{'object_id'};
            my $n = $ids_map{$id};
            my $code = $property->{'code'};
            $result[$n]{$code} = $property->{'value'};
        }
     }
    
    return @result;
}

sub get_object
{
    my ($id) = @_;
    if(!$id) {
        return undef;
    }
    
    my %filter = ('test' => 'hello', 'ids' => [$id]);
    my @objects = get_objects(\%filter);
    
    my $obj = shift(@objects);
    if(!$obj) {
        return undef;
    }
    
    return $obj;
}

sub st10
{
    my ($q, $global) = @_;
    
    $studentId = int($q->param('student'));
    
    $dbh = DBI->connect($dsn, $db_user_name, $db_password, {RaiseError=>1, AutoCommit=>1});
    if(!$dbh) {
        die "Cannot connect to database";
    }
    $dbh->prepare('SET NAMES cp866')->execute();

    my $action = $q->param('action');
    if(defined $ACTIONS{$action}) {
        $currentAction = $action;
        $ACTIONS{$action}->($q, $global);
    } else {
        $currentAction = 'list';
        $ACTIONS{'list'}->($q, $global);
    }
}

sub trim 
{
    my $s = shift; $s =~ s/\s+$//g; 
    return $s;
}

sub printErrorMessage
{
    my ($q, $global, $message) = @_;
    
    printHtmlHeader($q, $global);
    print '<div class="flash-error">' . $message . '</div>';
    printHtmlFooter();
}

sub printHtmlHeader
{
    my ($q, $global) = @_;
    
    my $css = getCss();
    my $menu = getMenu($q, $global);
    
    print $q->header('Content-type: text/html; charset=cp1251');
    
    print <<HTML;
<!DOCTYPE html>
<html>
    <head>
        <meta charset="cp1251" />
        <title>Kartoteka</title>
        <style type="text/css">
        $css
        </style>
    </head>
    <body>
        <div class="page-header">
            <h1 class="left">Kartoteka</h1>
            $menu
            <div class="clearfix"></div>
        </div>
HTML
}

sub printHtmlFooter
{
    print <<HTML;
        <div id="footer">
        &copy; 2014 Petr Kuklianov
        </div>
    </body>
</html>    
HTML
}

sub getMenu
{
    my ($q, $global) = @_;
    
    my $html = '<ul id="menu">
    <li><a href="' . $global->{selfurl} . '?student=' . $studentId . '&action=list">List of objects</a></li>
    <li><a href="' . $global->{selfurl} . '?student=' . $studentId . '&action=add">Add object</a></li>
    <li><a href="' . $global->{selfurl} . '?student=' . $studentId . '&action=import_dbm" onclick="return confirm(\'Run the import command?\');">Import DBM</a></li>
    <li><a href="' . $global->{selfurl} . '">Exit</a></li>
</ul>';
    
    return $html;
}

sub encode_entities
{
    my ($str) = @_;
    
    $str =~ s/"/&quot;/g;
    $str =~ s/'/&apos;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    
    return $str;
}

sub getCss
{
    return <<CSS;
.clearfix {
  *zoom: 1;
}

.clearfix:before,
.clearfix:after {
  display: table;
  line-height: 0;
  content: "";
}

.clearfix:after {
  clear: both;
}
.left {
    float: left;
}
.right {
    float: right;
}
body {
    font-family: Arial, sans-serif;
    margin: 1em 5em;
    font-size: 16px;
}
#footer {
    color: gray;
    font-size: 8pt;
    border-top: 1px solid #aaa;
    padding-top: 1em;
    margin-top: 3em;
}
a {
    color: #08c;
}
a:hover {
    text-decoration: none;    
}
.page-header {
    border-bottom: 1px solid #ddd;
    margin-bottom: 20px;
}
h1 {
    color: #5a5a5a;
    margin: 0px 10px 5px 0px;
}
#menu {
    list-style: none;
    margin-top: 10px;
    float: left;
}
#menu li {
    float: left;
    margin-right: 10px;
    padding-right: 10px;
    border-right: 1px solid #ccc;
}
#menu li:last-child {
    border-right: none;
}
#menu li.active a {
    font-weight: bold;
    text-decoration: none;
}
.item {
    border: 1px solid #ccc;
    border-radius: 5px;
    padding: 3px 10px 10px;
    margin-bottom: 10px;
    width: 600px;
}
.item .id {
    float: left;
    color: #3a87ad;
    font-weight: bold;
    margin-top: 3px;
    margin-left: 10px;
}
.item .label {
    float: left;
    width: 150px;
    min-height: 10px;
    font-size: 13px;
    font-weight: bold;
    color: #666;
    display: block;
}
.item .value {
    float: left;
    width: 445px;
    border-bottom: 1px dashed #ddd;
    margin-bottom: 5px;
    padding-bottom: 5px;
    min-height: 18px;
}
.item form.manage-buttons {
    float: right;
}
.item form.manage-buttons .buttons {
    float: left;
}
.item-form {
    margin-top: 5px;
}
.item-header {
    color: #3a87ad;
    font-weight: bold;
    margin: 3px 0px 10px;
}
div.flash-error, div.flash-notice, div.flash-success {
    border: 2px solid #DDDDDD;
    margin-bottom: 1em;
    padding: 0.8em;
}
div.flash-error {
    background: none repeat scroll 0 0 #FBE3E4;
    border-color: #FBC2C4;
    color: #8A1F11;
}
div.flash-notice {
    background: none repeat scroll 0 0 #FFF6BF;
    border-color: #FFD324;
    color: #514721;
}
div.flash-success {
    background: none repeat scroll 0 0 #E6EFC2;
    border-color: #C6D880;
    color: #264409;
}
div.flash-error a {
    color: #8A1F11;
}
div.flash-notice a {
    color: #514721;
}
div.flash-success a {
    color: #264409;
}
CSS
}
