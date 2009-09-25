#
# Config for watchr: http://github.com/mynyml/watchr
#

def specdoc
  puts
  puts "=" * 50
  puts
  system("rake specdoc")
end

# run specdoc on startup
specdoc

# watch the spec and lib dirs
watch('spec/.+_spec\.rb') { |m| system("spec -c #{m[0]}") }
watch('lib/(.*)\.rb')     { |m| system("spec -c spec/#{m[1]}_spec.rb") }

# run all tests if spec helper changes
watch('spec/spec_helper.rb') { |m| system("rake spec") }

# Ctrl-\ runs specdoc
Signal.trap('QUIT') { specdoc }
 
# Ctrl-C quits
Signal.trap('INT') { abort("\n") }
