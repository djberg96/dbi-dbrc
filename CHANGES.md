## 1.5.0 - 12-Apr-2021
* Switched from test-unit to rspec, with corresponding changes in the
  gemspec and Rakefile.
* Switched doc files to markdown format.
* Added a Gemfile.
 
## 1.4.1 - 14-Jan-2018
* Fixed some test warnings.
* Added metadata to gemspec.
* The VERSION constant is now frozen.
* Updated the cert, should be good for about 10 years.

## 1.4.0 - 6-Dec-2015
* Use Dir.home to calculate the home directory on Unixy platforms. Therefore
  Ruby 1.9.3 or later is now required.
* The DBI::DBRC::YML class looks for "maximum_reconnects" instead of
  "max_reconn" to be consistent with the other classes.
* Aliases are now universal for all classes.
* Some gemspec and Rakefile updates.
* Added a dbi-dbrc.rb file for convenience.

## 1.3.0 - 3-Oct-2015
* License changed to Apache 2.0.
* Rakefile gem related tasks now assume Rubygems 2.x.
* Added a certs file. This gem is now signed.

## 1.2.0 - 8-Nov-2014
* Updated dependency for MS Windows. Now uses win32-file-attributes instead
  of win32-file.
* Minor updates to the Rakefile and gemspec.

## 1.1.9 - 10-Jan-2013
* Fixed an unused variable warning.
* Changed the way I check for MS Windows.

## 1.1.8 - 7-Oct-2010
* Fixed a logic bug in the constructor that primarily affected MS Windows with
  regards to determining the user's home directory.

## 1.1.7 - 6-Oct-2010
* More robust file decryption/encryption for MS Windows.
* Better platform checking for MS Windows.
* Refactored the Rakefile. Removed the old installation tasks and replaced
  them with a series of gem tasks.
* Updated the win32 library dependencies.

## 1.1.6 - 10-Sep-2009
* Fixed validation for dbrc_dir argument.
* Added a test for bogus dbrc_dir arguments.

## 1.1.5 - 3-Sep-2009
* License changed to Artistic-2.0.
* Some gemspec updates, including the license and description.
* Renamed the test files. The ts_all.rb file was removed.
* Added win32-process as a dependency on MS Windows.
* Added test-unit as a development dependency. Some tests were refactored
  to use features from test-unit 2.x.
* Added the 'test_xml' and 'test_yml' rake tasks.
* Refactored the main test task.
* Added explicit copyright and warranty to the README file.

## 1.1.4 - 10-Nov-2008
* Added a custom inspect method which filters the password.

## 1.1.3 - 21-Jul-2008
* More RUBY_PLATFORM changes that I missed in the last release.
* Added inline RDOC for the accessors and updated the documentation
  for the constructor.
* Added the DBI::DBRC#dbrc_dir and DBI::DBRC#dbrc_file methods.
* More tests.

## 1.1.2 - 18-Jul-2008
* Changed platform checking from RUBY_PLATFORM to Config::CONFIG['host_os']
  so that other implementations won't choke.
* Updated the gemspec to add the sys-admin dependency.
* Added a rubyforge_project to the gemspec.
* Now has a separate gem for MS Windows.

## 1.1.1 - 2-Aug-2007
* DBRCError is now DBRC::Error.
* Added a Rakefile with tasks for installation and testing.
* Added the win32-dir library as a prerequisite for MS Windows.
* Removed the install.rb file. That's now handled by the Rakefile.
* Some refactoring in the constructor, including the elimination of
  warnings that appeared when run with -w.
* Some doc and test updates.

## 1.1.0 - 19-Oct-2005
* Bug fix for MS Windows (there's no Win32 namespace for win32/file).
* Changed platform detection mechanism.

## 1.0.1 - 7-Oct-2005
* Improved the error message when an entry isn't found.

## 1.0.0 - 15-Jun-2005
* Ditches the use of 'etc'.  Now requires the 'sys-admin' package as its
  replacement (for all platforms).
* Moved project to RubyForge.
* Minor updates to tests, README and gemspec.
* Now hosted on RubyForge.

## 0.5.1 - 17-Mar-2005
* Removed the 'doc' directory completely, and moved the primary
  documentation into the README file.
* Removed the INSTALL file.  Moved the installation directions into the
  README file.
* Moved the examples into a toplevel 'examples' directory.
* Made the README and CHANGES files rdoc friendly.
* Added a gemspec.

## 0.5.0 - 15-Oct-2004
* Added a YAML subclass.  Use this if you want to store your information in
  the .dbrc file in YAML format.
* On Win32 systems, the .dbrc file must now be "hidden".  Also, it will
  automatically decrypt/encrypt the file if it is encrypted.  This also
  means that the win32-file package is also required on Win32 systems.
* Massive refactoring of the XML subclass.  It should work better now.
* Moved the YML and XML subclasses directly into the dbrc.rb file.
* For the aliases, you can now write as well as read.
* In lieu of the namespace fix for "timeout" in 1.8, I have renamed "time_out"
  to simply "timeout".  For backwards compatability, I have created an alias,
  so you may still use the old method name.  However, this means that you
  should only use this package with 1.8.0 or later.
* Removed the dbrc.html file.  You can generate this on your own if you wish
  using rdtool.
* Test suite changes.

## 0.4.0 - 3-Sep-2004
* Removed redundant error handling for cases when the database and/or login
  are not found.
* Added an XML subclass.  Use this if you want to store your information in
  the .dbrc file in XML format.

## 0.3.0 - 26-Oct-2003
* Win32 support added.  Requires the win32-etc package.
* rd doc separated from source.  Moved to 'doc' directory.
* Documentation updates and corrections.
* Minor test suite tweaks for Win32 systems.

## 0.2.1 - 28-Aug-2003
* Removed VERSION class method.  Just use the constant.
* Bug fix with regards to split and Ruby 1.8.  Thanks Michael Garriss.
* Changed 'changelog' to 'CHANGES'.
* Added a vanilla test script (test.rb)
* Minor code optimization (IO.foreach)
* Test unit cleanup
* Minor internal directory layout and doc changes

## 0.2.0 - 13-Jan-2003
* DBRC class now under the DBI module namespace
* Changed "timeout" to "time_out" to avoid confusion with the timeout
  module.
* The 'time_out', 'max_reconn', and 'interval' methods now return Integers,
  rather than Strings.
* Only the database, user and password fields are required now within the
  .dbrc file.  The driver, time_out and max_reconn entries can be left blank
  without causing an error.  Note that the 'dsn' method will return 'nil'
  if the driver isn't set.
* Added a DBRCException class instead of just raising an error string.
* Changed 'db' method to 'database' (but 'db' is an alias)
* Changed 'max_reconn' method to 'maximum_reconnects' (but 'max_reconn'
  is an alias')
* Added 'passwd' alias for 'password' method 
* Added a VERSION class method
* Methods that should have been private are now private
* Internal directory layout change
* Tests added
* Install script improved
* Documentation additions, including plain text doc

## 0.1.1 - 26-Jul-2002
* Added 'dsn()' method
* Minor documentation additions

## 0.1.0 - 26-Jul-2002
* Initial release
