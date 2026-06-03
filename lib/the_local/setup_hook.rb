# frozen_string_literal: true

module TheLocal
  # Wires `the_local:refresh` into the host app's bin/setup so locals re-sync as
  # part of the normal post-dependency-change workflow. Idempotent (guarded by
  # markers) and a no-op when bin/setup is absent. Plain Ruby; the install
  # generator calls it.
  module SetupHook
    BEGIN_MARKER = "# the_local:begin"
    END_MARKER = "# the_local:end"
    BLOCK = <<~RUBY.chomp
      #{BEGIN_MARKER}
      # Re-sync installed locals after dependency changes.
      system("bin/rails the_local:refresh")
      #{END_MARKER}
    RUBY

    def self.apply(bin_setup_path)
      return false unless File.exist?(bin_setup_path)

      content = File.read(bin_setup_path)
      return false if content.include?(BEGIN_MARKER)

      File.write(bin_setup_path, "#{content.chomp}\n\n#{BLOCK}\n")
      true
    end
  end
end
