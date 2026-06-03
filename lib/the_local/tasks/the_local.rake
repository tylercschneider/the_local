# frozen_string_literal: true

namespace :the_local do
  desc "Re-sync installed locals from the current bundle"
  task refresh: :environment do
    allowed = TheLocal::Refresh.call(destination: Rails.root.to_s)
    puts "the_local: refreshed locals for #{allowed.join(", ")}"
  end
end
