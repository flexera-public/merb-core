require 'optparse'
require 'pry'

class OptionParser
  puts 'LOADED CustomOptionParser'

  def permute(*argv, into: nil)
    argv = argv[0].dup if argv.size == 1 and argv[0].is_a?(Array)
    permute!(argv, into: into)
  end

  #
  # Same as #permute, but removes switches destructively.
  # Non-option arguments remain in +argv+.
  #
  def permute!(argv = default_argv, into: nil)
    nonopts = []
    order!(argv, into: into, &nonopts.method(:<<))
    argv[0, 0] = nonopts
    argv
  end

  #
  # Parses command line arguments +argv+ in order when environment variable
  # POSIXLY_CORRECT is set, and in permutation mode otherwise.
  #
  def parse(*argv, into: nil)
    argv = argv[0].dup if argv.size == 1 and argv[0].is_a?(Array)
    parse!(argv, into: into)
  end

  #
  # Same as #parse, but removes switches destructively.
  # Non-option arguments remain in +argv+.
  #
  def parse!(argv = default_argv, into: nil)
    argv = fix_missplaced_args(argv) if argv.is_a?(Hash)

    if ENV.include?('POSIXLY_CORRECT')
      order!(argv, into: into)
    else
      permute!(argv, into: into)
    end
  end

  private

  def fix_missplaced_args(argv)
    argv.flat_map do |k, _v|
      k
    end
  end
end
