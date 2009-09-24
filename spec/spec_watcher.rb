#
# Config for watchr: http://github.com/mynyml/watchr
#

# run all specs on startup
system("rake spec")

# watch the spec and lib dirs
watch('spec/.+_spec\.rb') { |m| system("spec -c #{m[0]}") }
watch('lib/(.*)\.rb')     { |m| system("spec -c spec/#{m[1]}_spec.rb") }

# run all tests if spec helper changes
watch('spec/spec_helper.rb') { |m| system("rake spec") }

# Ctrl-\ runs all specs
Signal.trap('QUIT') { system("rake spec") }
 
# Ctrl-C quits
Signal.trap('INT') { abort("\n") }
