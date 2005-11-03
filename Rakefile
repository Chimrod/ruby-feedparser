require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'

task :default => [:package]

Rake::TestTask.new do |t|
	t.libs << "test"
	t.test_files = FileList['test/tc_*.rb']
end

Rake::RDocTask.new do |rd|
  f = []
  require 'find'
  Find.find('lib/') do |file|
    if FileTest.directory?(file) and file =~ /\.svn/
      Find.prune
    else
      f << file if not FileTest.directory?(file)
    end
  end
  f.delete('lib/feedparser.rb')
  # hack to document the Jabber module properly
  f.unshift('lib/feedparser.rb')
  rd.rdoc_files.include(f)
  rd.options << '--all'
  rd.options << '--diagram'
  rd.options << '--fileboxes'
  rd.options << '--inline-source'
  rd.options << '--line-numbers'
  rd.rdoc_dir = 'rdoc'
end

task :doctoweb => [:rdoc] do |t|
   # copies the rdoc to the CVS repository for ruby-feedparser website
	# repository is in $CVSDIR (default: ~/dev/ruby-feedparser-web)
   sh "tools/doctoweb.bash"
end

Rake::PackageTask.new('ruby-feedparser', '0.1') do |p|
	p.need_tar = true
	p.package_files.include('ChangeLog', 'README', 'COPYING', 'LICENSE', 'setup.rb',
	'Rakefile')
	require 'find'
	Find.find('lib/', 'data/', 'test/', 'tools/') do |f|
		if FileTest.directory?(f) and f =~ /\.svn/
			Find.prune
		else
			p.package_files << f
		end
	end
end

