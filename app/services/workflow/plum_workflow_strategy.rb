module Workflow
  class PlumWorkflowStrategy
    attr_reader :work

    def initialize(work, _attributes)
      @work = work
    end

    # @return [String] The name of the workflow to use
    def workflow_id
      return Sipity::Workflow.where(name: 'book_works').first!.id if book_works.include? work_class
      return Sipity::Workflow.where(name: 'geo_works').first!.id if geo_works.include? work_class
    end

    private

      def work_class
        work.class.to_s
      end

      def book_works
        %w(ScannedResource MultiVolumeWork)
      end

      def geo_works
        %w(ImageWork VectorWork RasterWork)
      end
  end
end
