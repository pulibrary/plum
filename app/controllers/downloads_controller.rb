class DownloadsController < ApplicationController
  include CurationConcerns::DownloadBehavior

  private

    def load_file
      file_reference = params[:file]
      return default_file unless file_reference

      file_path = PairtreeDerivativePath.derivative_path_for_reference(asset, file_reference)
      File.exist?(file_path) ? file_path : nil
    end
end
