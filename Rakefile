require 'rake/clean'

Dir.glob('lib/tasks/*').each { |d|
  Rake.add_rakelib d
}

CLEAN.include('build')
CLEAN.include('work')
CLEAN.include('dist')
CLOBBER.include('vendor')

