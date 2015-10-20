# Generated via
#  `rails generate curation_concerns:work ScannedResource`
module CurationConcerns
  class ScannedResourceActor < CurationConcerns::BaseActor
    include ::CurationConcerns::WorkActorBehavior

    # Generate the pdf and persist it as if it was any other local derivative
    # Saves the result in the default local derivative_path

    def generate_pdf
      output_path ||= CurationConcerns::DerivativePath.derivative_path_for_reference(curation_concern, 'pdf')
      output_file_dir = File.dirname(output_path)
      FileUtils.mkdir_p(output_file_dir) unless File.directory?(output_file_dir)
      curation_concern.render_pdf(output_path)
    end
  end
end
