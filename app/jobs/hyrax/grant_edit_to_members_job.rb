module Hyrax
  # Grants edit access for the supplied user for the members attached to a work
  class GrantEditToMembersJob < ApplicationJob
    include MembersPermissionJobBehavior
    # @param work [ActiveFedora::Base] the work object
    # @param user_key [String] the user to add
    def perform(work, user_key)
      # Iterate over ids because reifying objects is slow.
      file_set_ids(work).each do |file_set_id|
        # Call this synchronously, since we're already in a job
        GrantEditJob.perform_now(file_set_id, user_key, use_valkyrie: use_valkyrie?(work))
      end
    end
  end
end
