module ActiveFedora
  class Fedora
    def build_connection
      HackyConnection.new(ActiveFedora::InitializingConnection.new(caching_connection(omit_ldpr_interaction_model: true), root_resource_path))
    end
  end
end
