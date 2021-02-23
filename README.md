## Description
This is a supplement to the dbi module, allowing you to avoid hard-coding
passwords in your programs that make database connections. It can also
be used as a general password storage mechanism for other types of
connections, e.g. ssh, ftp, etc.

## Requirements
For most platforms there are no additional requirements. However, for MS
Windows there are these additional requirements:

* sys-admin
* win32-file-attributes
* win32-dir
* win32-process

## Installation
`gem install dbi-dbrc`

## Synopsis
```ruby
require 'dbi/dbrc'
include DBI

dbrc = DBRC.new('mydb') # or...
dbrc = DBRC.new('mydb', 'someUser')

puts dbrc.db
puts dbrc.user
puts dbrc.driver
puts dbrc.timeout
puts dbrc.max_reconn
puts dbrc.interval
puts dbrc.dsn
```

## Notes on the .dbrc file
This module relies on a file in your home directory called ".dbrc", and it
is meant to be analogous to the ".netrc" file used by programs such as
telnet. The .dbrc file has several conditions that must be met by the
module or it will fail:

* Permissions must be set to 600 (Unix only).
* Must be hidden (MS Windows only).
* Must be owned by the current user.
* Must have database, user and password. Other fields are optional.
* Must be in the following space-separated format (in the 'plain' version):

```
  database user password driver timeout maximum_reconnects interval
  # e.g. mydb     dan    mypass     oracle   10        2         30
```

You may include comments in the .dbrc file by starting the line with a
"#" symbol.

A failure in any of the rules mentioned above will result in a DBRC::Error
being raised. In addition, the file may also be encrypted on MS Windows
systems, in which case the file will automatically be (temporarily)
decrypted.

The format for XML (using the example above) is as follows:

```xml
<dbrc>
 <database name="mydb">
   <user>dan</user>
   <password>mypass</password>
   <driver>oracle</driver>
   <interval>30</interval>
   <timeout>10</timeout>
   <maximum_reconnects>2</maximum_reconnects>
 </database>
</dbrc>
```

The format for YAML is as follows:

```yaml
- mydb:
  user: dan
  password: mypass
  driver: oracle
  interval: 30
  timeout: 10
  max_reconn: 2
```
   
## Constants
`VERSION`

The current version of this library, returned as a String.
    
## Class Methods
`DBRC.new(db, user=nil, dir=nil)`

The constructor takes one to three arguments. The first argument is the
database name. This *must* be provided. If only the database name is
passed, the module will look for the first database entry in the .dbrc
file that matches.

The second argument, a user name, is optional. If it is passed, the
module will look for the first entry in the .dbrc file where both the
database *and* user name match.

The third argument, also optional, specifies the directory where DBRC will
look for the .dbrc file. By default, it looks in the pwuid (present
working user id) home directory. The rules for a .dbrc file still apply.

MS Windows users should read the "Notes" section for how your home directory
is determined.
    
## Instance Methods
`DBRC#database`

The name of the database. Note that the same entry can appear more than
once, presumably because you have multiple user id's for the same database.
    
`DBRC#db`

An alias for DBRC#database.
    
`DBRC#database=(database)`

Sets the database to +database+. This is generally discouraged because
it does not automatically reset the dsn.
    
`DBRC#db=(database)`

An alias for DBRC#database=.
   
`DBRC#user`

A valid user name for that database.
    
`DBRC#user=(user)`

Sets the user name to +user+.
    
`DBRC#password`

The password for that user.
    
`DBRC#passwd`

An alias for DBRC#password.
    
`DBRC#password=(password)`

Sets the password to +password+.

`DBRC#passwd=(password)`

An alias for DBRC#password=.
    
`DBRC#driver`

The driver type for that database (Oracle, MySql, etc).
    
`DBRC#driver=(driver)`

Sets the driver to +driver+.  This use is discouraged because it does not reset the dsn.
    
`DBRC#timeout`

The timeout period for a connection before the attempt is dropped.
   
`DBRC#time_out`

An alias for DBRC#timeout, provided purely for the sake of backwards compatability.
    
`DBRC#timeout=(int)`

Sets the timeout value to +int+.
   
`DBRC#maximum_reconnects`

The maximum number of reconnect attempts that should be made for the the
database. Presumablly, you would use this with a "retry" within a rescue block.

`DBRC#max_reconn`

An alias for DBRC#maximum_reconnects.
   
`DBRC#maximum_reconnects=(max)`

Sets the maximum number of reconnect attempts to +max+.

`DBRC#max_reconn=(max)`

An alias for DBRC#maximum_reconnects.
    
`DBRC#interval`

The number of seconds to wait before attempting to reconnect to the database
again should a network/database glitch occur.
    
`DBRC#interval=(int)`

Sets the interval seconds between connection attempts.
    
`DBRC#dsn`

Returns a string in "dbi:<driver>:<database>" format.
    
`DBRC#dsn=(dsn)`

Sets the dsn string to +dsn+.  This method is discouraged because it does
not automatically reset the driver or database.
    
## Canonical Example
```ruby
# This is a basic template for how I do things:

require 'dbi/dbrc'
require 'timeout'

db = DBI::DBRC.new("somedb")
n = db.max_reconn

begin
 Timeout.timeout(db.timeout){
   DBI.connect(db.dsn, db.user, db.passwd)
 }
rescue DBI::Error
 n -= 1
 if n > 0
   sleep db.interval
   retry
 end
 raise
rescue TimeoutError
 # handle timeout error
end
```

## Notes for MS Windows Users
The 'home' directory for Win32 users is determined by ENV['USERPROFILE'].
If that is not set, ENV['HOME'] is used. If that is not set, then
the directory found by the sys-admin library is used.

To make your file hidden, right click on the .dbrc file in your Explorer
window, select "Properties" and check the "Hidden" checkbox.

I was going to require that the .dbrc file be encrypted on MS Windows,
but that may require an official "certificate", assigned to you by a third
party, which is a bit much to expect. However, if the file is encrypted,
DBRC will attempt to decrypt it, parse it, and encrypt it again when done
parsing.

## Notes on running the test suite
I cannot guarantee that the .dbrc files under the +examples+
subdirectories maintain the appropriate properties. This can cause
failures for the test suite (which uses these files).

The only solution is to perform a 'chmod 600 .dbrc' (on Unix) or set
the properties to 'hidden' (on MS Windows) manually, for the file in
question.
   
## Summary
These "methods" don't really do anything. They're simply meant as a
convenience mechanism for you dbi connections, plus a little bit of
obfuscation (for passwords).

## Adding your own configuration
If you want to add your own type of configuration file, you can still use
the dbi-dbrc library. All you need to do is:

* subclass DBRC
* redefine the +parse_dbrc_config_file+ method (a private method).

Take a look at the XML and YML subclasses in dbrc.rb for two examples that
you can work from.
   
## Future Plans
Add DBI::DBRC::JSON.
   
## Known Bugs
I'm not positive about the dsn strings for databases other than Oracle.
If it's not correct, please let me know.
   
## Copyright
(C) Copyright 2002-2021, Daniel J. Berger, all rights reserved.

## License
Apache-2.0
   
## Warranty
This package is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose
   
## Author
Daniel J. Berger
